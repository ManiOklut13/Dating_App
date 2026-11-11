package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"younme/realtime/guard"
	"younme/realtime/hub"

	"github.com/gorilla/websocket"
	_ "github.com/lib/pq"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow cross-origin for client dev, Flutter, and staging
	},
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

// SupabaseJWTClaims holds identity extracted from validated Supabase Auth token
type SupabaseJWTClaims struct {
	Sub   string `json:"sub"`   // Supabase Auth UID -> app_users.authentication_uid
	Email string `json:"email"`
	Role  string `json:"role"`
	Exp   int64  `json:"exp"`
}

// VerifySupabaseJWT performs stateless verification of the Supabase JWT token
func VerifySupabaseJWT(tokenString string, secret string) (*SupabaseJWTClaims, error) {
	parts := strings.Split(tokenString, ".")
	if len(parts) != 3 {
		return nil, errors.New("malformed JWT: expected 3 parts")
	}

	headerB64, payloadB64, signatureB64 := parts[0], parts[1], parts[2]

	// Decode payload
	payloadBytes, err := base64.RawURLEncoding.DecodeString(payloadB64)
	if err != nil {
		return nil, fmt.Errorf("failed to decode JWT payload: %w", err)
	}

	var claims SupabaseJWTClaims
	if err := json.Unmarshal(payloadBytes, &claims); err != nil {
		return nil, fmt.Errorf("failed to parse JWT claims JSON: %w", err)
	}

	// Verify expiration
	if claims.Exp > 0 && time.Now().Unix() > claims.Exp {
		return nil, errors.New("supabase token has expired")
	}

	// If Supabase JWT Secret is provided, verify HMAC-SHA256 signature
	if secret != "" {
		mac := hmac.New(sha256.New, []byte(secret))
		mac.Write([]byte(headerB64 + "." + payloadB64))
		expectedSig := mac.Sum(nil)

		actualSig, err := base64.RawURLEncoding.DecodeString(signatureB64)
		if err != nil {
			return nil, fmt.Errorf("failed to decode signature: %w", err)
		}

		if !hmac.Equal(actualSig, expectedSig) {
			return nil, errors.New("supabase JWT signature mismatch")
		}
	}

	if claims.Sub == "" {
		return nil, errors.New("token missing required 'sub' claim")
	}

	return &claims, nil
}

// Global PostgreSQL database connection pool
var dbConn *sql.DB

func initDB() {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Println("[Go Real-Time Engine] No DATABASE_URL specified. Running in in-memory relay mode.")
		return
	}

	var err error
	dbConn, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Printf("[Go Real-Time Engine] Failed to open PostgreSQL connection: %v", err)
		return
	}

	dbConn.SetMaxOpenConns(25)
	dbConn.SetMaxIdleConns(5)
	dbConn.SetConnMaxLifetime(5 * time.Minute)

	if err := dbConn.Ping(); err != nil {
		log.Printf("[Go Real-Time Engine] PostgreSQL ping notice: %v", err)
	} else {
		log.Println("[Go Real-Time Engine] Connected to PostgreSQL system of record successfully.")
	}
}

// persistChatMessage stores validated clean chat messages in the chat_messages table
func persistChatMessage(roomID string, senderID string, content string) {
	if dbConn == nil {
		return
	}

	query := `
		INSERT INTO chat_messages (
			id, room_id, sender_id, message_type, raw_content, scan_status, status, created_at
		) VALUES (
			gen_random_uuid(), $1, (
				SELECT id FROM app_users WHERE authentication_uid = $2 OR id::text = $2 LIMIT 1
			), 'text', $3, 'clean', 'sent', now()
		)`

	go func() {
		_, err := dbConn.Exec(query, roomID, senderID, content)
		if err != nil {
			log.Printf("[Go Real-Time Engine] Failed to persist message to chat_messages: %v", err)
		}
	}()
}

func handleWebSocket(h *hub.Hub, w http.ResponseWriter, r *http.Request) {
	jwtSecret := os.Getenv("SUPABASE_JWT_SECRET")

	// 1. Extract token from query params or Authorization header
	token := r.URL.Query().Get("token")
	if token == "" {
		authHeader := r.Header.Get("Authorization")
		if strings.HasPrefix(authHeader, "Bearer ") {
			token = strings.TrimPrefix(authHeader, "Bearer ")
		}
	}

	var userId string

	// 2. Validate Supabase JWT token upon WebSocket handshake
	if token != "" {
		claims, err := VerifySupabaseJWT(token, jwtSecret)
		if err != nil {
			log.Printf("[Go Real-Time Engine] WebSocket handshake rejected: %v", err)
			http.Error(w, fmt.Sprintf("Unauthorized: %v", err), http.StatusUnauthorized)
			return
		}
		userId = claims.Sub
		log.Printf("[Go Real-Time Engine] Verified Supabase Auth UID: %s (%s)", claims.Sub, claims.Email)
	} else {
		// Fallback for dev / unauthenticated queries
		devUserId := r.URL.Query().Get("user_id")
		if devUserId != "" {
			userId = devUserId
			log.Printf("[Go Real-Time Engine] DEV Mode: Using unverified user_id parameter: %s", userId)
		} else {
			userId = "anonymous_" + fmt.Sprintf("%d", time.Now().UnixNano()%10000)
		}
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("[Go Real-Time Engine] Upgrade error:", err)
		return
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
					roomID, _ := payloadMap["room_id"].(string)
					if roomID == "" {
						roomID = strings.TrimPrefix(incoming.Channel, "chat:")
					}

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

					// Message is clean: persist to PostgreSQL database chat_messages
					persistChatMessage(roomID, client.UserID, body)

					// Message allowed, broadcast to channel subscribers
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

	initDB()

	h := hub.NewHub()
	go h.Run()

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"healthy","service":"realtime-go","auth":"Supabase JWT","runtime":"GCP Cloud Run asia-south1"}`))
	})

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		handleWebSocket(h, w, r)
	})

	log.Printf("[Go Real-Time Engine] Starting on :%s (Supabase JWT auth & PostGIS DB ready)...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Fatal: %v", err)
	}
}
