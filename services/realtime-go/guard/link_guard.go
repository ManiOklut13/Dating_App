package guard

import (
	"regexp"
	"strings"
	"unicode"
)

// ContactGuardResult contains validation analysis
type ContactGuardResult struct {
	IsBlocked     bool     `json:"is_blocked"`
	Reason        string   `json:"reason,omitempty"`
	DetectedType  string   `json:"detected_type,omitempty"`
	NormalizedTxt string   `json:"normalized_text"`
}

// Homoglyph map to intercept character obfuscation (e.g. 0 for o, @ for a, 1 for l/i)
var homoglyphs = map[rune]rune{
	'@': 'a',
	'0': 'o',
	'1': 'i',
	'3': 'e',
	'$': 's',
	'5': 's',
	'7': 't',
	'!': 'i',
}

// Normalizes text by mapping homoglyphs and stripping non-alphanumeric separators
func NormalizeText(input string) string {
	var builder strings.Builder
	for _, r := range input {
		if mapped, ok := homoglyphs[r]; ok {
			builder.WriteRune(mapped)
		} else if unicode.IsLetter(r) || unicode.IsDigit(r) || unicode.IsSpace(r) {
			builder.WriteRune(unicode.ToLower(r))
		}
	}
	return builder.String()
}

// CheckContactGuard checks if text contains restricted communication handles
func CheckContactGuard(content string, activeDays int, messagePairCount int) ContactGuardResult {
	// Rule: Contact sharing restriction unlocks after 3 days of active matching OR 20 message pairs exchanged
	if activeDays >= 3 || messagePairCount >= 20 {
		return ContactGuardResult{
			IsBlocked:     false,
			NormalizedTxt: content,
		}
	}

	norm := NormalizeText(content)

	// Regex 1: Phone numbers (Indian/international 10+ digits, with spaces or dashes)
	phoneRegex := regexp.MustCompile(`(\+?\d{1,3}[-.\s]?)?(\d{3,5}[-.\s]?\d{3,5}[-.\s]?\d{3,5})`)
	// Extract continuous digits only
	digitOnly := regexp.MustCompile(`\D`).ReplaceAllString(content, "")
	if len(digitOnly) >= 10 {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "Contact Guard: Sharing phone numbers is restricted during initial conversation.",
			DetectedType:  "phone_number",
			NormalizedTxt: norm,
		}
	}
	if phoneRegex.MatchString(norm) && len(digitOnly) >= 7 {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "Contact Guard: Direct contact numbers are blocked for your safety.",
			DetectedType:  "phone_number",
			NormalizedTxt: norm,
		}
	}

	// Regex 2: Instagram / Telegram / Social Handles
	socialRegex := regexp.MustCompile(`(?i)(insta|ig|telegram|snap|snapchat|t\.me|wa\.me|whatsapp|sc)\s*[:@\s_-]?\s*([a-zA-Z0-9_.]{3,})`)
	if socialRegex.MatchString(content) || socialRegex.MatchString(norm) {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "Contact Guard: Social handles (Instagram/Telegram/Snapchat) unlock after 3 days of chatting.",
			DetectedType:  "social_handle",
			NormalizedTxt: norm,
		}
	}

	// Regex 3: URLs and domains
	urlRegex := regexp.MustCompile(`(?i)(https?:\/\/|www\.)[^\s]+|([a-zA-Z0-9-]+\.(com|org|net|io|in|me|app|link|xyz))`)
	if urlRegex.MatchString(content) {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "Contact Guard: External web links are blocked for anti-fraud safety.",
			DetectedType:  "external_url",
			NormalizedTxt: norm,
		}
	}

	return ContactGuardResult{
		IsBlocked:     false,
		NormalizedTxt: norm,
	}
}
