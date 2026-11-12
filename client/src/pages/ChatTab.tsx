import React, { useState, useEffect, useRef, useMemo, useCallback } from 'react';
import {
  Send,
  ShieldAlert,
  ShieldCheck,
  Flame,
  Mic,
  Lock,
  PhoneCall,
  CheckCheck,
  Search,
  Phone,
  Video,
  Settings,
  UserPlus,
  Share2,
  MoreVertical,
  VolumeX,
  Volume2,
  Pin,
  Flag,
  Ban,
  ChevronLeft,
  Check,
  X,
  MessageCircle,
  Inbox,
  Gift,
  Plus,
  AlertTriangle,
  Clock,
  RefreshCw,
} from 'lucide-react';
import { MessageItem, MatchItem, MessageRequest } from '../types';

// ============================================================================
// DEMO / CONFIG CONSTANTS
// ============================================================================

// Hard cap on outbound message requests per day.
// TODO(backend): read the real limit from the server (e.g. GET /v1/message-requests/quota)
// instead of hardcoding it here.
const DAILY_REQUEST_LIMIT = 10;

// Message-request intro text is capped at 150 characters (live counter in composer).
const REQUEST_TEXT_LIMIT = 150;

// ============================================================================
// DEMO DATA — conversations.
// `conversations` (component state) is only ever populated from the backend.
// When no backend is reachable we render this constant instead and show a
// "Demo data" chip; nothing here is written into real state.
// Production source: GET /v1/matches.
// NOTE: previews are passed through sanitizePreview() so no phone numbers,
// social handles, links or real IDs are ever rendered.
// ============================================================================
const DEMO_CONVERSATIONS: MatchItem[] = [
  {
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 3).toISOString(),
    source: 'swipe',
    message_pair_count: 6,
    unread_count: 2,
    counterpart: {
      user_id: '22222222-2222-2222-2222-222222222222',
      nickname: 'Ananya',
      age: 24,
      avatar: '/ananya.jpg',
      city: 'Mumbai (Bandra)',
      is_verified: true,
      is_online: true,
      photo_urls: ['/ananya.jpg'],
      bio: 'UI designer & matcha lover 🍵',
    },
    last_message: {
      body: 'Are we still on for Subko this Saturday? ☕',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 12).toISOString(),
    },
  },
  {
    id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 27).toISOString(),
    source: 'spark',
    message_pair_count: 3,
    unread_count: 1,
    counterpart: {
      user_id: '44444444-4444-4444-4444-444444444444',
      nickname: 'Riya',
      age: 23,
      avatar: '/riya.jpg',
      city: 'Mumbai (Colaba)',
      is_verified: true,
      is_online: true,
      photo_urls: ['/riya.jpg'],
      bio: 'Fashion curator & cinema buff 🎬',
    },
    last_message: {
      body: 'That film photography walk sounds fun!',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString(),
    },
  },
  {
    id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 76).toISOString(),
    source: 'swipe',
    message_pair_count: 4,
    unread_count: 0,
    counterpart: {
      user_id: '33333333-3333-3333-3333-333333333333',
      nickname: 'Rohit',
      age: 27,
      avatar: '/rohit.jpg',
      city: 'Mumbai (Juhu)',
      is_verified: true,
      is_online: true,
      photo_urls: ['/rohit.jpg'],
      bio: 'Chasing sunsets by evening 🌇',
    },
    last_message: {
      body: 'Sunrise climb at Kanheri this weekend?',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString(),
    },
  },
  {
    id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 52).toISOString(),
    source: 'swipe',
    message_pair_count: 1,
    unread_count: 0,
    counterpart: {
      user_id: '88888888-8888-8888-8888-888888888888',
      nickname: 'Meera',
      age: 26,
      avatar: '/ananya.jpg',
      city: 'Mumbai (Andheri)',
      is_verified: true,
      is_online: false,
      photo_urls: ['/ananya.jpg'],
      bio: 'Architect by training, ceramicist at heart ☕',
    },
    last_message: {
      body: 'Loved the slow-morning playlist you shared.',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 60 * 20).toISOString(),
    },
  },
  {
    id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 101).toISOString(),
    source: 'like',
    message_pair_count: 0,
    unread_count: 0,
    counterpart: {
      user_id: '66666666-6666-6666-6666-666666666666',
      nickname: 'Priya',
      age: 25,
      avatar: '/ananya.jpg',
      city: 'Mumbai (Worli)',
      is_verified: true,
      is_online: false,
      photo_urls: ['/ananya.jpg'],
      bio: 'Product strategist & avid reader 📚',
    },
    last_message: {
      // Contains a phone number → rendered as "Message hidden (link blocked)".
      body: 'Here is my number just ping me 9812345678',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 60 * 44).toISOString(),
    },
  },
  {
    id: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 120).toISOString(),
    source: 'swipe',
    message_pair_count: 2,
    unread_count: 0,
    counterpart: {
      user_id: '55555555-5555-5555-5555-555555555555',
      nickname: 'Kabir',
      age: 26,
      avatar: '/aditya.jpg',
      city: 'Mumbai (Khar West)',
      is_verified: true,
      is_online: true,
      photo_urls: ['/aditya.jpg'],
      bio: 'Sound designer & vinyl collector 🎧',
    },
    last_message: {
      body: 'Sending you a playlist of rare jazz finds.',
      type: 'text',
      created_at: new Date(Date.now() - 1000 * 60 * 60 * 40).toISOString(),
    },
  },
  {
    id: '11111111-aaaa-aaaa-aaaa-111111111111',
    matched_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 9).toISOString(),
    source: 'swipe',
    message_pair_count: 0,
    unread_count: 0,
    counterpart: {
      user_id: '77777777-7777-7777-7777-777777777777',
      nickname: 'Tara',
      age: 24,
      avatar: '/aditya.jpg',
      city: 'Mumbai (Juhu)',
      is_verified: false,
      is_online: false,
      photo_urls: ['/aditya.jpg'],
      bio: 'Chasing golden hour sunsets along Juhu beach 🌅',
    },
  },
];

// Received message requests (demo). Production: GET /v1/message-requests?direction=received.
const DEMO_REQUESTS_RECEIVED: MessageRequest[] = [
  {
    id: 'req-recv-1',
    user_id: 'r1111111-1111-1111-1111-111111111111',
    nickname: 'Sana',
    age: 25,
    avatar: '/riya.jpg',
    is_verified: true,
    is_online: true,
    city: 'Mumbai (Bandra)',
    message: 'Loved your vinyl playlist! Would you be up for a gig this weekend?',
    direction: 'received',
    created_at: new Date(Date.now() - 1000 * 60 * 40).toISOString(),
  },
  {
    id: 'req-recv-2',
    user_id: 'r2222222-2222-2222-2222-222222222222',
    nickname: 'Aryan',
    age: 30,
    avatar: '/rohit.jpg',
    is_verified: true,
    is_online: false,
    city: 'Mumbai (Andheri)',
    // Contains a phone number → shown as "Message hidden (link blocked)".
    message: 'Hey! Ping me on 9823456789 so we can plan faster.',
    direction: 'received',
    created_at: new Date(Date.now() - 1000 * 60 * 60 * 3).toISOString(),
  },
  {
    id: 'req-recv-3',
    user_id: 'r3333333-3333-3333-3333-333333333333',
    nickname: 'Nisha',
    age: 22,
    avatar: '/ananya.jpg',
    is_verified: false,
    is_online: true,
    city: 'Mumbai (Powai)',
    // Contains a link → shown as "Message hidden (link blocked)".
    message: 'Check my portfolio at https://example.com/nisha — would love your thoughts.',
    direction: 'received',
    created_at: new Date(Date.now() - 1000 * 60 * 60 * 26).toISOString(),
  },
];

// Sent message requests (demo). Production: GET /v1/message-requests?direction=sent.
const DEMO_REQUESTS_SENT: MessageRequest[] = [
  {
    id: 'req-sent-1',
    user_id: 's1111111-1111-1111-1111-111111111111',
    nickname: 'Dev',
    age: 27,
    avatar: '/aditya.jpg',
    is_verified: true,
    is_online: false,
    city: 'Mumbai (Juhu)',
    message: 'Hey! Noticed we both love bouldering 🧗 Free to climb sometime?',
    direction: 'sent',
    created_at: new Date(Date.now() - 1000 * 60 * 60 * 8).toISOString(),
  },
  {
    id: 'req-sent-2',
    user_id: 's2222222-2222-2222-2222-222222222222',
    nickname: 'Tara',
    age: 24,
    avatar: '/riya.jpg',
    is_verified: false,
    is_online: false,
    city: 'Mumbai (Juhu)',
    message: 'Hi! Your ceramic work looks amazing — what got you started?',
    direction: 'sent',
    created_at: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString(),
  },
];

// Recipients selectable in the demo "New Request" composer.
const DEMO_REQUEST_TARGETS = [
  { user_id: 's3333333-3333-3333-3333-333333333333', nickname: 'Priya', avatar: '/ananya.jpg' },
  { user_id: 's4444444-4444-4444-4444-444444444444', nickname: 'Rohit', avatar: '/rohit.jpg' },
  { user_id: 's5555555-5555-5555-5555-555555555555', nickname: 'Meera', avatar: '/ananya.jpg' },
];

// ============================================================================
// HELPERS
// ============================================================================

const LINK_RE = /(https?:\/\/|www\.|\b(?:wa\.me|t\.me|t\.co|bit\.ly|instagram\.com|snapchat\.com)\b)/i;
const PHONE_RE = /\+?\d[\d\s().-]{6,}\d/;
const HANDLE_RE = /(^|\s)@[a-z0-9._]{2,}/i;

/**
 * Message previews must never expose phone numbers, social handles, links or
 * real IDs. If one is detected we replace the whole preview with a notice.
 */
function sanitizePreview(text?: string): { text: string; blocked: boolean } {
  const body = text || '';
  if (body && (LINK_RE.test(body) || PHONE_RE.test(body) || HANDLE_RE.test(body))) {
    return { text: 'Message hidden (link blocked)', blocked: true };
  }
  return { text: body, blocked: false };
}

/** Relative "time ago" label for a conversation / request timestamp. */
function formatRelativeTime(iso: string): string {
  const then = new Date(iso).getTime();
  if (Number.isNaN(then)) return 'recently';
  const diffMs = Date.now() - then;
  if (diffMs < 0) return 'just now';
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h`;
  const days = Math.floor(hours / 24);
  if (days === 1) return '1d';
  if (days < 30) return `${days}d`;
  const months = Math.floor(days / 30);
  return `${months}mo`;
}

// ============================================================================
// PROPS
// ============================================================================

interface ChatTabProps {
  selectedConvId?: string;
  initialDraft?: string;
  onStartCall: (calleeId: string, name: string, avatar: string) => void;
  /** Opens a conversation (sets selectedConvId + switches to the chat tab). */
  onOpenChat: (convId: string) => void;
  /** Returns from a conversation to the chat list. */
  onBack: () => void;
  /** Opens the existing coin store (used for "Buy Coins" when the daily limit is hit). */
  onOpenStore: () => void;
  /** Jumps to the Connect tab from the empty state. */
  onGoToConnect: () => void;
}

// ============================================================================
// TOP-LEVEL SWITCHER — list vs. conversation room
// ============================================================================

export const ChatTab: React.FC<ChatTabProps> = (props) => {
  const { selectedConvId } = props;

  // ── Shared chat-list state (kept here so filters survive opening a chat) ────
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const [conversations, setConversations] = useState<MatchItem[]>([]);
  const [chatLoadState, setChatLoadState] = useState<'loading' | 'ready' | 'error'>('loading');
  const [usingDemoChats, setUsingDemoChats] = useState(false);
  const [blockedConvIds, setBlockedConvIds] = useState<Set<string>>(new Set());
  const [mutedConvIds, setMutedConvIds] = useState<Set<string>>(new Set());
  const [pinnedConvIds, setPinnedConvIds] = useState<Set<string>>(new Set());
  // Conversations created by accepting a message request (local demo only).
  const [acceptedConversations, setAcceptedConversations] = useState<MatchItem[]>([]);

  const [requestsReceived, setRequestsReceived] = useState<MessageRequest[]>(DEMO_REQUESTS_RECEIVED);
  const [requestsSent, setRequestsSent] = useState<MessageRequest[]>(DEMO_REQUESTS_SENT);
  const [usingDemoRequests] = useState(true);
  const [requestsUsedToday, setRequestsUsedToday] = useState(3);

  // Loads the real conversation list. Demo data is NEVER written into
  // `conversations`; when the backend is unavailable we render DEMO_CONVERSATIONS
  // with a "Demo data" chip. `asError` powers the manual Retry button.
  const loadChats = useCallback(async (opts?: { asError?: boolean }) => {
    setChatLoadState('loading');
    try {
      const res = await fetch('/v1/matches?user_id=11111111-1111-1111-1111-111111111111');
      const data = await res.json();
      if (data?.success && Array.isArray(data.matches) && data.matches.length > 0) {
        setConversations(data.matches);
        setUsingDemoChats(false);
      } else {
        setUsingDemoChats(true);
      }
      setChatLoadState('ready');
    } catch (err) {
      if (opts?.asError) {
        setChatLoadState('error');
        return;
      }
      // No backend in this build → labelled demo fallback.
      setUsingDemoChats(true);
      setChatLoadState('ready');
    }
  }, []);

  useEffect(() => {
    loadChats();
  }, [loadChats]);

  // The list actually rendered: real data when available, else labelled demo.
  // Accepted requests (local demo) are prepended so they show in Messages and
  // can be opened as a conversation.
  const displayConversations = useMemo(
    () => [...acceptedConversations, ...(usingDemoChats ? DEMO_CONVERSATIONS : conversations)],
    [acceptedConversations, usingDemoChats, conversations]
  );

  if (selectedConvId) {
    const active = displayConversations.find((c) => c.id === selectedConvId);
    return (
      <ChatRoom
        convId={selectedConvId}
        counterpart={active?.counterpart}
        onStartCall={props.onStartCall}
        onBack={props.onBack}
        initialDraft={props.initialDraft}
      />
    );
  }

  return (
    <ChatList
      conversations={displayConversations}
      loadState={chatLoadState}
      usingDemo={usingDemoChats}
      onRetry={() => loadChats({ asError: true })}
      blockedConvIds={blockedConvIds}
      setBlockedConvIds={setBlockedConvIds}
      mutedConvIds={mutedConvIds}
      setMutedConvIds={setMutedConvIds}
      pinnedConvIds={pinnedConvIds}
      setPinnedConvIds={setPinnedConvIds}
      setAcceptedConversations={setAcceptedConversations}
      requestsReceived={requestsReceived}
      setRequestsReceived={setRequestsReceived}
      requestsSent={requestsSent}
      setRequestsSent={setRequestsSent}
      usingDemoRequests={usingDemoRequests}
      requestsUsedToday={requestsUsedToday}
      setRequestsUsedToday={setRequestsUsedToday}
      onOpenChat={props.onOpenChat}
      onOpenStore={props.onOpenStore}
      onGoToConnect={props.onGoToConnect}
      showToast={showToast}
      toastMessage={toastMessage}
    />
  );
};

// ============================================================================
// CHAT LIST
// ============================================================================

interface ChatListProps {
  conversations: MatchItem[];
  loadState: 'loading' | 'ready' | 'error';
  usingDemo: boolean;
  onRetry: () => void;
  blockedConvIds: Set<string>;
  setBlockedConvIds: React.Dispatch<React.SetStateAction<Set<string>>>;
  mutedConvIds: Set<string>;
  setMutedConvIds: React.Dispatch<React.SetStateAction<Set<string>>>;
  pinnedConvIds: Set<string>;
  setPinnedConvIds: React.Dispatch<React.SetStateAction<Set<string>>>;
  setAcceptedConversations: React.Dispatch<React.SetStateAction<MatchItem[]>>;
  requestsReceived: MessageRequest[];
  setRequestsReceived: React.Dispatch<React.SetStateAction<MessageRequest[]>>;
  requestsSent: MessageRequest[];
  setRequestsSent: React.Dispatch<React.SetStateAction<MessageRequest[]>>;
  usingDemoRequests: boolean;
  requestsUsedToday: number;
  setRequestsUsedToday: React.Dispatch<React.SetStateAction<number>>;
  onOpenChat: (convId: string) => void;
  onOpenStore: () => void;
  onGoToConnect: () => void;
  showToast: (msg: string) => void;
  toastMessage: string | null;
}

type ChatFilter = 'all' | 'unread' | 'online' | 'verified';

const ChatList: React.FC<ChatListProps> = ({
  conversations,
  loadState,
  usingDemo,
  onRetry,
  blockedConvIds,
  setBlockedConvIds,
  mutedConvIds,
  setMutedConvIds,
  pinnedConvIds,
  setPinnedConvIds,
  setAcceptedConversations,
  requestsReceived,
  setRequestsReceived,
  requestsSent,
  setRequestsSent,
  usingDemoRequests,
  requestsUsedToday,
  setRequestsUsedToday,
  onOpenChat,
  onOpenStore,
  onGoToConnect,
  showToast,
  toastMessage,
}) => {
  const [section, setSection] = useState<'messages' | 'requests'>('messages');
  const [requestSubTab, setRequestSubTab] = useState<'received' | 'sent'>('received');
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<ChatFilter>('all');

  // Sheets / menus
  const [menuConv, setMenuConv] = useState<MatchItem | null>(null);
  const [blockConfirmConv, setBlockConfirmConv] = useState<MatchItem | null>(null);
  const [showSettings, setShowSettings] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [showComposer, setShowComposer] = useState(false);

  // Settings (local demo only)
  const [whoCanMessage, setWhoCanMessage] = useState<'everyone' | 'matches' | 'nobody'>('matches');

  // Composer state
  const [requestText, setRequestText] = useState('');
  const [requestTarget, setRequestTarget] = useState(DEMO_REQUEST_TARGETS[0]);

  // ── Derived lists ──────────────────────────────────────────────────────────
  const baseConversations = useMemo(
    () => conversations.filter((c) => !blockedConvIds.has(c.id)),
    [conversations, blockedConvIds]
  );

  const totalUnread = baseConversations.reduce((sum, c) => sum + (c.unread_count || 0), 0);

  const visibleConversations = useMemo(() => {
    const q = query.trim().toLowerCase();
    const filtered = baseConversations.filter((c) => {
      if (filter === 'unread' && !(c.unread_count && c.unread_count > 0)) return false;
      if (filter === 'online' && !c.counterpart.is_online) return false;
      if (filter === 'verified' && !c.counterpart.is_verified) return false;
      if (q && !c.counterpart.nickname.toLowerCase().includes(q)) return false;
      return true;
    });
    // Pinned first, then newest activity, capped at 50 rows.
    filtered.sort((a, b) => {
      const pa = pinnedConvIds.has(a.id) ? 1 : 0;
      const pb = pinnedConvIds.has(b.id) ? 1 : 0;
      if (pa !== pb) return pb - pa;
      const ta = new Date(a.last_message?.created_at || a.matched_at).getTime();
      const tb = new Date(b.last_message?.created_at || b.matched_at).getTime();
      return tb - ta;
    });
    return filtered.slice(0, 50);
  }, [baseConversations, filter, query, pinnedConvIds]);

  // ── Actions ────────────────────────────────────────────────────────────────
  const toggleMute = (id: string) => {
    setMutedConvIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
    setMenuConv(null);
  };

  const togglePin = (id: string) => {
    setPinnedConvIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
    setMenuConv(null);
  };

  const reportConv = (conv: MatchItem) => {
    setMenuConv(null);
    // Local-only; a real build would POST /v1/reports.
    showToast(`Report received for ${conv.counterpart.nickname}. Our team will review.`);
  };

  const confirmBlock = () => {
    if (!blockConfirmConv) return;
    const name = blockConfirmConv.counterpart.nickname;
    setBlockedConvIds((prev) => new Set(prev).add(blockConfirmConv.id));
    setBlockConfirmConv(null);
    showToast(`${name} has been blocked.`);
  };

  const acceptRequest = (req: MessageRequest) => {
    setRequestsReceived((prev) => prev.filter((r) => r.id !== req.id));
    // Local demo only: surface the accepted request as a conversation.
    // A real build would POST /v1/message-requests/{id}/accept then reload.
    const conv: MatchItem = {
      id: `req-${req.id}`,
      matched_at: new Date().toISOString(),
      source: 'request',
      message_pair_count: 0,
      unread_count: 0,
      counterpart: {
        user_id: req.user_id,
        nickname: req.nickname,
        age: req.age,
        avatar: req.avatar,
        city: req.city || '',
        is_verified: req.is_verified,
        is_online: req.is_online,
        photo_urls: [req.avatar],
      },
      last_message: { body: req.message, type: 'text', created_at: req.created_at },
    };
    setAcceptedConversations((prev) => [conv, ...prev]);
    setSection('messages');
    showToast(`Request from ${req.nickname} accepted (demo)`);
  };

  const declineRequest = (req: MessageRequest) => {
    setRequestsReceived((prev) => prev.filter((r) => r.id !== req.id));
    // Local demo only; a real build would POST /v1/message-requests/{id}/decline.
    showToast(`Request from ${req.nickname} declined`);
  };

  const sendRequest = () => {
    const text = requestText.trim();
    if (!text || requestsUsedToday >= DAILY_REQUEST_LIMIT) return;
    const sent: MessageRequest = {
      id: `req-sent-${Date.now()}`,
      user_id: requestTarget.user_id,
      nickname: requestTarget.nickname,
      avatar: requestTarget.avatar,
      is_verified: true,
      message: text,
      direction: 'sent',
      created_at: new Date().toISOString(),
    };
    // Local demo only; a real build would POST /v1/message-requests.
    setRequestsSent((prev) => [sent, ...prev]);
    setRequestsUsedToday((u) => u + 1);
    setRequestText('');
    setShowComposer(false);
    showToast(`Request sent to ${requestTarget.nickname} (demo)`);
  };

  const shareInvite = () => {
    // navigator.share is only offered where the Web Share API exists.
    if (typeof navigator !== 'undefined' && (navigator as any).share) {
      (navigator as any)
        .share({ title: 'Join me on YoUnMe', text: 'Join me on YoUnMe — a kinder way to meet people.' })
        .catch(() => undefined);
    } else {
      showToast('Sharing is not supported on this device');
    }
  };

  const filters: { key: ChatFilter; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'unread', label: 'Unread' },
    { key: 'online', label: 'Online' },
    { key: 'verified', label: 'Verified' },
  ];

  const limitReached = requestsUsedToday >= DAILY_REQUEST_LIMIT;

  // Contextual empty copy for the filtered message list.
  const emptyMessage =
    filter === 'unread'
      ? 'No unread chats'
      : filter === 'online'
        ? 'No one is online right now'
        : filter === 'verified'
          ? 'No verified chats yet'
          : 'No chats yet. Start from Connect';

  // ==========================================================================
  // RENDER
  // ==========================================================================
  return (
    <div className="chat-screen">
      {/* Toast */}
      {toastMessage && (
        <div
          role="status"
          style={{
            position: 'fixed',
            top: '76px',
            left: '50%',
            transform: 'translateX(-50%)',
            background: 'rgba(20, 24, 38, 0.95)',
            border: '1px solid rgba(255, 45, 85, 0.4)',
            borderRadius: 'var(--radius-full)',
            padding: '10px 20px',
            fontSize: '13px',
            fontWeight: 700,
            color: '#ffffff',
            zIndex: 90,
            boxShadow: 'var(--shadow-glow)',
            maxWidth: '90vw',
            textAlign: 'center',
            backdropFilter: 'blur(16px)',
          }}
        >
          {toastMessage}
        </div>
      )}

      {/* Header */}
      <div className="chat-header">
        <div style={{ minWidth: 0 }}>
          <h1 style={{ fontSize: '22px', fontWeight: 800, letterSpacing: '-0.4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <MessageCircle size={22} color="#ff2d55" />
            Chats
            {totalUnread > 0 && (
              <span className="chat-unread-badge">{totalUnread > 99 ? '99+' : totalUnread}</span>
            )}
          </h1>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
            Messages, requests & connections
          </p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexShrink: 0 }}>
          <button
            type="button"
            className="chat-icon-btn"
            aria-label="Audio call"
            title="Audio call"
            onClick={() => showToast('Calls are available inside a chat')}
          >
            <Phone size={17} />
          </button>
          <button
            type="button"
            className="chat-icon-btn"
            aria-label="Video call"
            title="Video call"
            onClick={() => showToast('Calls are available inside a chat')}
          >
            <Video size={17} />
          </button>
          <button
            type="button"
            className="chat-icon-btn"
            aria-label="Chat settings"
            title="Chat settings"
            onClick={() => setShowSettings(true)}
          >
            <Settings size={17} />
          </button>
        </div>
      </div>

      {/* Demo chip */}
      {(usingDemo || usingDemoRequests) && (
        <span
          title="Demo data — no backend connected"
          style={{ display: 'inline-block', marginBottom: '12px', background: 'rgba(255, 215, 0, 0.08)', border: '1px solid rgba(255, 215, 0, 0.25)', borderRadius: 'var(--radius-full)', padding: '4px 10px', fontSize: '10px', fontWeight: 700, color: '#ffd700' }}
        >
          Demo data
        </span>
      )}

      {/* Section tabs */}
      <div className="seg-tabs" role="tablist" style={{ marginBottom: '14px' }}>
        <button
          type="button"
          role="tab"
          aria-selected={section === 'messages'}
          className={`seg-tab ${section === 'messages' ? 'active' : ''}`}
          onClick={() => setSection('messages')}
        >
          <MessageCircle size={15} /> Messages
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={section === 'requests'}
          className={`seg-tab ${section === 'requests' ? 'active' : ''}`}
          onClick={() => setSection('requests')}
        >
          <Inbox size={15} /> Requests
          {requestsReceived.length > 0 && (
            <span className="chat-unread-badge">{requestsReceived.length}</span>
          )}
        </button>
      </div>

      {section === 'messages' ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {/* Search */}
          <div className="chat-search">
            <Search size={16} color="var(--text-muted)" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search chats by name"
              aria-label="Search chats by name"
            />
            {query && (
              <button
                type="button"
                className="chat-row-menu"
                aria-label="Clear search"
                style={{ width: '32px', height: '32px' }}
                onClick={() => setQuery('')}
              >
                <X size={15} />
              </button>
            )}
          </div>

          {/* Invite CTA */}
          <div className="invite-card">
            <div style={{ width: '42px', height: '42px', borderRadius: '50%', background: 'rgba(255,45,85,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <UserPlus size={20} color="#ff2d55" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: '14px', fontWeight: 700 }}>Invite to App</div>
              <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Find friends already on YoUnMe
              </div>
            </div>
            <button
              type="button"
              className="btn-primary"
              style={{ padding: '10px 14px', fontSize: '12px', gap: '6px', flexShrink: 0 }}
              onClick={() => setShowInvite(true)}
            >
              <UserPlus size={14} />
              Sync
            </button>
          </div>

          {/* Filter chips */}
          <div className="chat-filters" role="group" aria-label="Filter chats">
            {filters.map((f) => (
              <button
                key={f.key}
                type="button"
                className={`filter-pill ${filter === f.key ? 'active' : ''}`}
                aria-pressed={filter === f.key}
                onClick={() => setFilter(f.key)}
              >
                {f.label}
              </button>
            ))}
          </div>

          {/* List / states */}
          {loadState === 'loading' ? (
            <div className="chat-list" aria-hidden="true">
              {[0, 1, 2, 3, 4].map((i) => (
                <div key={i} className="chat-skeleton-row">
                  <div className="skeleton" style={{ width: '50px', height: '50px', borderRadius: '50%', flexShrink: 0 }} />
                  <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <div className="skeleton" style={{ width: '40%', height: '12px', borderRadius: '6px' }} />
                    <div className="skeleton" style={{ width: '75%', height: '10px', borderRadius: '6px' }} />
                  </div>
                </div>
              ))}
            </div>
          ) : loadState === 'error' ? (
            <div className="chat-empty">
              <AlertTriangle size={34} color="#ffa502" />
              <div style={{ fontSize: '15px', fontWeight: 700 }}>Couldn&apos;t load chats</div>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Check your connection and try again.
              </p>
              <button type="button" className="btn-primary" style={{ padding: '11px 20px', fontSize: '13px', gap: '6px' }} onClick={onRetry}>
                <RefreshCw size={15} />
                Retry
              </button>
            </div>
          ) : visibleConversations.length === 0 ? (
            <div className="chat-empty">
              <MessageCircle size={34} color="var(--text-muted)" />
              <div style={{ fontSize: '15px', fontWeight: 700 }}>{emptyMessage}</div>
              {filter === 'all' && !query && (
                <>
                  <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                    Mutual matches show up here. Go meet someone new.
                  </p>
                  <button type="button" className="btn-primary" style={{ padding: '11px 20px', fontSize: '13px', gap: '6px' }} onClick={onGoToConnect}>
                    Go to Connect
                  </button>
                </>
              )}
            </div>
          ) : (
            <div className="chat-list">
              {visibleConversations.map((conv) => (
                <ChatRow
                  key={conv.id}
                  conv={conv}
                  muted={mutedConvIds.has(conv.id)}
                  pinned={pinnedConvIds.has(conv.id)}
                  onOpen={() => onOpenChat(conv.id)}
                  onMenu={() => setMenuConv(conv)}
                />
              ))}
            </div>
          )}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {/* Sub-tabs */}
          <div className="seg-tabs" role="tablist">
            <button
              type="button"
              role="tab"
              aria-selected={requestSubTab === 'received'}
              className={`seg-tab ${requestSubTab === 'received' ? 'active' : ''}`}
              onClick={() => setRequestSubTab('received')}
            >
              <Inbox size={15} /> Received ({requestsReceived.length})
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={requestSubTab === 'sent'}
              className={`seg-tab ${requestSubTab === 'sent' ? 'active' : ''}`}
              onClick={() => setRequestSubTab('sent')}
            >
              <Send size={15} /> Sent ({requestsSent.length})
            </button>
          </div>

          {/* Daily quota + New request */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '10px', flexWrap: 'wrap' }}>
            <div style={{ fontSize: '12px', color: limitReached ? '#ffa502' : 'var(--text-secondary)', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Clock size={13} />
              {requestsUsedToday}/{DAILY_REQUEST_LIMIT} requests used today
            </div>
            {limitReached ? (
              <button type="button" className="btn-gold" style={{ padding: '10px 14px', fontSize: '12px', display: 'inline-flex', alignItems: 'center', gap: '6px' }} onClick={onOpenStore}>
                <Gift size={14} />
                Buy Coins
              </button>
            ) : (
              <button type="button" className="btn-primary" style={{ padding: '10px 14px', fontSize: '12px', display: 'inline-flex', alignItems: 'center', gap: '6px' }} onClick={() => setShowComposer(true)}>
                <Plus size={14} />
                New Request
              </button>
            )}
          </div>

          {limitReached && (
            <div style={{ padding: '10px 12px', borderRadius: 'var(--radius-md)', background: 'rgba(255,170,0,0.08)', border: '1px solid rgba(255,170,0,0.3)', fontSize: '12px', color: '#ffd700' }}>
              Daily limit reached. Buy coins to send more requests.
              {/* TODO(backend): confirm whether extra requests are a paid action. */}
            </div>
          )}

          {requestSubTab === 'received' ? (
            requestsReceived.length === 0 ? (
              <div className="chat-empty">
                <Inbox size={34} color="var(--text-muted)" />
                <div style={{ fontSize: '15px', fontWeight: 700 }}>No pending requests</div>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                  New message requests will appear here.
                </p>
              </div>
            ) : (
              <div className="chat-list">
                {requestsReceived.map((req) => (
                  <RequestCard
                    key={req.id}
                    req={req}
                    onAccept={() => acceptRequest(req)}
                    onDecline={() => declineRequest(req)}
                  />
                ))}
              </div>
            )
          ) : requestsSent.length === 0 ? (
            <div className="chat-empty">
              <Send size={34} color="var(--text-muted)" />
              <div style={{ fontSize: '15px', fontWeight: 700 }}>No sent requests</div>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Requests you send will appear here until they&apos;re accepted.
              </p>
            </div>
          ) : (
            <div className="chat-list">
              {requestsSent.map((req) => (
                <SentRequestCard key={req.id} req={req} />
              ))}
            </div>
          )}
        </div>
      )}

      {/* ================= Conversation row menu ================= */}
      {menuConv && (
        <div className="bottom-sheet-overlay" onClick={() => setMenuConv(null)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '16px 18px 24px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '14px' }}>
              <img src={menuConv.counterpart.avatar} alt="" style={{ width: '44px', height: '44px', borderRadius: '50%', objectFit: 'cover' }} />
              <div style={{ fontSize: '15px', fontWeight: 700 }}>{menuConv.counterpart.nickname}</div>
            </div>
            <MenuItem
              icon={mutedConvIds.has(menuConv.id) ? <Volume2 size={18} /> : <VolumeX size={18} />}
              label={mutedConvIds.has(menuConv.id) ? 'Unmute notifications' : 'Mute notifications'}
              onClick={() => toggleMute(menuConv.id)}
            />
            <MenuItem
              icon={<Pin size={18} />}
              label={pinnedConvIds.has(menuConv.id) ? 'Unpin chat' : 'Pin chat'}
              onClick={() => togglePin(menuConv.id)}
            />
            <MenuItem icon={<Flag size={18} />} label="Report" onClick={() => reportConv(menuConv)} />
            <MenuItem icon={<Ban size={18} />} label="Block" danger onClick={() => setBlockConfirmConv(menuConv)} />
            <button type="button" className="btn-ghost" style={{ width: '100%', padding: '12px', marginTop: '8px' }} onClick={() => setMenuConv(null)}>
              Cancel
            </button>
          </div>
        </div>
      )}

      {/* ================= Block confirmation ================= */}
      {blockConfirmConv && (
        <div className="bottom-sheet-overlay" onClick={() => setBlockConfirmConv(null)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '24px', textAlign: 'center' }}>
            <Ban size={38} color="#ff4757" style={{ margin: '0 auto 12px', display: 'block' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>
              Block {blockConfirmConv.counterpart.nickname}?
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              You won&apos;t see messages from them and they&apos;ll disappear from your chats.
            </p>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" className="btn-ghost" style={{ flex: 1, padding: '12px' }} onClick={() => setBlockConfirmConv(null)}>
                Cancel
              </button>
              <button type="button" className="btn-primary" style={{ flex: 1, padding: '12px', background: '#ff4757', boxShadow: 'none' }} onClick={confirmBlock}>
                Block
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= Settings sheet ================= */}
      {showSettings && (
        <div className="bottom-sheet-overlay" onClick={() => setShowSettings(false)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '20px 18px 26px' }}>
            <h3 style={{ fontSize: '17px', fontWeight: 800, marginBottom: '4px' }}>Chat settings</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              Demo setting — not saved to your account yet.
              {/* TODO(backend): persist via the profile settings API. */}
            </p>
            <div style={{ fontSize: '13px', fontWeight: 700, marginBottom: '10px' }}>Who can message me</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {([
                { key: 'everyone', label: 'Everyone', desc: 'Anyone can send you a message request.' },
                { key: 'matches', label: 'Matches', desc: 'Only people you\u2019ve matched with.' },
                { key: 'nobody', label: 'Nobody', desc: 'No new message requests.' },
              ] as const).map((opt) => (
                <button
                  key={opt.key}
                  type="button"
                  onClick={() => setWhoCanMessage(opt.key)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    width: '100%',
                    minHeight: '56px',
                    padding: '12px 14px',
                    textAlign: 'left',
                    cursor: 'pointer',
                    borderRadius: 'var(--radius-md)',
                    background: whoCanMessage === opt.key ? 'rgba(255,45,85,0.12)' : 'rgba(255,255,255,0.03)',
                    border: whoCanMessage === opt.key ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                  }}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: '14px', fontWeight: 700 }}>{opt.label}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{opt.desc}</div>
                  </div>
                  {whoCanMessage === opt.key && <Check size={18} color="#ff2d55" />}
                </button>
              ))}
            </div>
            <button type="button" className="btn-ghost" style={{ width: '100%', padding: '12px', marginTop: '16px' }} onClick={() => setShowSettings(false)}>
              Done
            </button>
          </div>
        </div>
      )}

      {/* ================= Invite / contacts sheet ================= */}
      {showInvite && (
        <div className="bottom-sheet-overlay" onClick={() => setShowInvite(false)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '24px', textAlign: 'center' }}>
            <UserPlus size={38} color="#ff2d55" style={{ margin: '0 auto 12px', display: 'block' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>Invite to YoUnMe</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              Contact syncing isn&apos;t enabled in this build. You can still share your invite link with friends.
            </p>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" className="btn-ghost" style={{ flex: 1, padding: '12px' }} onClick={() => setShowInvite(false)}>
                Close
              </button>
              <button type="button" className="btn-primary" style={{ flex: 1, padding: '12px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }} onClick={shareInvite}>
                <Share2 size={15} />
                Share invite
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ================= New message request composer ================= */}
      {showComposer && (
        <div className="bottom-sheet-overlay" onClick={() => setShowComposer(false)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '20px 18px 26px' }}>
            <h3 style={{ fontSize: '17px', fontWeight: 800, marginBottom: '4px' }}>New message request</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '14px' }}>
              Keep it short and kind. Requests are capped at {REQUEST_TEXT_LIMIT} characters.
            </p>

            {/* Recipient (demo picker) */}
            <div style={{ fontSize: '12px', fontWeight: 700, marginBottom: '8px' }}>To</div>
            <div className="chat-filters" style={{ marginBottom: '14px' }}>
              {DEMO_REQUEST_TARGETS.map((t) => (
                <button
                  key={t.user_id}
                  type="button"
                  onClick={() => setRequestTarget(t)}
                  className={`filter-pill ${requestTarget.user_id === t.user_id ? 'active' : ''}`}
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
                >
                  <img src={t.avatar} alt="" style={{ width: '20px', height: '20px', borderRadius: '50%', objectFit: 'cover' }} />
                  {t.nickname}
                </button>
              ))}
            </div>

            <textarea
              value={requestText}
              onChange={(e) => setRequestText(e.target.value.slice(0, REQUEST_TEXT_LIMIT))}
              placeholder="Say something friendly..."
              rows={4}
              maxLength={REQUEST_TEXT_LIMIT}
              style={{
                width: '100%',
                resize: 'none',
                padding: '12px 14px',
                borderRadius: 'var(--radius-md)',
                background: 'rgba(255,255,255,0.06)',
                border: '1px solid var(--border-glass)',
                color: '#ffffff',
                fontSize: '13.5px',
                outline: 'none',
                lineHeight: 1.5,
                boxSizing: 'border-box',
              }}
            />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '6px', marginBottom: '14px', fontSize: '11px', color: 'var(--text-muted)' }}>
              <span>
                {requestText.length}/{REQUEST_TEXT_LIMIT}
              </span>
              <span className="req-tag-pending" style={{ color: '#ffd700' }}>
                Demo — not sent to a real user
              </span>
            </div>

            {/* Disabled extras */}
            <div style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
              <button type="button" className="chat-icon-btn" disabled title="Coming soon" aria-label="Audio request (coming soon)">
                <Mic size={17} />
              </button>
              <button type="button" className="chat-icon-btn" disabled title="Coming soon" aria-label="Send a bitmoji gift (coming soon)">
                <Gift size={17} />
              </button>
              <span style={{ alignSelf: 'center', fontSize: '11px', color: 'var(--text-muted)' }}>
                Audio &amp; gifts — Coming soon
              </span>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" className="btn-ghost" style={{ flex: 1, padding: '12px' }} onClick={() => setShowComposer(false)}>
                Cancel
              </button>
              <button
                type="button"
                className="btn-primary"
                style={{ flex: 1, padding: '12px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '6px', opacity: requestText.trim() ? 1 : 0.5 }}
                disabled={!requestText.trim()}
                onClick={sendRequest}
              >
                <Send size={15} />
                Send
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

const ChatRow: React.FC<{
  conv: MatchItem;
  muted: boolean;
  pinned: boolean;
  onOpen: () => void;
  onMenu: () => void;
}> = ({ conv, muted, pinned, onOpen, onMenu }) => {
  const { counterpart, last_message, unread_count } = conv;
  const preview = sanitizePreview(last_message?.body);
  const timestamp = counterpart.is_online && !last_message ? 'Active' : formatRelativeTime(last_message?.created_at || conv.matched_at);
  const hasUnread = (unread_count || 0) > 0;

  return (
    <div
      className="chat-row"
      role="button"
      tabIndex={0}
      aria-label={`Open chat with ${counterpart.nickname}`}
      onClick={onOpen}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onOpen();
        }
      }}
    >
      <div className="chat-row-avatar">
        <img src={counterpart.avatar} alt="" />
        {counterpart.is_online && <span className="status-dot-online" aria-label="Online" />}
      </div>

      <div className="chat-row-body">
        <div className="chat-row-name">
          <span>{counterpart.nickname}</span>
          {counterpart.is_verified && <span className="badge-blue-tick" aria-label="Verified">✓</span>}
          {pinned && <Pin size={12} color="var(--text-muted)" aria-label="Pinned" />}
          {muted && <VolumeX size={12} color="var(--text-muted)" aria-label="Muted" />}
        </div>
        <div className={`chat-row-preview ${preview.blocked ? 'is-blocked' : ''}`}>
          {preview.text || 'You matched! Say hi 👋'}
        </div>
      </div>

      <div className="chat-row-meta">
        <span>{timestamp}</span>
        {hasUnread && <span className="chat-unread-badge">{unread_count}</span>}
      </div>

      <button
        type="button"
        className="chat-row-menu"
        aria-label={`Options for ${counterpart.nickname}`}
        onClick={(e) => {
          e.stopPropagation();
          onMenu();
        }}
      >
        <MoreVertical size={18} />
      </button>
    </div>
  );
};

const RequestCard: React.FC<{
  req: MessageRequest;
  onAccept: () => void;
  onDecline: () => void;
}> = ({ req, onAccept, onDecline }) => {
  const preview = sanitizePreview(req.message);
  return (
    <div className="req-card">
      <div className="req-head">
        <div className="chat-row-avatar" style={{ width: '46px', height: '46px' }}>
          <img src={req.avatar} alt="" />
          {req.is_online && <span className="status-dot-online" aria-label="Online" />}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="chat-row-name">
            <span>{req.nickname}</span>
            {req.is_verified && <span className="badge-blue-tick" aria-label="Verified">✓</span>}
          </div>
          <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
            {req.city ? `${req.city} · ` : ''}
            {formatRelativeTime(req.created_at)}
          </div>
        </div>
      </div>

      <div className={`req-msg ${preview.blocked ? 'is-blocked' : ''}`}>{preview.text}</div>

      <div className="req-actions">
        <button type="button" className="btn-ghost" onClick={onDecline}>
          <X size={15} /> Decline
        </button>
        <button type="button" className="btn-primary" onClick={onAccept}>
          <Check size={15} /> Accept
        </button>
      </div>
    </div>
  );
};

const SentRequestCard: React.FC<{ req: MessageRequest }> = ({ req }) => {
  const preview = sanitizePreview(req.message);
  return (
    <div className="req-card">
      <div className="req-head">
        <div className="chat-row-avatar" style={{ width: '46px', height: '46px' }}>
          <img src={req.avatar} alt="" />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="chat-row-name">
            <span>{req.nickname}</span>
            {req.is_verified && <span className="badge-blue-tick" aria-label="Verified">✓</span>}
          </div>
          <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{formatRelativeTime(req.created_at)}</div>
        </div>
        <span className="req-tag-pending">Pending</span>
      </div>
      <div className={`req-msg ${preview.blocked ? 'is-blocked' : ''}`} style={{ opacity: 0.85 }}>{preview.text}</div>
    </div>
  );
};

const MenuItem: React.FC<{
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  danger?: boolean;
}> = ({ icon, label, onClick, danger }) => (
  <button
    type="button"
    onClick={onClick}
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: '12px',
      width: '100%',
      minHeight: '48px',
      padding: '12px 10px',
      background: 'transparent',
      border: 'none',
      borderBottom: '1px solid var(--border-glass)',
      color: danger ? '#ff4757' : 'var(--text-primary)',
      fontSize: '14px',
      fontWeight: 600,
      cursor: 'pointer',
      textAlign: 'left',
    }}
  >
    {icon}
    {label}
  </button>
);

// ============================================================================
// CHAT ROOM (existing single-conversation view)
// ============================================================================

interface ChatRoomProps {
  convId: string;
  counterpart?: MatchItem['counterpart'];
  initialDraft?: string;
  onStartCall: (calleeId: string, name: string, avatar: string) => void;
  onBack: () => void;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ convId, counterpart, onStartCall, onBack, initialDraft }) => {
  const name = counterpart?.nickname || 'Ananya';
  const avatar = counterpart?.avatar || '/ananya.jpg';
  const uid = counterpart?.user_id || '22222222-2222-2222-2222-222222222222';
  const city = counterpart?.city || 'Bandra Pali Hill';

  const [messages, setMessages] = useState<MessageItem[]>([]);
  const [inputText, setInputText] = useState(initialDraft || '');
  const [isVanishMode, setIsVanishMode] = useState(false);
  const [guardAlert, setGuardAlert] = useState<{ reason: string; strikes: number } | null>(null);
  const [contactUnlocked, setContactUnlocked] = useState(false);
  const [activeDays, setActiveDays] = useState(1);
  const [pairCount, setPairCount] = useState(6);
  const [isRecording, setIsRecording] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const fetchMessages = async () => {
    try {
      const res = await fetch(`/v1/messages/${convId}`);
      const data = await res.json();
      if (data.success) {
        setMessages(data.messages);
        setContactUnlocked(data.contact_sharing_unlocked);
        setActiveDays(data.active_days);
        setPairCount(data.message_pair_count);
      }
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchMessages();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [convId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;

    setGuardAlert(null);

    try {
      const res = await fetch('/v1/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          conv_id: convId,
          sender_id: '11111111-1111-1111-1111-111111111111',
          type: 'text',
          body: inputText,
          vanish_seconds: isVanishMode ? 60 : null,
        }),
      });

      const data = await res.json();

      if (res.status === 422) {
        // Contact Guard Intercepted!
        setGuardAlert({
          reason: data.reason,
          strikes: data.strike_count,
        });
        return;
      }

      if (data.success) {
        setMessages((prev) => [...prev, data.message]);
        setPairCount(data.message_pair_count);
        setInputText('');

        // Simulate realistic smart reply after 2 seconds.
        if (messages.length % 2 === 0) {
          setTimeout(() => {
            const replies = [
              'Totally agree! Have you listened to the new Peter Cat Recording Co. vinyl?',
              "Subko's cinnamon toast is iconic! We definitely need to grab coffee there soon ☕",
              'Haha that dry wit is dangerous! Are you always this witty on first conversations? 😊',
            ];
            const botReply: MessageItem = {
              id: Date.now(),
              conv_id: convId,
              sender_id: uid,
              type: 'text',
              body: replies[Math.floor(Math.random() * replies.length)],
              is_flagged: false,
              created_at: new Date().toISOString(),
            };
            setMessages((prev) => [...prev, botReply]);
          }, 1800);
        }
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSendAudioNote = () => {
    setIsRecording(true);
    setTimeout(async () => {
      setIsRecording(false);
      try {
        const res = await fetch('/v1/messages', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            conv_id: convId,
            sender_id: '11111111-1111-1111-1111-111111111111',
            type: 'audio',
            body: `🎙️ Voice Note (0:14) — "Hey ${name}, Subko Bandra tomorrow?"`,
            media_url: 'voice_note_subko.mp3',
          }),
        });
        const data = await res.json();
        if (data.success) {
          setMessages((prev) => [...prev, data.message]);
        }
      } catch (err) {
        console.error(err);
      }
    }, 1500);
  };

  return (
    <div style={{ maxWidth: '680px', margin: '20px auto', padding: '0 16px' }}>
      {/* Chat Container */}
      <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', height: '620px', display: 'flex', flexDirection: 'column', overflow: 'hidden', border: '1px solid var(--border-glass)' }}>

        {/* Chat Header */}
        <div style={{ padding: '14px 20px', background: 'rgba(8, 10, 16, 0.9)', borderBottom: '1px solid var(--border-glass)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', minWidth: 0 }}>
            <button
              type="button"
              className="chat-icon-btn"
              aria-label="Back to chats"
              title="Back to chats"
              onClick={onBack}
              style={{ flexShrink: 0 }}
            >
              <ChevronLeft size={18} />
            </button>
            <div style={{ position: 'relative', width: '42px', height: '42px', flexShrink: 0 }}>
              <img
                src={avatar}
                alt={name}
                style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
              />
              {counterpart?.is_online !== false && (
                <div style={{ position: 'absolute', bottom: 0, right: 0, width: '10px', height: '10px', borderRadius: '50%', background: '#00e676', border: '2px solid #080a10' }} />
              )}
            </div>
            <div style={{ minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ fontWeight: 700, fontSize: '15px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</span>
                {counterpart?.is_verified !== false && <span className="badge-blue-tick">✓</span>}
              </div>
              <div style={{ fontSize: '11px', color: '#00e676' }}>Active Now • {city}</div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexShrink: 0 }}>
            {/* Vanish Mode Switch */}
            <button
              onClick={() => setIsVanishMode(!isVanishMode)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                padding: '6px 10px',
                borderRadius: 'var(--radius-full)',
                border: isVanishMode ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                background: isVanishMode ? 'rgba(255, 45, 85, 0.2)' : 'rgba(255, 255, 255, 0.05)',
                color: isVanishMode ? '#ff2d55' : 'var(--text-secondary)',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
              }}
              title="Vanish Mode: Disappearing Ephemeral Messages"
            >
              <Flame size={14} />
              <span>{isVanishMode ? 'Vanish ON' : 'Vanish'}</span>
            </button>

            {/* LiveKit Call Button */}
            <button
              onClick={() => onStartCall(uid, name, avatar)}
              className="btn-primary"
              style={{ padding: '8px 14px', fontSize: '12px', gap: '6px' }}
            >
              <PhoneCall size={14} />
              <span>Call</span>
            </button>
          </div>
        </div>

        {/* Contact Guard Status Ribbon */}
        <div style={{ padding: '8px 16px', background: contactUnlocked ? 'rgba(0, 230, 118, 0.1)' : 'rgba(255, 170, 0, 0.08)', borderBottom: '1px solid rgba(255, 255, 255, 0.05)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px', fontSize: '11px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: contactUnlocked ? '#00e676' : '#ffd700', minWidth: 0 }}>
            {contactUnlocked ? <ShieldCheck size={14} /> : <Lock size={14} />}
            <span>
              {contactUnlocked
                ? 'Trust Phase Complete: Direct contact sharing is unlocked.'
                : `🛡️ Trust Guard Active: Phone numbers & external links locked (Day ${activeDays}/3 • ${pairCount}/20 messages)`}
            </span>
          </div>
          <span style={{ color: 'var(--text-muted)', whiteSpace: 'nowrap' }}>Auto-Unlocks at 20 msgs</span>
        </div>

        {/* Warning Toast if Contact Guard Triggers */}
        {guardAlert && (
          <div style={{ margin: '12px 16px', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 71, 87, 0.15)', border: '1px solid #ff4757', display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
            <ShieldAlert size={18} color="#ff4757" style={{ flexShrink: 0, marginTop: '2px' }} />
            <div>
              <div style={{ fontSize: '13px', fontWeight: 700, color: '#ff4757' }}>Interception: Contact Guard Triggered</div>
              <div style={{ fontSize: '12px', color: '#ffffff', marginTop: '2px' }}>{guardAlert.reason}</div>
              <div style={{ fontSize: '11px', color: 'rgba(255, 255, 255, 0.7)', marginTop: '4px' }}>
                Strike count logged: {guardAlert.strikes}. Please keep interactions within YoUnMe during early acquaintance.
              </div>
            </div>
          </div>
        )}

        {/* Messages Stream */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {messages.map((msg) => {
            const isMe = msg.sender_id === '11111111-1111-1111-1111-111111111111';
            return (
              <div
                key={msg.id}
                style={{
                  alignSelf: isMe ? 'flex-end' : 'flex-start',
                  maxWidth: '75%',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: isMe ? 'flex-end' : 'flex-start',
                }}
              >
                <div
                  style={{
                    padding: '10px 14px',
                    borderRadius: '16px',
                    borderTopRightRadius: isMe ? '4px' : '16px',
                    borderTopLeftRadius: !isMe ? '4px' : '16px',
                    background: isMe ? 'var(--gradient-flame)' : 'rgba(255, 255, 255, 0.08)',
                    color: '#ffffff',
                    fontSize: '13.5px',
                    lineHeight: 1.4,
                    boxShadow: isMe ? 'var(--shadow-glow)' : 'none',
                    border: !isMe ? '1px solid var(--border-glass)' : 'none',
                  }}
                >
                  {msg.body}
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '4px', fontSize: '10px', color: 'var(--text-muted)' }}>
                  <span>{new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                  {isMe && <CheckCheck size={12} color="#00e5ff" />}
                  {msg.expires_at && <span style={{ color: '#ff2d55' }}>🔥 vanish</span>}
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        {/* Chat Input Bar */}
        <form onSubmit={handleSendMessage} style={{ padding: '12px 16px', background: 'rgba(8, 10, 16, 0.95)', borderTop: '1px solid var(--border-glass)', display: 'flex', alignItems: 'center', gap: '10px' }}>
          {/* Audio Note Recorder */}
          <button
            type="button"
            onClick={handleSendAudioNote}
            style={{
              background: isRecording ? '#ff2d55' : 'rgba(255, 255, 255, 0.06)',
              border: 'none',
              borderRadius: '50%',
              width: '38px',
              height: '38px',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)',
              flexShrink: 0,
            }}
            title="Record 2-minute Audio Note"
          >
            <Mic size={18} />
          </button>

          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            placeholder={isRecording ? 'Recording audio note...' : 'Type a message... (Try phone or IG to test guard)'}
            style={{
              flex: 1,
              minWidth: 0,
              padding: '10px 14px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(255, 255, 255, 0.06)',
              border: '1px solid var(--border-glass)',
              color: '#ffffff',
              fontSize: '13px',
              outline: 'none',
            }}
          />

          <button
            type="submit"
            className="btn-primary"
            style={{ width: '38px', height: '38px', borderRadius: '50%', padding: 0, flexShrink: 0 }}
          >
            <Send size={16} />
          </button>
        </form>

      </div>
    </div>
  );
};
