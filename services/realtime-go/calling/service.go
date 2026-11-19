package calling

import (
	"context"
	"crypto/rand"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/livekit/protocol/livekit"
	"younme/realtime/hub"
)

// CallService coordinates LiveKit token issuance, room management, and real-time WebSocket signaling.
type CallService struct {
	client       LiveKitClient
	store        CallStore
	hub          *hub.Hub
	livekitWSURL string
	processedWH  map[string]time.Time
	whMu         sync.Mutex
}

// NewCallService creates a fully configured CallService.
func NewCallService(client LiveKitClient, store CallStore, h *hub.Hub, livekitWSURL string) *CallService {
	return &CallService{
		client:       client,
		store:        store,
		hub:          h,
		livekitWSURL: livekitWSURL,
		processedWH:  make(map[string]time.Time),
	}
}

// GenerateUUID generates a RFC-4122 compliant UUID v4 string.
func GenerateUUID() string {
	var b [16]byte
	_, _ = rand.Read(b[:])
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%08x-%04x-%04x-%04x-%012x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

// InitiateCall creates a call session, provisions a LiveKit room, generates caller token,
// and notifies the callee in real-time via their active WebSocket connection.
func (s *CallService) InitiateCall(ctx context.Context, callerID string, req *InitiateCallRequest) (*InitiateCallResponse, error) {
	if s.client == nil {
		return nil, ErrLiveKitNotReady
	}

	if err := req.Validate(); err != nil {
		return nil, err
	}

	if callerID == req.CalleeID {
		return nil, ErrSelfCall
	}

	callID := GenerateUUID()
	roomName := fmt.Sprintf("rm_%s_%s", req.CallType, callID)

	// 1. Provision room on LiveKit Cloud
	_, err := s.client.CreateRoom(ctx, roomName, 300, 2)
	if err != nil {
		log.Printf("[LiveKit Calling] Warning: CreateRoom returned: %v (continuing with on-demand room creation)", err)
	}

	// 2. Generate signed LiveKit token for Caller
	callerName := req.CallerName
	if callerName == "" {
		callerName = "Caller"
	}
	callerToken, err := s.client.CreateToken(roomName, callerID, callerName, true, true, 15*time.Minute)
	if err != nil {
		return nil, fmt.Errorf("failed to generate caller livekit token: %w", err)
	}

	// 3. Persist call session
	now := time.Now().UTC()
	session := &CallSession{
		ID:              callID,
		LiveKitRoomName: roomName,
		CallerUserID:    callerID,
		CalleeUserID:    req.CalleeID,
		MatchID:         req.MatchID,
		CallType:        req.CallType,
		Status:          "initiating",
		DurationSeconds: 0,
		CreatedAt:       now,
	}

	if err := s.store.CreateCall(ctx, session); err != nil {
		log.Printf("[LiveKit Calling] Warning saving call session: %v", err)
	}

	// 4. Notify Callee in real-time via WebSocket
	if s.hub != nil {
		s.hub.SendToUser(req.CalleeID, hub.OutboundMessage{
			Event:   hub.EventCallIncoming,
			FromUID: callerID,
			Payload: hub.CallIncomingPayload{
				CallID:       callID,
				CallerID:     callerID,
				CallerName:   req.CallerName,
				CallerAvatar: req.CallerAvatar,
				RoomName:     roomName,
				CallType:     req.CallType,
				MatchID:      req.MatchID,
				CreatedAt:    now.UnixMilli(),
			},
			Timestamp: now.UnixMilli(),
		})
	}

	return &InitiateCallResponse{
		Success:             true,
		CallID:              callID,
		RoomName:            roomName,
		LiveKitURL:          s.livekitWSURL,
		LiveKitToken:        callerToken,
		ParticipantIdentity: callerID,
		CallType:            req.CallType,
		Status:              "initiating",
	}, nil
}

// GetParticipantToken validates authorization and generates a LiveKit token for a participant to join a call.
func (s *CallService) GetParticipantToken(ctx context.Context, userID string, req *GetTokenRequest) (*GetTokenResponse, error) {
	if s.client == nil {
		return nil, ErrLiveKitNotReady
	}

	if err := req.Validate(); err != nil {
		return nil, err
	}

	var session *CallSession
	var err error

	if req.CallID != "" {
		session, err = s.store.GetCallByID(ctx, req.CallID)
	} else {
		session, err = s.store.GetCallByRoom(ctx, req.RoomName)
	}

	if err != nil || session == nil {
		return nil, ErrCallNotFound
	}

	// Security: Only caller or callee may obtain a token for this room
	if userID != session.CallerUserID && userID != session.CalleeUserID {
		return nil, ErrUnauthorizedCall
	}

	isCallee := userID == session.CalleeUserID
	participantName := "Participant"
	if isCallee {
		participantName = "Callee"
	} else {
		participantName = "Caller"
	}

	// Generate participant token
	token, err := s.client.CreateToken(session.LiveKitRoomName, userID, participantName, true, true, 15*time.Minute)
	if err != nil {
		return nil, fmt.Errorf("failed to generate participant livekit token: %w", err)
	}

	// If callee joined, update status to active and notify caller
	if isCallee && session.Status == "initiating" {
		_ = s.store.UpdateCallStatus(ctx, session.ID, "active")
		session.Status = "active"

		if s.hub != nil {
			now := time.Now().UnixMilli()
			s.hub.SendToUser(session.CallerUserID, hub.OutboundMessage{
				Event:   hub.EventCallAccepted,
				FromUID: userID,
				Payload: hub.CallStatusPayload{
					CallID:    session.ID,
					RoomName:  session.LiveKitRoomName,
					UserID:    userID,
					Timestamp: now,
				},
				Timestamp: now,
			})
		}
	}

	return &GetTokenResponse{
		Success:             true,
		CallID:              session.ID,
		RoomName:            session.LiveKitRoomName,
		LiveKitURL:          s.livekitWSURL,
		LiveKitToken:        token,
		ParticipantIdentity: userID,
		Status:              session.Status,
	}, nil
}

// EndCall terminates an ongoing call session, deletes the LiveKit room, and notifies the other participant.
func (s *CallService) EndCall(ctx context.Context, userID string, req *EndCallRequest) (*EndCallResponse, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	session, err := s.store.GetCallByID(ctx, req.CallID)
	if err != nil || session == nil {
		return nil, ErrCallNotFound
	}

	// Security: Only authorized participants can terminate a call
	if userID != session.CallerUserID && userID != session.CalleeUserID {
		return nil, ErrUnauthorizedCall
	}

	// Calculate duration
	duration := 0
	if session.StartedAt != nil {
		duration = int(time.Since(*session.StartedAt).Seconds())
		if duration < 0 {
			duration = 0
		}
	}

	status := "completed"
	reason := strings.ToLower(strings.TrimSpace(req.Reason))
	if reason == "declined" || reason == "rejected" {
		status = "declined"
	} else if reason == "missed" || reason == "timeout" {
		status = "missed"
	}

	// 1. Terminate room on LiveKit Cloud
	if s.client != nil {
		_ = s.client.DeleteRoom(ctx, session.LiveKitRoomName)
	}

	// 2. Persist end state
	_ = s.store.EndCall(ctx, session.ID, status, duration)

	// 3. Notify the counterpart user via WebSocket
	counterpartID := session.CallerUserID
	if userID == session.CallerUserID {
		counterpartID = session.CalleeUserID
	}

	if s.hub != nil {
		event := hub.EventCallEnded
		if status == "declined" {
			event = hub.EventCallRejected
		} else if status == "missed" {
			event = hub.EventCallMissed
		}

		now := time.Now().UnixMilli()
		s.hub.SendToUser(counterpartID, hub.OutboundMessage{
			Event:   event,
			FromUID: userID,
			Payload: hub.CallStatusPayload{
				CallID:    session.ID,
				RoomName:  session.LiveKitRoomName,
				UserID:    userID,
				Reason:    req.Reason,
				Duration:  duration,
				Timestamp: now,
			},
			Timestamp: now,
		})
	}

	return &EndCallResponse{
		Success:         true,
		CallID:          session.ID,
		DurationSeconds: duration,
		Status:          status,
	}, nil
}

// HandleWebhook validates and processes incoming LiveKit server events with deduplication.
func (s *CallService) HandleWebhook(ctx context.Context, r *http.Request) (*livekit.WebhookEvent, error) {
	if s.client == nil {
		return nil, ErrLiveKitNotReady
	}

	// Verify cryptographic signature and decode event
	event, err := s.client.ReceiveWebhook(r)
	if err != nil {
		return nil, err
	}

	// Deduplication check
	eventID := event.Id
	if eventID != "" {
		s.whMu.Lock()
		if _, exists := s.processedWH[eventID]; exists {
			s.whMu.Unlock()
			log.Printf("[LiveKit Webhook] Duplicate event %s ignored", eventID)
			return event, nil
		}
		s.processedWH[eventID] = time.Now()
		// Clean up events older than 1 hour
		if len(s.processedWH) > 500 {
			cutoff := time.Now().Add(-1 * time.Hour)
			for id, t := range s.processedWH {
				if t.Before(cutoff) {
					delete(s.processedWH, id)
				}
			}
		}
		s.whMu.Unlock()
	}

	roomName := ""
	if event.Room != nil {
		roomName = event.Room.Name
	}

	log.Printf("[LiveKit Webhook] Event received: '%s' for room '%s'", event.Event, roomName)

	if roomName == "" {
		return event, nil
	}

	session, _ := s.store.GetCallByRoom(ctx, roomName)

	switch event.Event {
	case "room_started":
		if session != nil {
			_ = s.store.UpdateCallStatus(ctx, session.ID, "active")
		}
	case "room_finished":
		if session != nil {
			duration := 0
			if event.Room != nil && event.CreatedAt > event.Room.CreationTime && event.Room.CreationTime > 0 {
				duration = int(event.CreatedAt - event.Room.CreationTime)
			} else if session.StartedAt != nil {
				duration = int(time.Since(*session.StartedAt).Seconds())
			}
			_ = s.store.EndCall(ctx, session.ID, "completed", duration)

			if s.hub != nil {
				now := time.Now().UnixMilli()
				payload := hub.CallStatusPayload{
					CallID:    session.ID,
					RoomName:  roomName,
					Duration:  duration,
					Reason:    "room_finished",
					Timestamp: now,
				}
				s.hub.SendToUser(session.CallerUserID, hub.OutboundMessage{
					Event:     hub.EventCallEnded,
					Payload:   payload,
					Timestamp: now,
				})
				s.hub.SendToUser(session.CalleeUserID, hub.OutboundMessage{
					Event:     hub.EventCallEnded,
					Payload:   payload,
					Timestamp: now,
				})
			}
		}
	case "participant_left":
		// If only 1 participant left, or room is now empty
		if event.Room != nil && event.Room.NumParticipants <= 1 && session != nil && session.Status == "active" {
			log.Printf("[LiveKit Webhook] Participant left room %s (remaining: %d)", roomName, event.Room.NumParticipants)
		}
	}

	return event, nil
}
