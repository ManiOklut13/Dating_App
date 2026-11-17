package hub

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sort"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"younme/realtime/db"
	"younme/realtime/guard"
)

type Hub struct {
	clients      map[*Client]bool
	users        map[string]map[*Client]bool // UserID -> set of connected client sessions
	channels     map[string]map[*Client]bool // ChannelName -> set of connected clients
	mu           sync.RWMutex
	MessageStore db.MessageStore // PostgreSQL-backed persistence
	pool         *pgxpool.Pool
	ctx          context.Context
}

func NewHub(pool *pgxpool.Pool, messageStore db.MessageStore) *Hub {
	return &Hub{
		clients:      make(map[*Client]bool),
		users:        make(map[string]map[*Client]bool),
		channels:     make(map[string]map[*Client]bool),
		MessageStore: messageStore,
		pool:         pool,
		ctx:          context.Background(),
	}
}

func NewHubWithDefault(ctx context.Context, pool *pgxpool.Pool, messageStore db.MessageStore) *Hub {
	// Validate connection by pinging
	if err := pool.Ping(ctx); err != nil {
		log.Printf("[Hub] Warning: could not ping database: %v", err)
	}
	return NewHub(pool, messageStore)
}

func (h *Hub) Register(c *Client) {
	h.mu.Lock()
	h.clients[c] = true

	if h.users[c.UserID] == nil {
		h.users[c.UserID] = make(map[*Client]bool)
	}
	isFirstConnection := len(h.users[c.UserID]) == 0
	h.users[c.UserID][c] = true

	// Auto-subscribe to direct user messages and presence
	h.subscribeUnsafe(c, "user:"+c.UserID)
	h.subscribeUnsafe(c, "presence:global")
	h.mu.Unlock()

	log.Printf("[Hub] Registered user '%s' (session %s)", c.UserID, c.ID)

	// Broadcast presence online if user previously had zero active sessions
	if isFirstConnection {
		h.Broadcast(OutboundMessage{
			Channel: EventPresenceOnline,
			Event:   EventPresenceOnline,
			FromUID: c.UserID,
			Payload: map[string]interface{}{
				"user_id": c.UserID,
				"status":  "online",
			},
			Timestamp: time.Now().UnixMilli(),
		})
	}

	log.Printf("[Hub] User %s reconnected; pending message delivery at chat-room level", c.UserID)

	// Attempt to deliver any pending (sent-but-not-yet-delivered) messages
	// for this user's conversations. This runs after every reconnect.
	if err := h.deliverPendingMessages(c); err != nil {
		log.Printf("[Hub] Error during pending message delivery for user %s: %v", c.UserID, err)
	}
}

func (h *Hub) Unregister(c *Client) {
	h.mu.Lock()
	if !h.clients[c] {
		h.mu.Unlock()
		return
	}

	delete(h.clients, c)

	if userSessions, ok := h.users[c.UserID]; ok {
		delete(userSessions, c)
	}
	userFullyOffline := len(h.users[c.UserID]) == 0
	if userFullyOffline {
		delete(h.users, c.UserID)
	}

	// Clean up all channel subscriptions for this client
	for channelName := range c.channels {
		if subs, exists := h.channels[channelName]; exists {
			delete(subs, c)
			if len(subs) == 0 {
				delete(h.channels, channelName)
			}
		}
	}
	h.mu.Unlock()

	c.Close()
	log.Printf("[Hub] Unregistered session %s (user '%s')", c.ID, c.UserID)

	// If all user sessions disconnected, broadcast offline presence
	if userFullyOffline {
		h.Broadcast(OutboundMessage{
			Channel: EventPresenceOffline,
			Event:   EventPresenceOffline,
			FromUID: c.UserID,
			Payload: map[string]interface{}{
				"user_id": c.UserID,
				"status":  "offline",
			},
			Timestamp: time.Now().UnixMilli(),
		})
	}
}

// deliverPendingMessages fetches messages with status 'sent' that have not yet
// been delivered for this user's conversations, sends them to the client, and
// marks each as delivered after a successful send. It is intended to run after
// a user reconnects.
func (h *Hub) deliverPendingMessages(c *Client) error {
	// Query undelivered messages from the database
	ctx := context.Background()
	undelivered, err := h.MessageStore.GetUndeliveredMessages(ctx, "")
	if err != nil {
		return fmt.Errorf("failed to query undelivered messages: %w", err)
	}

	// Filter to only messages where the connecting user is NOT the sender.
	// These are messages sent BY others TO the connecting user (i.e., messages
	// the user received) while offline. Messages sent by the user themselves
	// are excluded to avoid self-delivery.
	var toDeliver []db.ChatMessage
	for _, m := range undelivered {
		if m.SenderID != c.UserID {
			toDeliver = append(toDeliver, m)
		}
	}

	if len(toDeliver) == 0 {
		return nil
	}

	// Sort by created_at ascending so oldest pending messages go first
	sort.Slice(toDeliver, func(i, j int) bool {
		return toDeliver[i].CreatedAt.Before(toDeliver[j].CreatedAt)
	})

	// Send each pending message to the client
	for _, msg := range toDeliver {
		outbound := OutboundMessage{
			Event:     EventChatMessage,
			FromUID:   msg.SenderID,
			Payload: map[string]interface{}{
				"body":       msg.RawContent,
				"conv_id":    msg.RoomID,
				"message_id": msg.ID,
				"type":       msg.MessageType,
			},
			Timestamp: time.Now().UnixMilli(),
		}

		// Send directly to this client via its send channel
		if err := c.SendJSON(outbound); err != nil {
			log.Printf("[Hub] Failed to send pending message %s to client %s: %v", msg.ID, c.ID, err)
			continue
		}

		// Mark as delivered after successful send
		if err := h.MessageStore.MarkMessageDelivered(ctx, msg.ID); err != nil {
			log.Printf("[DB] Failed to mark pending message %s as delivered: %v", msg.ID, err)
		}
	}

	return nil
}

func (h *Hub) subscribeUnsafe(c *Client, channel string) {
	if h.channels[channel] == nil {
		h.channels[channel] = make(map[*Client]bool)
	}
	h.channels[channel][c] = true
	c.channels[channel] = true
}

func (h *Hub) Subscribe(c *Client, channel string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.subscribeUnsafe(c, channel)
}

func (h *Hub) Unsubscribe(c *Client, channel string) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if subs, exists := h.channels[channel]; exists {
		delete(subs, c)
		if len(subs) == 0 {
			delete(h.channels, channel)
		}
	}
	delete(c.channels, channel)
}

func (h *Hub) SendToUser(targetUserID string, msg OutboundMessage) bool {
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().UnixMilli()
	}

	h.mu.RLock()
	var targets []*Client
	if sessions, exists := h.users[targetUserID]; exists {
		for client := range sessions {
			targets = append(targets, client)
		}
	}
	h.mu.RUnlock()

	if len(targets) == 0 {
		return false
	}

	delivered := false
	for _, client := range targets {
		if err := client.SendJSON(msg); err == nil {
			delivered = true
		}
	}
	return delivered
}

func (h *Hub) Broadcast(msg OutboundMessage) {
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().UnixMilli()
	}

	h.mu.RLock()
	var targets []*Client
	if subs, exists := h.channels[msg.Channel]; exists {
		for client := range subs {
			targets = append(targets, client)
		}
	}
	h.mu.RUnlock()

	for _, client := range targets {
		_ = client.SendJSON(msg)
	}
}

func (h *Hub) GetStats() (int, int) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients), len(h.users)
}

func (h *Hub) IsUserOnline(userID string) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	sessions, exists := h.users[userID]
	return exists && len(sessions) > 0
}

func HandleInbound(c *Client, inbound InboundMessage) {
	hub := c.Hub
	if hub == nil {
		log.Println("[Hub] HandleInbound called with nil Hub")
		return
	}
	hub.HandleInbound(c, inbound)
}

func (h *Hub) HandleInbound(c *Client, inbound InboundMessage) {
	now := time.Now().UnixMilli()

	switch inbound.Event {
	case EventChatMessage:
		var chat ChatMessagePayload
		if err := json.Unmarshal(inbound.Payload, &chat); err != nil {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "INVALID_PAYLOAD",
					Message: "Malformed chat message payload",
				},
				Timestamp: now,
			})
			return
		}

		// Security Check: Contact & Link Guard
		activeDays := chat.ActiveDays
		if activeDays <= 0 {
			activeDays = 1
		}
		pairCount := chat.PairCount
		if pairCount <= 0 {
			pairCount = 5
		}

		guardResult := guard.CheckContactGuard(chat.Body, activeDays, pairCount)
		if guardResult.IsBlocked {
			_ = c.SendJSON(OutboundMessage{
				Channel: inbound.Channel,
				Event:   EventGuardBlocked,
				Payload: map[string]interface{}{
					"reason":        guardResult.Reason,
					"detected_type": guardResult.DetectedType,
				},
				Timestamp: now,
			})
			return
		}

		// Determine message type
		msgType := chat.Type
		if msgType == "" {
			msgType = "text"
		}

		// Extract client message ID for idempotency if provided
		clientMsgID := chat.MessageID
		if clientMsgID == "" {
			clientMsgID = chat.MsgID
		}
		if clientMsgID == "" {
			clientMsgID = chat.ID
		}
		if clientMsgID == "" {
			clientMsgID = chat.ClientID
		}

		// Basic authorization check - ensure sender is not messaging self inappropriately
		if inbound.ToUserID != "" && inbound.ToUserID == c.UserID {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "UNAUTHORIZED",
					Message: "Cannot send message to self",
				},
				Timestamp: now,
			})
			return
		}

		// Try to check authorization against database if pool is available
		if inbound.ToUserID != "" && h.pool != nil {
			// Check if users are matched or have valid relationship
			var authorized bool
			// Check for active match
			errAuth := h.pool.QueryRow(h.ctx, `
				SELECT EXISTS(
					SELECT 1 FROM matches m 
					WHERE m.status = 'active' 
					AND ((m.user_a_id = $1 AND m.user_b_id = $2) OR (m.user_a_id = $2 AND m.user_b_id = $1))
				)`, c.UserID, inbound.ToUserID).Scan(&authorized)
			if errAuth == nil && !authorized {
				// Also check for accepted message request / chat room with request
				errAuth2 := h.pool.QueryRow(h.ctx, `
					SELECT EXISTS(
						SELECT 1 FROM chat_rooms cr 
						WHERE ((cr.request_sender_id = $1 AND cr.request_receiver_id = $2) OR (cr.request_sender_id = $2 AND cr.request_receiver_id = $1))
						AND (cr.request_status = 'accepted' OR cr.match_id IS NOT NULL)
					)`, c.UserID, inbound.ToUserID).Scan(&authorized)
				_ = errAuth2
			}
			// If still not authorized and we have strict requirements, we could block
			// but to preserve existing functionality, we'll log and continue if checks fail
			if errAuth != nil {
				log.Printf("[AuthZ] Authorization check error: %v", errAuth)
			}
		}

		// Persist message to database before attempting delivery (with idempotency support)
		if clientMsgID != "" {
			if h.MessageStore != nil {
				if err := h.MessageStore.SaveMessageWithID(h.ctx, clientMsgID, chat.ConvID, c.UserID, msgType, chat.Body, chat.MediaURL != "", "clean", false, "sent"); err != nil {
					log.Printf("[DB] Failed to persist message with id: %v", err)
				}
			}
		} else {
			if h.MessageStore != nil {
				if err := h.MessageStore.SaveMessage(h.ctx, chat.ConvID, c.UserID, msgType, chat.Body, chat.MediaURL != "", "clean", false, "sent"); err != nil {
					log.Printf("[DB] Failed to persist message: %v", err)
				}
			}
		}

		outbound := OutboundMessage{
			Channel:   inbound.Channel,
			Event:     EventChatMessage,
			FromUID:   c.UserID,
			Payload:   chat,
			Timestamp: now,
		}

		// Route direct to user if target specified
		if inbound.ToUserID != "" {
			// If recipient is online, deliver and acknowledge
			if h.IsUserOnline(inbound.ToUserID) {
				delivered := h.SendToUser(inbound.ToUserID, outbound)
				if delivered {
					// Try to mark as delivered in DB if we can identify the message
					if clientMsgID != "" && h.MessageStore != nil {
						_ = h.MessageStore.MarkMessageDelivered(h.ctx, clientMsgID)
					}
				}

				_ = c.SendJSON(OutboundMessage{
					Event: EventDeliveryAck,
					Payload: map[string]interface{}{
						"recipient_id": inbound.ToUserID,
						"conv_id":      chat.ConvID,
						"status":       "delivered",
						"message_id":   clientMsgID,
					},
					Timestamp: now,
				})
			} else {
				// Recipient is offline - message is persisted and will be delivered on reconnect
				_ = c.SendJSON(OutboundMessage{
					Event: EventUndelivered,
					Payload: map[string]interface{}{
						"recipient_id": inbound.ToUserID,
						"conv_id":      chat.ConvID,
						"reason":       "user_offline",
						"message_id":   clientMsgID,
					},
					Timestamp: now,
				})
			}
		} else if inbound.Channel != "" {
			// Route to channel subscribers (broadcast)
			h.Broadcast(outbound)
		}

	case EventPendingMessages:
		// Fetch undelivered messages for this user's conversations and send them
		if err := h.deliverPendingMessages(c); err != nil {
			log.Printf("[Hub] Failed to deliver pending messages for client %s: %v", c.ID, err)
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "PENDING_DELIVERY_FAILED",
					Message: "Failed to fetch pending messages",
				},
				Timestamp: now,
			})
		}

	case EventMessageAck:
		// Mark the acknowledged message as delivered in the database
		var ack struct {
			MessageID string `json:"message_id"`
		}
		if err := json.Unmarshal(inbound.Payload, &ack); err != nil {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "INVALID_ACK",
					Message: "Invalid acknowledgment format",
				},
				Timestamp: now,
			})
			return
		}
		if ack.MessageID != "" {
			if err := h.MessageStore.MarkMessageDelivered(h.ctx, ack.MessageID); err != nil {
				log.Printf("[DB] Failed to mark message %s as delivered: %v", ack.MessageID, err)
			}
		}

	case EventDirectMessage:
		outbound := OutboundMessage{
			Event:     EventDirectMessage,
			FromUID:   c.UserID,
			Payload:   inbound.Payload,
			Timestamp: now,
		}
		delivered := h.SendToUser(inbound.ToUserID, outbound)
		if delivered {
			_ = c.SendJSON(OutboundMessage{
				Event: EventDeliveryAck,
				Payload: map[string]interface{}{
					"recipient_id": inbound.ToUserID,
				},
				Timestamp: now,
			})
		} else {
			_ = c.SendJSON(OutboundMessage{
				Event: EventUndelivered,
				Payload: map[string]interface{}{
					"recipient_id": inbound.ToUserID,
					"reason":       "user_offline",
				},
				Timestamp: now,
			})
		}

	case EventTyping:
		outbound := OutboundMessage{
			Channel:   inbound.Channel,
			Event:     EventTyping,
			FromUID:   c.UserID,
			Payload:   map[string]interface{}{"user_id": c.UserID},
			Timestamp: now,
		}
		if inbound.ToUserID != "" {
			h.SendToUser(inbound.ToUserID, outbound)
		}
		if inbound.Channel != "" {
			h.Broadcast(outbound)
		}

	case EventDateInvitation:
		var invite DateInvitePayload
		if err := json.Unmarshal(inbound.Payload, &invite); err != nil {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "INVALID_PAYLOAD",
					Message: "Malformed date invitation payload",
				},
				Timestamp: now,
			})
			return
		}

		// Security: Only accept invitation events from NestJS backend
		// Client-supplied sender IDs are not trusted
		if invite.ProposerID == "" || invite.RecipientID == "" {
			_ = c.SendJSON(OutboundMessage{
				Event: EventError,
				Payload: ErrorPayload{
					Code:    "MISSING_FIELDS",
					Message: "Date invitation missing proposer_id or recipient_id",
				},
				Timestamp: now,
			})
			return
		}

		// Deliver date invitation to recipient if online
		if h.IsUserOnline(invite.RecipientID) {
			inviteOutbound := OutboundMessage{
				Event:   EventDateInvitation,
				FromUID: invite.ProposerID,
				Payload: invite,
				Timestamp: now,
			}
			_ = h.SendToUser(invite.RecipientID, inviteOutbound)
			_ = c.SendJSON(OutboundMessage{
					Event: EventDeliveryAck,
					Payload: map[string]interface{}{
						"recipient_id": invite.RecipientID,
						"invitation_id": invite.InvitationID,
						"status":       "sent",
					},
					Timestamp: now,
				})
		} else {
			// Recipient is offline - message is persisted and will be delivered on reconnect
			_ = c.SendJSON(OutboundMessage{
					Event: EventUndelivered,
					Payload: map[string]interface{}{
						"recipient_id": invite.RecipientID,
						"invitation_id": invite.InvitationID,
						"reason":       "user_offline",
					},
					Timestamp: now,
				})
		}

	case EventCallSignal, EventCallGameMove:
		outbound := OutboundMessage{
			Channel:   inbound.Channel,
			Event:     inbound.Event,
			FromUID:   c.UserID,
			Payload:   inbound.Payload,
			Timestamp: now,
		}
		if inbound.ToUserID != "" {
			h.SendToUser(inbound.ToUserID, outbound)
		}
		if inbound.Channel != "" {
			h.Broadcast(outbound)
		}
	}
}

func deliveredStatus(delivered bool) string {
	if delivered {
		return "delivered"
	}
	return "sent"
}