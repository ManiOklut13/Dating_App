package auth

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"younme/realtime/config"
)

const testJWTSecret = "test-secret-for-unit-tests-only"

func ecPublicKeyToJWK(pub *ecdsa.PublicKey, kid string) map[string]interface{} {
	pad := func(b []byte, size int) []byte {
		if len(b) >= size {
			return b
		}
		padded := make([]byte, size)
		copy(padded[size-len(b):], b)
		return padded
	}

	xBytes := pad(pub.X.Bytes(), 32)
	yBytes := pad(pub.Y.Bytes(), 32)

	return map[string]interface{}{
		"kty": "EC",
		"crv": "P-256",
		"x":   base64.RawURLEncoding.EncodeToString(xBytes),
		"y":   base64.RawURLEncoding.EncodeToString(yBytes),
		"kid": kid,
		"alg": "ES256",
		"use": "sig",
	}
}

func setupMockJWKSServer(t *testing.T, keys map[string]*ecdsa.PublicKey) (*httptest.Server, *int) {
	t.Helper()
	callCount := 0
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		callCount++
		if r.URL.Path != "/auth/v1/.well-known/jwks.json" {
			http.NotFound(w, r)
			return
		}
		jwkList := make([]map[string]interface{}, 0, len(keys))
		for kid, pub := range keys {
			jwkList = append(jwkList, ecPublicKeyToJWK(pub, kid))
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]interface{}{"keys": jwkList})
	})
	server := httptest.NewServer(handler)
	return server, &callCount
}

func signES256Token(t *testing.T, key *ecdsa.PrivateKey, kid string, claims jwt.MapClaims) string {
	t.Helper()
	token := jwt.NewWithClaims(jwt.SigningMethodES256, claims)
	if kid != "" {
		token.Header["kid"] = kid
	}
	signed, err := token.SignedString(key)
	if err != nil {
		t.Fatalf("failed to sign ES256 token: %v", err)
	}
	return signed
}

// signHS256Token builds an HS256 token signed with testJWTSecret.
func signHS256Token(t *testing.T, secret string, claims jwt.MapClaims) string {
	t.Helper()
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(secret))
	if err != nil {
		t.Fatalf("failed to sign HS256 token: %v", err)
	}
	return signed
}

func testLegacyVerifier(t *testing.T) *SupabaseVerifier {
	t.Helper()
	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseJwtSecret:  testJWTSecret,
		SupabaseProjectRef: "ocacwpazrfaecmckmtbz",
	})
	if err != nil {
		t.Fatalf("failed to build legacy verifier: %v", err)
	}
	return v
}

func TestMockVerifier_ValidToken(t *testing.T) {
	mock := NewMockVerifier(map[string]*UserInfo{
		"valid-token-user-1": {
			ID:    "user_123",
			Email: "user1@example.com",
		},
	})

	ctx := context.Background()
	info, err := mock.VerifyToken(ctx, "valid-token-user-1")
	if err != nil {
		t.Fatalf("expected nil error, got %v", err)
	}
	if info.ID != "user_123" {
		t.Errorf("expected ID 'user_123', got '%s'", info.ID)
	}
	if info.Email != "user1@example.com" {
		t.Errorf("expected email 'user1@example.com', got '%s'", info.Email)
	}
}

func TestMockVerifier_MissingToken(t *testing.T) {
	mock := NewMockVerifier(nil)
	ctx := context.Background()

	_, err := mock.VerifyToken(ctx, "")
	if !errors.Is(err, ErrMissingToken) {
		t.Errorf("expected ErrMissingToken, got %v", err)
	}

	_, err = mock.VerifyToken(ctx, "   ")
	if !errors.Is(err, ErrMissingToken) {
		t.Errorf("expected ErrMissingToken for whitespace, got %v", err)
	}
}

func TestMockVerifier_ExpiredToken(t *testing.T) {
	mock := NewMockVerifier(nil)
	ctx := context.Background()

	_, err := mock.VerifyToken(ctx, "expired-token")
	if !errors.Is(err, ErrExpiredToken) {
		t.Errorf("expected ErrExpiredToken, got %v", err)
	}
}

func TestMockVerifier_InvalidToken(t *testing.T) {
	mock := NewMockVerifier(nil)
	ctx := context.Background()

	_, err := mock.VerifyToken(ctx, "random-garbage-token")
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken, got %v", err)
	}
}

func TestNewSupabaseVerifier_MissingConfig(t *testing.T) {
	cfg := &config.Config{}

	_, err := NewSupabaseVerifier(cfg)
	if err == nil {
		t.Fatalf("expected error when credentials missing, got nil")
	}
	if !errors.Is(err, ErrNotConfigured) {
		t.Errorf("expected error wrapping ErrNotConfigured, got %v", err)
	}
}

func TestNewSupabaseVerifier_ValidWithURLOnly(t *testing.T) {
	cfg := &config.Config{
		SupabaseURL: "https://ocacwpazrfaecmckmtbz.supabase.co",
	}

	v, err := NewSupabaseVerifier(cfg)
	if err != nil {
		t.Fatalf("expected nil error for valid URL config, got %v", err)
	}
	if !v.es256Enabled {
		t.Errorf("expected es256Enabled to be true")
	}
	if v.legacyHS256Enabled {
		t.Errorf("expected legacyHS256Enabled to be false when secret is empty")
	}
}

func TestSupabaseVerifier_ES256_ValidUserToken(t *testing.T) {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatalf("failed to generate ecdsa key: %v", err)
	}
	kid := "test-kid-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL:        server.URL,
		SupabaseProjectRef: "test-ref",
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	token := signES256Token(t, key, kid, jwt.MapClaims{
		"sub":   "11111111-1111-1111-1111-111111111111",
		"email": "user@example.com",
		"phone": "+1234567890",
		"role":  "authenticated",
		"ref":   "test-ref",
		"iss":   server.URL + "/auth/v1",
		"exp":   time.Now().Add(time.Hour).Unix(),
		"iat":   time.Now().Unix(),
	})

	info, err := v.VerifyToken(context.Background(), token)
	if err != nil {
		t.Fatalf("expected nil error, got %v", err)
	}
	if info.ID != "11111111-1111-1111-1111-111111111111" {
		t.Errorf("unexpected user id: %s", info.ID)
	}
	if info.Email != "user@example.com" {
		t.Errorf("unexpected email: %s", info.Email)
	}
	if info.PhoneNumber != "+1234567890" {
		t.Errorf("unexpected phone: %s", info.PhoneNumber)
	}
	if info.Role != "authenticated" {
		t.Errorf("unexpected role: %s", info.Role)
	}
}

func TestSupabaseVerifier_ES256_JWKSCaching(t *testing.T) {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatalf("failed to generate ecdsa key: %v", err)
	}
	kid := "cache-test-kid"
	server, callCount := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL:        server.URL,
		SupabaseProjectRef: "test-ref",
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	token := signES256Token(t, key, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	// First verification fetches JWKS
	_, err = v.VerifyToken(context.Background(), token)
	if err != nil {
		t.Fatalf("first verify failed: %v", err)
	}
	if *callCount != 1 {
		t.Fatalf("expected 1 JWKS server call, got %d", *callCount)
	}

	// Second verification must use in-memory cache without hitting network
	_, err = v.VerifyToken(context.Background(), token)
	if err != nil {
		t.Fatalf("second verify failed: %v", err)
	}
	if *callCount != 1 {
		t.Errorf("expected JWKS call count to stay 1 due to caching, got %d", *callCount)
	}
}

func TestSupabaseVerifier_ES256_InvalidSignature(t *testing.T) {
	key1, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	key2, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader) // Different key!
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key1.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	// Signed with key2, but header claims kid is key-1
	token := signES256Token(t, key2, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for invalid signature, got %v", err)
	}
}

func TestSupabaseVerifier_ES256_ExpiredToken(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	token := signES256Token(t, key, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(-5 * time.Minute).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrExpiredToken) {
		t.Errorf("expected ErrExpiredToken, got %v", err)
	}
}

func TestSupabaseVerifier_ES256_WrongIssuer(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	// Case 1: Foreign issuer
	token := signES256Token(t, key, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  "https://other-project.supabase.co/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})
	_, err = v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for foreign issuer, got %v", err)
	}

	// Case 2: Missing issuer
	tokenNoIss := signES256Token(t, key, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})
	_, err = v.VerifyToken(context.Background(), tokenNoIss)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for missing issuer, got %v", err)
	}
}

func TestSupabaseVerifier_ES256_WrongRole(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	for _, badRole := range []string{"anon", "service_role", "admin"} {
		token := signES256Token(t, key, kid, jwt.MapClaims{
			"sub":  "11111111-1111-1111-1111-111111111111",
			"role": badRole,
			"iss":  server.URL + "/auth/v1",
			"exp":  time.Now().Add(time.Hour).Unix(),
		})

		_, err = v.VerifyToken(context.Background(), token)
		if !errors.Is(err, ErrInvalidRole) {
			t.Errorf("expected ErrInvalidRole for role=%q, got %v", badRole, err)
		}
	}
}

func TestSupabaseVerifier_ES256_UnknownKid(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "known-kid"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	token := signES256Token(t, key, "unknown-kid-999", jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for unknown kid, got %v", err)
	}
}

func TestSupabaseVerifier_ES256_MissingKid(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "known-kid"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	// Omit kid from header
	token := signES256Token(t, key, "", jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for missing kid header, got %v", err)
	}
}

func TestSupabaseVerifier_UnsupportedAlgorithms(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key.PublicKey})
	defer server.Close()

	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL: server.URL,
	})
	if err != nil {
		t.Fatalf("failed to create verifier: %v", err)
	}

	// 1. Alg None
	unsigned := jwt.NewWithClaims(jwt.SigningMethodNone, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})
	signedNone, _ := unsigned.SignedString(jwt.UnsafeAllowNoneSignatureType)
	_, err = v.VerifyToken(context.Background(), signedNone)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for alg=none, got %v", err)
	}

	// 2. RS256
	rsaKey, _ := rsa.GenerateKey(rand.Reader, 2048)
	rsaToken := jwt.NewWithClaims(jwt.SigningMethodRS256, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})
	signedRSA, _ := rsaToken.SignedString(rsaKey)
	_, err = v.VerifyToken(context.Background(), signedRSA)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for RS256, got %v", err)
	}
}

func TestSupabaseVerifier_NoSilentFallbackToHS256(t *testing.T) {
	key1, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	key2, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	kid := "key-1"
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{kid: &key1.PublicKey})
	defer server.Close()

	// Both ES256 and HS256 configured simultaneously
	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL:              server.URL,
		SupabaseJwtSecret:        testJWTSecret,
		SupabaseAllowLegacyHS256: true,
	})
	if err != nil {
		t.Fatalf("failed to create dual-configured verifier: %v", err)
	}

	// Token has alg: ES256, but signed with wrong key
	badES256 := signES256Token(t, key2, kid, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"iss":  server.URL + "/auth/v1",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), badES256)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken on invalid ES256 signature without falling back to HS256, got %v", err)
	}
}

func TestSupabaseVerifier_LegacyHS256_ValidUserToken(t *testing.T) {
	v := testLegacyVerifier(t)

	token := signHS256Token(t, testJWTSecret, jwt.MapClaims{
		"sub":   "11111111-1111-1111-1111-111111111111",
		"email": "arjun@younme.social",
		"phone": "+919820011111",
		"role":  "authenticated",
		"ref":   "ocacwpazrfaecmckmtbz",
		"exp":   time.Now().Add(time.Hour).Unix(),
		"iat":   time.Now().Unix(),
	})

	info, err := v.VerifyToken(context.Background(), token)
	if err != nil {
		t.Fatalf("expected nil error, got %v", err)
	}
	if info.ID != "11111111-1111-1111-1111-111111111111" {
		t.Errorf("unexpected id %q", info.ID)
	}
	if info.Email != "arjun@younme.social" {
		t.Errorf("unexpected email %q", info.Email)
	}
	if info.PhoneNumber != "+919820011111" {
		t.Errorf("unexpected phone %q", info.PhoneNumber)
	}
	if info.Role != "authenticated" {
		t.Errorf("unexpected role %q", info.Role)
	}
}

func TestSupabaseVerifier_LegacyHS256_RejectsAPIKeyRoles(t *testing.T) {
	v := testLegacyVerifier(t)

	for _, role := range []string{"anon", "service_role"} {
		token := signHS256Token(t, testJWTSecret, jwt.MapClaims{
			"sub":  "some-key-subject",
			"role": role,
			"ref":  "ocacwpazrfaecmckmtbz",
			"exp":  time.Now().Add(time.Hour).Unix(),
			"iat":  time.Now().Unix(),
		})

		_, err := v.VerifyToken(context.Background(), token)
		if !errors.Is(err, ErrInvalidRole) {
			t.Errorf("expected ErrInvalidRole for role=%q, got %v", role, err)
		}
	}
}

func TestSupabaseVerifier_LegacyHS256_RejectsExpiredToken(t *testing.T) {
	v := testLegacyVerifier(t)

	token := signHS256Token(t, testJWTSecret, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"ref":  "ocacwpazrfaecmckmtbz",
		"exp":  time.Now().Add(-time.Minute).Unix(),
		"iat":  time.Now().Add(-2 * time.Hour).Unix(),
	})

	_, err := v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrExpiredToken) {
		t.Errorf("expected ErrExpiredToken, got %v", err)
	}
}

func TestSupabaseVerifier_LegacyHS256_RejectsWrongSecret(t *testing.T) {
	v := testLegacyVerifier(t)

	signed := signHS256Token(t, "a-different-secret", jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"ref":  "ocacwpazrfaecmckmtbz",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err := v.VerifyToken(context.Background(), signed)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken, got %v", err)
	}
}

func TestSupabaseVerifier_LegacyHS256_RejectsTokenFromOtherProject(t *testing.T) {
	v := testLegacyVerifier(t)

	token := signHS256Token(t, testJWTSecret, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"ref":  "someotherprojectref",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err := v.VerifyToken(context.Background(), token)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken for foreign project ref, got %v", err)
	}
}

func TestSupabaseVerifier_LegacyHS256_CanBeDisabled(t *testing.T) {
	key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	server, _ := setupMockJWKSServer(t, map[string]*ecdsa.PublicKey{"kid-1": &key.PublicKey})
	defer server.Close()

	t.Setenv("SUPABASE_ALLOW_LEGACY_HS256", "false")
	v, err := NewSupabaseVerifier(&config.Config{
		SupabaseURL:              server.URL,
		SupabaseJwtSecret:        testJWTSecret,
		SupabaseAllowLegacyHS256: false,
	})
	if err != nil {
		t.Fatalf("failed to initialize verifier: %v", err)
	}

	hsToken := signHS256Token(t, testJWTSecret, jwt.MapClaims{
		"sub":  "11111111-1111-1111-1111-111111111111",
		"role": "authenticated",
		"exp":  time.Now().Add(time.Hour).Unix(),
	})

	_, err = v.VerifyToken(context.Background(), hsToken)
	if !errors.Is(err, ErrInvalidToken) {
		t.Errorf("expected ErrInvalidToken when legacy HS256 is disabled, got %v", err)
	}
}

func TestProjectRefFromURL(t *testing.T) {
	cases := map[string]string{
		"https://ocacwpazrfaecmckmtbz.supabase.co":  "ocacwpazrfaecmckmtbz",
		"https://ocacwpazrfaecmckmtbz.supabase.co/": "ocacwpazrfaecmckmtbz",
		"http://ocacwpazrfaecmckmtbz.supabase.co":   "ocacwpazrfaecmckmtbz",
		"": "",
	}

	for input, want := range cases {
		if got := projectRefFromURL(input); got != want {
			t.Errorf("projectRefFromURL(%q) = %q, want %q", input, got, want)
		}
	}
}
