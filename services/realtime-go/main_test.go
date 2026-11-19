package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/livekit/protocol/livekit"
	"younme/realtime/auth"
	"younme/realtime/calling"
	"younme/realtime/config"
	"younme/realtime/db"
	"younme/realtime/hub"

	"github.com/gorilla/websocket"
)

// inMemoryMessageStore is a simple in-memory implementation for testing.
type inMemoryMessageStore struct {
	messages map[string][]db.ChatMessage
}

func (i *inMemoryMessageStore) SaveMessage(_ context.Context, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	if i.messages == nil {
		i.messages = make(map[string][]db.ChatMessage)
	}
	i.messages[roomID] = append(i.messages[roomID], db.ChatMessage{
		ID:          "test-" + time.Now().UTC().Format("20060102150405.999"),
		RoomID:      roomID,
		SenderID:    senderID,
		MessageType: messageType,
		RawContent:  rawContent,
		IsViewOnce:  isViewOnce,
		ScanStatus:  scanStatus,
		IsFlagged:   isFlagged,
		Status:      status,
		SentAt:      time.Now().UTC(),
	})
	return nil
}

func (i *inMemoryMessageStore) SaveMessageWithID(_ context.Context, messageID, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	if i.messages == nil {
		i.messages = make(map[string][]db.ChatMessage)
	}
	mid := messageID
	if mid == "" {
		mid = "test-" + time.Now().UTC().Format("20060102150405.999")
	}
	i.messages[roomID] = append(i.messages[roomID], db.ChatMessage{
		ID:          mid,
		RoomID:      roomID,
		SenderID:    senderID,
		MessageType: messageType,
		RawContent:  rawContent,
		IsViewOnce:  isViewOnce,
		ScanStatus:  scanStatus,
		IsFlagged:   isFlagged,
		Status:      status,
		SentAt:      time.Now().UTC(),
	})
	return nil
}

func (i *inMemoryMessageStore) MessageExists(_ context.Context, messageID string) (bool, error) {
	if i.messages == nil {
		return false, nil
	}
	for _, msgs := range i.messages {
		for _, m := range msgs {
			if m.ID == messageID {
				return true, nil
			}
		}
	}
	return false, nil
}

func (i *inMemoryMessageStore) GetConversationHistory(_ context.Context, roomID string, limit, offset int) ([]db.ChatMessage, error) {
	if i.messages == nil {
		return nil, nil
	}
	msgs := i.messages[roomID]
	var result []db.ChatMessage
	for range msgs {
		offset++
	}
	return result, nil
}

func (i *inMemoryMessageStore) GetUndeliveredMessages(_ context.Context, roomID string) ([]db.ChatMessage, error) {
	if i.messages == nil {
		return nil, nil
	}
	var result []db.ChatMessage
	for _, m := range i.messages[roomID] {
		if m.Status == "sent" {
			result = append(result, m)
		}
	}
	return result, nil
}

func (i *inMemoryMessageStore) MarkMessageDelivered(_ context.Context, messageID string) error {
	return nil
}

func (i *inMemoryMessageStore) MarkMessageRead(_ context.Context, messageID string) error {
	return nil
}

func TestHealthCheck(t *testing.T) {
	cfg := &config.Config{Port: "8081"}
	msgStore := &inMemoryMessageStore{}
	h := hub.NewHub(nil, msgStore)
	handler := SetupRouter(cfg, nil, h)

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected status 200, got %d", rec.Code)
	}

	var res map[string]interface{}
	if err := json.Unmarshal(rec.Body.Bytes(), &res); err != nil {
		t.Fatalf("failed to parse JSON response: %v", err)
	}

	if res["status"] != "healthy" {
		t.Errorf("expected status 'healthy', got %v", res["status"])
	}
	if res["service"] != "realtime-go" {
		t.Errorf("expected service 'realtime-go', got %v", res["service"])
	}
}

func TestHealthCheck_MethodNotAllowed(t *testing.T) {
	cfg := &config.Config{Port: "8081"}
	msgStore := &inMemoryMessageStore{}
	h := hub.NewHub(nil, msgStore)
	handler := SetupRouter(cfg, nil, h)

	req := httptest.NewRequest(http.MethodPost, "/health", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusMethodNotAllowed {
		t.Fatalf("expected status 405, got %d", rec.Code)
	}
}

func TestWebSocket_AuthenticationFailures(t *testing.T) {
	cfg := &config.Config{Port: "8081"}
	msgStore := &inMemoryMessageStore{}
	h := hub.NewHub(nil, msgStore)
	mockVerifier := auth.NewMockVerifier(map[string]*auth.UserInfo{
		"valid-token": {ID: "usr_alice"},
	})
	handler := SetupRouter(cfg, mockVerifier, h)

	// Case 1: Missing Token
	req := httptest.NewRequest(http.MethodGet, "/ws", nil)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for missing token, got %d", rec.Code)
	}

	// Case 2: Invalid Token
	req = httptest.NewRequest(http.MethodGet, "/ws?token=invalid-fake-token", nil)
	rec = httptest.NewRecorder()
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for invalid token, got %d", rec.Code)
	}

	// Case 3: Expired Token
	req = httptest.NewRequest(http.MethodGet, "/ws?token=expired-token", nil)
	rec = httptest.NewRecorder()
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for expired token, got %d", rec.Code)
	}

	// Case 4: Missing Verifier (Server has no Supabase configuration)
	unconfiguredHandler := SetupRouter(cfg, nil, h)
	req = httptest.NewRequest(http.MethodGet, "/ws?token=any-token", nil)
	rec = httptest.NewRecorder()
	unconfiguredHandler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 when Supabase is unconfigured, got %d", rec.Code)
	}
}

func TestWebSocket_AuthenticatedConnectionAndEcho(t *testing.T) {
	cfg := &config.Config{Port: "8081"}
	msgStore := &inMemoryMessageStore{}
	h := hub.NewHub(nil, msgStore)
	mockVerifier := auth.NewMockVerifier(map[string]*auth.UserInfo{
		"valid-token": {ID: "usr_alice"},
	})

	server := httptest.NewServer(SetupRouter(cfg, mockVerifier, h))
	defer server.Close()

	// Convert http URL to ws URL
	wsURL := "ws" + strings.TrimPrefix(server.URL, "http") + "/ws?token=valid-token"

	// Connect via Gorilla WebSocket client
	conn, resp, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		t.Fatalf("failed to dial websocket: %v (status: %v)", err, resp)
	}
	defer conn.Close()

	// Verify usr_alice is now online in the Hub
	time.Sleep(50 * time.Millisecond)
	if !h.IsUserOnline("usr_alice") {
		t.Errorf("expected usr_alice to be online in hub")
	}

	// Send a valid chat message to Bob
	sendMsg := hub.InboundMessage{
		Event:    hub.EventChatMessage,
		ToUserID: "usr_bob",
		Payload:  json.RawMessage(`{"body":"Hey Bob, nice to meet you!"}`),
	}
	msgBytes, _ := json.Marshal(sendMsg)
	if err := conn.WriteMessage(websocket.TextMessage, msgBytes); err != nil {
		t.Fatalf("failed to write message: %v", err)
	}

	// Because Bob is offline, Alice should receive an undelivered ack
	var outbound hub.OutboundMessage
	receivedAck := false
	deadline := time.Now().Add(2 * time.Second)

	for time.Now().Before(deadline) {
		_ = conn.SetReadDeadline(time.Now().Add(500 * time.Millisecond))
		_, receivedBytes, err := conn.ReadMessage()
		if err != nil {
			break
		}
		if err := json.Unmarshal(receivedBytes, &outbound); err == nil {
			if outbound.Event == hub.EventUndelivered {
				receivedAck = true
				break
			}
		}
	}

	if !receivedAck {
		t.Errorf("expected event 'chat:undelivered' from server for offline recipient")
	}
}

func TestCORS_PreflightAndHeaders(t *testing.T) {
	cfg := &config.Config{
		Port:           "8081",
		AllowedOrigins: []string{"http://localhost:5173", "http://localhost:3000"},
	}
	msgStore := &inMemoryMessageStore{}
	h := hub.NewHub(nil, msgStore)
	handler := SetupRouter(cfg, nil, h)

	// 1. OPTIONS preflight request
	req := httptest.NewRequest(http.MethodOptions, "/health", nil)
	req.Header.Set("Origin", "http://localhost:5173")
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusNoContent {
		t.Errorf("expected status 204 for OPTIONS preflight, got %d", rec.Code)
	}
	if got := rec.Header().Get("Access-Control-Allow-Origin"); got != "http://localhost:5173" {
		t.Errorf("expected Access-Control-Allow-Origin 'http://localhost:5173', got %q", got)
	}
	if got := rec.Header().Get("Access-Control-Allow-Credentials"); got != "true" {
		t.Errorf("expected Access-Control-Allow-Credentials 'true', got %q", got)
	}

	// 2. GET request with Origin header
	getReq := httptest.NewRequest(http.MethodGet, "/health", nil)
	getReq.Header.Set("Origin", "http://localhost:5173")
	getRec := httptest.NewRecorder()
	handler.ServeHTTP(getRec, getReq)

	if getRec.Code != http.StatusOK {
		t.Errorf("expected status 200 for GET /health, got %d", getRec.Code)
	}
	if got := getRec.Header().Get("Access-Control-Allow-Origin"); got != "http://localhost:5173" {
		t.Errorf("expected Access-Control-Allow-Origin 'http://localhost:5173', got %q", got)
	}
}

// mockLKForMainTest implements calling.LiveKitClient for HTTP router tests.
type mockLKForMainTest struct{}

func (m *mockLKForMainTest) CreateToken(roomName, identity, name string, canPublish, canSubscribe bool, ttl time.Duration) (string, error) {
	return "mock.livekit.jwt.token", nil
}
func (m *mockLKForMainTest) CreateRoom(_ context.Context, _ string, _, _ uint32) (*livekit.Room, error) {
	return &livekit.Room{Name: "test-room"}, nil
}
func (m *mockLKForMainTest) DeleteRoom(_ context.Context, _ string) error {
	return nil
}
func (m *mockLKForMainTest) RemoveParticipant(_ context.Context, _, _ string) error {
	return nil
}
func (m *mockLKForMainTest) ListParticipants(_ context.Context, _ string) ([]*livekit.ParticipantInfo, error) {
	return nil, nil
}
func (m *mockLKForMainTest) ReceiveWebhook(r *http.Request) (*livekit.WebhookEvent, error) {
	if r.Header.Get("Authorization") == "bad-sig" {
		return nil, errors.New("invalid signature")
	}
	return &livekit.WebhookEvent{Event: "room_finished"}, nil
}

func TestCallsAPI_InitiateTokenEnd(t *testing.T) {
	cfg := &config.Config{
		Port:         "8081",
		LiveKitWSURL: "wss://test.livekit.cloud",
	}
	mockVerifier := auth.NewMockVerifier(map[string]*auth.UserInfo{
		"token-alice": {
			ID:   "user-alice",
			Role: "authenticated",
		},
		"token-bob": {
			ID:   "user-bob",
			Role: "authenticated",
		},
		"token-eve": {
			ID:   "user-eve",
			Role: "authenticated",
		},
	})
	h := hub.NewHub(nil, &inMemoryMessageStore{})
	callStore := calling.NewMemoryCallStore()
	callSvc := calling.NewCallService(&mockLKForMainTest{}, callStore, h, cfg.LiveKitWSURL)
	handler := SetupRouterWithCalling(cfg, mockVerifier, h, callSvc)

	// 1. Missing Auth Token -> 401
	initReq := httptest.NewRequest(http.MethodPost, "/v1/calls/initiate", strings.NewReader(`{"callee_id":"user-bob"}`))
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, initReq)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for unauthenticated request, got %d", rec.Code)
	}

	// 2. Caller calling self -> 400
	selfReq := httptest.NewRequest(http.MethodPost, "/v1/calls/initiate", strings.NewReader(`{"callee_id":"user-alice"}`))
	selfReq.Header.Set("Authorization", "Bearer token-alice")
	selfRec := httptest.NewRecorder()
	handler.ServeHTTP(selfRec, selfReq)
	if selfRec.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for self-call, got %d", selfRec.Code)
	}

	// 3. Successful Initiate -> 200
	successReq := httptest.NewRequest(http.MethodPost, "/v1/calls/initiate", strings.NewReader(`{"callee_id":"user-bob","call_type":"video"}`))
	successReq.Header.Set("Authorization", "Bearer token-alice")
	successRec := httptest.NewRecorder()
	handler.ServeHTTP(successRec, successReq)
	if successRec.Code != http.StatusOK {
		t.Fatalf("expected 200 for initiate call, got %d: %s", successRec.Code, successRec.Body.String())
	}

	var initResp calling.InitiateCallResponse
	if err := json.NewDecoder(successRec.Body).Decode(&initResp); err != nil {
		t.Fatalf("failed to decode initiate response: %v", err)
	}
	if initResp.CallID == "" || initResp.LiveKitToken == "" {
		t.Fatalf("expected non-empty CallID and LiveKitToken, got %+v", initResp)
	}

	// 4. Unauthorized User (Eve) requests token -> 403 Forbidden
	eveReq := httptest.NewRequest(http.MethodPost, "/v1/calls/token", strings.NewReader(fmt.Sprintf(`{"call_id":"%s"}`, initResp.CallID)))
	eveReq.Header.Set("Authorization", "Bearer token-eve")
	eveRec := httptest.NewRecorder()
	handler.ServeHTTP(eveRec, eveReq)
	if eveRec.Code != http.StatusForbidden {
		t.Fatalf("expected 403 for unauthorized user token request, got %d", eveRec.Code)
	}

	// 5. Authorized Callee (Bob) requests token -> 200 OK
	bobReq := httptest.NewRequest(http.MethodPost, "/v1/calls/token", strings.NewReader(fmt.Sprintf(`{"call_id":"%s"}`, initResp.CallID)))
	bobReq.Header.Set("Authorization", "Bearer token-bob")
	bobRec := httptest.NewRecorder()
	handler.ServeHTTP(bobRec, bobReq)
	if bobRec.Code != http.StatusOK {
		t.Fatalf("expected 200 for authorized callee, got %d: %s", bobRec.Code, bobRec.Body.String())
	}

	// 6. Authorized Caller (Alice) ends call -> 200 OK
	endReq := httptest.NewRequest(http.MethodPost, "/v1/calls/end", strings.NewReader(fmt.Sprintf(`{"call_id":"%s","reason":"hangup"}`, initResp.CallID)))
	endReq.Header.Set("Authorization", "Bearer token-alice")
	endRec := httptest.NewRecorder()
	handler.ServeHTTP(endRec, endReq)
	if endRec.Code != http.StatusOK {
		t.Fatalf("expected 200 for end call, got %d: %s", endRec.Code, endRec.Body.String())
	}
}

func TestCallsAPI_Webhook(t *testing.T) {
	cfg := &config.Config{Port: "8081"}
	h := hub.NewHub(nil, &inMemoryMessageStore{})
	callStore := calling.NewMemoryCallStore()
	callSvc := calling.NewCallService(&mockLKForMainTest{}, callStore, h, "wss://test.livekit.cloud")
	handler := SetupRouterWithCalling(cfg, nil, h, callSvc)

	// 1. Invalid webhook signature -> 401
	badReq := httptest.NewRequest(http.MethodPost, "/v1/calls/webhook", strings.NewReader(`{}`))
	badReq.Header.Set("Authorization", "bad-sig")
	badRec := httptest.NewRecorder()
	handler.ServeHTTP(badRec, badReq)
	if badRec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 for invalid webhook signature, got %d", badRec.Code)
	}

	// 2. Valid webhook signature -> 200
	goodReq := httptest.NewRequest(http.MethodPost, "/v1/calls/webhook", strings.NewReader(`{}`))
	goodReq.Header.Set("Authorization", "valid-sig")
	goodRec := httptest.NewRecorder()
	handler.ServeHTTP(goodRec, goodReq)
	if goodRec.Code != http.StatusOK {
		t.Fatalf("expected 200 for valid webhook, got %d", goodRec.Code)
	}
}
