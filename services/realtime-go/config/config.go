package config

import (
	"os"
	"strings"

	"github.com/joho/godotenv"
)

func init() {
	// Load services/realtime-go/.env (non-fatally) so `go run .` and
	// scripts/start-all.js pick up credentials the same way the NestJS
	// ConfigModule does. Real environment variables always win: godotenv
	// never overrides variables that are already set.
	_ = godotenv.Load()
}

// Config holds runtime configuration loaded from environment variables.
type Config struct {
	Port                     string
	AllowedOrigins           []string
	SupabaseURL              string
	SupabaseProjectRef       string
	SupabaseAnonKey          string
	SupabaseServiceRoleKey   string
	SupabaseJwtSecret        string
	SupabaseRequiredRole     string
	SupabaseAllowLegacyHS256 bool
	DatabaseURL              string
}

// Load reads configuration from environment variables with sensible defaults.
func Load() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	var allowedOrigins []string
	if origins := os.Getenv("ALLOWED_ORIGINS"); origins != "" {
		for _, o := range strings.Split(origins, ",") {
			trimmed := strings.TrimSpace(o)
			if trimmed != "" {
				allowedOrigins = append(allowedOrigins, trimmed)
			}
		}
	}

	allowLegacyHS256 := false
	if v := os.Getenv("SUPABASE_ALLOW_LEGACY_HS256"); v != "" {
		allowLegacyHS256 = strings.EqualFold(v, "true") || v == "1"
	} else if os.Getenv("SUPABASE_JWT_SECRET") != "" {
		allowLegacyHS256 = true
	}

	return &Config{
		Port:                     port,
		AllowedOrigins:           allowedOrigins,
		SupabaseURL:              os.Getenv("SUPABASE_URL"),
		SupabaseProjectRef:       os.Getenv("SUPABASE_PROJECT_REF"),
		SupabaseAnonKey:          os.Getenv("SUPABASE_ANON_KEY"),
		SupabaseServiceRoleKey:   os.Getenv("SUPABASE_SERVICE_ROLE_KEY"),
		SupabaseJwtSecret:        os.Getenv("SUPABASE_JWT_SECRET"),
		SupabaseRequiredRole:     os.Getenv("SUPABASE_REQUIRED_ROLE"),
		SupabaseAllowLegacyHS256: allowLegacyHS256,
		DatabaseURL:              os.Getenv("DATABASE_URL"),
	}
}
