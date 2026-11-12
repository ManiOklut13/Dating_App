import { NotificationPrefs } from './types';

export const COUNTRY_CODES = [
  { code: '+91', label: 'IN +91' },
  { code: '+1', label: 'US +1' },
  { code: '+44', label: 'UK +44' },
  { code: '+61', label: 'AU +61' },
  { code: '+971', label: 'AE +971' },
  { code: '+65', label: 'SG +65' },
  { code: '+49', label: 'DE +49' },
];

export const GENDER_OPTIONS = ['Man', 'Woman', 'Non-binary', 'Self-describe', 'Prefer not to say'];

export const ORIENTATION_OPTIONS = [
  'Straight',
  'Gay',
  'Lesbian',
  'Bisexual',
  'Pansexual',
  'Asexual',
  'Queer',
  'Questioning',
  'Prefer not to say',
  'Self-describe',
];

export const LOOKING_FOR_OPTIONS = [
  { id: 'Dating', emoji: '💘', hint: 'Meaningful romantic connections' },
  { id: 'Friendship', emoji: '🤝', hint: 'Long-lasting friendships' },
  { id: 'New Friends', emoji: '👋', hint: 'Meet people nearby' },
  { id: 'Dating & Friendship', emoji: '✨', hint: 'A bit of everything' },
  { id: 'Casual Connections', emoji: '🌙', hint: 'Low-pressure good times' },
];

export const INTERESTED_IN_OPTIONS = ['Men', 'Women', 'Non-binary people', 'Everyone'];

export const LANGUAGES = ['English', 'Telugu', 'Hindi', 'Tamil', 'Kannada', 'Malayalam', 'Other'];

export const INTEREST_OPTIONS = [
  { id: 'Music', emoji: '🎵' },
  { id: 'Gaming', emoji: '🎮' },
  { id: 'Travel', emoji: '✈️' },
  { id: 'Food', emoji: '🍜' },
  { id: 'Movies', emoji: '🎬' },
  { id: 'Reading', emoji: '📚' },
  { id: 'Art', emoji: '🎨' },
  { id: 'Sports', emoji: '⚽' },
  { id: 'Photography', emoji: '📷' },
  { id: 'Fitness', emoji: '💪' },
  { id: 'Dance', emoji: '💃' },
  { id: 'Technology', emoji: '💻' },
  { id: 'Nature', emoji: '🌿' },
  { id: 'Cooking', emoji: '🍳' },
  { id: 'Culture', emoji: '🏛️' },
];

export const MOCK_CITIES = [
  { name: 'Hyderabad', region: 'Telangana, India' },
  { name: 'Bengaluru', region: 'Karnataka, India' },
  { name: 'Chennai', region: 'Tamil Nadu, India' },
  { name: 'Mumbai', region: 'Maharashtra, India' },
  { name: 'Delhi', region: 'Delhi, India' },
  { name: 'Pune', region: 'Maharashtra, India' },
  { name: 'Kolkata', region: 'West Bengal, India' },
  { name: 'Ahmedabad', region: 'Gujarat, India' },
  { name: 'Jaipur', region: 'Rajasthan, India' },
  { name: 'Kochi', region: 'Kerala, India' },
  { name: 'Vijayawada', region: 'Andhra Pradesh, India' },
  { name: 'Visakhapatnam', region: 'Andhra Pradesh, India' },
  { name: 'Warangal', region: 'Telangana, India' },
  { name: 'London', region: 'United Kingdom' },
  { name: 'New York', region: 'United States' },
  { name: 'San Francisco', region: 'United States' },
  { name: 'Toronto', region: 'Canada' },
  { name: 'Singapore', region: 'Singapore' },
  { name: 'Dubai', region: 'United Arab Emirates' },
  { name: 'Sydney', region: 'Australia' },
  { name: 'Berlin', region: 'Germany' },
  { name: 'Amsterdam', region: 'Netherlands' },
];

/** Sample avatars — decorative only, no biometrics involved. */
export const AVATAR_BASES = ['🧑', '👩', '👨', '👧', '👦', '🧕', '👱', '🧔', '👩‍🎤', '🧑‍🚀', '👨‍💻', '👩‍🔬'];
export const AVATAR_SKIN = ['#f7d7b6', '#eab696', '#c68642', '#a26537', '#8d5524', '#5c3a21'];
export const AVATAR_OUTFIT = ['#ff2d55', '#9b51e0', '#00e5ff', '#00e676', '#ffa502', '#1da1f2'];
export const AVATAR_ACCESSORY = ['', '🕶️', '👓', '🧢', '🎧', '🌺'];

export const SAMPLE_CONTACTS = [
  { name: 'Priya Sharma', handle: '@priya.sh', mutual: 3 },
  { name: 'Rahul Verma', handle: '@rahulv', mutual: 1 },
  { name: 'Meera Nair', handle: '@meera', mutual: 5 },
  { name: 'Arjun Rao', handle: '@arjunr', mutual: 0 },
];

export const SAFETY_TIPS = [
  { icon: '🔒', title: 'Keep personal details private', text: 'Avoid sharing your address, workplace or bank details with people you just met.' },
  { icon: '🚩', title: 'Report suspicious behaviour', text: 'Scams, harassment and fake profiles can be reported in a couple of taps.' },
  { icon: '🚫', title: 'Block or restrict freely', text: 'You are always in control of who can reach you — no explanation needed.' },
  { icon: '🔢', title: 'Never share verification codes', text: 'YoUnMe will never ask for your password or login codes. Not ever.' },
  { icon: '⚙️', title: 'Review privacy settings', text: 'Revisit your safety choices whenever you like from Settings → Privacy & Safety.' },
];

export const PERMISSION_CARDS = [
  { id: 'notifications', icon: '🔔', title: 'Notifications', text: 'New messages, likes, matches and daily reminders.' },
  { id: 'contacts', icon: '👥', title: 'Find Friends by Contacts', text: 'See which of your contacts are already here. Contacts are never uploaded.' },
  { id: 'microphone', icon: '🎤', title: 'Microphone', text: 'Voice messages and audio calls with your matches.' },
  { id: 'camera', icon: '📷', title: 'Camera', text: 'Profile photos and video calls. The camera never opens on its own.' },
] as const;

/** Small, non-explicit sample list for the profanity demo. */
export const PROFANITY_SAMPLE = ['stupid', 'idiot', 'hate', 'loser'];

export const DEMO_MESSAGE_SUGGESTIONS = [
  'Hi! How is your day going?',
  'https://meet.example.com/chat',
  'Call me at 98765 43210',
  'follow me on instagram @younme_demo',
];

export const DEFAULT_NOTIFICATION_PREFS: NotificationPrefs = {
  messages: true,
  likes: true,
  matches: true,
  requests: true,
  calls: true,
  rewards: false,
  email: false,
  push: true,
};
