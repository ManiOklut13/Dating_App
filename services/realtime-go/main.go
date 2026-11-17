package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"younme/realtime/auth"
	"younme/realtime/config"
	"younme/realtime/db"
	"younme/realtime/hub"

	"github.com/gorilla/websocket"
)

var startTime = time.Now()

// BuildUpgrader creates a Gorilla WebSocket upgrader respecting allowed origins.
func BuildUpgrader(allowedOrigins []string) websocket.Upgrader {
	return websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			if len(allowedOrigins) == 0 {
				return true // Permissive in dev / staging
			}
			origin := r.Header.Get("Origin")
			for _, allowed := range allowedOrigins {
				if allowed == "*" || allowed == origin {
					return true
				}
			}
			return false
		},
	}
}

// ExtractToken retrieves the authentication token from query params or Authorization header.
func ExtractToken(r *http.Request) string {
	// 1. Check query parameter ?token= or ?access_token=
	if t := r.URL.Query().Get("token"); strings.TrimSpace(t) != "" {
		return strings.TrimSpace(t)
	}
	if t := r.URL.Query().Get("access_token"); strings.TrimSpace(t) != "" {
		return strings.TrimSpace(t)
	}

	// 2. Check Authorization: Bearer <token> header
	authHeader := r.Header.Get("Authorization")
	if strings.HasPrefix(strings.ToLower(authHeader), "bearer ") {
		return strings.TrimSpace(authHeader[7:])
	}

	// 3. Check Sec-WebSocket-Protocol header fallback
	if subproto := r.Header.Get("Sec-WebSocket-Protocol"); subproto != "" {
		parts := strings.Split(subproto, ",")
		if len(parts) > 0 && strings.TrimSpace(parts[0]) != "" {
			return strings.TrimSpace(parts[0])
		}
	}

	return ""
}

// SetupRouter constructs the HTTP handler for health checks and authenticated WebSockets.
func SetupRouter(cfg *config.Config, verifier auth.TokenVerifier, h *hub.Hub) http.Handler {
	upgrader := BuildUpgrader(cfg.AllowedOrigins)
	mux := http.NewServeMux()

	// GET /health
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, `{"error":"Method Not Allowed"}`, http.StatusMethodNotAllowed)
			return
		}

		activeConns, activeUsers := h.GetStats()
		uptimeSecs := int64(time.Since(startTime).Seconds())

		response := map[string]interface{}{
			"status":             "healthy",
			"service":            "realtime-go",
			"uptime_seconds":     uptimeSecs,
			"active_connections": activeConns,
			"active_users":       activeUsers,
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(response)
	})

	// POST /v1/date-invitation - NestJS notifies Go of date invitation creation/status
	// This endpoint is authenticated via Supabase access token
	// Body expects JSON with: event, invitation_id, match_id, proposer_id, recipient_id, status
	// Optional: date_mode, date_type, scheduled_at, message
	mux.HandleFunc("/v1/date-invitation", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, `{"error":"Method Not Allowed"}`, http.StatusMethodNotAllowed)
			return
		}

		// Verify authentication token
		token := ExtractToken(r)
		if token == "" {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Missing authentication token",
			})
			return
		}

		if verifier == nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Supabase authentication is not configured on the server.",
			})
			return
		}

		userInfo, err := verifier.VerifyToken(r.Context(), token)
		if err != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Invalid or expired authentication token",
			})
			return
		}

		// Only authenticated users can notify Go of date invitations
		if userInfo.Role != "authenticated" {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusForbidden)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Forbidden",
				"message": "Only authenticated users can send date invitation notifications",
			})
			return
		}

		// Parse the invitation event payload
		var dateInvite struct {
			Event         string `json:"event"`
			InvitationID  string `json:"invitation_id"`
			MatchID       string `json:"match_id"`
			ProposerID    string `json:"proposer_id"`
			RecipientID   string `json:"recipient_id"`
			Status        string `json:"status"`
			DateMode      string `json:"date_mode"`
			DateType      string `json:"date_type"`
			ScheduledAt   string `json:"scheduled_at"`
			Message       string `json:"message"`
		}

		if err := json.NewDecoder(r.Body).Decode(&dateInvite); err != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Bad Request",
				"message": "Invalid payload format",
			})
			return
		}

		// Validate required fields based on event type
		switch dateInvite.Event {
		case "created":
			if dateInvite.ProposerID == "" || dateInvite.RecipientID == "" || dateInvite.MatchID == "" {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusBadRequest)
				_ = json.NewEncoder(w).Encode(map[string]string{
					"error":   "Bad Request",
					"message": "Created event requires proposer_id, recipient_id, and match_id",
				})
				return
			}
			// Deliver date invitation to recipient via WebSocket
			invite := hub.DateInvitePayload{
				InvitationID: dateInvite.InvitationID,
				MatchID:      dateInvite.MatchID,
				ProposerID:   dateInvite.ProposerID,
				RecipientID:  dateInvite.RecipientID,
				DateMode:     dateInvite.DateMode,
				DateType:     dateInvite.DateType,
				ScheduledAt:  dateInvite.ScheduledAt,
				Message:      dateInvite.Message,
			}
			outbound := hub.OutboundMessage{
				Event:   hub.EventDateInvitation,
				FromUID: dateInvite.ProposerID,
				Payload: invite,
			}
			h.SendToUser(dateInvite.RecipientID, outbound)
		case "accepted":
			// Acknowledge acceptance - could update UI status, etc.
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"status": "ok",
				"message": "Date invitation accepted",
			})
		case "declined":
			// Acknowledge decline - could update UI status, etc.
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"status": "ok",
				"message": "Date invitation declined",
			})
		default:
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Bad Request",
				"message": "Unknown event type: " + dateInvite.Event,
			})
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status": "ok",
			"message": "Date invitation processed",
		})
	})

	// GET /ws (WebSocket endpoint with Supabase token authentication)
	mux.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, `{"error":"Method Not Allowed"}`, http.StatusMethodNotAllowed)
			return
		}

		// Security Check: Verify authentication token before upgrading
		token := ExtractToken(r)
		if token == "" {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Missing authentication token. Provide ?token=<supabase_access_token> or Authorization header.",
			})
			return
		}

		if verifier == nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Supabase authentication is not configured on the server. Configure SUPABASE_URL (and/or SUPABASE_JWT_SECRET).",
			})
			return
		}

		userInfo, err := verifier.VerifyToken(r.Context(), token)
		if err != nil {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			_ = json.NewEncoder(w).Encode(map[string]string{
				"error":   "Unauthorized",
				"message": "Invalid or expired authentication token",
			})
			return
		}

		// Strictly derive the user's identity from the verified access token
		verifiedUserID := userInfo.ID

		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.Printf("[WebSocket] Upgrade handshake error: %v", err)
			return
		}

		sessionID := fmt.Sprintf("%s-%d", r.RemoteAddr, time.Now().UnixNano())
		client := hub.NewClient(sessionID, verifiedUserID, conn, h)

		// Safely register client with Hub
		h.Register(client)

		// Start dedicated reader and writer pump goroutines
		go client.WritePump()
		go client.ReadPump()
	})

	return WithCORS(mux, cfg.AllowedOrigins)
}

// WithCORS wraps an http.Handler with CORS headers supporting frontend dev/prod origins.
func WithCORS(next http.Handler, allowedOrigins []string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		allow := false

		if len(allowedOrigins) == 0 {
			// Permissive in dev: allow request origin or wildcard
			allow = true
		} else {
			for _, o := range allowedOrigins {
				if o == "*" || o == origin {
					allow = true
					break
				}
			}
		}

		if allow && origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With, apikey, Sec-WebSocket-Protocol")
			w.Header().Set("Access-Control-Allow-Credentials", "true")
		} else if allow && origin == "" {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	cfg := config.Load()

	// Initialize PostgreSQL connection pool
	pool, err := newPgxPool(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("[Go Real-Time Engine] Failed to create database connection pool: %v", err)
	}
	defer pool.Close()

	// Initialize Supabase Authentication
	var verifier auth.TokenVerifier
	supabaseVerifier, err := auth.NewSupabaseVerifier(cfg)
	if err != nil {
		log.Printf("[Go Real-Time Engine] WARNING: Supabase authentication not initialized (%v).", err)
		log.Println("[Go Real-Time Engine] NOTICE: WebSocket connections will require valid credentials to verify tokens.")
	} else {
		verifier = supabaseVerifier
		log.Println("[Go Real-Time Engine] Supabase access-token verifier initialized successfully.")
	}

	// Initialize DB repository
	dbRepo := db.NewMessageStore(pool)

	h := hub.NewHub(pool, dbRepo)
	router := SetupRouter(cfg, verifier, h)

	server := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           router,
		ReadHeaderTimeout: 10 * time.Second,
	}

	// Graceful shutdown handling
	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, os.Interrupt, syscall.SIGTERM)

	go func() {
		log.Printf("[Go Real-Time Engine] Starting on :%s (PID: %d)...", cfg.Port, os.Getpid())
		log.Printf("[Go Real-Time Engine] WebSocket Endpoint: ws://localhost:%s/ws", cfg.Port)
		log.Printf("[Go Real-Time Engine] Health Check: http://localhost:%s/health", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("[Go Real-Time Engine] Server failed to start: %v", err)
		}
	}()

	<-stopChan
	log.Println("[Go Real-Time Engine] Received shutdown signal. Gracefully shutting down...")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("[Go Real-Time Engine] Error during server shutdown: %v", err)
	}

	log.Println("[Go Real-Time Engine] Server stopped gracefully.")
}

// newPgxPool creates a PostgreSQL connection pool from the DATABASE_URL.
func newPgxPool(databaseURL string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, err
	}
	pool, err := pgxpool.NewWithConfig(context.Background(), cfg)
	if err != nil {
		return nil, err
	}
	return pool, nil
}