package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"younme/realtime/guard"
	"younme/realtime/hub"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow cross-origin for client dev & staging
	},
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func handleWebSocket(h *hub.Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("[Go Engine] Upgrade error:", err)
		return
	}

	userId := r.URL.Query().Get("user_id")
	if userId == "" {
		userId = "anonymous"
	}

	client := &hub.Client{
		ID:       r.RemoteAddr,
		UserID:   userId,
		Conn:     conn,
		Send:     make(chan []byte, 256),
		Channels: make(map[string]bool),
		Hub:      h,
	}

	// Register with hub
	h.Subscribe(client, "user:"+userId)
	h.Subscribe(client, "presence:global")

	// Broadcast presence online event
	h.Broadcast(hub.EventMessage{
		Channel: "presence:" + userId,
		Event:   "presence:online",
		Payload: map[string]interface{}{"user_id": userId, "status": "online"},
	})

	// Reader pump
	go func() {
		defer func() {
			conn.Close()
			h.Broadcast(hub.EventMessage{
				Channel: "presence:" + userId,
				Event:   "presence:offline",
				Payload: map[string]interface{}{"user_id": userId, "status": "offline"},
			})
		}()

		for {
			_, msgBytes, err := conn.ReadMessage()
			if err != nil {
				break
			}

			var incoming hub.EventMessage
			if err := json.Unmarshal(msgBytes, &incoming); err != nil {
				continue
			}

			// Handle actions
			switch incoming.Event {
			case "subscribe":
				targetChan, ok := incoming.Payload.(string)
				if ok && targetChan != "" {
					h.Subscribe(client, targetChan)
				}

			case "unsubscribe":
				targetChan, ok := incoming.Payload.(string)
				if ok && targetChan != "" {
					h.Unsubscribe(client, targetChan)
				}

			case "chat:message":
				// Pass through Contact & Link Guard
				payloadMap, ok := incoming.Payload.(map[string]interface{})
				if ok {
					body, _ := payloadMap["body"].(string)
					activeDays := 1
					messagePairs := 5
					if d, ok := payloadMap["active_days"].(float64); ok {
						activeDays = int(d)
					}
					if m, ok := payloadMap["pair_count"].(float64); ok {
						messagePairs = int(m)
					}

					guardResult := guard.CheckContactGuard(body, activeDays, messagePairs)
					if guardResult.IsBlocked {
						// Reject message and notify sender
						conn.WriteJSON(hub.EventMessage{
							Channel: incoming.Channel,
							Event:   "guard:blocked",
							Payload: map[string]interface{}{
								"reason":        guardResult.Reason,
								"detected_type": guardResult.DetectedType,
							},
						})
						continue
					}

					// Message allowed, broadcast to channel
					h.Broadcast(incoming)
				}

			case "typing", "call:signal", "call:game_move":
				h.Broadcast(incoming)
			}
		}
	}()

	// Writer pump
	go func() {
		ticker := time.NewTicker(30 * time.Second)
		defer func() {
			ticker.Stop()
			conn.Close()
		}()

		for {
			select {
			case message, ok := <-client.Send:
				if !ok {
					conn.WriteMessage(websocket.CloseMessage, []byte{})
					return
				}
				conn.WriteMessage(websocket.TextMessage, message)

			case <-ticker.C:
				if err := conn.WriteMessage(websocket.PingMessage, nil); err != nil {
					return
				}
			}
		}
	}()
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	h := hub.NewHub()
	go h.Run()

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy","service":"realtime-go","runtime":"GCP Cloud Run asia-south1"}`))
	})

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		handleWebSocket(h, w, r)
	})

	log.Printf("[Go Real-Time Engine] Starting on :%s (1 vCPU, 1 GiB Cloud Run config)...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Fatal: %v", err)
	}
}
