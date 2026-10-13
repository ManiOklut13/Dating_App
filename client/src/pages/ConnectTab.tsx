import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  Heart,
  X,
  Sparkles,
  Zap,
  MessageSquare,
  ShieldCheck,
  Lock,
  MapPin,
  RotateCcw,
  SlidersHorizontal,
  AlertTriangle,
  Ban,
  Info,
  ChevronRight,
  ChevronLeft,
  Coins,
  Check,
  MoreVertical,
  Flag,
  RefreshCw,
} from 'lucide-react';
import { CandidateCard, MatchItem, IncomingLike } from '../types';

interface ConnectTabProps {
  onOpenChat: (convId: string) => void;
  onOpenStore: () => void;
  onMutualMatch?: (profile: CandidateCard) => void;
  /** Current coin balance, used to gate Sparks. */
  coinBalance?: number;
  /** Called after a (demo) coin spend so the wallet stays in sync. */
  onCoinsDeducted?: (newBalance: number) => void;
  /**
   * Viewer gender. The Likes UI stays identical for everyone, but female
   * viewers are steered to the earn/convert flow instead of "Buy Coins".
   * TODO(auth): read this from the authenticated user profile.
   */
  viewerGender?: string;
}

/**
 * How many full profiles a free-tier v1 user can reveal per day.
 * TODO(backend): this MUST be supplied by the backend (daily counter +
 * subscription tier). Hard-coded for the demo only.
 */
const DAILY_LIKES_VIEW_LIMIT = 5;

/** Cost of one Spark / Mega-Crush in coins. TODO(backend): server-authoritative. */
const SPARK_COST = 10;

const defaultCandidates: CandidateCard[] = [
  {
    user_id: '22222222-2222-2222-2222-222222222222',
    nickname: 'Ananya',
    age: 24,
    bio: 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let’s explore quaint cafes or art galleries!',
    city: 'Mumbai (Bandra)',
    distance_km: 0.8,
    photo_urls: ['/ananya.jpg'],
    is_verified: true,
    is_online: true,
    shared_interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨', 'Bandra Cafes 🥐'],
    profile_progress: 95,
    vibe_score: 95,
  },
  {
    user_id: '33333333-3333-3333-3333-333333333333',
    nickname: 'Rohit',
    age: 27,
    bio: 'Architecting spaces by day, chasing sunsets by evening. Fitness, rock climbing, and deep late-night conversations 🌇🧗‍♂️',
    city: 'Mumbai (Juhu)',
    distance_km: 5.3,
    photo_urls: ['/rohit.jpg'],
    is_verified: true,
    is_online: true,
    shared_interests: ['Architecture 🏛️', 'Bouldering 🧗', 'Sunset Runs 🌅', 'Acoustic Rock 🎸'],
    profile_progress: 88,
    vibe_score: 88,
  },
  {
    user_id: '44444444-4444-4444-4444-444444444444',
    nickname: 'Riya',
    age: 23,
    bio: 'Fashion curator & cinema buff 🎬 Weekend flea markets, film photography, and finding the best artisanal gelatos in town.',
    city: 'Mumbai (Colaba)',
    distance_km: 15.2,
    photo_urls: ['/riya.jpg'],
    is_verified: true,
    is_online: false,
    shared_interests: ['Vintage Fashion 👗', '35mm Film 📷', 'Art Cinema 📽️', 'Italian Cuisine 🍕'],
    profile_progress: 91,
    vibe_score: 92,
  },
  {
    user_id: '55555555-5555-5555-5555-555555555555',
    nickname: 'Kabir',
    age: 26,
    bio: 'Sound designer & vinyl collector 🎧 Always on the hunt for obscure jazz records and hidden midnight bakeries in Khar.',
    city: 'Mumbai (Khar West)',
    distance_km: 2.1,
    photo_urls: ['/aditya.jpg'],
    is_verified: true,
    is_online: true,
    shared_interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Night Cycling 🚴', 'Live Jazz 🎷'],
    profile_progress: 89,
    vibe_score: 91,
  },
];

const defaultMatches: MatchItem[] = [
  {
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    matched_at: new Date(Date.now() - 86400000).toISOString(),
    source: 'swipe',
    message_pair_count: 6,
    counterpart: {
      user_id: '22222222-2222-2222-2222-222222222222',
      nickname: 'Ananya',
      age: 24,
      avatar: '/ananya.jpg',
      city: 'Mumbai (Bandra)',
      is_verified: true,
      is_online: true,
      shared_interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
      bio: 'UI designer & matcha lover 🍵 Seeking someone who laughs at witty dry humor. Let’s explore quaint cafes or art galleries!',
      photo_urls: ['/ananya.jpg'],
    },
    last_message: {
      body: 'Hey Arjun! Saw you love filter kaapi and vinyl records. Have you tried Subko in Bandra?',
      type: 'text',
      created_at: new Date(Date.now() - 3600000 * 12).toISOString(),
    },
  },
];

// ============================================================================
// DEMO DATA — incoming "Likes You" entries.
// A person who liked you is NOT a match: they only become a match after you
// like them back. Production source: GET /v1/connect/likes-you.
// TODO(backend): delete this array once the likes-you endpoint is served.
// NOTE: no phone numbers, social handles or real user IDs are ever rendered.
// ============================================================================
const defaultLikesStack: IncomingLike[] = [
  {
    actor_id: '44444444-4444-4444-4444-444444444444',
    nickname: 'Riya',
    age: 23,
    gender: 'Female',
    avatar: '/riya.jpg',
    bitmoji: '/riya.jpg',
    photo_urls: ['/riya.jpg', '/ananya.jpg'],
    city: 'Mumbai (Colaba)',
    distance_km: 4.6,
    action: 'spark',
    is_verified: true,
    is_online: true,
    shared_interests: ['Vintage Fashion 👗', '35mm Film 📷', 'Art Cinema 📽️', 'Italian Cuisine 🍕'],
    bio: 'Fashion curator & cinema buff 🎬 Weekend flea markets and film photography.',
    match_percent: 91,
  },
  {
    actor_id: '66666666-6666-6666-6666-666666666666',
    nickname: 'Priya',
    age: 25,
    gender: 'Female',
    avatar: '/ananya.jpg',
    bitmoji: '/ananya.jpg',
    photo_urls: ['/ananya.jpg'],
    city: 'Mumbai (Worli)',
    distance_km: 8.1,
    action: 'like',
    is_verified: true,
    is_online: true,
    shared_interests: ['Specialty Coffee ☕', 'Modern Art 🎨', 'Live Jazz 🎷'],
    bio: 'Product strategist & avid reader 📚 Chai over coffee any day!',
    match_percent: 84,
  },
  {
    actor_id: '77777777-7777-7777-7777-777777777777',
    nickname: 'Tara',
    age: 24,
    gender: 'Female',
    avatar: '/aditya.jpg',
    bitmoji: '/aditya.jpg',
    photo_urls: ['/aditya.jpg'],
    city: 'Mumbai (Juhu)',
    distance_km: 12.3,
    action: 'like',
    is_verified: false,
    is_online: false,
    shared_interests: ['Sunset Runs 🌅', 'Acoustic Rock 🎸', 'Night Cycling 🚴'],
    bio: 'Chasing golden hour sunsets along Juhu beach 🌅',
    match_percent: 72,
  },
  {
    actor_id: '88888888-8888-8888-8888-888888888888',
    nickname: 'Meera',
    age: 26,
    gender: 'Female',
    avatar: '/ananya.jpg',
    bitmoji: '/ananya.jpg',
    photo_urls: ['/ananya.jpg', '/riya.jpg'],
    city: 'Mumbai (Andheri)',
    distance_km: 6.4,
    action: 'spark',
    is_verified: true,
    is_online: true,
    shared_interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
    bio: 'Architect by training, ceramicist at heart. Big on slow mornings ☕',
    match_percent: 88,
  },
  {
    actor_id: '99999999-9999-9999-9999-999999999999',
    nickname: 'Nisha',
    age: 22,
    gender: 'Female',
    avatar: '/riya.jpg',
    bitmoji: '/riya.jpg',
    photo_urls: ['/riya.jpg'],
    city: 'Mumbai (Powai)',
    distance_km: 18.7,
    action: 'like',
    is_verified: false,
    is_online: false,
    shared_interests: ['35mm Film 📷', 'Art Cinema 📽️', 'Italian Cuisine 🍕'],
    bio: 'Film student documenting Mumbai one frame at a time.',
    match_percent: 69,
  },
  {
    // Restricted profile: stays limited even within the daily view limit.
    actor_id: 'abababab-abab-abab-abab-abababababab',
    nickname: 'Sana',
    age: 27,
    gender: 'Female',
    avatar: '/aditya.jpg',
    bitmoji: '/aditya.jpg',
    photo_urls: ['/aditya.jpg'],
    city: 'Mumbai (Versova)',
    distance_km: 9.9,
    action: 'like',
    is_verified: true,
    is_online: true,
    shared_interests: ['Live Jazz 🎷', 'Specialty Coffee ☕', 'Modern Art 🎨'],
    bio: 'Music producer. Ask me about my vinyl collection.',
    is_restricted: true,
    match_percent: 80,
  },
];

export const ConnectTab: React.FC<ConnectTabProps> = ({
  onOpenChat,
  onOpenStore,
  onMutualMatch,
  coinBalance = 0,
  onCoinsDeducted,
  viewerGender = 'male',
}) => {
  // Navigation tabs: 'discover' | 'matches' | 'likes'
  const [activeTab, setActiveTab] = useState<'discover' | 'matches' | 'likes'>('discover');

  // Candidate card deck state
  const [allCandidates, setAllCandidates] = useState<CandidateCard[]>(defaultCandidates);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [activePhotoIdx, setActivePhotoIdx] = useState(0);
  const [matches, setMatches] = useState<MatchItem[]>(defaultMatches);
  const [likesStack, setLikesStack] = useState<IncomingLike[]>(defaultLikesStack);

  // Drag and swipe mechanics — all hot-path values stored in refs to avoid stale closures
  const [dragOffset, setDragOffset] = useState({ x: 0, y: 0 });
  const [isAnimating, setIsAnimating] = useState(false);
  const [swipeStamp, setSwipeStamp] = useState<'like' | 'dislike' | 'spark' | null>(null);
  const dragActiveRef = useRef(false);
  const dragStartRef = useRef<{ x: number; y: number } | null>(null);
  const dragOffsetRef = useRef({ x: 0, y: 0 });
  const rafRef = useRef<number | null>(null);
  const isAnimatingRef = useRef(false);
  const cardRef = useRef<HTMLDivElement>(null);

  // ── Likes tab ("X Likes You") state ────────────────────────────────────────
  // `is_liked` is tracked locally per admirer. Pass sets it false for the
  // session; a Passed/Blocked profile is removed from the list permanently.
  const [likedAdmirerIds, setLikedAdmirerIds] = useState<Set<string>>(new Set());
  const [passedAdmirerIds, setPassedAdmirerIds] = useState<Set<string>>(new Set());
  const [matchedAdmirerIds, setMatchedAdmirerIds] = useState<Set<string>>(new Set());
  const [sparkedAdmirerIds, setSparkedAdmirerIds] = useState<Set<string>>(new Set());
  const [sparkConfirmAdmirer, setSparkConfirmAdmirer] = useState<IncomingLike | null>(null);
  const [insufficientBalanceOpen, setInsufficientBalanceOpen] = useState(false);
  // 'loading' skeleton → 'ready' → 'error' (with Retry).
  const [likesLoadState, setLikesLoadState] = useState<'loading' | 'ready' | 'error'>('loading');
  // True when the list shown is the local demo fallback (no backend).
  const [usingDemoLikes, setUsingDemoLikes] = useState(false);
  // Demo counter of how many full profiles were revealed today.
  const [likesViewedToday, setLikesViewedToday] = useState(0);
  // Profile bottom sheet: swipeable photos, 3-dot menu, limited treatment.
  const [profilePhotoIdx, setProfilePhotoIdx] = useState(0);
  const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
  const [inspectingProfileLimited, setInspectingProfileLimited] = useState(false);
  const cardTapRef = useRef<{ id: string | null; time: number }>({ id: null, time: 0 });
  const profileSwipeStartRef = useRef<number | null>(null);
  // Likes row: element ref + mouse drag-to-scroll state.
  const likesRowRef = useRef<HTMLDivElement>(null);
  const likesDragRef = useRef({ active: false, moved: false, startX: 0, startScrollLeft: 0, pointerId: -1 });
  const suppressLikesClickRef = useRef(false);

  // Filters state
  const [presetFilter, setPresetFilter] = useState<'recommended' | 'nearby' | 'online' | 'verified'>('recommended');
  const [maxDistance, setMaxDistance] = useState<number>(50);
  const [minAge, setMinAge] = useState<number>(18);
  const [maxAge, setMaxAge] = useState<number>(35);
  const [selectedInterest, setSelectedInterest] = useState<string | null>(null);
  const [isFilterModalOpen, setIsFilterModalOpen] = useState(false);

  // Modals & Bottom sheets
  const [inspectingProfile, setInspectingProfile] = useState<CandidateCard | null>(null);
  const [blockedUserIds, setBlockedUserIds] = useState<Set<string>>(new Set());
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [showBlockDialog, setShowBlockDialog] = useState<CandidateCard | null>(null);
  const [showReportDialog, setShowReportDialog] = useState<CandidateCard | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  // Loads the incoming "Likes You" stack.
  // DEMO BEHAVIOUR: with no backend in this build the request fails and we
  // fall back to labelled demo data. `asError` (used by the manual Refresh
  // control) instead surfaces the error state so Retry can be exercised.
  const loadLikes = useCallback(async (opts?: { asError?: boolean }) => {
    setLikesLoadState('loading');
    try {
      const res = await fetch('/v1/connect/likes-you?user_id=11111111-1111-1111-1111-111111111111');
      const data = await res.json();
      if (data?.success && Array.isArray(data.likes_stack) && data.likes_stack.length > 0) {
        setLikesStack(data.likes_stack);
        setUsingDemoLikes(false);
      } else {
        setLikesStack(defaultLikesStack);
        setUsingDemoLikes(true);
      }
      setLikesLoadState('ready');
    } catch (err) {
      if (opts?.asError) {
        setLikesLoadState('error');
        return;
      }
      setLikesStack(defaultLikesStack);
      setUsingDemoLikes(true);
      setLikesLoadState('ready');
    }
  }, []);

  // Fetch deck + matches (best-effort, silent fallback to demo data).
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [resDeck, resMatches] = await Promise.all([
          fetch('/v1/discovery/deck?user_id=11111111-1111-1111-1111-111111111111&radius_km=50'),
          fetch('/v1/matches?user_id=11111111-1111-1111-1111-111111111111'),
        ]);
        const dataDeck = await resDeck.json();
        const dataMatches = await resMatches.json();

        if (dataDeck?.success && dataDeck.deck?.length > 0) {
          setAllCandidates(dataDeck.deck);
        }
        if (dataMatches?.success && dataMatches.matches?.length > 0) {
          setMatches(dataMatches.matches);
        }
      } catch (err) {
        // Safe local demo data fallback
      }
    };
    fetchData();
    loadLikes();
  }, [loadLikes]);

  // Filtered candidate deck
  const filteredCandidates = allCandidates
    .filter((c) => !blockedUserIds.has(c.user_id))
    .filter((c) => {
      if (presetFilter === 'nearby' && c.distance_km > 10) return false;
      if (presetFilter === 'online' && !c.is_online) return false;
      if (presetFilter === 'verified' && !c.is_verified) return false;

      if (c.distance_km > maxDistance) return false;
      const age = c.age || 24;
      if (age < minAge || age > maxAge) return false;
      if (selectedInterest && !c.shared_interests?.includes(selectedInterest)) return false;

      return true;
    });

  const currentCandidate = filteredCandidates[currentIndex];

  const resetFilters = () => {
    setPresetFilter('recommended');
    setMaxDistance(50);
    setMinAge(18);
    setMaxAge(35);
    setSelectedInterest(null);
    setCurrentIndex(0);
    setActivePhotoIdx(0);
    showToast('Filters reset to Recommended');
  };

  const isFilterActive =
    presetFilter !== 'recommended' ||
    maxDistance !== 50 ||
    minAge !== 18 ||
    maxAge !== 35 ||
    selectedInterest !== null;

  // ─── Swipe engine (ref-based, document-level pointer events) ────────────────

  /**
   * Commit the exit animation and advance the deck.
   * `action` must already be set in swipeStamp before calling.
   */
  const commitExit = useCallback(
    async (action: 'like' | 'dislike' | 'spark', candidate: CandidateCard) => {
      // Apply exit transform directly on the DOM node for immediate feedback
      if (cardRef.current) {
        const exitX = action === 'dislike' ? '-130vw' : action === 'like' ? '130vw' : '0';
        const exitY = action === 'spark' ? '-130vh' : '0';
        const exitRot = action === 'dislike' ? '-20deg' : action === 'like' ? '20deg' : '0';
        cardRef.current.style.transition = 'transform 0.32s ease-out, opacity 0.32s ease-out';
        cardRef.current.style.transform = `translate(${exitX}, ${exitY}) rotate(${exitRot})`;
        cardRef.current.style.opacity = '0';
      }

      // Fire backend (best-effort)
      try {
        const res = await fetch('/v1/swipes', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            actor_id: '11111111-1111-1111-1111-111111111111',
            target_id: candidate.user_id,
            action,
          }),
        });
        const data = await res.json();
        if (data?.is_match && onMutualMatch) onMutualMatch(candidate);
      } catch { /* local demo */ }

      if (action === 'like') showToast(`Liked ${candidate.nickname}! ❤️`);
      else if (action === 'spark') showToast(`Super-liked ${candidate.nickname}! ✨`);
      else showToast(`Passed on ${candidate.nickname}`);

      // Advance deck after animation
      setTimeout(() => {
        setCurrentIndex((prev) => prev + 1);
        setActivePhotoIdx(0);
        setDragOffset({ x: 0, y: 0 });
        dragOffsetRef.current = { x: 0, y: 0 };
        setIsAnimating(false);
        isAnimatingRef.current = false;
        setSwipeStamp(null);
      }, 350);
    },
    [onMutualMatch]
  );

  /**
   * Public handler called by buttons AND by gesture completion.
   */
  const executeSwipe = useCallback(
    (action: 'like' | 'dislike' | 'spark') => {
      if (!currentCandidate || isAnimatingRef.current) return;
      isAnimatingRef.current = true;
      setIsAnimating(true);
      setSwipeStamp(action);
      commitExit(action, currentCandidate);
    },
    [currentCandidate, commitExit]
  );

  /**
   * Pointer-down on the card — start dragging.
   * Registers document-level move/up so fast gestures never drop.
   */
  const handlePointerDown = useCallback(
    (e: React.PointerEvent<HTMLDivElement>) => {
      if (isAnimatingRef.current || !currentCandidate) return;
      // Ignore clicks on interactive children
      if ((e.target as HTMLElement).closest('button, a, input, select')) return;

      e.currentTarget.setPointerCapture(e.pointerId);
      dragActiveRef.current = true;
      dragStartRef.current = { x: e.clientX, y: e.clientY };
      dragOffsetRef.current = { x: 0, y: 0 };

      // Apply grab cursor immediately
      if (cardRef.current) {
        cardRef.current.style.cursor = 'grabbing';
        cardRef.current.style.transition = 'none';
      }
    },
    [currentCandidate]
  );

  const handlePointerMove = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
    if (!dragActiveRef.current || !dragStartRef.current) return;
    const dx = e.clientX - dragStartRef.current.x;
    const dy = e.clientY - dragStartRef.current.y;
    dragOffsetRef.current = { x: dx, y: dy };

    // Update card transform directly on DOM for zero-lag visual feedback
    if (cardRef.current) {
      cardRef.current.style.transform = `translate(${dx}px, ${dy * 0.35}px) rotate(${dx * 0.06}deg)`;
    }

    // Throttle React state updates with rAF (stamps only need ~60fps)
    if (rafRef.current === null) {
      rafRef.current = requestAnimationFrame(() => {
        rafRef.current = null;
        setDragOffset({ x: dragOffsetRef.current.x, y: dragOffsetRef.current.y });
      });
    }
  }, []);

  const handlePointerUp = useCallback(
    (e: React.PointerEvent<HTMLDivElement>) => {
      if (!dragActiveRef.current) return;
      dragActiveRef.current = false;

      if (rafRef.current !== null) {
        cancelAnimationFrame(rafRef.current);
        rafRef.current = null;
      }

      const dx = dragOffsetRef.current.x;
      const THRESHOLD = 90;

      if (dx > THRESHOLD) {
        executeSwipe('like');
      } else if (dx < -THRESHOLD) {
        executeSwipe('dislike');
      } else {
        // Snap back
        if (cardRef.current) {
          cardRef.current.style.transition = 'transform 0.28s cubic-bezier(0.34,1.56,0.64,1)';
          cardRef.current.style.transform = 'none';
          cardRef.current.style.cursor = 'grab';
        }
        dragOffsetRef.current = { x: 0, y: 0 };
        setDragOffset({ x: 0, y: 0 });
      }
    },
    [executeSwipe]
  );

  const handleRevert = () => {
    if (currentIndex > 0) {
      setCurrentIndex((prev) => prev - 1);
      setActivePhotoIdx(0);
      showToast('Previous card restored!');
    } else {
      showToast('No previous card to restore.');
    }
  };

  // Block User Action
  const confirmBlockUser = (profile: CandidateCard) => {
    setBlockedUserIds((prev) => new Set(prev).add(profile.user_id));
    setInspectingProfile(null);
    setShowBlockDialog(null);
    showToast(`${profile.nickname} has been blocked.`);
  };

  // Report User Action
  const confirmReportUser = (profile: CandidateCard, reason: string) => {
    setShowReportDialog(null);
    setInspectingProfile(null);
    showToast(`Report received: "${reason}". Profile flagged locally.`);
  };

  // ── Likes tab ("X Likes You") helpers ──────────────────────────────────────
  const admirerToCandidate = (a: IncomingLike): CandidateCard => ({
    user_id: a.actor_id,
    nickname: a.nickname,
    age: a.age,
    bio: a.bio,
    city: a.city,
    distance_km: a.distance_km,
    photo_urls: a.photo_urls?.length ? a.photo_urls : [a.avatar],
    is_verified: a.is_verified,
    is_online: a.is_online,
    shared_interests: a.shared_interests,
    profile_progress: 90,
    vibe_score: a.match_percent || 85,
  });

  // Cards removed for this session: passed, blocked, or already liked.
  const visibleLikes = likesStack.filter(
    (a) =>
      !passedAdmirerIds.has(a.actor_id) &&
      !likedAdmirerIds.has(a.actor_id) &&
      !blockedUserIds.has(a.actor_id)
  );

  // Limited visibility applies to restricted profiles and once the daily
  // reveal limit is spent. Full visibility shows every interest + full photo.
  const isLimitedVisibility = (a: IncomingLike) =>
    a.is_restricted === true || likesViewedToday >= DAILY_LIKES_VIEW_LIMIT;

  const dailyLimitReached = likesViewedToday >= DAILY_LIKES_VIEW_LIMIT;
  const recordView = () => setLikesViewedToday((n) => n + 1);

  // DEMO: everyone in this tab already liked you, so liking back is mutual.
  // The "It's a match" modal is demo behaviour only — no backend match is
  // created and no fake matches are inserted into the Matches list.
  const handleLikeAdmirer = (a: IncomingLike) => {
    recordView();
    setLikedAdmirerIds((prev) => new Set(prev).add(a.actor_id));
    const alreadyLikedYou = true; // all incoming "Likes You" entries
    if (alreadyLikedYou && onMutualMatch) {
      setMatchedAdmirerIds((prev) => new Set(prev).add(a.actor_id));
      // DEMO ONLY — reuse the existing match modal.
      onMutualMatch(admirerToCandidate(a));
    } else {
      // Local-only record; a real build would POST /v1/swipes here.
      showToast(`Liked ${a.nickname} back!`);
    }
  };

  // Pass / Dislike: locally sets is_liked = false and removes for the session.
  const handlePassAdmirer = (a: IncomingLike) => {
    recordView();
    setPassedAdmirerIds((prev) => new Set(prev).add(a.actor_id));
    showToast(`Passed on ${a.nickname}`);
  };

  // Spark guard: insufficient balance → modal; otherwise → confirm dialog.
  const handleSparkRequest = (a: IncomingLike) => {
    recordView();
    if (coinBalance <= SPARK_COST) {
      setInsufficientBalanceOpen(true);
      return;
    }
    setSparkConfirmAdmirer(a);
  };

  // DEMO spend: deducts locally so the wallet reflects the cost. Replace with
  // the server-authoritative spend call once the coin backend is wired.
  const confirmSpark = (a: IncomingLike) => {
    if (coinBalance <= SPARK_COST) {
      setSparkConfirmAdmirer(null);
      setInsufficientBalanceOpen(true);
      return;
    }
    // DEMO ONLY — local balance change; never sends a real payment.
    onCoinsDeducted?.(coinBalance - SPARK_COST);
    setSparkedAdmirerIds((prev) => new Set(prev).add(a.actor_id));
    setSparkConfirmAdmirer(null);
    showToast(`Spark sent to ${a.nickname}! ✨ (demo)`);
  };

  // Double-tap a card to fire a Spark (interactive children are ignored).
  const handleCardTap = (a: IncomingLike, e: React.MouseEvent) => {
    if (suppressLikesClickRef.current) {
      // A drag just ended — swallow the click so the card isn't liked/opened.
      suppressLikesClickRef.current = false;
      return;
    }
    if ((e.target as HTMLElement).closest('button, a, input, select')) return;
    const now = Date.now();
    const last = cardTapRef.current;
    if (last.id === a.actor_id && now - last.time < 300) {
      cardTapRef.current = { id: null, time: 0 };
      handleSparkRequest(a);
      return;
    }
    cardTapRef.current = { id: a.actor_id, time: now };
  };

  // Scroll the row by one card (used by the desktop arrow buttons).
  const scrollLikesBy = (dir: number) => {
    const row = likesRowRef.current;
    if (!row) return;
    const first = row.querySelector<HTMLElement>('.likes-card');
    const step = first ? first.offsetWidth + 14 : Math.round(row.clientWidth * 0.8);
    row.scrollBy({ left: dir * step, behavior: 'smooth' });
  };

  // Mouse-only drag-to-scroll (touch uses native momentum scrolling).
  const handleLikesPointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    if (e.pointerType !== 'mouse') return;
    if ((e.target as HTMLElement).closest('button, a, input, select')) return;
    const row = likesRowRef.current;
    if (!row) return;
    suppressLikesClickRef.current = false;
    likesDragRef.current = {
      active: true,
      moved: false,
      startX: e.clientX,
      startScrollLeft: row.scrollLeft,
      pointerId: e.pointerId,
    };
    row.setPointerCapture(e.pointerId);
  };

  const handleLikesPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = likesDragRef.current;
    if (!d.active) return;
    const dx = e.clientX - d.startX;
    if (Math.abs(dx) > 4) {
      d.moved = true;
      likesRowRef.current?.classList.add('is-dragging');
    }
    const row = likesRowRef.current;
    if (row) row.scrollLeft = d.startScrollLeft - dx;
  };

  const handleLikesPointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = likesDragRef.current;
    if (!d.active) return;
    const row = likesRowRef.current;
    if (row && row.hasPointerCapture?.(d.pointerId)) row.releasePointerCapture(d.pointerId);
    row?.classList.remove('is-dragging');
    if (d.moved) {
      // Suppress the trailing click and reset any pending double-tap.
      suppressLikesClickRef.current = true;
      cardTapRef.current = { id: null, time: 0 };
    }
    d.active = false;
  };

  const openAdmirerProfile = (a: IncomingLike, limited: boolean) => {
    setInspectingProfile(admirerToCandidate(a));
    setInspectingProfileLimited(limited);
    setProfilePhotoIdx(0);
    setIsProfileMenuOpen(false);
  };

  // Card base style — transitions controlled by commitExit / snap-back logic on the DOM node
  const cardStyle: React.CSSProperties = {
    position: 'relative',
    height: '520px',
    borderRadius: 'var(--radius-lg)',
    overflow: 'hidden',
    boxShadow: 'var(--shadow-lg)',
    border: '1px solid var(--border-glass)',
    cursor: 'grab',
    userSelect: 'none',
    touchAction: 'pan-y', // allow vertical page scroll; horizontal captured by pointer events
    willChange: 'transform',
  };

  return (
    <div
      className="home-container"
      style={{
        maxWidth: '520px',
        margin: '0 auto',
        padding: '14px 16px 95px',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        gap: '14px',
      }}
    >
      {/* Toast Notification */}
      {toastMessage && (
        <div
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
            whiteSpace: 'nowrap',
            backdropFilter: 'blur(16px)',
          }}
        >
          {toastMessage}
        </div>
      )}

      {/* Screen Title & Subtitle */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 800, letterSpacing: '-0.4px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Heart size={22} color="#ff2d55" fill="#ff2d55" />
            Connect & Matches
          </h1>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
            Swipe discovery deck, mutual matches & secret admirers
          </p>
        </div>
      </div>

      {/* Primary Navigation Tabs */}
      <div
        style={{
          display: 'flex',
          background: 'rgba(255, 255, 255, 0.04)',
          borderRadius: 'var(--radius-full)',
          padding: '4px',
          border: '1px solid var(--border-glass)',
        }}
      >
        <button
          onClick={() => setActiveTab('discover')}
          style={{
            flex: 1,
            padding: '8px 12px',
            borderRadius: 'var(--radius-full)',
            border: 'none',
            fontSize: '13px',
            fontWeight: activeTab === 'discover' ? 700 : 500,
            cursor: 'pointer',
            background: activeTab === 'discover' ? 'var(--gradient-flame)' : 'transparent',
            color: activeTab === 'discover' ? '#ffffff' : 'var(--text-secondary)',
            boxShadow: activeTab === 'discover' ? 'var(--shadow-glow)' : 'none',
            transition: 'all var(--transition-fast)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <Zap size={15} />
          <span>Discover</span>
        </button>

        <button
          onClick={() => setActiveTab('matches')}
          style={{
            flex: 1,
            padding: '8px 12px',
            borderRadius: 'var(--radius-full)',
            border: 'none',
            fontSize: '13px',
            fontWeight: activeTab === 'matches' ? 700 : 500,
            cursor: 'pointer',
            background: activeTab === 'matches' ? 'var(--gradient-flame)' : 'transparent',
            color: activeTab === 'matches' ? '#ffffff' : 'var(--text-secondary)',
            boxShadow: activeTab === 'matches' ? 'var(--shadow-glow)' : 'none',
            transition: 'all var(--transition-fast)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <Heart size={15} />
          <span>Matches ({matches.length})</span>
        </button>

        <button
          onClick={() => setActiveTab('likes')}
          style={{
            flex: 1,
            padding: '8px 12px',
            borderRadius: 'var(--radius-full)',
            border: 'none',
            fontSize: '13px',
            fontWeight: activeTab === 'likes' ? 700 : 500,
            cursor: 'pointer',
            background: activeTab === 'likes' ? 'var(--gradient-gold)' : 'transparent',
            color: activeTab === 'likes' ? '#1a1002' : 'var(--text-secondary)',
            boxShadow: activeTab === 'likes' ? 'var(--shadow-gold)' : 'none',
            transition: 'all var(--transition-fast)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px',
          }}
        >
          <Sparkles size={15} />
          <span>Likes ({likesStack.length})</span>
        </button>
      </div>

      {/* =========================================================================
          TAB 1: DISCOVER (SWIPEABLE PROFILE CARDS DECK & FILTERS)
          ========================================================================= */}
      {activeTab === 'discover' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          
          {/* Quick Filter Chips Row */}
          <div
            style={{
              display: 'flex',
              gap: '8px',
              overflowX: 'auto',
              paddingBottom: '4px',
              scrollbarWidth: 'none',
              WebkitOverflowScrolling: 'touch',
            }}
          >
            <button
              onClick={() => setPresetFilter('recommended')}
              className={`filter-pill ${presetFilter === 'recommended' && !selectedInterest ? 'active' : ''}`}
            >
              ⭐ Recommended
            </button>
            <button
              onClick={() => setPresetFilter('nearby')}
              className={`filter-pill ${presetFilter === 'nearby' ? 'active' : ''}`}
            >
              📍 Nearby (&lt;10km)
            </button>
            <button
              onClick={() => setPresetFilter('online')}
              className={`filter-pill ${presetFilter === 'online' ? 'active' : ''}`}
            >
              🟢 Online Now
            </button>
            <button
              onClick={() => setPresetFilter('verified')}
              className={`filter-pill ${presetFilter === 'verified' ? 'active' : ''}`}
            >
              ✓ Verified
            </button>
            <button
              onClick={() => setIsFilterModalOpen(true)}
              className={`filter-pill ${isFilterActive ? 'active' : ''}`}
              style={{ display: 'flex', alignItems: 'center', gap: '4px' }}
            >
              <SlidersHorizontal size={13} />
              <span>Filters</span>
            </button>
            {isFilterActive && (
              <button
                onClick={resetFilters}
                className="filter-pill"
                style={{ color: '#ffa502', borderColor: 'rgba(255, 165, 2, 0.4)' }}
              >
                ↺ Reset
              </button>
            )}
          </div>

          {/* Swipeable Card or Empty State */}
          {currentCandidate ? (
            <>
              <div
                ref={cardRef}
                style={cardStyle}
                onPointerDown={handlePointerDown}
                onPointerMove={handlePointerMove}
                onPointerUp={handlePointerUp}
                onPointerCancel={handlePointerUp}
              >
                {/* Photo */}
                <img
                  src={currentCandidate.photo_urls[activePhotoIdx] || '/ananya.jpg'}
                  alt={currentCandidate.nickname}
                  style={{
                    width: '100%',
                    height: '100%',
                    objectFit: 'cover',
                    pointerEvents: 'none',
                    display: 'block',
                  }}
                />

                {/* Photo Story Progress Bars */}
                {currentCandidate.photo_urls.length > 1 && (
                  <div style={{ position: 'absolute', top: '10px', left: '14px', right: '14px', display: 'flex', gap: '4px', zIndex: 20 }}>
                    {currentCandidate.photo_urls.map((_, idx) => (
                      <div
                        key={idx}
                        style={{
                          flex: 1,
                          height: '3px',
                          borderRadius: '2px',
                          background: idx === activePhotoIdx ? '#ffffff' : 'rgba(255, 255, 255, 0.3)',
                        }}
                      />
                    ))}
                  </div>
                )}

                {/* Top Badges */}
                <div
                  style={{
                    position: 'absolute',
                    top: currentCandidate.photo_urls.length > 1 ? '22px' : '14px',
                    left: '14px',
                    right: '14px',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    zIndex: 20,
                  }}
                >
                  <div className="badge-vibe" style={{ fontSize: '11px', padding: '3px 8px' }}>
                    <Zap size={13} />
                    {currentCandidate.vibe_score || 94}% Vibe
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    {currentCandidate.is_online && (
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '5px',
                          background: 'rgba(0, 0, 0, 0.55)',
                          padding: '3px 8px',
                          borderRadius: 'var(--radius-full)',
                          fontSize: '11px',
                          fontWeight: 600,
                          backdropFilter: 'blur(8px)',
                        }}
                      >
                        <span className="status-dot-online" />
                        <span>Online</span>
                      </div>
                    )}
                    {currentCandidate.is_verified && (
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '3px',
                          background: 'rgba(29, 161, 242, 0.25)',
                          padding: '3px 8px',
                          borderRadius: 'var(--radius-full)',
                          border: '1px solid rgba(29, 161, 242, 0.5)',
                          color: '#1da1f2',
                          fontSize: '11px',
                          fontWeight: 700,
                        }}
                      >
                        <ShieldCheck size={13} />
                        Verified
                      </div>
                    )}
                  </div>
                </div>

                {/* Stamp overlays — shown while dragging or animating */}
                {(dragOffset.x > 30 || swipeStamp === 'like') && (
                  <div
                    style={{
                      position: 'absolute',
                      top: '40px',
                      left: '20px',
                      transform: 'rotate(-15deg)',
                      border: '4px solid #2ed573',
                      color: '#2ed573',
                      fontSize: '30px',
                      fontWeight: 900,
                      padding: '4px 16px',
                      borderRadius: '8px',
                      zIndex: 30,
                      background: 'rgba(0,0,0,0.6)',
                      opacity: swipeStamp === 'like' ? 1 : Math.min(1, dragOffset.x / 70),
                      pointerEvents: 'none',
                    }}
                  >
                    LIKE ❤️
                  </div>
                )}

                {(dragOffset.x < -30 || swipeStamp === 'dislike') && (
                  <div
                    style={{
                      position: 'absolute',
                      top: '40px',
                      right: '20px',
                      transform: 'rotate(15deg)',
                      border: '4px solid #ff4757',
                      color: '#ff4757',
                      fontSize: '30px',
                      fontWeight: 900,
                      padding: '4px 16px',
                      borderRadius: '8px',
                      zIndex: 30,
                      background: 'rgba(0,0,0,0.6)',
                      opacity: swipeStamp === 'dislike' ? 1 : Math.min(1, -dragOffset.x / 70),
                      pointerEvents: 'none',
                    }}
                  >
                    PASS ✗
                  </div>
                )}

                {/* Gradient Card Overlay */}
                <div style={{ position: 'absolute', inset: 0, background: 'var(--gradient-card-overlay)', pointerEvents: 'none' }} />

                {/* Bottom Card Information */}
                <div style={{ position: 'absolute', bottom: '16px', left: '16px', right: '16px', zIndex: 20 }}>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '2px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <h2 style={{ fontSize: '24px', fontWeight: 800 }}>{currentCandidate.nickname}</h2>
                      <span style={{ fontSize: '20px', color: 'var(--text-secondary)' }}>
                        {currentCandidate.age || 24}
                      </span>
                    </div>

                    {/* View Profile Action */}
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        setInspectingProfile(currentCandidate);
                      }}
                      className="glass-pill"
                      style={{
                        padding: '5px 12px',
                        fontSize: '11px',
                        fontWeight: 700,
                        color: 'var(--cyan-vibe)',
                        border: '1px solid rgba(0, 229, 255, 0.35)',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '4px',
                      }}
                    >
                      <Info size={13} />
                      View Profile
                    </button>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--cyan-vibe)', fontSize: '12px', marginBottom: '6px' }}>
                    <MapPin size={13} />
                    <span>{currentCandidate.distance_km} km away • {currentCandidate.city}</span>
                  </div>

                  {/* Shared Interests */}
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px', marginBottom: '8px' }}>
                    {(currentCandidate.shared_interests || ['Specialty Coffee ☕', 'Indie Vinyl 🎵']).map((tag, i) => (
                      <span
                        key={i}
                        style={{
                          background: 'rgba(255, 255, 255, 0.08)',
                          borderRadius: 'var(--radius-full)',
                          padding: '2px 8px',
                          fontSize: '11px',
                          color: '#ffffff',
                        }}
                      >
                        {tag}
                      </span>
                    ))}
                  </div>

                  <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.35, margin: 0 }}>
                    {currentCandidate.bio}
                  </p>
                </div>
              </div>

              {/* Action Buttons Bar */}
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '12px',
                  marginTop: '4px',
                }}
              >
                <button
                  onClick={handleRevert}
                  disabled={currentIndex === 0 || isAnimating}
                  title="Undo last swipe"
                  className="action-btn-circle btn-revert"
                  style={{ width: '52px', height: '52px', opacity: currentIndex === 0 ? 0.4 : 1 }}
                >
                  <RotateCcw size={19} />
                </button>

                <button
                  onClick={() => executeSwipe('dislike')}
                  disabled={isAnimating}
                  title="Pass (swipe left)"
                  className="action-btn-circle btn-dislike"
                  style={{ width: '58px', height: '58px' }}
                >
                  <X size={26} />
                </button>

                <button
                  onClick={() => executeSwipe('like')}
                  disabled={isAnimating}
                  title="Like (swipe right)"
                  className="action-btn-circle btn-like"
                  style={{ width: '68px', height: '68px' }}
                >
                  <Heart size={34} fill="#ffffff" />
                </button>

                <button
                  onClick={() => executeSwipe('spark')}
                  disabled={isAnimating}
                  title="Super Like"
                  className="action-btn-circle btn-spark"
                  style={{ width: '58px', height: '58px' }}
                >
                  <Sparkles size={24} />
                </button>
              </div>
            </>
          ) : (
            /* Empty State */
            <div
              className="glass-panel"
              style={{
                height: '460px',
                borderRadius: 'var(--radius-lg)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                textAlign: 'center',
                padding: '28px',
              }}
            >
              <div style={{ fontSize: '48px', marginBottom: '12px' }}>✨</div>
              <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>
                {isFilterActive ? 'No profiles match your filters' : "You've seen everyone for now"}
              </h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '18px', maxWidth: '300px' }}>
                {isFilterActive
                  ? 'Try expanding your distance limit or resetting filters to discover more people.'
                  : 'New verified profiles join daily. Come back later or adjust your filters.'}
              </p>
              {isFilterActive ? (
                <button onClick={resetFilters} className="btn-primary" style={{ padding: '10px 22px', fontSize: '13px' }}>
                  Reset Filters
                </button>
              ) : (
                <button onClick={() => setCurrentIndex(0)} className="btn-primary" style={{ padding: '10px 22px', fontSize: '13px' }}>
                  Try Again
                </button>
              )}
            </div>
          )}

        </div>
      )}

      {/* =========================================================================
          TAB 2: MATCHES (MUTUAL CONNECTIONS LIST & CHAT NAVIGATION)
          ========================================================================= */}
      {activeTab === 'matches' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
              Mutual connections ready to message
            </span>
            <span style={{ fontSize: '12px', color: '#00e676', fontWeight: 700 }}>
              {matches.length} active
            </span>
          </div>

          {matches.length === 0 ? (
            <div
              className="glass-panel"
              style={{
                padding: '40px 20px',
                textAlign: 'center',
                borderRadius: 'var(--radius-lg)',
              }}
            >
              <Heart size={36} color="var(--text-muted)" style={{ margin: '0 auto 12px' }} />
              <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '6px' }}>No mutual matches yet</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                Swipe right on profiles in the Discover deck to form reciprocal matches.
              </p>
              <button
                onClick={() => setActiveTab('discover')}
                className="btn-primary"
                style={{ padding: '8px 18px', fontSize: '12px' }}
              >
                Go to Discover
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {matches.map((m) => (
                <div
                  key={m.id}
                  className="glass-panel"
                  style={{
                    borderRadius: 'var(--radius-md)',
                    padding: '14px',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '10px',
                    border: '1px solid rgba(255, 45, 85, 0.25)',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ position: 'relative', width: '54px', height: '54px', flexShrink: 0 }}>
                      <img
                        src={m.counterpart.avatar}
                        alt={m.counterpart.nickname}
                        style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
                      />
                      {m.counterpart.is_verified && (
                        <div className="badge-blue-tick" style={{ position: 'absolute', bottom: 0, right: 0, width: '16px', height: '16px', fontSize: '10px' }}>
                          ✓
                        </div>
                      )}
                    </div>

                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <h3 style={{ fontSize: '15px', fontWeight: 700, margin: 0 }}>
                          {m.counterpart.nickname}, {m.counterpart.age || 24}
                        </h3>
                        {m.counterpart.is_online && <span className="status-dot-online" />}
                      </div>
                      <div style={{ fontSize: '11px', color: 'var(--cyan-vibe)' }}>{m.counterpart.city}</div>
                      {m.last_message && (
                        <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          💬 "{m.last_message.body}"
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Actions: View Profile & Chat */}
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button
                      onClick={() =>
                        setInspectingProfile({
                          user_id: m.counterpart.user_id,
                          nickname: m.counterpart.nickname,
                          age: m.counterpart.age || 24,
                          bio: m.counterpart.bio || 'Matched connection on YoUnMe.',
                          city: m.counterpart.city,
                          distance_km: 1.2,
                          photo_urls: m.counterpart.photo_urls || [m.counterpart.avatar],
                          is_verified: m.counterpart.is_verified,
                          is_online: m.counterpart.is_online,
                          shared_interests: m.counterpart.shared_interests || ['Specialty Coffee ☕', 'Indie Vinyl 🎵'],
                          profile_progress: 95,
                          vibe_score: 95,
                        })
                      }
                      className="btn-ghost"
                      style={{ flex: 1, padding: '7px 10px', fontSize: '12px' }}
                    >
                      View Profile
                    </button>
                    <button
                      onClick={() => onOpenChat(m.id)}
                      className="btn-primary"
                      style={{ flex: 1, padding: '7px 10px', fontSize: '12px' }}
                    >
                      <MessageSquare size={13} />
                      Open Chat
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* =========================================================================
          TAB 3: LIKES YOU — INCOMING ADMIRERS WITH ACTIONS
          ========================================================================= */}
      {activeTab === 'likes' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', minWidth: 0 }}>

          {/* ── Header: "X Likes You" ── */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '10px' }}>
            <div style={{ minWidth: 0 }}>
              <h2 style={{ fontSize: '20px', fontWeight: 800, display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Sparkles size={18} color="#ffd700" />
                {visibleLikes.length} Likes You
              </h2>
              <p style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                A like is not a match — liking back makes it mutual.
              </p>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexShrink: 0 }}>
              {usingDemoLikes && (
                <span
                  title="Demo data — no backend connected"
                  style={{
                    background: 'rgba(255, 215, 0, 0.08)',
                    border: '1px solid rgba(255, 215, 0, 0.25)',
                    borderRadius: 'var(--radius-full)',
                    padding: '4px 10px',
                    fontSize: '10px',
                    fontWeight: 700,
                    color: '#ffd700',
                  }}
                >
                  Demo data
                </span>
              )}
              <button
                className="tap-target-44 glass-pill"
                title="Refresh likes from server"
                aria-label="Refresh likes from server"
                onClick={() => loadLikes({ asError: true })}
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border-glass)', cursor: 'pointer' }}
              >
                <RefreshCw size={15} />
              </button>
            </div>
          </div>

          {/* Daily view counter (demo) */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              background: 'rgba(255, 215, 0, 0.06)',
              border: '1px solid rgba(255, 215, 0, 0.2)',
              borderRadius: 'var(--radius-md)',
              padding: '8px 12px',
              fontSize: '11px',
              fontWeight: 700,
              color: '#ffd700',
            }}
          >
            <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <Zap size={12} />
              {likesViewedToday}/{DAILY_LIKES_VIEW_LIMIT} profiles viewed today
            </span>
            <span style={{ color: 'var(--text-secondary)', fontWeight: 500 }}>
              {dailyLimitReached ? 'Full photos locked' : 'Full visibility'}
            </span>
          </div>

          {/* Daily limit reached — explanation + Buy/Earn Coins */}
          {dailyLimitReached && (
            <div
              className="glass-panel"
              style={{ borderRadius: 'var(--radius-md)', padding: '14px', display: 'flex', flexDirection: 'column', gap: '10px' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', fontWeight: 700 }}>
                <Lock size={15} color="#ffd700" />
                Daily free views used up
              </div>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.4, margin: 0 }}>
                You can still Like, Pass or send a Spark. Full photos unlock again tomorrow.
              </p>
              {/* Gender-aware CTA: female viewers are routed to the earn flow. */}
              {viewerGender?.toLowerCase() === 'female' ? (
                <button onClick={onOpenStore} className="btn-gold" style={{ padding: '10px', fontSize: '13px' }}>
                  <Coins size={14} />
                  Earn Coins
                </button>
              ) : (
                <button onClick={onOpenStore} className="btn-gold" style={{ padding: '10px', fontSize: '13px' }}>
                  <Coins size={14} />
                  Buy Coins
                </button>
              )}
            </div>
          )}

          {/* ── Loading skeleton ── */}
          {likesLoadState === 'loading' && (
            <div className="likes-scroll-row" aria-hidden="true">
              {[0, 1, 2].map((n) => (
                <div key={n} className="likes-card glass-panel" style={{ borderRadius: 'var(--radius-lg)', overflow: 'hidden' }}>
                  <div className="skeleton" style={{ height: '260px' }} />
                  <div style={{ padding: '12px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <div className="skeleton" style={{ height: '14px', width: '70%', borderRadius: '6px' }} />
                    <div className="skeleton" style={{ height: '10px', width: '45%', borderRadius: '6px' }} />
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* ── Error state with Retry ── */}
          {likesLoadState === 'error' && (
            <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '44px 24px', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
              <div style={{ fontSize: '40px' }}>⚠️</div>
              <h3 style={{ fontSize: '16px', fontWeight: 800 }}>Couldn't load likes</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', maxWidth: '260px' }}>
                Something went wrong while fetching who likes you. Please try again.
              </p>
              <button onClick={() => loadLikes()} className="btn-primary" style={{ padding: '10px 22px', fontSize: '13px' }}>
                <RefreshCw size={14} />
                Retry
              </button>
            </div>
          )}

          {/* ── Empty state ── */}
          {likesLoadState === 'ready' && visibleLikes.length === 0 && (
            <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '48px 24px', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '10px' }}>
              <div style={{ fontSize: '44px' }}>💫</div>
              <h3 style={{ fontSize: '16px', fontWeight: 800, maxWidth: '280px' }}>
                No likes yet. Keep swiping to get noticed
              </h3>
              <button onClick={() => setActiveTab('discover')} className="btn-primary" style={{ padding: '9px 20px', fontSize: '12px', marginTop: '4px' }}>
                Go to Discover
              </button>
            </div>
          )}

          {/* ── Horizontal sliding card row (scroll-snap + peek) ── */}
          {likesLoadState === 'ready' && visibleLikes.length > 0 && (
            <div className="likes-row-wrap">
              <button
                type="button"
                className="likes-nav-btn likes-nav-prev"
                aria-label="Scroll to previous profiles"
                onClick={() => scrollLikesBy(-1)}
              >
                <ChevronLeft size={18} />
              </button>
              <div
                className="likes-scroll-row"
                ref={likesRowRef}
                onPointerDown={handleLikesPointerDown}
                onPointerMove={handleLikesPointerMove}
                onPointerUp={handleLikesPointerUp}
                onPointerCancel={handleLikesPointerUp}
              >
                {visibleLikes.map((admirer, i) => {
                const limited = isLimitedVisibility(admirer);
                const isMatched = matchedAdmirerIds.has(admirer.actor_id);
                const isIncomingSpark = admirer.action === 'spark';
                const interests = limited
                  ? (admirer.shared_interests || []).slice(0, 3)
                  : (admirer.shared_interests || []);
                const photo = limited
                  ? admirer.avatar
                  : (admirer.photo_urls?.[0] || admirer.avatar);

                return (
                  <div
                    key={admirer.actor_id || i}
                    className="likes-card glass-panel"
                    onClick={(e) => handleCardTap(admirer, e)}
                    title="Double-tap to send a Spark"
                    style={{
                      borderRadius: 'var(--radius-lg)',
                      overflow: 'hidden',
                      border: isIncomingSpark
                        ? '1.5px solid rgba(255, 165, 2, 0.55)'
                        : '1px solid rgba(255, 45, 85, 0.3)',
                      boxShadow: isIncomingSpark
                        ? '0 0 20px rgba(255,165,2,0.2)'
                        : '0 8px 24px rgba(0,0,0,0.35)',
                      display: 'flex',
                      flexDirection: 'column',
                      cursor: 'pointer',
                      userSelect: 'none',
                    }}
                  >
                    {/* ── Photo area ── */}
                    <div style={{ position: 'relative', height: '260px' }}>
                      <img
                        src={photo}
                        alt={admirer.nickname}
                        style={{
                          width: '100%',
                          height: '100%',
                          objectFit: 'cover',
                          filter: limited ? 'blur(16px) brightness(0.55)' : 'none',
                          transition: 'filter 0.4s ease-out',
                          display: 'block',
                        }}
                      />
                      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, transparent 35%, rgba(8,10,16,0.92) 100%)' }} />

                      {/* Incoming Spark → "Super Like" tag */}
                      {isIncomingSpark && (
                        <div style={{ position: 'absolute', top: '10px', left: '10px', background: 'rgba(255,153,0,0.9)', padding: '3px 10px', borderRadius: 'var(--radius-full)', fontSize: '10px', fontWeight: 800, color: '#fff', letterSpacing: '0.4px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                          <Sparkles size={11} />
                          Super Like
                        </div>
                      )}

                      {/* Verified badge */}
                      {admirer.is_verified && (
                        <div
                          title="Verified"
                          style={{ position: 'absolute', top: isIncomingSpark ? '42px' : '10px', right: '10px', background: 'rgba(29, 161, 242, 0.85)', borderRadius: '50%', width: '26px', height: '26px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                        >
                          <ShieldCheck size={14} color="#ffffff" />
                        </div>
                      )}

                      {/* Online status */}
                      {admirer.is_online && (
                        <div style={{ position: 'absolute', bottom: '52px', right: '12px', background: 'rgba(0,0,0,0.6)', borderRadius: 'var(--radius-full)', padding: '3px 8px', fontSize: '10px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '5px' }}>
                          <span className="status-dot-online" />
                          Online
                        </div>
                      )}

                      {/* Limited visibility overlay: blurred photo + match % */}
                      {limited && (
                        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '6px', pointerEvents: 'none' }}>
                          <div style={{ background: 'rgba(0,0,0,0.55)', border: '1px solid rgba(255,215,0,0.4)', borderRadius: 'var(--radius-full)', padding: '4px 12px', fontSize: '13px', fontWeight: 800, color: '#ffd700' }}>
                            {admirer.match_percent || 80}% Match
                          </div>
                          <span style={{ fontSize: '10px', color: 'rgba(255,255,255,0.75)', fontWeight: 600 }}>Photo locked</span>
                        </div>
                      )}

                      {/* Limited visibility keeps an unblurred avatar/bitmoji */}
                      {limited && (
                        <img
                          src={admirer.bitmoji || admirer.avatar}
                          alt=""
                          style={{ position: 'absolute', bottom: '10px', left: '10px', width: '40px', height: '40px', borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(255,255,255,0.7)' }}
                        />
                      )}

                      {/* Name / age / gender / general distance */}
                      <div style={{ position: 'absolute', bottom: '10px', left: limited ? '60px' : '12px', right: '12px' }}>
                        <div style={{ fontSize: '16px', fontWeight: 800, color: '#ffffff' }}>
                          {admirer.nickname}, {admirer.age}
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: 'var(--cyan-vibe)', marginTop: '2px' }}>
                          <MapPin size={11} />
                          <span>~{admirer.distance_km} km • {admirer.gender}</span>
                        </div>
                      </div>
                    </div>

                    {/* ── Card body ── */}
                    <div style={{ padding: '12px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
                        {interests.map((tag: string, ti: number) => (
                          <span key={ti} style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)', borderRadius: 'var(--radius-full)', padding: '2px 8px', fontSize: '10px', color: '#ffffff' }}>
                            {tag}
                          </span>
                        ))}
                      </div>

                      {isMatched ? (
                        <button
                          onClick={() => {
                            const matchId = matches.find((m) => m.counterpart.user_id === admirer.actor_id)?.id;
                            if (matchId) onOpenChat(matchId);
                          }}
                          className="btn-primary"
                          style={{ width: '100%', minHeight: '44px', padding: '8px', fontSize: '12px' }}
                        >
                          <MessageSquare size={13} />
                          Open Chat
                        </button>
                      ) : (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                          {/* Dislike (left) / Like (right) — always available */}
                          <div style={{ display: 'flex', gap: '6px' }}>
                            <button
                              onClick={() => handlePassAdmirer(admirer)}
                              className="btn-ghost"
                              aria-label={`Pass on ${admirer.nickname}`}
                              style={{ flex: 1, minHeight: '44px', padding: '7px', fontSize: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '5px', color: '#ff4757', borderColor: 'rgba(255,71,87,0.3)' }}
                            >
                              <X size={15} />
                              Pass
                            </button>
                            <button
                              onClick={() => handleLikeAdmirer(admirer)}
                              className="btn-primary"
                              aria-label={`Like ${admirer.nickname} back`}
                              style={{ flex: 1, minHeight: '44px', padding: '7px', fontSize: '12px' }}
                            >
                              <Heart size={15} fill="#ffffff" />
                              Like
                            </button>
                          </div>

                          <div style={{ display: 'flex', gap: '6px' }}>
                            <button
                              onClick={() => openAdmirerProfile(admirer, limited)}
                              className="btn-ghost"
                              aria-label={`View ${admirer.nickname}'s profile`}
                              style={{ flex: 1, minHeight: '44px', padding: '7px 6px', fontSize: '11px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px' }}
                            >
                              <Info size={13} />
                              Profile
                            </button>
                            <button
                              onClick={() => handleSparkRequest(admirer)}
                              className="btn-ghost"
                              aria-label={`Send a Spark to ${admirer.nickname}`}
                              style={{ flex: 1, minHeight: '44px', padding: '7px 6px', fontSize: '11px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '4px', color: '#ffa502', borderColor: 'rgba(255,165,2,0.35)' }}
                            >
                              <Sparkles size={13} />
                              {sparkedAdmirerIds.has(admirer.actor_id) ? 'Sparked' : 'Spark'}
                            </button>
                          </div>

                          <span style={{ fontSize: '10px', color: 'var(--text-muted)', textAlign: 'center' }}>
                            Double-tap the card to send a Mega-Crush
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
              </div>
              <button
                type="button"
                className="likes-nav-btn likes-nav-next"
                aria-label="Scroll to next profiles"
                onClick={() => scrollLikesBy(1)}
              >
                <ChevronRight size={18} />
              </button>
            </div>
          )}

          {/* ── Coins shortcut (gender-aware) ── */}
          {viewerGender?.toLowerCase() === 'female' ? (
            // TODO(workflow): female viewers use the earn/convert flow, not Buy Coins.
            <button
              onClick={onOpenStore}
              style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'radial-gradient(circle at 10% 50%, rgba(0,230,118,0.12) 0%, rgba(15,18,29,0.9) 100%)', border: '1px solid rgba(0,230,118,0.3)', borderRadius: 'var(--radius-md)', padding: '14px 16px', cursor: 'pointer', width: '100%', textAlign: 'left' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Coins size={18} color="#00e676" />
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 700, color: '#ffffff' }}>Earn Coins</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Convert your creator balance to coins</div>
                </div>
              </div>
              <ChevronRight size={16} color="var(--text-muted)" />
            </button>
          ) : (
            <button
              onClick={onOpenStore}
              style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'radial-gradient(circle at 10% 50%, rgba(255,170,0,0.12) 0%, rgba(15,18,29,0.9) 100%)', border: '1px solid rgba(255,170,0,0.3)', borderRadius: 'var(--radius-md)', padding: '14px 16px', cursor: 'pointer', width: '100%', textAlign: 'left' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Coins size={18} color="#ffd700" />
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 700, color: '#ffffff' }}>Get More Coins</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Send Sparks and unlock faster</div>
                </div>
              </div>
              <ChevronRight size={16} color="var(--text-muted)" />
            </button>
          )}

        </div>
      )}

      {/* =========================================================================
          SPARK CONFIRMATION MODAL
          ========================================================================= */}
      {sparkConfirmAdmirer && (
        <div className="bottom-sheet-overlay" onClick={() => setSparkConfirmAdmirer(null)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '24px', textAlign: 'center' }}>
            <div style={{ fontSize: '40px', marginBottom: '8px' }}>✨</div>
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>
              Send a Spark to {sparkConfirmAdmirer.nickname}?
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '6px' }}>
              A Spark is a Mega-Crush — it puts you at the top of their list and tags you as a Super Like.
            </p>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', background: 'rgba(255,170,0,0.12)', border: '1px solid rgba(255,170,0,0.3)', borderRadius: 'var(--radius-full)', padding: '4px 12px', fontSize: '12px', color: '#ffd700', fontWeight: 700, marginBottom: '20px' }}>
              <Coins size={13} />
              {SPARK_COST} coins · Demo spend
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setSparkConfirmAdmirer(null)} className="btn-ghost" style={{ flex: 1, padding: '12px' }}>
                Cancel
              </button>
              <button
                onClick={() => confirmSpark(sparkConfirmAdmirer)}
                className="btn-gold"
                style={{ flex: 1, padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}
              >
                <Sparkles size={14} />
                Send Spark
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =========================================================================
          INSUFFICIENT BALANCE MODAL
          ========================================================================= */}
      {insufficientBalanceOpen && (
        <div className="bottom-sheet-overlay" onClick={() => setInsufficientBalanceOpen(false)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '24px', textAlign: 'center' }}>
            <Coins size={40} color="#ffa502" style={{ margin: '0 auto 12px', display: 'block' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>Insufficient Balance</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              A Spark costs {SPARK_COST} coins. You have {coinBalance} coins. Add more to send a Mega-Crush.
            </p>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={() => setInsufficientBalanceOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '12px' }}>
                Close
              </button>
              <button
                onClick={() => { setInsufficientBalanceOpen(false); onOpenStore(); }}
                className="btn-gold"
                style={{ flex: 1, padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}
              >
                <Coins size={14} />
                Buy Coins
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =========================================================================
          PROFILE DETAILS BOTTOM SHEET (swipeable photos + 3-dot menu)
          ========================================================================= */}
      {inspectingProfile && (
        <div className="bottom-sheet-overlay" onClick={() => { setInspectingProfile(null); setIsProfileMenuOpen(false); }}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '20px' }}>
            {/* Header + 3-dot menu */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', minWidth: 0 }}>
                <h3 style={{ fontSize: '20px', fontWeight: 800, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {inspectingProfile.nickname}, {inspectingProfile.age || 24}
                </h3>
                {inspectingProfile.is_verified && (
                  <span style={{ display: 'flex', alignItems: 'center', gap: '3px', background: 'rgba(29, 161, 242, 0.2)', padding: '2px 8px', borderRadius: 'var(--radius-full)', color: '#1da1f2', fontSize: '11px', fontWeight: 700, flexShrink: 0 }}>
                    <ShieldCheck size={12} />
                    Verified
                  </span>
                )}
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '4px', position: 'relative', flexShrink: 0 }}>
                <button
                  className="tap-target-44"
                  aria-label="Profile options"
                  onClick={() => setIsProfileMenuOpen((v) => !v)}
                  style={{ background: 'rgba(255,255,255,0.08)', border: 'none', borderRadius: '50%', color: '#fff', cursor: 'pointer' }}
                >
                  <MoreVertical size={18} />
                </button>
                <button
                  className="tap-target-44"
                  aria-label="Close profile"
                  onClick={() => { setInspectingProfile(null); setIsProfileMenuOpen(false); }}
                  style={{ background: 'rgba(255,255,255,0.08)', border: 'none', borderRadius: '50%', color: '#fff', cursor: 'pointer' }}
                >
                  <X size={16} />
                </button>

                {isProfileMenuOpen && (
                  <div className="glass-panel" style={{ position: 'absolute', top: '46px', right: 0, borderRadius: 'var(--radius-md)', overflow: 'hidden', minWidth: '160px', zIndex: 5 }}>
                    <button
                      onClick={() => { setIsProfileMenuOpen(false); setShowReportDialog(inspectingProfile); }}
                      style={{ display: 'flex', alignItems: 'center', gap: '8px', width: '100%', padding: '12px 14px', background: 'transparent', border: 'none', color: '#ffa502', fontSize: '13px', cursor: 'pointer', textAlign: 'left' }}
                    >
                      <Flag size={14} />
                      Report
                    </button>
                    <button
                      onClick={() => { setIsProfileMenuOpen(false); setShowBlockDialog(inspectingProfile); }}
                      style={{ display: 'flex', alignItems: 'center', gap: '8px', width: '100%', padding: '12px 14px', background: 'transparent', border: 'none', color: '#ff4757', fontSize: '13px', cursor: 'pointer', textAlign: 'left', borderTop: '1px solid var(--border-glass)' }}
                    >
                      <Ban size={14} />
                      Block
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Swipeable photos */}
            <div
              style={{ position: 'relative', height: '320px', borderRadius: 'var(--radius-md)', overflow: 'hidden', marginBottom: '16px', touchAction: 'pan-y' }}
              onPointerDown={(e) => { profileSwipeStartRef.current = e.clientX; }}
              onPointerUp={(e) => {
                const start = profileSwipeStartRef.current;
                profileSwipeStartRef.current = null;
                if (start === null) return;
                const dx = e.clientX - start;
                const total = inspectingProfile.photo_urls.length || 1;
                if (dx < -40) setProfilePhotoIdx((p) => Math.min(p + 1, total - 1));
                else if (dx > 40) setProfilePhotoIdx((p) => Math.max(p - 1, 0));
              }}
            >
              <img
                src={inspectingProfile.photo_urls[profilePhotoIdx] || inspectingProfile.photo_urls[0] || '/ananya.jpg'}
                alt={inspectingProfile.nickname}
                style={{ width: '100%', height: '100%', objectFit: 'cover', filter: inspectingProfileLimited ? 'blur(18px) brightness(0.55)' : 'none' }}
              />

              {/* Story progress bars */}
              {inspectingProfile.photo_urls.length > 1 && (
                <div style={{ position: 'absolute', top: '10px', left: '14px', right: '14px', display: 'flex', gap: '4px' }}>
                  {inspectingProfile.photo_urls.map((_, idx) => (
                    <div key={idx} style={{ flex: 1, height: '3px', borderRadius: '2px', background: idx === profilePhotoIdx ? '#fff' : 'rgba(255,255,255,0.35)' }} />
                  ))}
                </div>
              )}

              {/* Limited-visibility overlay */}
              {inspectingProfileLimited && (
                <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
                  <div style={{ background: 'rgba(0,0,0,0.55)', border: '1px solid rgba(255,215,0,0.4)', borderRadius: 'var(--radius-full)', padding: '5px 14px', fontSize: '14px', fontWeight: 800, color: '#ffd700' }}>
                    {inspectingProfile.vibe_score || 80}% Match
                  </div>
                  <span style={{ fontSize: '11px', color: 'rgba(255,255,255,0.75)' }}>Full photo locked today</span>
                </div>
              )}

              {/* General distance pill */}
              <div style={{ position: 'absolute', bottom: '12px', left: '12px', background: 'rgba(0,0,0,0.6)', padding: '4px 10px', borderRadius: 'var(--radius-full)', fontSize: '12px', color: 'var(--cyan-vibe)', display: 'flex', alignItems: 'center', gap: '5px' }}>
                <MapPin size={13} />
                <span>~{inspectingProfile.distance_km} km • {inspectingProfile.city}</span>
              </div>
            </div>

            {/* Bio */}
            <div style={{ marginBottom: '16px' }}>
              <h4 style={{ fontSize: '12px', textTransform: 'uppercase', color: 'var(--text-muted)', marginBottom: '4px', letterSpacing: '0.8px' }}>About</h4>
              <p style={{ fontSize: '14px', color: 'var(--text-secondary)', lineHeight: 1.45 }}>{inspectingProfile.bio}</p>
            </div>

            {/* Interests (limited shows only top 3) */}
            <div style={{ marginBottom: '20px' }}>
              <h4 style={{ fontSize: '12px', textTransform: 'uppercase', color: 'var(--text-muted)', marginBottom: '8px', letterSpacing: '0.8px' }}>
                {inspectingProfileLimited ? 'Top Interests' : 'Shared Passions & Interests'}
              </h4>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {(inspectingProfileLimited
                  ? (inspectingProfile.shared_interests || []).slice(0, 3)
                  : (inspectingProfile.shared_interests || ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'])
                ).map((tag, idx) => (
                  <span key={idx} style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)', borderRadius: 'var(--radius-full)', padding: '4px 10px', fontSize: '12px', color: '#fff' }}>
                    {tag}
                  </span>
                ))}
              </div>
            </div>

            {/* Trust & safety actions */}
            <div style={{ borderTop: '1px solid rgba(255,255,255,0.08)', paddingTop: '16px', display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setShowReportDialog(inspectingProfile)}
                className="btn-ghost"
                style={{ flex: 1, minHeight: '44px', padding: '10px', fontSize: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', color: '#ffa502' }}
              >
                <AlertTriangle size={14} />
                Report
              </button>
              <button
                onClick={() => setShowBlockDialog(inspectingProfile)}
                className="btn-ghost"
                style={{ flex: 1, minHeight: '44px', padding: '10px', fontSize: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', color: '#ff4757' }}
              >
                <Ban size={14} />
                Block
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =========================================================================
          FILTER MODAL / BOTTOM DRAWER
          ========================================================================= */}
      {isFilterModalOpen && (
        <div className="bottom-sheet-overlay" onClick={() => setIsFilterModalOpen(false)}>
          <div className="bottom-sheet-content" onClick={(e) => e.stopPropagation()} style={{ padding: '22px' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: 800 }}>Discovery Filters</h3>
              <button
                onClick={() => setIsFilterModalOpen(false)}
                style={{ background: 'none', border: 'none', color: '#fff', cursor: 'pointer' }}
              >
                <X size={18} />
              </button>
            </div>

            {/* Distance Filter Slider */}
            <div style={{ marginBottom: '18px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Maximum Distance</span>
                <strong style={{ color: 'var(--cyan-vibe)' }}>{maxDistance} km</strong>
              </div>
              <input
                type="range"
                min="5"
                max="100"
                step="5"
                value={maxDistance}
                onChange={(e) => setMaxDistance(Number(e.target.value))}
                style={{ width: '100%', accentColor: '#00e5ff' }}
              />
            </div>

            {/* Age Range Sliders */}
            <div style={{ marginBottom: '18px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Age Range</span>
                <strong style={{ color: '#ff2d55' }}>{minAge} - {maxAge} years</strong>
              </div>
              <div style={{ display: 'flex', gap: '12px' }}>
                <input
                  type="range"
                  min="18"
                  max="40"
                  value={minAge}
                  onChange={(e) => setMinAge(Math.min(Number(e.target.value), maxAge))}
                  style={{ width: '50%', accentColor: '#ff2d55' }}
                />
                <input
                  type="range"
                  min="18"
                  max="50"
                  value={maxAge}
                  onChange={(e) => setMaxAge(Math.max(Number(e.target.value), minAge))}
                  style={{ width: '50%', accentColor: '#ff2d55' }}
                />
              </div>
            </div>

            {/* Interest Filter */}
            <div style={{ marginBottom: '22px' }}>
              <div style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '8px' }}>Interest Vibe</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨', 'Architecture 🏛️', 'Vintage Fashion 👗'].map((interest) => (
                  <button
                    key={interest}
                    onClick={() => setSelectedInterest(selectedInterest === interest ? null : interest)}
                    className={`filter-pill ${selectedInterest === interest ? 'active' : ''}`}
                    style={{ fontSize: '11px', padding: '4px 10px' }}
                  >
                    {interest}
                  </button>
                ))}
              </div>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={resetFilters}
                className="btn-ghost"
                style={{ flex: 1, padding: '12px', fontSize: '13px' }}
              >
                Reset
              </button>
              <button
                onClick={() => {
                  setIsFilterModalOpen(false);
                  setCurrentIndex(0);
                  showToast('Filters applied!');
                }}
                className="btn-primary"
                style={{ flex: 2, padding: '12px', fontSize: '13px' }}
              >
                Apply Filters
              </button>
            </div>
          </div>
        </div>
      )}

      {/* BLOCK CONFIRMATION DIALOG */}
      {showBlockDialog && (
        <div className="bottom-sheet-overlay" onClick={() => setShowBlockDialog(null)}>
          <div
            className="bottom-sheet-content"
            onClick={(e) => e.stopPropagation()}
            style={{ padding: '24px', textAlign: 'center' }}
          >
            <Ban size={40} color="#ff4757" style={{ margin: '0 auto 12px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '6px' }}>
              Block {showBlockDialog.nickname}?
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              They will be removed from your Likes, discovery deck and matches. This action is enforced immediately for this session.
            </p>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setShowBlockDialog(null)}
                className="btn-ghost"
                style={{ flex: 1, padding: '12px' }}
              >
                Cancel
              </button>
              <button
                onClick={() => confirmBlockUser(showBlockDialog)}
                className="btn-primary"
                style={{ flex: 1, padding: '12px', background: '#ff4757' }}
              >
                Confirm Block
              </button>
            </div>
          </div>
        </div>
      )}

      {/* REPORT CONFIRMATION DIALOG */}
      {showReportDialog && (
        <div className="bottom-sheet-overlay" onClick={() => setShowReportDialog(null)}>
          <div
            className="bottom-sheet-content"
            onClick={(e) => e.stopPropagation()}
            style={{ padding: '24px' }}
          >
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>
              Report {showReportDialog.nickname}
            </h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              Select a reason to flag this profile to the YoUnMe Trust & Safety moderation team:
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
              {['Inappropriate or explicit photos', 'Suspected fake profile / bot', 'Commercial spam or solicitations', 'Harassment or abusive behavior'].map((reason) => (
                <button
                  key={reason}
                  onClick={() => confirmReportUser(showReportDialog, reason)}
                  className="btn-ghost"
                  style={{ textAlign: 'left', padding: '12px 14px', fontSize: '13px' }}
                >
                  {reason}
                </button>
              ))}
            </div>
            <button
              onClick={() => setShowReportDialog(null)}
              className="btn-ghost"
              style={{ width: '100%', padding: '10px' }}
            >
              Cancel
            </button>
          </div>
        </div>
      )}

    </div>
  );
};
