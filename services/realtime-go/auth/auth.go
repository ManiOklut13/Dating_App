package auth

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math/big"
	"net/http"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"younme/realtime/config"
)

var (
	// ErrMissingToken occurs when no authentication token was supplied.
	ErrMissingToken = errors.New("authentication token is missing")

	// ErrInvalidToken occurs when the provided token fails signature verification,
	// has an unknown kid, unsupported algorithm, malformed structure, or invalid issuer.
	ErrInvalidToken = errors.New("authentication token is invalid")

	// ErrExpiredToken occurs when the token's lifetime has lapsed.
	ErrExpiredToken = errors.New("authentication token has expired")

	// ErrInvalidRole occurs when a validly signed token is not a user session
	// (for example the public anon API key or the service_role API key).
	ErrInvalidRole = errors.New("authentication token is not an authenticated user token")

	// ErrNotConfigured occurs when Supabase authentication is not configured.
	ErrNotConfigured = errors.New("supabase authentication is not configured")
)

// UserInfo represents the verified identity derived from a Supabase access token.
type UserInfo struct {
	// ID is the Supabase auth.users.id (UUID). Replaces the Firebase UID.
	ID          string `json:"id"`
	Email       string `json:"email,omitempty"`
	PhoneNumber string `json:"phone_number,omitempty"`
	Role        string `json:"role,omitempty"`
	SessionID   string `json:"session_id,omitempty"`
}

// TokenVerifier defines the interface for validating user identity tokens.
type TokenVerifier interface {
	VerifyToken(ctx context.Context, accessToken string) (*UserInfo, error)
}

type jwkKey struct {
	Kty string `json:"kty"`
	Crv string `json:"crv"`
	X   string `json:"x"`
	Y   string `json:"y"`
	Kid string `json:"kid"`
	Alg string `json:"alg"`
	Use string `json:"use"`
}

type jwksResponse struct {
	Keys []jwkKey `json:"keys"`
}

type jwksCache struct {
	mu          sync.RWMutex
	keys        map[string]*ecdsa.PublicKey
	fetchedAt   time.Time
	ttl         time.Duration
	minInterval time.Duration
	httpClient  *http.Client
	jwksURL     string
}

func decodeBase64URL(raw string) ([]byte, error) {
	raw = strings.TrimRight(strings.TrimSpace(raw), "=")
	if raw == "" {
		return nil, errors.New("empty base64 string")
	}
	b, err := base64.RawURLEncoding.DecodeString(raw)
	if err != nil {
		b, err = base64.RawStdEncoding.DecodeString(raw)
	}
	return b, err
}

func parseECPublicKey(xStr, yStr string) (*ecdsa.PublicKey, error) {
	xBytes, err := decodeBase64URL(xStr)
	if err != nil {
		return nil, fmt.Errorf("invalid x coordinate: %w", err)
	}
	yBytes, err := decodeBase64URL(yStr)
	if err != nil {
		return nil, fmt.Errorf("invalid y coordinate: %w", err)
	}

	curve := elliptic.P256()
	x := new(big.Int).SetBytes(xBytes)
	y := new(big.Int).SetBytes(yBytes)

	if !curve.IsOnCurve(x, y) {
		return nil, errors.New("jwk EC point is not on curve P-256")
	}

	return &ecdsa.PublicKey{
		Curve: curve,
		X:     x,
		Y:     y,
	}, nil
}

func (c *jwksCache) GetKey(ctx context.Context, kid string) (*ecdsa.PublicKey, error) {
	if strings.TrimSpace(kid) == "" {
		return nil, errors.New("empty key id (kid)")
	}

	c.mu.RLock()
	key, ok := c.keys[kid]
	isFresh := time.Since(c.fetchedAt) < c.ttl
	c.mu.RUnlock()

	if ok && isFresh {
		return key, nil
	}

	c.mu.Lock()
	defer c.mu.Unlock()

	// Double check under write lock
	if key, ok := c.keys[kid]; ok && time.Since(c.fetchedAt) < c.ttl {
		return key, nil
	}

	// Rate limit fetches for unknown kids to protect the JWKS endpoint
	if time.Since(c.fetchedAt) < c.minInterval && len(c.keys) > 0 {
		if key, ok := c.keys[kid]; ok {
			return key, nil
		}
		return nil, fmt.Errorf("key id %q not found in JWKS", kid)
	}

	if err := c.refreshLocked(ctx); err != nil {
		if key, ok := c.keys[kid]; ok {
			return key, nil
		}
		return nil, fmt.Errorf("failed to fetch JWKS: %w", err)
	}

	key, ok = c.keys[kid]
	if !ok {
		return nil, fmt.Errorf("key id %q not found in JWKS", kid)
	}
	return key, nil
}

func (c *jwksCache) refreshLocked(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.jwksURL, nil)
	if err != nil {
		return fmt.Errorf("failed to create JWKS request: %w", err)
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "younme-realtime/1.0")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to fetch JWKS from %s: %w", c.jwksURL, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("JWKS endpoint %s returned status %d", c.jwksURL, resp.StatusCode)
	}

	var jwks jwksResponse
	limited := io.LimitReader(resp.Body, 1024*1024)
	if err := json.NewDecoder(limited).Decode(&jwks); err != nil {
		return fmt.Errorf("failed to decode JWKS JSON: %w", err)
	}

	newKeys := make(map[string]*ecdsa.PublicKey, len(jwks.Keys))
	for _, k := range jwks.Keys {
		if k.Kid == "" {
			continue
		}
		if k.Kty != "EC" || (k.Crv != "" && k.Crv != "P-256") {
			continue
		}
		if k.Alg != "" && k.Alg != "ES256" {
			continue
		}
		if k.Use != "" && k.Use != "sig" {
			continue
		}
		pubKey, err := parseECPublicKey(k.X, k.Y)
		if err != nil {
			continue
		}
		newKeys[k.Kid] = pubKey
	}

	if len(newKeys) == 0 {
		return errors.New("no valid ES256 P-256 public keys found in JWKS response")
	}

	c.keys = newKeys
	c.fetchedAt = time.Now()
	return nil
}

// SupabaseVerifier validates Supabase (GoTrue) access tokens.
//
// Modern Supabase tokens are ES256-signed and verified via public keys retrieved
// from the project's JWKS endpoint (<SUPABASE_URL>/auth/v1/.well-known/jwks.json).
// Legacy HS256 tokens signed with SUPABASE_JWT_SECRET are also supported when enabled.
type SupabaseVerifier struct {
	supabaseURL        string
	projectRef         string
	requiredRole       string
	es256Enabled       bool
	legacyHS256Enabled bool
	jwtSecret          []byte
	validMethods       []string
	jwksCache          *jwksCache
}

// VerifierOption configures optional behavior of SupabaseVerifier.
type VerifierOption func(*SupabaseVerifier)

// WithHTTPClient allows setting a custom HTTP client for JWKS fetching.
func WithHTTPClient(client *http.Client) VerifierOption {
	return func(v *SupabaseVerifier) {
		if client != nil && v.jwksCache != nil {
			v.jwksCache.httpClient = client
		}
	}
}

// WithJWKSCacheTTL configures cache expiration and rate-limiting cooldown for JWKS.
func WithJWKSCacheTTL(ttl, minInterval time.Duration) VerifierOption {
	return func(v *SupabaseVerifier) {
		if v.jwksCache != nil {
			v.jwksCache.ttl = ttl
			v.jwksCache.minInterval = minInterval
		}
	}
}

// NewSupabaseVerifier builds a verifier from the Supabase configuration.
func NewSupabaseVerifier(cfg *config.Config, opts ...VerifierOption) (*SupabaseVerifier, error) {
	if cfg == nil {
		return nil, fmt.Errorf("%w: configuration is nil", ErrNotConfigured)
	}

	projectRef := strings.TrimSpace(cfg.SupabaseProjectRef)
	supabaseURL := strings.TrimSpace(cfg.SupabaseURL)
	if projectRef == "" && supabaseURL != "" {
		projectRef = projectRefFromURL(supabaseURL)
	}
	if supabaseURL == "" && projectRef != "" {
		supabaseURL = fmt.Sprintf("https://%s.supabase.co", projectRef)
	}

	var es256Enabled bool
	var jwksURL string
	if supabaseURL != "" {
		parsedURL, err := url.Parse(supabaseURL)
		if err != nil || (parsedURL.Scheme != "http" && parsedURL.Scheme != "https") {
			return nil, fmt.Errorf("%w: invalid SUPABASE_URL: %s", ErrNotConfigured, supabaseURL)
		}
		trimmed := strings.TrimRight(supabaseURL, "/")
		base := strings.TrimSuffix(trimmed, "/auth/v1")
		jwksURL = base + "/auth/v1/.well-known/jwks.json"
		es256Enabled = true
	}

	secret := strings.TrimSpace(cfg.SupabaseJwtSecret)
	allowLegacyHS256 := cfg.SupabaseAllowLegacyHS256
	if !allowLegacyHS256 && secret != "" {
		// When SUPABASE_JWT_SECRET is set, default to allowing legacy HS256 unless explicitly forbidden
		if env := os.Getenv("SUPABASE_ALLOW_LEGACY_HS256"); !strings.EqualFold(env, "false") && env != "0" {
			allowLegacyHS256 = true
		}
	}

	var legacyHS256Enabled bool
	var jwtSecret []byte
	if allowLegacyHS256 && secret != "" {
		legacyHS256Enabled = true
		jwtSecret = []byte(secret)
	}

	if !es256Enabled && !legacyHS256Enabled {
		return nil, fmt.Errorf("%w: please set SUPABASE_URL (for ES256) or SUPABASE_JWT_SECRET (for legacy HS256)", ErrNotConfigured)
	}

	requiredRole := strings.TrimSpace(cfg.SupabaseRequiredRole)
	if requiredRole == "" {
		requiredRole = "authenticated"
	}

	var validMethods []string
	if es256Enabled {
		validMethods = append(validMethods, jwt.SigningMethodES256.Alg())
	}
	if legacyHS256Enabled {
		validMethods = append(validMethods, jwt.SigningMethodHS256.Alg())
	}

	var cache *jwksCache
	if es256Enabled {
		cache = &jwksCache{
			keys:        make(map[string]*ecdsa.PublicKey),
			ttl:         1 * time.Hour,
			minInterval: 10 * time.Second,
			httpClient:  &http.Client{Timeout: 5 * time.Second},
			jwksURL:     jwksURL,
		}
	}

	v := &SupabaseVerifier{
		supabaseURL:        strings.TrimRight(supabaseURL, "/"),
		projectRef:         projectRef,
		requiredRole:       requiredRole,
		es256Enabled:       es256Enabled,
		legacyHS256Enabled: legacyHS256Enabled,
		jwtSecret:          jwtSecret,
		validMethods:       validMethods,
		jwksCache:          cache,
	}

	for _, opt := range opts {
		opt(v)
	}

	return v, nil
}

// projectRefFromURL extracts the project ref from https://<ref>.supabase.co.
func projectRefFromURL(rawURL string) string {
	rawURL = strings.TrimSpace(rawURL)
	if rawURL == "" {
		return ""
	}
	trimmed := strings.TrimPrefix(strings.TrimPrefix(rawURL, "https://"), "http://")
	trimmed = strings.TrimSuffix(trimmed, "/")
	if idx := strings.Index(trimmed, "/"); idx != -1 {
		trimmed = trimmed[:idx]
	}
	if idx := strings.Index(trimmed, "."); idx != -1 {
		trimmed = trimmed[:idx]
	}
	return trimmed
}

func (v *SupabaseVerifier) isValidIssuer(iss string) bool {
	iss = strings.TrimRight(strings.TrimSpace(iss), "/")
	if iss == "" {
		return false
	}

	if v.supabaseURL != "" {
		base := strings.TrimRight(v.supabaseURL, "/")
		baseWithoutAuth := strings.TrimSuffix(base, "/auth/v1")
		if iss == base || iss == base+"/auth/v1" || iss == baseWithoutAuth || iss == baseWithoutAuth+"/auth/v1" {
			return true
		}
	}

	if v.projectRef != "" {
		projectBase := fmt.Sprintf("https://%s.supabase.co", v.projectRef)
		if iss == projectBase || iss == projectBase+"/auth/v1" {
			return true
		}
	}

	return false
}

// VerifyToken verifies a Supabase access token and returns the verified identity.
// Never logs raw tokens, secrets, or private keys.
func (v *SupabaseVerifier) VerifyToken(ctx context.Context, accessToken string) (*UserInfo, error) {
	if strings.TrimSpace(accessToken) == "" {
		return nil, ErrMissingToken
	}

	claims := jwt.MapClaims{}
	parser := jwt.NewParser(
		// Pin valid methods: reject "alg: none", RS256, and cross-algorithm confusion
		jwt.WithValidMethods(v.validMethods),
		jwt.WithExpirationRequired(),
	)

	token, err := parser.ParseWithClaims(accessToken, claims, func(t *jwt.Token) (interface{}, error) {
		alg := t.Method.Alg()
		switch alg {
		case jwt.SigningMethodES256.Alg():
			if !v.es256Enabled || v.jwksCache == nil {
				return nil, fmt.Errorf("%w: ES256 verification is not configured", ErrInvalidToken)
			}
			kidRaw, ok := t.Header["kid"]
			if !ok {
				return nil, fmt.Errorf("%w: missing kid in token header", ErrInvalidToken)
			}
			kid, ok := kidRaw.(string)
			if !ok || strings.TrimSpace(kid) == "" {
				return nil, fmt.Errorf("%w: invalid kid in token header", ErrInvalidToken)
			}
			pubKey, err := v.jwksCache.GetKey(ctx, kid)
			if err != nil {
				return nil, fmt.Errorf("%w: %v", ErrInvalidToken, err)
			}
			return pubKey, nil

		case jwt.SigningMethodHS256.Alg():
			if !v.legacyHS256Enabled || len(v.jwtSecret) == 0 {
				return nil, fmt.Errorf("%w: HS256 verification is not enabled", ErrInvalidToken)
			}
			return v.jwtSecret, nil

		default:
			return nil, fmt.Errorf("%w: unsupported signing algorithm %q", ErrInvalidToken, alg)
		}
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrExpiredToken
		}
		return nil, fmt.Errorf("%w: %v", ErrInvalidToken, err)
	}

	if !token.Valid {
		return nil, ErrInvalidToken
	}

	role, _ := claims["role"].(string)

	// CRITICAL SECURITY CONTROL.
	// The `anon` and `service_role` API keys are JWTs signed with the same keys
	// as user access tokens. Only `authenticated` role tokens represent user sessions.
	if v.requiredRole != "" && role != v.requiredRole {
		return nil, ErrInvalidRole
	}

	// Validate issuer against configured Supabase project URL
	iss, hasIss := claims["iss"].(string)
	if token.Method.Alg() == jwt.SigningMethodES256.Alg() {
		// ES256 tokens MUST have an issuer that matches the configured Supabase URL
		if !hasIss || !v.isValidIssuer(iss) {
			return nil, fmt.Errorf("%w: token issuer %q does not match configured Supabase project URL", ErrInvalidToken, iss)
		}
	} else {
		// For legacy HS256 tokens, validate issuer whenever present
		if hasIss && strings.TrimSpace(iss) != "" {
			if !v.isValidIssuer(iss) {
				return nil, fmt.Errorf("%w: token issuer %q does not match configured Supabase project URL", ErrInvalidToken, iss)
			}
		}
	}

	// A token minted by a different Supabase project must not be accepted.
	if v.projectRef != "" {
		if ref, ok := claims["ref"].(string); ok && ref != "" && ref != v.projectRef {
			return nil, fmt.Errorf("%w: token was issued for a different project", ErrInvalidToken)
		}
	}

	subject, _ := claims["sub"].(string)
	if strings.TrimSpace(subject) == "" {
		return nil, fmt.Errorf("%w: token has no subject", ErrInvalidToken)
	}

	userInfo := &UserInfo{
		ID:    subject,
		Role:  role,
		Email: "",
	}
	if email, ok := claims["email"].(string); ok {
		userInfo.Email = email
	}
	if phone, ok := claims["phone"].(string); ok {
		userInfo.PhoneNumber = phone
	}
	if sessionID, ok := claims["session_id"].(string); ok {
		userInfo.SessionID = sessionID
	}

	log.Printf("[Auth] Verified Supabase access token for user %s (role=%s)", subject, role)

	return userInfo, nil
}

// MockVerifier provides an in-memory token verifier for testing.
type MockVerifier struct {
	ValidTokens map[string]*UserInfo
}

// NewMockVerifier creates a MockVerifier with predefined token mappings.
func NewMockVerifier(tokens map[string]*UserInfo) *MockVerifier {
	if tokens == nil {
		tokens = make(map[string]*UserInfo)
	}
	return &MockVerifier{ValidTokens: tokens}
}

// VerifyToken validates against the in-memory mock map.
func (m *MockVerifier) VerifyToken(ctx context.Context, accessToken string) (*UserInfo, error) {
	if strings.TrimSpace(accessToken) == "" {
		return nil, ErrMissingToken
	}
	if accessToken == "expired-token" {
		return nil, ErrExpiredToken
	}
	if info, exists := m.ValidTokens[accessToken]; exists {
		return info, nil
	}
	return nil, ErrInvalidToken
}
