package hub

import (
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

// Event payload envelope
type EventMessage struct {
	Channel   string      `json:"channel"`   // e.g. "chat:123", "presence:usr_1", "user:usr_1", "call:call_99"
	Event     string      `json:"event"`     // e.g. "message:send", "typing", "call:signal", "streak:update"
	Payload   interface{} `json:"payload"`
	Timestamp int64       `json:"timestamp"`
}

// Client represents a connected user WebSocket
type Client struct {
	ID        string
	UserID    string
	Conn      *websocket.Conn
	Send      chan []byte
	Channels  map[string]bool
	Hub       *Hub
	mu        sync.Mutex
}

// Hub maintains the set of active clients and broadcasts messages to channels
type Hub struct {
	clients    map[*Client]bool
	channels   map[string]map[*Client]bool // channelName -> set of clients
	broadcast  chan EventMessage
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

func NewHub() *Hub {
	return &Hub{
		broadcast:  make(chan EventMessage, 1024),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
		channels:   make(map[string]map[*Client]bool),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client] = true
			// Auto subscribe to their user channel and presence
			userChan := "user:" + client.UserID
			presenceChan := "presence:" + client.UserID
			h.subscribeUnsafe(client, userChan)
			h.subscribeUnsafe(client, presenceChan)
			h.mu.Unlock()
			log.Printf("[Go Hub] Client connected: %s (User: %s)", client.ID, client.UserID)

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				for ch := range client.Channels {
					if subscribers, exists := h.channels[ch]; exists {
						delete(subscribers, client)
						if len(subscribers) == 0 {
							delete(h.channels, ch)
						}
					}
				}
				close(client.Send)
			}
			h.mu.Unlock()
			log.Printf("[Go Hub] Client disconnected: %s", client.ID)

		case message := <-h.broadcast:
			message.Timestamp = time.Now().UnixMilli()
			data, err := json.Marshal(message)
			if err != nil {
				continue
			}

			h.mu.RLock()
			subscribers, exists := h.channels[message.Channel]
			if exists {
				for client := range subscribers {
					select {
					case client.Send <- data:
					default:
						close(client.Send)
						delete(h.clients, client)
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *Hub) subscribeUnsafe(c *Client, channel string) {
	if h.channels[channel] == nil {
		h.channels[channel] = make(map[*Client]bool)
	}
	h.channels[channel][c] = true
	c.Channels[channel] = true
}

func (h *Hub) Subscribe(c *Client, channel string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.subscribeUnsafe(c, channel)
}

func (h *Hub) Unsubscribe(c *Client, channel string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if subscribers, exists := h.channels[channel]; exists {
		delete(subscribers, c)
		if len(subscribers) == 0 {
			delete(h.channels, channel)
		}
	}
	delete(c.Channels, channel)
}

func (h *Hub) Broadcast(msg EventMessage) {
	h.broadcast <- msg
}
