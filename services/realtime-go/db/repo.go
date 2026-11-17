package db

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// MessageStore defines the interface for chat message persistence operations.
type MessageStore interface {
	SaveMessage(ctx context.Context, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error
	SaveMessageWithID(ctx context.Context, messageID, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error
	GetConversationHistory(ctx context.Context, roomID string, limit, offset int) ([]ChatMessage, error)
	GetUndeliveredMessages(ctx context.Context, roomID string) ([]ChatMessage, error)
	MarkMessageDelivered(ctx context.Context, messageID string) error
	MarkMessageRead(ctx context.Context, messageID string) error
	MessageExists(ctx context.Context, messageID string) (bool, error)
}

// ChatMessage represents a chat message with its persistence fields.
type ChatMessage struct {
	ID          string
	RoomID      string
	SenderID    string
	MessageType string
	RawContent  string
	IsViewOnce  bool
	ScanStatus  string
	IsFlagged   bool
	Status      string
	SentAt      time.Time
	DeliveredAt *time.Time
	ReadAt      *time.Time
	CreatedAt   time.Time
}

// chatMessageDB is the internal database representation.
type chatMessageDB struct {
	ID          string
	RoomID      string
	SenderID    string
	MessageType string
	RawContent  string
	IsViewOnce  bool
	ScanStatus  string
	IsFlagged   bool
	Status      string
	SentAt      time.Time
	DeliveredAt sql.NullTime
	ReadAt      sql.NullTime
	CreatedAt   time.Time
}

// NewMessageStore creates a new PostgreSQL-backed MessageStore.
func NewMessageStore(pool *pgxpool.Pool) MessageStore {
	return &pgMessageStore{pool: pool}
}

// pgMessageStore implements MessageStore using PostgreSQL via pgxpool.
type pgMessageStore struct {
	pool *pgxpool.Pool
}

// SaveMessage persists a new chat message to the database.
func (s *pgMessageStore) SaveMessage(ctx context.Context, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	q := `
		INSERT INTO chat_messages (
			id, room_id, sender_id, message_type, raw_content,
			is_view_once, scan_status, is_flagged,
			status, sent_at, delivered_at, read_at, created_at
		) VALUES (
			gen_random_uuid(), $1, $2, $3, $4,
			$5, $6, $7, $8, now(), NULL, NULL, now()
		)`
	_, err := s.pool.Exec(ctx, q,
		roomID, senderID, messageType, rawContent,
		isViewOnce, scanStatus, isFlagged,
		status,
	)
	if err != nil {
		return fmt.Errorf("failed to save message: %w", err)
	}
	log.Printf("[DB] Saved message from %s to room %s", senderID, roomID)
	return nil
}

// SaveMessageWithID persists a new chat message with a specific ID (for idempotency).
func (s *pgMessageStore) SaveMessageWithID(ctx context.Context, messageID, roomID, senderID, messageType, rawContent string, isViewOnce bool, scanStatus string, isFlagged bool, status string) error {
	if messageID == "" {
		return s.SaveMessage(ctx, roomID, senderID, messageType, rawContent, isViewOnce, scanStatus, isFlagged, status)
	}
	q := `
		INSERT INTO chat_messages (
			id, room_id, sender_id, message_type, raw_content,
			is_view_once, scan_status, is_flagged,
			status, sent_at, delivered_at, read_at, created_at
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9, now(), NULL, NULL, now()
		)
		ON CONFLICT (id) DO NOTHING`
	_, err := s.pool.Exec(ctx, q,
		messageID, roomID, senderID, messageType, rawContent,
		isViewOnce, scanStatus, isFlagged,
		status,
	)
	if err != nil {
		return fmt.Errorf("failed to save message with id: %w", err)
	}
	log.Printf("[DB] Saved message %s from %s to room %s", messageID, senderID, roomID)
	return nil
}

// MessageExists checks if a message with the given ID exists.
func (s *pgMessageStore) MessageExists(ctx context.Context, messageID string) (bool, error) {
	var exists bool
	err := s.pool.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM chat_messages WHERE id = $1)", messageID).Scan(&exists)
	if err != nil {
		return false, err
	}
	return exists, nil
}

// GetConversationHistory retrieves paginated conversation history for a room.
func (s *pgMessageStore) GetConversationHistory(ctx context.Context, roomID string, limit, offset int) ([]ChatMessage, error) {
	q := `
		SELECT id, room_id, sender_id, message_type, raw_content,
			   is_view_once, scan_status, is_flagged,
			   status, sent_at, delivered_at, read_at, created_at
		FROM chat_messages
		WHERE room_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`
	rows, err := s.pool.Query(ctx, q, roomID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to query conversation history: %w", err)
	}
	defer rows.Close()

	var messages []ChatMessage
	for rows.Next() {
		var m chatMessageDB
		var deliveredAt, readAt sql.NullTime
		if err := rows.Scan(
			&m.ID, &m.RoomID, &m.SenderID, &m.MessageType, &m.RawContent,
			&m.IsViewOnce, &m.ScanStatus, &m.IsFlagged,
			&m.Status, &m.SentAt, &deliveredAt, &readAt, &m.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan message: %w", err)
		}

		var deliveredAtPtr, readAtPtr *time.Time
		if deliveredAt.Valid {
			deliveredAtPtr = &deliveredAt.Time
		}
		if readAt.Valid {
			readAtPtr = &readAt.Time
		}

		messages = append(messages, ChatMessage{
			ID:          m.ID,
			RoomID:      m.RoomID,
			SenderID:    m.SenderID,
			MessageType: m.MessageType,
			RawContent:  m.RawContent,
			IsViewOnce:  m.IsViewOnce,
			ScanStatus:  m.ScanStatus,
			IsFlagged:   m.IsFlagged,
			Status:      m.Status,
			SentAt:      m.SentAt,
			DeliveredAt: deliveredAtPtr,
			ReadAt:      readAtPtr,
			CreatedAt:   m.CreatedAt,
		})
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %w", err)
	}
	return messages, nil
}

// GetUndeliveredMessages retrieves messages with status 'sent' that haven't been delivered yet.
func (s *pgMessageStore) GetUndeliveredMessages(ctx context.Context, roomID string) ([]ChatMessage, error) {
	var q string

	if roomID == "" {
		q = `
			SELECT id, room_id, sender_id, message_type, raw_content,
				   is_view_once, scan_status, is_flagged,
				   status, sent_at, delivered_at, read_at, created_at
			FROM chat_messages
			WHERE status = 'sent'
			ORDER BY created_at ASC`
		r, err := s.pool.Query(ctx, q)
		if err != nil {
			return nil, fmt.Errorf("failed to query undelivered messages: %w", err)
		}
		defer r.Close()

		var messages []ChatMessage
		for r.Next() {
			var m chatMessageDB
			var deliveredAt, readAt sql.NullTime
			if err := r.Scan(
				&m.ID, &m.RoomID, &m.SenderID, &m.MessageType, &m.RawContent,
				&m.IsViewOnce, &m.ScanStatus, &m.IsFlagged,
				&m.Status, &m.SentAt, &deliveredAt, &readAt, &m.CreatedAt,
			); err != nil {
				return nil, fmt.Errorf("failed to scan undelivered message: %w", err)
			}

			var deliveredAtPtr, readAtPtr *time.Time
			if deliveredAt.Valid {
				deliveredAtPtr = &deliveredAt.Time
			}
			if readAt.Valid {
				readAtPtr = &readAt.Time
			}

			messages = append(messages, ChatMessage{
				ID:          m.ID,
				RoomID:      m.RoomID,
				SenderID:    m.SenderID,
				MessageType: m.MessageType,
				RawContent:  m.RawContent,
				IsViewOnce:  m.IsViewOnce,
				ScanStatus:  m.ScanStatus,
				IsFlagged:   m.IsFlagged,
				Status:      m.Status,
				SentAt:      m.SentAt,
				DeliveredAt: deliveredAtPtr,
				ReadAt:      readAtPtr,
				CreatedAt:   m.CreatedAt,
			})
		}
		if err := r.Err(); err != nil {
			return nil, fmt.Errorf("row iteration error: %w", err)
		}
		return messages, nil
	}

	q = `
		SELECT id, room_id, sender_id, message_type, raw_content,
			   is_view_once, scan_status, is_flagged,
			   status, sent_at, delivered_at, read_at, created_at
		FROM chat_messages
		WHERE room_id = $1 AND status = 'sent'
		ORDER BY created_at ASC`
	r, err := s.pool.Query(ctx, q, roomID)
	if err != nil {
		return nil, fmt.Errorf("failed to query undelivered messages: %w", err)
	}
	defer r.Close()

	var messages []ChatMessage
	for r.Next() {
		var m chatMessageDB
		var deliveredAt, readAt sql.NullTime
		if err := r.Scan(
			&m.ID, &m.RoomID, &m.SenderID, &m.MessageType, &m.RawContent,
			&m.IsViewOnce, &m.ScanStatus, &m.IsFlagged,
			&m.Status, &m.SentAt, &deliveredAt, &readAt, &m.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan undelivered message: %w", err)
		}

		var deliveredAtPtr, readAtPtr *time.Time
		if deliveredAt.Valid {
			deliveredAtPtr = &deliveredAt.Time
		}
		if readAt.Valid {
			readAtPtr = &readAt.Time
		}

		messages = append(messages, ChatMessage{
			ID:          m.ID,
			RoomID:      m.RoomID,
			SenderID:    m.SenderID,
			MessageType: m.MessageType,
			RawContent:  m.RawContent,
			IsViewOnce:  m.IsViewOnce,
			ScanStatus:  m.ScanStatus,
			IsFlagged:   m.IsFlagged,
			Status:      m.Status,
			SentAt:      m.SentAt,
			DeliveredAt: deliveredAtPtr,
			ReadAt:      readAtPtr,
			CreatedAt:   m.CreatedAt,
		})
	}
	if err := r.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %w", err)
	}
	return messages, nil
}

// MarkMessageDelivered updates a message's status to 'delivered' and sets delivered_at timestamp.
func (s *pgMessageStore) MarkMessageDelivered(ctx context.Context, messageID string) error {
	q := `UPDATE chat_messages SET status = 'delivered', delivered_at = now() WHERE id = $1 AND status = 'sent'`
	result, err := s.pool.Exec(ctx, q, messageID)
	if err != nil {
		return fmt.Errorf("failed to mark message delivered: %w", err)
	}
	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.New("message not found or already processed")
	}
	log.Printf("[DB] Marked message %s as delivered", messageID)
	return nil
}

// MarkMessageRead updates a message's status to 'read' and sets read_at timestamp.
func (s *pgMessageStore) MarkMessageRead(ctx context.Context, messageID string) error {
	q := `UPDATE chat_messages SET status = 'read', read_at = now() WHERE id = $1 AND status IN ('sent', 'delivered')`
	result, err := s.pool.Exec(ctx, q, messageID)
	if err != nil {
		return fmt.Errorf("failed to mark message read: %w", err)
	}
	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.New("message not found or already processed")
	}
	log.Printf("[DB] Marked message %s as read", messageID)
	return nil
}
