package calling

import (
	"errors"
	"strings"
	"time"
)

var (
	ErrCallNotFound     = errors.New("call session not found")
	ErrUnauthorizedCall = errors.New("user is not an authorized participant in this call")
	ErrInvalidCallType  = errors.New("call type must be 'audio' or 'video'")
	ErrSelfCall         = errors.New("cannot initiate a call to yourself")
	ErrMissingRecipient = errors.New("callee_id is required")
	ErrMissingCallID    = errors.New("call_id is required")
	ErrLiveKitNotReady  = errors.New("livekit client is not configured")
)

// CallSession represents a persisted call record matching the PostgreSQL schema.
type CallSession struct {
	ID              string     `json:"id"`
	LiveKitRoomName string     `json:"livekit_room_name"`
	CallerUserID    string     `json:"caller_user_id"`
	CalleeUserID    string     `json:"callee_user_id"`
	MatchID         string     `json:"match_id,omitempty"`
	CallType        string     `json:"call_type"` // "audio" | "video"
	Status          string     `json:"status"`    // "initiating" | "active" | "completed" | "declined" | "missed"
	DurationSeconds int        `json:"duration_seconds"`
	StartedAt       *time.Time `json:"started_at,omitempty"`
	EndedAt         *time.Time `json:"ended_at,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

// InitiateCallRequest represents payload to start a new call.
type InitiateCallRequest struct {
	CalleeID     string `json:"callee_id"`
	CallType     string `json:"call_type"` // "audio" or "video", defaults to "audio"
	MatchID      string `json:"match_id,omitempty"`
	CallerName   string `json:"caller_name,omitempty"`
	CallerAvatar string `json:"caller_avatar,omitempty"`
}

// Validate checks request validity.
func (r *InitiateCallRequest) Validate() error {
	r.CalleeID = strings.TrimSpace(r.CalleeID)
	if r.CalleeID == "" {
		return ErrMissingRecipient
	}
	r.CallType = strings.ToLower(strings.TrimSpace(r.CallType))
	if r.CallType == "" {
		r.CallType = "audio"
	}
	if r.CallType != "audio" && r.CallType != "video" {
		return ErrInvalidCallType
	}
	return nil
}

// InitiateCallResponse represents the returned details for Flutter caller.
type InitiateCallResponse struct {
	Success             bool   `json:"success"`
	CallID              string `json:"call_id"`
	RoomName            string `json:"room_name"`
	LiveKitURL          string `json:"livekit_url"`
	LiveKitToken        string `json:"livekit_token"`
	ParticipantIdentity string `json:"participant_identity"`
	CallType            string `json:"call_type"`
	Status              string `json:"status"`
}

// GetTokenRequest represents request to get a LiveKit room token (caller or callee).
type GetTokenRequest struct {
	CallID   string `json:"call_id"`
	RoomName string `json:"room_name,omitempty"`
}

// Validate checks token request parameters.
func (r *GetTokenRequest) Validate() error {
	r.CallID = strings.TrimSpace(r.CallID)
	r.RoomName = strings.TrimSpace(r.RoomName)
	if r.CallID == "" && r.RoomName == "" {
		return ErrMissingCallID
	}
	return nil
}

// GetTokenResponse contains the LiveKit join token for the participant.
type GetTokenResponse struct {
	Success             bool   `json:"success"`
	CallID              string `json:"call_id"`
	RoomName            string `json:"room_name"`
	LiveKitURL          string `json:"livekit_url"`
	LiveKitToken        string `json:"livekit_token"`
	ParticipantIdentity string `json:"participant_identity"`
	Status              string `json:"status"`
}

// EndCallRequest represents request to hang up or decline a call.
type EndCallRequest struct {
	CallID string `json:"call_id"`
	Reason string `json:"reason,omitempty"` // "hangup", "declined", "busy", "timeout"
}

// Validate checks end call request.
func (r *EndCallRequest) Validate() error {
	r.CallID = strings.TrimSpace(r.CallID)
	if r.CallID == "" {
		return ErrMissingCallID
	}
	return nil
}

// EndCallResponse represents result of terminating a call.
type EndCallResponse struct {
	Success         bool   `json:"success"`
	CallID          string `json:"call_id"`
	DurationSeconds int    `json:"duration_seconds"`
	Status          string `json:"status"`
}
