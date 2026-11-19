package calling

import (
	"context"
	"errors"
	"net/http"
	"time"

	"github.com/livekit/protocol/auth"
	"github.com/livekit/protocol/livekit"
	"github.com/livekit/protocol/webhook"
	lksdk "github.com/livekit/server-sdk-go/v2"
)

// LiveKitClient encapsulates LiveKit Cloud operations and token issuance.
type LiveKitClient interface {
	CreateToken(roomName, identity, name string, canPublish, canSubscribe bool, ttl time.Duration) (string, error)
	CreateRoom(ctx context.Context, roomName string, emptyTimeout uint32, maxParticipants uint32) (*livekit.Room, error)
	DeleteRoom(ctx context.Context, roomName string) error
	RemoveParticipant(ctx context.Context, roomName, identity string) error
	ListParticipants(ctx context.Context, roomName string) ([]*livekit.ParticipantInfo, error)
	ReceiveWebhook(r *http.Request) (*livekit.WebhookEvent, error)
}

type livekitClientImpl struct {
	apiKey     string
	apiSecret  string
	url        string
	roomClient *lksdk.RoomServiceClient
	keyProv    auth.KeyProvider
}

// NewLiveKitClient creates a production LiveKit client using official Server SDK v2.
func NewLiveKitClient(livekitURL, apiKey, apiSecret string) (LiveKitClient, error) {
	if apiKey == "" || apiSecret == "" {
		return nil, errors.New("livekit api key and secret are required")
	}

	roomClient := lksdk.NewRoomServiceClient(livekitURL, apiKey, apiSecret)
	keyProv := auth.NewSimpleKeyProvider(apiKey, apiSecret)

	return &livekitClientImpl{
		apiKey:     apiKey,
		apiSecret:  apiSecret,
		url:        livekitURL,
		roomClient: roomClient,
		keyProv:    keyProv,
	}, nil
}

// CreateToken generates a signed LiveKit JWT access token with room join permissions.
func (c *livekitClientImpl) CreateToken(roomName, identity, name string, canPublish, canSubscribe bool, ttl time.Duration) (string, error) {
	if ttl <= 0 {
		ttl = 10 * time.Minute
	}

	at := auth.NewAccessToken(c.apiKey, c.apiSecret)
	grant := &auth.VideoGrant{
		Room:     roomName,
		RoomJoin: true,
	}
	grant.SetCanPublish(canPublish)
	grant.SetCanSubscribe(canSubscribe)
	grant.SetCanPublishData(true)

	at.AddGrant(grant).
		SetIdentity(identity).
		SetName(name).
		SetValidFor(ttl)

	return at.ToJWT()
}

// CreateRoom explicitly provisions a LiveKit room with specified parameters.
func (c *livekitClientImpl) CreateRoom(ctx context.Context, roomName string, emptyTimeout uint32, maxParticipants uint32) (*livekit.Room, error) {
	if emptyTimeout == 0 {
		emptyTimeout = 300 // 5 minutes empty timeout
	}
	if maxParticipants == 0 {
		maxParticipants = 2 // Default 1-on-1 dating call
	}

	req := &livekit.CreateRoomRequest{
		Name:            roomName,
		EmptyTimeout:    emptyTimeout,
		MaxParticipants: maxParticipants,
	}

	return c.roomClient.CreateRoom(ctx, req)
}

// DeleteRoom terminates an active room on LiveKit Cloud.
func (c *livekitClientImpl) DeleteRoom(ctx context.Context, roomName string) error {
	req := &livekit.DeleteRoomRequest{
		Room: roomName,
	}
	_, err := c.roomClient.DeleteRoom(ctx, req)
	return err
}

// RemoveParticipant forcefully disconnects a participant from a room.
func (c *livekitClientImpl) RemoveParticipant(ctx context.Context, roomName, identity string) error {
	req := &livekit.RoomParticipantIdentity{
		Room:     roomName,
		Identity: identity,
	}
	_, err := c.roomClient.RemoveParticipant(ctx, req)
	return err
}

// ListParticipants returns all active participants in a room.
func (c *livekitClientImpl) ListParticipants(ctx context.Context, roomName string) ([]*livekit.ParticipantInfo, error) {
	req := &livekit.ListParticipantsRequest{
		Room: roomName,
	}
	res, err := c.roomClient.ListParticipants(ctx, req)
	if err != nil {
		return nil, err
	}
	return res.Participants, nil
}

// ReceiveWebhook validates the cryptographic signature of an incoming LiveKit Cloud webhook.
func (c *livekitClientImpl) ReceiveWebhook(r *http.Request) (*livekit.WebhookEvent, error) {
	return webhook.ReceiveWebhookEvent(r, c.keyProv)
}
