package guard

import (
	"testing"
)

func TestCheckContactGuard_PhoneNumbers(t *testing.T) {
	tests := []struct {
		name        string
		text        string
		activeDays  int
		pairCount   int
		shouldBlock bool
	}{
		{
			name:        "Standard 10-digit number (new user)",
			text:        "Call me at 9876543210 please",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Formatted phone number with dashes",
			text:        "Hit me up at +91-98765-43210",
			activeDays:  1,
			pairCount:   2,
			shouldBlock: true,
		},
		{
			name:        "Phone number allowed after 3 active days",
			text:        "My number is 9876543210",
			activeDays:  3,
			pairCount:   5,
			shouldBlock: false,
		},
		{
			name:        "Phone number allowed after 20 message pairs",
			text:        "My number is 9876543210",
			activeDays:  1,
			pairCount:   20,
			shouldBlock: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			res := CheckContactGuard(tc.text, tc.activeDays, tc.pairCount)
			if res.IsBlocked != tc.shouldBlock {
				t.Errorf("expected is_blocked=%v, got %v (reason: %s)", tc.shouldBlock, res.IsBlocked, res.Reason)
			}
		})
	}
}

func TestCheckContactGuard_SocialHandles(t *testing.T) {
	tests := []struct {
		name        string
		text        string
		shouldBlock bool
	}{
		{
			name:        "Instagram handle with colon separator",
			text:        "My insta:dating_star is on there",
			shouldBlock: true,
		},
		{
			name:        "Telegram handle",
			text:        "Add me on telegram:cool_guy99",
			shouldBlock: true,
		},
		{
			name:        "Snapchat handle with colon separator",
			text:        "My snap:sweet_girl xoxo",
			shouldBlock: true,
		},
		{
			name:        "Telegram t.me link",
			text:        "Find me at t.me/myusername",
			shouldBlock: true,
		},
		{
			name:        "Normal friendly text",
			text:        "Hey! How is your weekend going?",
			shouldBlock: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			res := CheckContactGuard(tc.text, 1, 5)
			if res.IsBlocked != tc.shouldBlock {
				t.Errorf("expected is_blocked=%v, got %v (reason: %s)", tc.shouldBlock, res.IsBlocked, res.Reason)
			}
		})
	}
}

func TestCheckContactGuard_ExternalUrls(t *testing.T) {
	tests := []struct {
		name        string
		text        string
		shouldBlock bool
	}{
		{
			name:        "Full https URL",
			text:        "Check this out: https://suspicious-site.com/login",
			shouldBlock: true,
		},
		{
			name:        "Raw domain name",
			text:        "Go to mywebsite.org to see my photos",
			shouldBlock: true,
		},
		{
			name:        "Clean greeting",
			text:        "Let's grab a coffee at Marine Drive!",
			shouldBlock: false,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			res := CheckContactGuard(tc.text, 1, 5)
			if res.IsBlocked != tc.shouldBlock {
				t.Errorf("expected is_blocked=%v, got %v (reason: %s)", tc.shouldBlock, res.IsBlocked, res.Reason)
			}
		})
	}
}

func TestCheckContactGuard_MeetupPhrases(t *testing.T) {
	tests := []struct {
		name        string
		text        string
		activeDays  int
		pairCount   int
		shouldBlock bool
	}{
		{
			name:        "Block 'Let's go on a date'",
			text:        "Let's go on a date tonight!",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Let's meet'",
			text:        "Let's meet up later",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Let's meet up'",
			text:        "Let's meet up at the park",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Let's catch up'",
			text:        "Hey, let's catch up soon",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Meet me here'",
			text:        "Meet me here at 5pm",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Where should we meet?'",
			text:        "Where should we meet?",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Block 'Let's meet tomorrow'",
			text:        "Let's meet tomorrow",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Punctuation variation - with period",
			text:        "Let's go on a date.",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Punctuation variation - with exclamation",
			text:        "Let's meet!",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Punctuation variation - with question mark",
			text:        "Where should we meet?",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Harmless message - should NOT block",
			text:        "Hey! How is your weekend going?",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: false,
		},
		{
			name:        "Harmless message about friends - should NOT block",
			text:        "Want to hang out with friends tomorrow?",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: false,
		},
		{
			name:        "False positive avoided - 'date' as calendar date not meetup",
			text:        "What is the date of the event?",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: false,
		},
		{
			name:        "False positive avoided - 'meet' as business meeting",
			text:        "I have a meeting at 3pm",
			activeDays:  1,
			pairCount:   5,
			shouldBlock: false,
		},
		{
			name:        "Meetup remains blocked after 3 days",
			text:        "Let's go on a date",
			activeDays:  3,
			pairCount:   5,
			shouldBlock: true,
		},
		{
			name:        "Meetup remains blocked after 20 message pairs",
			text:        "Let's go on a date",
			activeDays:  1,
			pairCount:   20,
			shouldBlock: true,
		},
		{
			name:        "Meetup remains blocked when both conditions met",
			text:        "Let's meet",
			activeDays:  3,
			pairCount:   20,
			shouldBlock: true,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			res := CheckContactGuard(tc.text, tc.activeDays, tc.pairCount)
			if res.IsBlocked != tc.shouldBlock {
				t.Errorf("expected is_blocked=%v, got %v (reason: %s, detected_type: %s)",
					tc.shouldBlock, res.IsBlocked, res.Reason, res.DetectedType)
			}
			// When blocked, verify the reason contains the expected key
			if res.IsBlocked && tc.shouldBlock {
				if !containsReason(res.Reason, "meetup_requires_date_invitation") {
					t.Errorf("expected reason to contain 'meetup_requires_date_invitation', got: %s", res.Reason)
				}
			}
		})
	}
}

func containsReason(reason, substr string) bool {
	return containsSubstr(reason, substr)
}

func containsSubstr(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && containsHelper(s, substr))
}

func containsHelper(s, substr string) bool {
	if len(substr) == 0 {
		return true
	}
	if len(s) < len(substr) {
		return false
	}
	if len(substr) == 1 {
		return s == substr || (len(s) > 1 && (s[:1] == substr || s[1:] == substr))
	}
	if s[:len(substr)] == substr {
		return true
	}
	return containsHelper(s[1:], substr)
}