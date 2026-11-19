package calling

import (
	"context"
	"errors"
	"net/http"
	"testing"
	"time"

	"github.com/livekit/protocol/auth"
	"github.com/livekit/protocol/livekit"
	"younme/realtime/hub"
)

// mockLiveKitClient implements LiveKitClient for unit testing.
type mockLiveKitClient struct {
	createdTokens   []string
	createdRooms    []string
	deletedRooms    []string
	removedUsers    []string
	webhookToReturn *livekit.WebhookEvent
	webhookErr      error
}

func newMockLiveKitClient() *mockLiveKitClient {
	return &mockLiveKitClient{
		createdTokens: make([]string, 0),
		createdRooms:  make([]string, 0),
		deletedRooms:  make([]string, 0),
		removedUsers:  make([]string, 0),
	}
}

func (m *mockLiveKitClient) CreateToken(roomName, identity, name string, canPublish, canSubscribe bool, ttl time.Duration) (string, error) {
	at := auth.NewAccessToken("mock_key", "mock_secret_long_enough_for_sha256_hashing_32_bytes_min")
	grant := &auth.VideoGrant{
		Room:     roomName,
		RoomJoin: true,
	}
	grant.SetCanPublish(canPublish)
	grant.SetCanSubscribe(canSubscribe)
	at.AddGrant(grant).SetIdentity(identity).SetName(name).SetValidFor(ttl)
	token, err := at.ToJWT()
	if err == nil {
		m.createdTokens = append(m.createdTokens, token)
	}
	return token, err
}

func (m *mockLiveKitClient) CreateRoom(_ context.Context, roomName string, _ uint32, _ uint32) (*livekit.Room, error) {
	m.createdRooms = append(m.createdRooms, roomName)
	return &livekit.Room{Name: roomName, Sid: "rm_sid_" + roomName}, nil
}

func (m *mockLiveKitClient) DeleteRoom(_ context.Context, roomName string) error {
	m.deletedRooms = append(m.deletedRooms, roomName)
	return nil
}

func (m *mockLiveKitClient) RemoveParticipant(_ context.Context, roomName, identity string) error {
	m.removedUsers = append(m.removedUsers, identity)
	return nil
}

func (m *mockLiveKitClient) ListParticipants(_ context.Context, _ string) ([]*livekit.ParticipantInfo, error) {
	return []*livekit.ParticipantInfo{}, nil
}

func (m *mockLiveKitClient) ReceiveWebhook(_ *http.Request) (*livekit.WebhookEvent, error) {
	if m.webhookErr != nil {
		return nil, m.webhookErr
	}
	if m.webhookToReturn != nil {
		return m.webhookToReturn, nil
	}
	return &livekit.WebhookEvent{Event: "room_started"}, nil
}

func TestInitiateCall_ValidationErrors(t *testing.T) {
	store := NewMemoryCallStore()
	mockLK := newMockLiveKitClient()
	svc := NewCallService(mockLK, store, nil, "wss://test.livekit.cloud")

	ctx := context.Background()

	// 1. Missing recipient
	_, err := svc.InitiateCall(ctx, "caller-1", &InitiateCallRequest{CalleeID: ""})
	if !errors.Is(err, ErrMissingRecipient) {
		t.Fatalf("expected ErrMissingRecipient, got %v", err)
	}

	// 2. Self call
	_, err = svc.InitiateCall(ctx, "caller-1", &InitiateCallRequest{CalleeID: "caller-1"})
	if !errors.Is(err, ErrSelfCall) {
		t.Fatalf("expected ErrSelfCall, got %v", err)
	}

	// 3. Invalid call type
	_, err = svc.InitiateCall(ctx, "caller-1", &InitiateCallRequest{CalleeID: "callee-1", CallType: "hologram"})
	if !errors.Is(err, ErrInvalidCallType) {
		t.Fatalf("expected ErrInvalidCallType, got %v", err)
	}
}

func TestInitiateCall_Success(t *testing.T) {
	store := NewMemoryCallStore()
	mockLK := newMockLiveKitClient()
	h := hub.NewHub(nil, nil)
	svc := NewCallService(mockLK, store, h, "wss://test.livekit.cloud")

	ctx := context.Background()

	resp, err := svc.InitiateCall(ctx, "caller-1", &InitiateCallRequest{
		CalleeID: "callee-2",
		CallType: "video",
		MatchID:  "match-123",
	})
	if err != nil {
		t.Fatalf("unexpected error initiating call: %v", err)
	}

	if !resp.Success {
		t.Errorf("expected resp.Success to be true")
	}
	if resp.CallID == "" {
		t.Errorf("expected non-empty CallID")
	}
	if resp.LiveKitToken == "" {
		t.Errorf("expected valid livekit token")
	}
	if resp.Status != "initiating" {
		t.Errorf("expected status 'initiating', got %s", resp.Status)
	}
	if resp.ParticipantIdentity != "caller-1" {
		t.Errorf("expected participant identity 'caller-1', got %s", resp.ParticipantIdentity)
	}

	// Verify session was stored
	session, err := store.GetCallByID(ctx, resp.CallID)
	if err != nil || session == nil {
		t.Fatalf("session not found in store: %v", err)
	}
	if session.CallerUserID != "caller-1" || session.CalleeUserID != "callee-2" {
		t.Errorf("stored session user IDs mismatch")
	}

	// Verify LiveKit room was provisioned
	if len(mockLK.createdRooms) != 1 || mockLK.createdRooms[0] != resp.RoomName {
		t.Errorf("expected room %s to be created in LiveKit", resp.RoomName)
	}
}

func TestGetParticipantToken_Authorization(t *testing.T) {
	store := NewMemoryCallStore()
	mockLK := newMockLiveKitClient()
	h := hub.NewHub(nil, nil)
	svc := NewCallService(mockLK, store, h, "wss://test.livekit.cloud")

	ctx := context.Background()

	initResp, err := svc.InitiateCall(ctx, "user-alice", &InitiateCallRequest{
		CalleeID: "user-bob",
		CallType: "audio",
	})
	if err != nil {
		t.Fatalf("failed to init call: %v", err)
	}

	// 1. Unauthorized third party attempts to get token
	_, err = svc.GetParticipantToken(ctx, "user-eve-intruder", &GetTokenRequest{
		CallID: initResp.CallID,
	})
	if !errors.Is(err, ErrUnauthorizedCall) {
		t.Fatalf("expected ErrUnauthorizedCall for third party, got %v", err)
	}

	// 2. Callee (Bob) accepts and gets token
	bobResp, err := svc.GetParticipantToken(ctx, "user-bob", &GetTokenRequest{
		CallID: initResp.CallID,
	})
	if err != nil {
		t.Fatalf("unexpected error getting token for Bob: %v", err)
	}
	if bobResp.ParticipantIdentity != "user-bob" {
		t.Errorf("expected identity user-bob, got %s", bobResp.ParticipantIdentity)
	}
	if bobResp.LiveKitToken == "" {
		t.Errorf("expected valid LiveKit token for Bob")
	}

	// Check status transitioned to active
	updated, _ := store.GetCallByID(ctx, initResp.CallID)
	if updated.Status != "active" {
		t.Errorf("expected call status to transition to 'active', got %s", updated.Status)
	}

	// 3. Caller (Alice) can also get token
	aliceResp, err := svc.GetParticipantToken(ctx, "user-alice", &GetTokenRequest{
		CallID: initResp.CallID,
	})
	if err != nil {
		t.Fatalf("unexpected error getting token for Alice: %v", err)
	}
	if aliceResp.ParticipantIdentity != "user-alice" {
		t.Errorf("expected identity user-alice, got %s", aliceResp.ParticipantIdentity)
	}
}

func TestEndCall_TerminationAndNotification(t *testing.T) {
	store := NewMemoryCallStore()
	mockLK := newMockLiveKitClient()
	h := hub.NewHub(nil, nil)
	svc := NewCallService(mockLK, store, h, "wss://test.livekit.cloud")

	ctx := context.Background()

	initResp, err := svc.InitiateCall(ctx, "caller-10", &InitiateCallRequest{
		CalleeID: "callee-20",
		CallType: "video",
	})
	if err != nil {
		t.Fatalf("init call failed: %v", err)
	}

	// Non-participant cannot end call
	_, err = svc.EndCall(ctx, "stranger", &EndCallRequest{CallID: initResp.CallID})
	if !errors.Is(err, ErrUnauthorizedCall) {
		t.Fatalf("expected ErrUnauthorizedCall, got %v", err)
	}

	// Callee declines call
	endResp, err := svc.EndCall(ctx, "callee-20", &EndCallRequest{
		CallID: initResp.CallID,
		Reason: "declined",
	})
	if err != nil {
		t.Fatalf("unexpected error ending call: %v", err)
	}
	if endResp.Status != "declined" {
		t.Errorf("expected status 'declined', got %s", endResp.Status)
	}

	// Verify room was deleted on LiveKit
	if len(mockLK.deletedRooms) != 1 || mockLK.deletedRooms[0] != initResp.RoomName {
		t.Errorf("expected room %s to be deleted on LiveKit", initResp.RoomName)
	}
}

func TestHandleWebhook_EventsAndDeduplication(t *testing.T) {
	store := NewMemoryCallStore()
	mockLK := newMockLiveKitClient()
	h := hub.NewHub(nil, nil)
	svc := NewCallService(mockLK, store, h, "wss://test.livekit.cloud")

	ctx := context.Background()

	initResp, _ := svc.InitiateCall(ctx, "user-1", &InitiateCallRequest{CalleeID: "user-2"})

	// 1. Webhook: room_started
	mockLK.webhookToReturn = &livekit.WebhookEvent{
		Id:    "evt_001",
		Event: "room_started",
		Room:  &livekit.Room{Name: initResp.RoomName},
	}
	evt, err := svc.HandleWebhook(ctx, nil)
	if err != nil {
		t.Fatalf("webhook handling failed: %v", err)
	}
	if evt.Event != "room_started" {
		t.Errorf("expected event room_started, got %s", evt.Event)
	}

	session, _ := store.GetCallByID(ctx, initResp.CallID)
	if session.Status != "active" {
		t.Errorf("expected session to become active after room_started, got %s", session.Status)
	}

	// 2. Webhook: duplicate event ignored
	evt2, err := svc.HandleWebhook(ctx, nil)
	if err != nil {
		t.Fatalf("duplicate webhook failed: %v", err)
	}
	if evt2.Id != "evt_001" {
		t.Errorf("expected same event id")
	}

	// 3. Webhook: room_finished
	mockLK.webhookToReturn = &livekit.WebhookEvent{
		Id:        "evt_002",
		Event:     "room_finished",
		Room:      &livekit.Room{Name: initResp.RoomName, CreationTime: 1000},
		CreatedAt: 1125,
	}
	evt3, err := svc.HandleWebhook(ctx, nil)
	if err != nil {
		t.Fatalf("room_finished webhook failed: %v", err)
	}
	if evt3.Event != "room_finished" {
		t.Errorf("expected room_finished, got %s", evt3.Event)
	}

	sessionFinished, _ := store.GetCallByID(ctx, initResp.CallID)
	if sessionFinished.Status != "completed" {
		t.Errorf("expected status 'completed', got %s", sessionFinished.Status)
	}
	if sessionFinished.DurationSeconds != 125 {
		t.Errorf("expected duration 125s, got %d", sessionFinished.DurationSeconds)
	}
}
