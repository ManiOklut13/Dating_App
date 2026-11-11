package hub

import (
	"encoding/json"
	"errors"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	// writeWait is the maximum time allowed to write a message to the peer.
	writeWait = 10 * time.Second

	// pongWait is the maximum time allowed to read the next pong message from the peer.
	pongWait = 60 * time.Second

	// pingPeriod sends pings to peer with this period. Must be less than pongWait.
	pingPeriod = (pongWait * 9) / 10

	// maxMessageSize is the maximum message size allowed from peer (64 KB).
	maxMessageSize = 65536
)

// Client represents a connected WebSocket user session.
type Client struct {
	ID       string          // Unique session ID (e.g. RemoteAddr)
	UserID   string          // Verified Supabase user id (auth.users.id)
	Conn     *websocket.Conn // Gorilla WebSocket connection
	Send     chan []byte     // Buffered channel of outbound messages
	Hub      *Hub            // Pointer to the central messaging Hub
	channels map[string]bool // Subscribed channel names
	mu       sync.Mutex
	isClosed bool
}

// NewClient initializes a new connected client instance.
func NewClient(id, userID string, conn *websocket.Conn, hub *Hub) *Client {
	return &Client{
		ID:       id,
		UserID:   userID,
		Conn:     conn,
		Send:     make(chan []byte, 256),
		Hub:      hub,
		channels: make(map[string]bool),
	}
}

// SendJSON enqueues a JSON-serializable message for transmission via WritePump.
// Thread-safe and prevents concurrent WebSocket write operations.
func (c *Client) SendJSON(v interface{}) error {
	data, err := json.Marshal(v)
	if err != nil {
		return err
	}

	c.mu.Lock()
	defer c.mu.Unlock()

	if c.isClosed {
		return errors.New("client connection already closed")
	}

	select {
	case c.Send <- data:
		return nil
	default:
		log.Printf("[Client %s] Send buffer full, dropping message", c.ID)
		return errors.New("send buffer full")
	}
}

// Close safely terminates the outbound channel without double-close panic.
func (c *Client) Close() {
	c.mu.Lock()
	defer c.mu.Unlock()

	if !c.isClosed {
		c.isClosed = true
		close(c.Send)
	}
}

// ReadPump handles incoming WebSocket frames, heartbeats, and message dispatching.
// Runs in its own goroutine per client connection.
func (c *Client) ReadPump() {
	defer func() {
		c.Hub.Unregister(c)
		c.Conn.Close()
	}()

	c.Conn.SetReadLimit(maxMessageSize)
	_ = c.Conn.SetReadDeadline(time.Now().Add(pongWait))
	c.Conn.SetPongHandler(func(string) error {
		_ = c.Conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, messageBytes, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("[Client %s] Read error: %v", c.ID, err)
			}
			break
		}

		var inbound InboundMessage
		if err := json.Unmarshal(messageBytes, &inbound); err != nil {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "MALFORMED_JSON",
					Message: "Received invalid JSON structure",
				},
				Timestamp: time.Now().UnixMilli(),
			})
			continue
		}

		if err := inbound.Validate(); err != nil {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "VALIDATION_ERROR",
					Message: err.Error(),
				},
				Timestamp: time.Now().UnixMilli(),
			})
			continue
		}

		c.Hub.HandleInbound(c, inbound)
	}
}

// WritePump serializes all writes to the WebSocket connection.
// This is the ONLY goroutine allowed to call WriteMessage on c.Conn.
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			_ = c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// Hub closed the channel
				_ = c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			if _, err := w.Write(message); err != nil {
				return
			}

			// Flush queued messages if any
			n := len(c.Send)
			for i := 0; i < n; i++ {
				if _, err := w.Write([]byte{'\n'}); err != nil {
					return
				}
				if _, err := w.Write(<-c.Send); err != nil {
					return
				}
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			_ = c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
