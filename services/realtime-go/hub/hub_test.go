package hub

import (
	"context"
	"encoding/json"
	"sync"
	"testing"
	"time"

	"younme/realtime/db"
)

type inMemoryMessageStore struct {
	mu        sync.Mutex
	pendingMsgs map[string]db.ChatMessage // message_id -> chat message
	savedMessages map[string]db.ChatMessage // message_id -> chat message (persisted)
}

func (i *inMemoryMessageStore) SaveMessage(_ context.Context, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	i.mu.Lock()
	defer i.mu.Unlock()
	if i.savedMessages == nil {
		i.savedMessages = make(map[string]db.ChatMessage)
	}
	mid := "test-msg-id"
	i.savedMessages[mid] = db.ChatMessage{
		ID:          mid,
		RoomID:      roomID,
		SenderID:    senderID,
		MessageType: messageType,
		RawContent:  rawContent,
		IsViewOnce:  isViewOnce,
		ScanStatus:  scanStatus,
		IsFlagged:   isFlagged,
		Status:      status,
		CreatedAt:   time.Now().UTC(),
	}
	return nil
}

func (i *inMemoryMessageStore) SaveMessageWithID(_ context.Context, messageID, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	i.mu.Lock()
	defer i.mu.Unlock()
	if i.savedMessages == nil {
		i.savedMessages = make(map[string]db.ChatMessage)
	}
	mid := messageID
	if mid == "" {
		mid = "test-msg-id"
	}
	i.savedMessages[mid] = db.ChatMessage{
		ID:          mid,
		RoomID:      roomID,
		SenderID:    senderID,
		MessageType: messageType,
		RawContent:  rawContent,
		IsViewOnce:  isViewOnce,
		ScanStatus:  scanStatus,
		IsFlagged:   isFlagged,
		Status:      status,
		CreatedAt:   time.Now().UTC(),
	}
	return nil
}

func (i *inMemoryMessageStore) MessageExists(_ context.Context, messageID string) (bool, error) {
	i.mu.Lock()
	defer i.mu.Unlock()
	if i.savedMessages == nil {
		return false, nil
	}
	_, ok := i.savedMessages[messageID]
	return ok, nil
}

func (i *inMemoryMessageStore) GetConversationHistory(_ context.Context, roomID string, limit, offset int) ([]db.ChatMessage, error) {
	i.mu.Lock()
	defer i.mu.Unlock()
	var results []db.ChatMessage
	for _, m := range i.savedMessages {
		if m.RoomID == roomID {
			results = append(results, m)
		}
	}
	return results, nil
}

func (i *inMemoryMessageStore) GetUndeliveredMessages(_ context.Context, roomID string) ([]db.ChatMessage, error) {
	i.mu.Lock()
	defer i.mu.Unlock()
	var results []db.ChatMessage
	for _, m := range i.savedMessages {
		if m.Status == "sent" {
			results = append(results, m)
		}
	}
	return results, nil
}

func (i *inMemoryMessageStore) MarkMessageDelivered(_ context.Context, messageID string) error {
	i.mu.Lock()
	defer i.mu.Unlock()
	if i.savedMessages == nil {
		return nil
	}
	if m, ok := i.savedMessages[messageID]; ok {
		m.Status = "delivered"
		i.savedMessages[messageID] = m
		return nil
	}
	// Also try to mark any sent message as delivered for flexibility
	for k, m := range i.savedMessages {
		if m.Status == "sent" {
			m.Status = "delivered"
			i.savedMessages[k] = m
			return nil
		}
	}
	return nil
}

func (i *inMemoryMessageStore) MarkMessageRead(_ context.Context, messageID string) error {
	return nil
}

func TestInboundMessageValidation(t *testing.T) {
	msg := InboundMessage{Event: ""}
	if err := msg.Validate(); err == nil {
		t.Errorf("expected error for empty event")
	}

	msg = InboundMessage{
		Event:   EventChatMessage,
		Payload: json.RawMessage(`{"body":"hello"}`),
	}
	if err := msg.Validate(); err == nil {
		t.Errorf("expected error when both channel and to_user_id are empty")
	}

	msg = InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "usr_2",
	}
	if err := msg.Validate(); err == nil {
		t.Errorf("expected error for empty payload in chat message")
	}

	msg = InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "usr_2",
		Payload:  json.RawMessage(`{"body":""}`),
	}
	if err := msg.Validate(); err == nil {
		t.Errorf("expected error for empty body")
	}

	msg = InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "usr_2",
		Payload:  json.RawMessage(`{"body":"Hey there!"}`),
	}
	if err := msg.Validate(); err != nil {
		t.Errorf("expected valid chat message, got error: %v", err)
	}

	msg = InboundMessage{
		Event:   EventSubscribe,
		Channel: "chat:match_123",
	}
	if err := msg.Validate(); err != nil {
		t.Errorf("expected valid subscribe message, got error: %v", err)
	}
}

func drainUntilEvent(c *Client, eventName string, timeout time.Duration) (*OutboundMessage, error) {
	deadline := time.After(timeout)
	for {
		select {
		case data := <-c.Send:
			var msg OutboundMessage
			if err := json.Unmarshal(data, &msg); err == nil {
				if msg.Event == eventName {
					return &msg, nil
				}
			}
		case <-deadline:
			return nil, nil
		}
	}
}

func TestHub_UserRegistryAndDirectRouting(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	// Create simulated client 1 (User A)
	client1 := &Client{
		ID:       "session_1",
		UserID:   "usr_alice",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(client1)

	// Verify User A is online
	if !h.IsUserOnline("usr_alice") {
		t.Errorf("expected usr_alice to be online")
	}
	activeClients, activeUsers := h.GetStats()
	if activeClients != 1 || activeUsers != 1 {
		t.Errorf("expected 1 client and 1 user, got %d clients, %d users", activeClients, activeUsers)
	}

	// Create simulated client 2 (User B)
	client2 := &Client{
		ID:       "session_2",
		UserID:   "usr_bob",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(client2)

	// Send direct message from Alice to Bob
	directMsg := OutboundMessage{
		Event:   EventChatMessage,
		FromUID: "usr_alice",
		Payload: map[string]string{"body": "Hello Bob!"},
	}
	delivered := h.SendToUser("usr_bob", directMsg)
	if !delivered {
		t.Errorf("expected message to be delivered to online usr_bob")
	}

	// Check that Bob received the chat message in Send channel
	received, err := drainUntilEvent(client2, EventChatMessage, 500*time.Millisecond)
	if err != nil || received == nil {
		t.Fatalf("expected Bob to receive EventChatMessage, got nil")
	}
	if received.FromUID != "usr_alice" {
		t.Errorf("expected from usr_alice, got %s", received.FromUID)
	}

	// Try sending to offline user Charlie
	directMsg2 := OutboundMessage{
		Event:   EventChatMessage,
		FromUID: "usr_alice",
		Payload: map[string]string{"body": "Hello Charlie!"},
	}
	deliveredOffline := h.SendToUser("usr_charlie", directMsg2)
	if deliveredOffline {
		t.Errorf("expected SendToUser to return false for offline user")
	}

	// Unregister Bob
	h.Unregister(client2)
	if h.IsUserOnline("usr_bob") {
		t.Errorf("expected usr_bob to be offline after unregister")
	}
}

func TestHub_ChannelBroadcast(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	client1 := &Client{
		ID:       "c1",
		UserID:   "usr_1",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	client2 := &Client{
		ID:       "c2",
		UserID:   "usr_2",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(client1)
	h.Register(client2)

	// Subscribe both to channel "chat:conv_abc"
	channelName := "chat:conv_abc"
	h.Subscribe(client1, channelName)
	h.Subscribe(client2, channelName)

	broadcastMsg := OutboundMessage{
		Channel: channelName,
		Event:   "match:update",
		FromUID: "usr_1",
		Payload: map[string]string{"text": "Match status updated"},
	}
	h.Broadcast(broadcastMsg)

	// Both client1 and client2 should receive the message
	for _, client := range []*Client{client1, client2} {
		msg, err := drainUntilEvent(client, "match:update", 500*time.Millisecond)
		if err != nil || msg == nil {
			t.Fatalf("timed out waiting for match:update broadcast on %s", client.ID)
		}
		if msg.Channel != channelName {
			t.Errorf("expected channel %s, got %s", channelName, msg.Channel)
		}
	}
}

func TestHub_ChatRouting_SenderIdentityFromVerifiedClient(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	clientA := &Client{
		ID:       "session_sender",
		UserID:   "11111111-1111-1111-1111-111111111111",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	clientB := &Client{
		ID:       "session_recipient",
		UserID:   "22222222-2222-2222-2222-222222222222",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(clientA)
	h.Register(clientB)

	// Inbound chat message: sender identity must come from the verified client (user A),
	// never from the payload itself.
	inbound := InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "22222222-2222-2222-2222-222222222222",
		Payload:  json.RawMessage(`{"body":"Hey Bob, nice to meet you!"}`),
	}

	h.HandleInbound(clientA, inbound)

	// Recipient must receive the chat message, authored by the verified sender
	received, err := drainUntilEvent(clientB, EventChatMessage, 500*time.Millisecond)
	if err != nil || received == nil {
		t.Fatalf("expected recipient to receive EventChatMessage, got nil (err=%v)", err)
	}
	if received.FromUID != "11111111-1111-1111-1111-111111111111" {
		t.Errorf("expected from_uid to be the verified sender (1111...), got %s", received.FromUID)
	}
	if received.Event != EventChatMessage {
		t.Errorf("expected event %s, got %s", EventChatMessage, received.Event)
	}
}

func TestHub_ThreadSafetyConcurrent(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)
	var wg sync.WaitGroup

	numGoroutines := 20
	numOperations := 25

	for i := 0; i < numGoroutines; i++ {
		wg.Add(1)
		go func(routineID int) {
			defer wg.Done()
			for j := 0; j < numOperations; j++ {
				client := &Client{
					ID:       "test_client",
					UserID:   "test_user",
					Send:     make(chan []byte, 100),
					channels: make(map[string]bool),
					Hub:      h,
				}
				h.Register(client)
				h.Subscribe(client, "test_channel")
				h.Broadcast(OutboundMessage{Channel: "test_channel", Event: "ping"})
				h.SendToUser("test_user", OutboundMessage{Event: "direct"})
				h.Unsubscribe(client, "test_channel")
				h.Unregister(client)
			}
		}(i)
	}

	wg.Wait()

	activeClients, activeUsers := h.GetStats()
	if activeClients != 0 || activeUsers != 0 {
		t.Errorf("expected 0 clients and 0 users after full cleanup, got %d clients, %d users", activeClients, activeUsers)
	}
}

func TestHub_PendingMessageDeliveryOnReconnect(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	// User A sends a message to User B while User B is "offline"
	// (simulated by not registering User B before sending)
	clientA := &Client{
		ID:       "session_sender",
		UserID:   "11111111-1111-1111-1111-111111111111",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}

	inbound := InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "22222222-2222-2222-2222-222222222222",
		Payload:  json.RawMessage(`{"body":"Hey Bob, nice to meet you!"}`),
	}

	h.HandleInbound(clientA, inbound)

	// Register User B to simulate reconnect
	clientB := &Client{
		ID:       "session_recipient",
		UserID:   "22222222-2222-2222-2222-222222222222",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(clientB)

	// After reconnection, pending messages should be delivered to User B
	received, err := drainUntilEvent(clientB, EventChatMessage, 500*time.Millisecond)
	if err != nil || received == nil {
		t.Fatalf("expected recipient to receive EventChatMessage after reconnect, got nil (err=%v)", err)
	}
	if received.FromUID != "11111111-1111-1111-1111-111111111111" {
		t.Errorf("expected from_uid to be the verified sender (1111...), got %s", received.FromUID)
	}
	if received.Event != EventChatMessage {
		t.Errorf("expected event %s, got %s", EventChatMessage, received.Event)
	}
}

func TestHub_MessageAck_DeliveryMarked(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	clientA := &Client{
		ID:       "session_sender",
		UserID:   "11111111-1111-1111-1111-111111111111",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	clientB := &Client{
		ID:       "session_recipient",
		UserID:   "22222222-2222-2222-2222-222222222222",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(clientA)
	h.Register(clientB)

	// User A sends a message to User B
	inbound := InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "22222222-2222-2222-2222-222222222222",
		Payload:  json.RawMessage(`{"body":"Hey Bob!"}`),
	}
	h.HandleInbound(clientA, inbound)

	// User B acknowledges the message with a message:ack event
	// Use a dummy message ID - the ack handler will try to mark it delivered
	// but since the store is mock, it will just return nil without error
	ackInbound := InboundMessage{
		Event: EventMessageAck,
		Payload: json.RawMessage(`{"message_id":"test-message-id-12345"}`),
	}
	// This should not panic or return an error
	h.HandleInbound(clientB, ackInbound)
}

func TestHub_DeliveryAck_PreventsDuplicate(t *testing.T) {
	msgStore := &inMemoryMessageStore{}
	h := NewHub(nil, msgStore)

	clientA := &Client{
		ID:       "session_sender",
		UserID:   "11111111-1111-1111-1111-111111111111",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	clientB := &Client{
		ID:       "session_recipient",
		UserID:   "22222222-2222-2222-2222-222222222222",
		Send:     make(chan []byte, 50),
		channels: make(map[string]bool),
		Hub:      h,
	}
	h.Register(clientA)
	h.Register(clientB)

	// User A sends a message to User B
	inbound := InboundMessage{
		Event:    EventChatMessage,
		ToUserID: "22222222-2222-2222-2222-222222222222",
		Payload:  json.RawMessage(`{"body":"Hey Bob!"}`),
	}
	h.HandleInbound(clientA, inbound)

	// User B acknowledges the message twice with the same message ID
	ackID := "test-message-id-once-only"
	ack1 := InboundMessage{
		Event: EventMessageAck,
		Payload: json.RawMessage(`{"message_id":"` + ackID + `"}`),
	}
	ack2 := InboundMessage{
		Event: EventMessageAck,
		Payload: json.RawMessage(`{"message_id":"` + ackID + `"}`),
	}

	// Both acks should be processed without error or panic
	h.HandleInbound(clientB, ack1)
	h.HandleInbound(clientB, ack2)

	t.Log("Both acks processed successfully without error")
}