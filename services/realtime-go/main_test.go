package main

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"younme/realtime/auth"
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
