package guard

import (
	"regexp"
	"strings"
	"unicode"
)

// ContactGuardResult contains validation analysis
type ContactGuardResult struct {
	IsBlocked     bool   `json:"is_blocked"`
	Reason        string `json:"reason,omitempty"`
	DetectedType  string `json:"detected_type,omitempty"`
	NormalizedTxt string `json:"normalized_text"`
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

// numberWords maps English number words (zero through nine) to true for detection.
var numberWords = map[string]bool{
	"zero": true,
	"one":  true,
	"two":  true,
	"three": true,
	"four": true,
	"five": true,
	"six":  true,
	"seven": true,
	"eight": true,
	"nine": true,
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

// containsPhoneNumberWords checks whether the given text contains a plausible
// phone-number sequence written out as English number words (zero–nine) and/or
// digit characters. It looks for seven or more consecutive number-relevant
// tokens after normalising separators and case. This catches patterns such as
// "nine eight seven six five four three two one zero" or "9 eight 7 six 5 four 3 two 1 zero"
// without flagging ordinary messages that happen to contain a single number word.
func containsPhoneNumberWords(content string) bool {
	// Lowercase and replace common separators with spaces so that
	// hyphenated or underscored word streams become tokenised.
	normalized := strings.ToLower(content)
	normalized = strings.ReplaceAll(normalized, "-", " ")
	normalized = strings.ReplaceAll(normalized, "_", " ")

	// Split into whitespace-separated tokens.
	words := strings.Fields(normalized)

	// Scan for a run of seven or more consecutive number-relevant tokens.
	consecutive := 0
	for _, w := range words {
		if isNumberWordOrDigit(w) {
			consecutive++
			if consecutive >= 7 {
				return true
			}
		} else {
			consecutive = 0
		}
	}
	return false
}

// isNumberWordOrDigit returns true when the token matches a recognised English
// number word (zero through nine) or consists entirely of digit characters.
func isNumberWordOrDigit(token string) bool {
	if token == "" {
		return false
	}
	// Check the built-in number-word set.
	if numberWords[token] {
		return true
	}
	// Check that the token is non-empty and every character is a decimal digit.
	allDigits := true
	for _, r := range token {
		if r < '0' || r > '9' {
			allDigits = false
			break
		}
	}
	return allDigits
}

// CheckContactGuard checks if text contains restricted communication handles
func CheckContactGuard(content string, activeDays int, messagePairCount int) ContactGuardResult {
	norm := NormalizeText(content)

	// Meetup planning phrases restriction - ALWAYS blocked regardless of conversation age or message count
	if containsMeetupPhrase(content) {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "meetup_requires_date_invitation",
			DetectedType:  "meetup_phrase",
			NormalizedTxt: norm,
		}
	}

	// Rule: Contact sharing restriction unlocks after 3 days of active matching OR 20 message pairs exchanged
	if activeDays >= 3 || messagePairCount >= 20 {
		return ContactGuardResult{
			IsBlocked:     false,
			NormalizedTxt: norm,
		}
	}

	// Regex 1: Phone numbers (Indian/international 10+ digits, with spaces or dashes)
	phoneRegex := regexp.MustCompile(`(\\+?\d{1,3}[-.\\s]?)?(\d{3,5}[-.\\s]?\d{3,5}[-.\\s]?\d{3,5})`)
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

	// Phone numbers written as English number words (e.g. "nine eight seven six five four three two one zero")
	if containsPhoneNumberWords(content) {
		return ContactGuardResult{
			IsBlocked:     true,
			Reason:        "Contact Guard: Phone numbers written as words are restricted during initial conversation.",
			DetectedType:  "phone_number_words",
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
	urlRegex := regexp.MustCompile(`(?i)(https?:\/\/(?:www\.)?[^\s]+|[a-zA-Z0-9-]+\.(com|org|net|io|in|me|app|link|xyz))`)
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

// meetupPhrases contains patterns that trigger meetup-arrangement blocking.
// These are checked case-insensitively and with flexible punctuation.
var meetupPhrases = []string{
	"let's go on a date",
	"let's meet",
	"let's meet up",
	"let's catch up",
	"meet me",
	"where should we meet",
	"let's meet tomorrow",
}

// containsMeetupPhrase checks if the given text contains any known meetup-planning phrase.
// The check is case-insensitive and normalizes whitespace/punctuation for matching.
func containsMeetupPhrase(content string) bool {
	lower := strings.ToLower(content)

	for _, phrase := range meetupPhrases {
		// Normalize: lowercase, collapse multiple spaces, trim
		normalized := strings.ToLower(strings.Join(strings.Fields(lower), " "))
		if strings.Contains(normalized, strings.ToLower(phrase)) {
			return true
		}
	}

	return false
}

// normalizeForSubstring lowercases and collapses whitespace for robust substring matching
func normalizeForSubstring(s string) string {
	return strings.ToLower(strings.Join(strings.Fields(s), " "))
}