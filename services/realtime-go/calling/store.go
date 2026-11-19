package calling

import (
	"context"
	"database/sql"
	"fmt"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// CallStore defines persistence operations for active and historical call sessions.
type CallStore interface {
	CreateCall(ctx context.Context, call *CallSession) error
	GetCallByID(ctx context.Context, callID string) (*CallSession, error)
	GetCallByRoom(ctx context.Context, roomName string) (*CallSession, error)
	UpdateCallStatus(ctx context.Context, callID, status string) error
	EndCall(ctx context.Context, callID, status string, durationSeconds int) error
}

// MemoryCallStore provides an in-memory thread-safe implementation.
type MemoryCallStore struct {
	mu     sync.RWMutex
	byID   map[string]*CallSession
	byRoom map[string]*CallSession
}

// NewMemoryCallStore initializes a new in-memory call store.
func NewMemoryCallStore() *MemoryCallStore {
	return &MemoryCallStore{
		byID:   make(map[string]*CallSession),
		byRoom: make(map[string]*CallSession),
	}
}

func (m *MemoryCallStore) CreateCall(_ context.Context, call *CallSession) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	copyCall := *call
	m.byID[call.ID] = &copyCall
	m.byRoom[call.LiveKitRoomName] = &copyCall
	return nil
}

func (m *MemoryCallStore) GetCallByID(_ context.Context, callID string) (*CallSession, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	call, ok := m.byID[callID]
	if !ok {
		return nil, ErrCallNotFound
	}
	copyCall := *call
	return &copyCall, nil
}

func (m *MemoryCallStore) GetCallByRoom(_ context.Context, roomName string) (*CallSession, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	call, ok := m.byRoom[roomName]
	if !ok {
		return nil, ErrCallNotFound
	}
	copyCall := *call
	return &copyCall, nil
}

func (m *MemoryCallStore) UpdateCallStatus(_ context.Context, callID, status string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	call, ok := m.byID[callID]
	if !ok {
		return ErrCallNotFound
	}
	call.Status = status
	if status == "active" && call.StartedAt == nil {
		now := time.Now().UTC()
		call.StartedAt = &now
	}
	return nil
}

func (m *MemoryCallStore) EndCall(_ context.Context, callID, status string, durationSeconds int) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	call, ok := m.byID[callID]
	if !ok {
		return ErrCallNotFound
	}
	call.Status = status
	call.DurationSeconds = durationSeconds
	now := time.Now().UTC()
	call.EndedAt = &now
	return nil
}

// PostgresCallStore persists call sessions into Supabase PostgreSQL.
type PostgresCallStore struct {
	pool     *pgxpool.Pool
	fallback *MemoryCallStore
}

// NewPostgresCallStore creates a store backed by pgxpool with in-memory fallback.
func NewPostgresCallStore(pool *pgxpool.Pool) *PostgresCallStore {
	return &PostgresCallStore{
		pool:     pool,
		fallback: NewMemoryCallStore(),
	}
}

// NewCallStore returns PostgresCallStore when pool is available, else MemoryCallStore.
func NewCallStore(pool *pgxpool.Pool) CallStore {
	if pool != nil {
		return NewPostgresCallStore(pool)
	}
	return NewMemoryCallStore()
}

func (p *PostgresCallStore) CreateCall(ctx context.Context, call *CallSession) error {
	// Always cache in memory as well
	_ = p.fallback.CreateCall(ctx, call)

	if p.pool == nil {
		return nil
	}

	query := `
		INSERT INTO call_sessions (
			id, livekit_room_name, caller_user_id, callee_user_id, match_id,
			call_type, is_random_blind_call, status,
			caller_coins_type, caller_coins, callee_coins_type, callee_coins, created_at
		) VALUES (
			$1, $2, $3, $4, NULLIF($5, '')::uuid,
			$6, false, $7,
			'daily_free_calls', 0, 'daily_free_calls', 0, now()
		)
		ON CONFLICT (id) DO UPDATE SET
			status = EXCLUDED.status,
			livekit_room_name = EXCLUDED.livekit_room_name;
	`
	_, err := p.pool.Exec(ctx, query,
		call.ID,
		call.LiveKitRoomName,
		call.CallerUserID,
		call.CalleeUserID,
		call.MatchID,
		call.CallType,
		call.Status,
	)
	if err != nil {
		// Log warning but allow call to proceed with memory store
		return fmt.Errorf("postgres call session insert notice: %w", err)
	}
	return nil
}

func (p *PostgresCallStore) GetCallByID(ctx context.Context, callID string) (*CallSession, error) {
	if p.pool == nil {
		return p.fallback.GetCallByID(ctx, callID)
	}

	query := `
		SELECT id, livekit_room_name, caller_user_id, callee_user_id, COALESCE(match_id::text, ''),
		       call_type, status, duration_seconds, started_at, ended_at, created_at
		FROM call_sessions
		WHERE id::text = $1
		LIMIT 1;
	`
	row := p.pool.QueryRow(ctx, query, callID)

	var s CallSession
	var matchID string
	var startedAt, endedAt sql.NullTime

	err := row.Scan(
		&s.ID,
		&s.LiveKitRoomName,
		&s.CallerUserID,
		&s.CalleeUserID,
		&matchID,
		&s.CallType,
		&s.Status,
		&s.DurationSeconds,
		&startedAt,
		&endedAt,
		&s.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			// Try fallback
			return p.fallback.GetCallByID(ctx, callID)
		}
		return nil, err
	}

	s.MatchID = matchID
	if startedAt.Valid {
		s.StartedAt = &startedAt.Time
	}
	if endedAt.Valid {
		s.EndedAt = &endedAt.Time
	}
	return &s, nil
}

func (p *PostgresCallStore) GetCallByRoom(ctx context.Context, roomName string) (*CallSession, error) {
	if p.pool == nil {
		return p.fallback.GetCallByRoom(ctx, roomName)
	}

	query := `
		SELECT id, livekit_room_name, caller_user_id, callee_user_id, COALESCE(match_id::text, ''),
		       call_type, status, duration_seconds, started_at, ended_at, created_at
		FROM call_sessions
		WHERE livekit_room_name = $1
		LIMIT 1;
	`
	row := p.pool.QueryRow(ctx, query, roomName)

	var s CallSession
	var matchID string
	var startedAt, endedAt sql.NullTime

	err := row.Scan(
		&s.ID,
		&s.LiveKitRoomName,
		&s.CallerUserID,
		&s.CalleeUserID,
		&matchID,
		&s.CallType,
		&s.Status,
		&s.DurationSeconds,
		&startedAt,
		&endedAt,
		&s.CreatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return p.fallback.GetCallByRoom(ctx, roomName)
		}
		return nil, err
	}

	s.MatchID = matchID
	if startedAt.Valid {
		s.StartedAt = &startedAt.Time
	}
	if endedAt.Valid {
		s.EndedAt = &endedAt.Time
	}
	return &s, nil
}

func (p *PostgresCallStore) UpdateCallStatus(ctx context.Context, callID, status string) error {
	_ = p.fallback.UpdateCallStatus(ctx, callID, status)
	if p.pool == nil {
		return nil
	}

	query := `
		UPDATE call_sessions
		SET status = $2,
		    started_at = CASE WHEN $2 = 'active' AND started_at IS NULL THEN now() ELSE started_at END
		WHERE id::text = $1;
	`
	_, err := p.pool.Exec(ctx, query, callID, status)
	return err
}

func (p *PostgresCallStore) EndCall(ctx context.Context, callID, status string, durationSeconds int) error {
	_ = p.fallback.EndCall(ctx, callID, status, durationSeconds)
	if p.pool == nil {
		return nil
	}

	query := `
		UPDATE call_sessions
		SET status = $2,
		    duration_seconds = $3,
		    ended_at = now()
		WHERE id::text = $1;
	`
	_, err := p.pool.Exec(ctx, query, callID, status, durationSeconds)
	return err
}
