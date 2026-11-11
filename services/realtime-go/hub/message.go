package hub

import (
	"encoding/json"
	"errors"
	"strings"
)

// Supported real-time event types
const (
	EventChatMessage      = "chat:message"
	EventDirectMessage    = "direct:message"
	EventSubscribe        = "subscribe"
	EventUnsubscribe      = "unsubscribe"
	EventTyping           = "typing"
	EventPresenceOnline   = "presence:online"
	EventPresenceOffline  = "presence:offline"
	EventGuardBlocked     = "guard:blocked"
	EventError            = "error"
	EventDeliveryAck      = "chat:delivered"
	EventUndelivered      = "chat:undelivered"
	EventCallSignal       = "call:signal"
	EventCallGameMove     = "call:game_move"
	EventPendingMessages  = "pending:messages"
	EventMessageAck       = "message:ack"
	EventDateInvitation   = "date:invitation"
)


// InboundMessage represents a validated client-sent WebSocket frame.
type InboundMessage struct {
	Event     string          `json:"event"`
	Channel   string          `json:"channel,omitempty"`
	ToUserID  string          `json:"to_user_id,omitempty"`
	Payload   json.RawMessage `json:"payload"`
	Timestamp int64           `json:"timestamp,omitempty"`
}

// ChatMessagePayload contains specific fields for dating app chat messages.
type ChatMessagePayload struct {
	Body       string `json:"body"`
	ActiveDays int    `json:"active_days,omitempty"`
	PairCount  int    `json:"pair_count,omitempty"`
	ConvID     string `json:"conv_id,omitempty"`
	Type       string `json:"type,omitempty"`
	MediaURL   string `json:"media_url,omitempty"`
	MessageID  string `json:"message_id,omitempty"`
	MsgID      string `json:"msg_id,omitempty"`
	ID         string `json:"id,omitempty"`
	ClientID   string `json:"client_id,omitempty"`
}

// DateInvitePayload contains fields for a date invitation sent in real-time.
type DateInvitePayload struct {
	InvitationID string `json:"invitation_id"`
	MatchID      string `json:"match_id"`
	ProposerID   string `json:"proposer_id"`
	RecipientID  string `json:"recipient_id"`
	DateMode     string `json:"date_mode"`
	DateType     string `json:"date_type"`
	ScheduledAt  string `json:"scheduled_at"`
	Message      string `json:"message"`
}

// OutboundMessage represents an envelope pushed to connected clients.
type OutboundMessage struct {
	Channel   string      `json:"channel,omitempty"`
	Event     string      `json:"event"`
	FromUID   string      `json:"from_uid,omitempty"`
	Payload   interface{} `json:"payload"`
	Timestamp int64       `json:"timestamp"`
}

// ErrorPayload standardizes error reports sent back to clients.
type ErrorPayload struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// Validate checks the structural validity of an incoming message.
func (m *InboundMessage) Validate() error {
	m.Event = strings.TrimSpace(m.Event)
	if m.Event == "" {
		return errors.New("event name is required")
	}

	switch m.Event {
	case EventChatMessage:
		if strings.TrimSpace(m.Channel) == "" && strings.TrimSpace(m.ToUserID) == "" {
			return errors.New("chat:message requires either 'channel' or 'to_user_id'")
		}
		if len(m.Payload) == 0 {
			return errors.New("chat:message requires a non-empty payload")
		}
		var chat ChatMessagePayload
		if err := json.Unmarshal(m.Payload, &chat); err != nil {
			return errors.New("invalid chat payload json format")
		}
		if strings.TrimSpace(chat.Body) == "" {
			return errors.New("chat body cannot be empty")
		}

	case EventDirectMessage:
		if strings.TrimSpace(m.ToUserID) == "" {
			return errors.New("direct:message requires 'to_user_id'")
		}
		if len(m.Payload) == 0 {
			return errors.New("direct:message requires a payload")
		}

	case EventSubscribe, EventUnsubscribe:
		if strings.TrimSpace(m.Channel) == "" {
			return errors.New("subscribe/unsubscribe requires 'channel'")
		}

	case EventTyping:
		if strings.TrimSpace(m.Channel) == "" && strings.TrimSpace(m.ToUserID) == "" {
			return errors.New("typing requires either 'channel' or 'to_user_id'")
		}
	}

	return nil
}
