import React, { useState, useMemo, useEffect, useRef } from 'react';
import {
  Heart,
  Sparkles,
  Flame,
  Phone,
  MessageCircle,
  PhoneCall,
  PhoneOff,
  Video,
  Mic,
  MicOff,
  Volume2,
  VolumeX,
  SlidersHorizontal,
  CheckCircle2,
  Users,
  Compass,
  X,
  Search,
  RefreshCw,
  Lock,
  Send,
  Trophy,
  Star,
  Zap,
  Shield,
  Square,
  Play,
  Calendar,
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { CandidateCard } from '../types';
import { DEMO_PROFILES } from '../data/profilesData';
import { RefreshAnimation } from '../components/RefreshAnimation';

export interface ConnectTabProps {
  onOpenChat: (convId: string, initialDraft?: string) => void;
  onStartCall?: (calleeId: string, name: string, avatar: string, mode?: 'audio' | 'video') => void;
  onOpenStore?: () => void;
  onMutualMatch?: (profile: CandidateCard) => void;
  coinBalance?: number;
  onCoinsDeducted?: (newBalance: number) => void;
  viewerGender?: string;
}

// Spark & Crush items
export interface SparkCrushItem {
  id: string;
  name: string;
  age: number;
  city: string;
  avatar: string;
  type: 'spark' | 'mega_crush';
  direction: 'received' | 'sent';
  message?: string;
  timestamp: string;
  interests: string[];
}

// Match History item (Max 50)
export interface MatchHistoryItem {
  id: string;
  userId: string;
  name: string;
  age: number;
  gender: string;
  city: string;
  avatar: string;
  matchPercentage: number;
  vibeScore: number;
  matched_at: string;
  lastActive: string;
  distance_km: number;
  preferences: string;
  bio: string;
  sharedInterests: string[];
  suggestedIcebreakers: string[];
}

// Like History item (Max 50)
export interface LikeHistoryItem {
  id: string;
  userId: string;
  name: string;
  age: number;
  gender: string;
  city: string;
  avatar: string;
  type: 'like' | 'spark' | 'mega_crush' | 'passed';
  timestamp: string;
  interests: string[];
  bio: string;
}

// Seed 50 realistic match history items from DEMO_PROFILES
const generate50Matches = (): MatchHistoryItem[] => {
  const list: MatchHistoryItem[] = [];
  const hoursAgo = (h: number) => new Date(Date.now() - h * 3600 * 1000).toISOString();
  for (let i = 0; i < 50; i++) {
    const p = DEMO_PROFILES[i % DEMO_PROFILES.length];
    list.push({
      id: `match_${i + 1}`,
      userId: p.user_id,
      name: p.nickname,
      age: p.age || 24,
      gender: p.gender || 'female',
      city: p.city,
      avatar: p.photo_urls[0],
      matchPercentage: Math.max(78, 99 - (i % 20)),
      vibeScore: Math.max(80, 98 - (i % 15)),
      matched_at: hoursAgo(i * 3 + 2),
      lastActive: i % 4 === 0 ? 'Active now' : `Active ${(i % 55) + 5}m ago`,
      distance_km: p.distance_km || 2.4,
      preferences: p.preference || 'Long-term relationship',
      bio: p.bio,
      sharedInterests: p.shared_interests || ['Coffee ☕', 'Vinyl 🎵', 'Art 🎨'],
      suggestedIcebreakers: [
        `What's your go-to weekend cafe in ${p.city.split(',')[0]}?`,
        'Which song do you currently have on repeat?',
        'Are you more into sunrise coffee or late night drives?',
      ],
    });
  }
  return list;
};

// Seed 50 realistic like history items
const generate50History = (): LikeHistoryItem[] => {
  const list: LikeHistoryItem[] = [];
  const types: ('like' | 'spark' | 'mega_crush' | 'passed')[] = ['like', 'spark', 'mega_crush', 'passed', 'like'];
  for (let i = 0; i < 50; i++) {
    const p = DEMO_PROFILES[i % DEMO_PROFILES.length];
    const itemType = types[i % types.length];
    list.push({
      id: `lh_${i + 1}`,
      userId: p.user_id,
      name: p.nickname,
      age: p.age || 24,
      gender: p.gender || 'female',
      city: p.city,
      avatar: p.photo_urls[0],
      type: itemType,
      timestamp: i < 5 ? `${(i + 1) * 2}h ago` : i < 15 ? `Yesterday` : `${Math.floor(i / 7) + 2}d ago`,
      interests: p.shared_interests || ['Music 🎵', 'Food 🍲', 'Travel ✈️'],
      bio: p.bio,
    });
  }
  return list;
};

// Spark / Crush items (received or sent)
const SPARK_CRUSH_LIST: SparkCrushItem[] = [
  {
    id: 'sc-1',
    name: 'Ananya',
    age: 24,
    city: 'Hyderabad, Jubilee Hills',
    avatar: DEMO_PROFILES[0].photo_urls[0],
    type: 'mega_crush',
    direction: 'received',
    message: 'Loved your playlist choice! Coffee this weekend?',
    timestamp: '15m ago',
    interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
  },
  {
    id: 'sc-2',
    name: 'Kavya',
    age: 23,
    city: 'Bengaluru, Indiranagar',
    avatar: DEMO_PROFILES[1].photo_urls[0],
    type: 'spark',
    direction: 'received',
    message: 'Your sketches look fantastic ✏️',
    timestamp: '1h ago',
    interests: ['Design Systems 📐', 'Filter Coffee ☕'],
  },
  {
    id: 'sc-3',
    name: 'Meera',
    age: 25,
    city: 'Hyderabad, Banjara Hills',
    avatar: DEMO_PROFILES[2].photo_urls[0],
    type: 'mega_crush',
    direction: 'sent',
    message: 'Would love to discuss magical realism books!',
    timestamp: '3h ago',
    interests: ['Books 📚', 'Classical Dance 💃', 'Vinyl 🎶'],
  },
  {
    id: 'sc-4',
    name: 'Riya',
    age: 24,
    city: 'Mumbai, Bandra West',
    avatar: DEMO_PROFILES[3].photo_urls[0],
    type: 'spark',
    direction: 'received',
    message: 'Bandra sunsets are unmatched 🌅',
    timestamp: '5h ago',
    interests: ['Pottery 🏺', 'Acoustic Rock 🎸'],
  },
  {
    id: 'sc-5',
    name: 'Ishita',
    age: 26,
    city: 'Hyderabad, Gachibowli',
    avatar: DEMO_PROFILES[4].photo_urls[0],
    type: 'spark',
    direction: 'sent',
    message: 'Let us hit the badminton court sometime 🏸',
    timestamp: 'Yesterday',
    interests: ['Badminton 🏸', 'Tech Startups 🚀'],
  },
];

// Icebreaker prompts list
const ICEBREAKER_PROMPTS = [
  "☕ If we met for coffee, what's your go-to order?",
  "🎵 What's one song that never fails to lift your mood?",
  "✈️ Spontaneous weekend getaway or cozy movie marathon?",
  "🌮 Best street food hidden gem in your city?",
  "🎨 If you could master any skill overnight, what would it be?",
  "📖 What's the last book that genuinely moved you?",
];

// STRICT REQUIREMENT: Illustrated/3D Avatars with Language tags for Floating Story Bubbles
export interface RandomCallAvatarProfile {
  id: string;
  name: string;
  avatar: string;
  countryName: string;
  countryFlag: string;
  language: string;
  isOnline: boolean;
  age: number;
}

export const RANDOM_CALL_AVATAR_PROFILES: RandomCallAvatarProfile[] = [
  {
    id: 'rc_1',
    name: 'Kavya Reddy',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Kavya&backgroundColor=ffd5dc,b6e3f4',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Telugu',
    isOnline: true,
    age: 23,
  },
  {
    id: 'rc_2',
    name: 'Aanya Sharma',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Aanya&backgroundColor=b6e3f4,ffd5dc,d1d4f9',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Hindi',
    isOnline: true,
    age: 24,
  },
  {
    id: 'rc_3',
    name: 'Rohan Mehra',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Rohan&backgroundColor=c0aede,ffd5dc',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'English',
    isOnline: true,
    age: 25,
  },
  {
    id: 'rc_4',
    name: 'Sneha Iyer',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Sneha&backgroundColor=d1d4f9,c0aede',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Tamil',
    isOnline: true,
    age: 23,
  },
  {
    id: 'rc_5',
    name: 'Meera Nair',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Meera&backgroundColor=b6e3f4,d1d4f9',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Malayalam',
    isOnline: true,
    age: 24,
  },
  {
    id: 'rc_6',
    name: 'Priya Patel',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Priya&backgroundColor=ffd5dc,d1d4f9',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Gujarati',
    isOnline: true,
    age: 24,
  },
  {
    id: 'rc_7',
    name: 'Kabir Verma',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Kabir&backgroundColor=c0aede,b6e3f4',
    countryName: 'India',
    countryFlag: '🇮🇳',
    language: 'Punjabi',
    isOnline: true,
    age: 26,
  },
  {
    id: 'rc_8',
    name: 'Maya Chen',
    avatar: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Maya&backgroundColor=d1d4f9,ffd5dc',
    countryName: 'Singapore',
    countryFlag: '🇸🇬',
    language: 'English',
    isOnline: true,
    age: 22,
  },
];

export const ConnectTab: React.FC<ConnectTabProps> = ({
  onOpenChat,
  onStartCall,
  onMutualMatch,
}) => {
  
  // 1. TOP SUB-TABS: STRICTLY Likes | Matches | Random Call
  const [activeSubTab, setActiveSubTab] = useState<'random_call' | 'likes' | 'matches'>('random_call');

  // 2. FILTER PILLS: Recommended | Nearby | Online | Interests | More
  const [activeFilterPill, setActiveFilterPill] = useState<'recommended' | 'nearby' | 'online' | 'interests'>('recommended');
  const [showMoreFiltersModal, setShowMoreFiltersModal] = useState(false);
  const [ageRange, setAgeRange] = useState<number>(28);
  const [maxDistanceKm, setMaxDistanceKm] = useState<number>(35);
  const [selectedRelationshipPref, setSelectedRelationshipPref] = useState<string>('All');
  const [selectedTopics, setSelectedTopics] = useState<string[]>(['Coffee ☕', 'Indie Vinyl 🎵']);

  // Data sets

  
  const [matches, setMatches] = useState<MatchHistoryItem[]>(generate50Matches);
  const [likesHistory, setLikesHistory] = useState<LikeHistoryItem[]>(generate50History);
  const [sparkCrushList, setSparkCrushList] = useState<SparkCrushItem[]>(SPARK_CRUSH_LIST);
  const [likesYouList, setLikesYouList] = useState<CandidateCard[]>(DEMO_PROFILES.slice(0, 10));
  const [searchQuery, setSearchQuery] = useState('');

  // Weekly metrics & Refreshing animation
  const [isRefreshing, setIsRefreshing] = useState(false);

  // MODAL STATES
  // Workflow: Partially Restricted Modal (Like Side)
  const [partiallyRestrictedProfile, setPartiallyRestrictedProfile] = useState<{
    name: string;
    avatar: string;
    age: number;
    is_verified: boolean;
    interests: string[];
    actor_id: string;
  } | null>(null);

  // Workflow: Restricted Modal (Dislike / Passed Side)
  const [restrictedProfile, setRestrictedProfile] = useState<{
    name: string;
    avatar: string;
  } | null>(null);

  // Workflow: Limited Visibility Modal (Potential Matches)
  const [limitedProfile, setLimitedProfile] = useState<{
    nickname: string;
    age: number;
    gender: string;
    distance_km: number;
    interests: string[];
  } | null>(null);

  // Workflow: Full Visibility Modal (Matched Recently)
  const [fullProfile, setFullProfile] = useState<MatchHistoryItem | null>(null);

  // Workflow: "Make First Move" Chat Overlay
  const [firstMoveChatMatch, setFirstMoveChatMatch] = useState<MatchHistoryItem | null>(null);
  const [firstMoveMessage, setFirstMoveMessage] = useState('');
  const [isRecordingVoice, setIsRecordingVoice] = useState(false);
  const [voiceRecordedToast, setVoiceRecordedToast] = useState(false);

  // Workflow: "Make First Move" Icebreakers Drawer
  const [firstMoveIcebreakerMatch, setFirstMoveIcebreakerMatch] = useState<MatchHistoryItem | null>(null);

  // Random Call state
  const [randomCallState, setRandomCallState] = useState<'idle' | 'searching' | 'connected'>('idle');
  const [randomCallTimer, setRandomCallTimer] = useState<number>(0);
  const [isMuted, setIsMuted] = useState(false);
  const [isSpeaker, setIsSpeaker] = useState(true);
  const [hasLikedCallPartner, setHasLikedCallPartner] = useState(false);
  const [randomProfileIndex, setRandomProfileIndex] = useState(0);
  const [currentCallMode, setCurrentCallMode] = useState<'audio' | 'video'>('audio');
  const [showRandomCallSelector, setShowRandomCallSelector] = useState<boolean>(true);
  const currentAvatarProfile = RANDOM_CALL_AVATAR_PROFILES[randomProfileIndex] || RANDOM_CALL_AVATAR_PROFILES[0];

  // Selected profile for Random Call popup modal
  const [selectedRandomCallProfile, setSelectedRandomCallProfile] = useState<{
    id: string;
    name: string;
    avatar: string;
    sticker: string;
    language: string;
    age: number;
    ringColor: string;
  } | null>(null);

  // Filtered profiles for Horizontal Slide View below Filter Pills
  const filteredProfilesCarousel = useMemo(() => {
    return DEMO_PROFILES.filter((p) => {
      if (activeFilterPill === 'nearby') return p.distance_km <= (maxDistanceKm || 15);
      if (activeFilterPill === 'online') return p.is_online === true;
      if (activeFilterPill === 'interests') {
        if (selectedTopics.length === 0) return true;
        return p.shared_interests?.some((i) => selectedTopics.some((t) => i.includes(t.split(' ')[0])));
      }
      return true; // recommended
    });
  }, [activeFilterPill, maxDistanceKm, selectedTopics]);

  // Filtered Random Call Floating Profiles
  const filteredRandomCallProfiles = useMemo(() => {
    const stickerEmojis = ['🦊', '🐰', '🐼', '🐱', '🦄', '🌸', '🐻', '🐯', '🍓', '🐨', '🦋', '🐥'];
    const ringColors = [
      'rgba(244, 63, 94, 0.75)',
      'rgba(56, 189, 248, 0.75)',
      'rgba(168, 85, 247, 0.75)',
      'rgba(251, 146, 60, 0.75)',
      'rgba(34, 197, 94, 0.75)',
      'rgba(236, 72, 153, 0.75)',
      'rgba(250, 204, 21, 0.75)',
      'rgba(20, 184, 166, 0.75)',
    ];

    return RANDOM_CALL_AVATAR_PROFILES.map((p, idx) => ({
      ...p,
      sticker: stickerEmojis[idx % stickerEmojis.length],
      ringColor: ringColors[idx % ringColors.length],
    })).filter((prof) => {
      if (activeFilterPill === 'online') return prof.isOnline;
      if (activeFilterPill === 'nearby') return prof.countryName === 'India' || prof.language === 'Telugu' || prof.language === 'English';
      if (activeFilterPill === 'interests') {
        if (selectedTopics.length === 0) return true;
        return true;
      }
      return true;
    });
  }, [activeFilterPill, selectedTopics]);

  // Vibe Scoreboard (Top 3 vibed this week)
  const topVibedWeekly = useMemo(() => {
    return matches.slice(0, 3);
  }, [matches]);

  // Potential Matches (Curated based on active preferences & daily prompts)
  const potentialMatches = useMemo(() => {
    return DEMO_PROFILES.slice(10, 20);
  }, []);

  // Matched Recently (Top matches relative to all swipes)
  const matchedRecentlyList = useMemo(() => {
    return matches.slice(0, 8);
  }, [matches]);

  // Filtered match history by search and active filter pill
  const filteredMatchHistory = useMemo(() => {
    let result = matches;
    if (activeFilterPill === 'nearby') {
      result = result.filter((m) => m.distance_km <= (maxDistanceKm || 25));
    } else if (activeFilterPill === 'online') {
      result = result.filter((m) => m.lastActive.toLowerCase().includes('online') || m.lastActive.toLowerCase().includes('m ago'));
    } else if (activeFilterPill === 'interests') {
      if (selectedTopics.length > 0) {
        result = result.filter((m) => m.sharedInterests.some((i) => selectedTopics.some((t) => i.includes(t.split(' ')[0]))));
      }
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter((m) => m.name.toLowerCase().includes(q) || m.city.toLowerCase().includes(q));
    }
    return result;
  }, [matches, searchQuery, activeFilterPill, maxDistanceKm, selectedTopics]);

  // Filter strip component for Matches and Random Call tabs (hidden on Likes tab)
  const renderFilterStrip = () => (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        overflowX: 'auto',
        scrollbarWidth: 'none',
        paddingBottom: '2px',
        marginBottom: '14px',
      }}
    >
      <button
        type="button"
        onClick={() => setActiveFilterPill('recommended')}
        style={{
          padding: '6px 14px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: 700,
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          transition: 'all 0.15s ease',
          background: activeFilterPill === 'recommended' ? '#f43f5e' : '#191c24',
          color: activeFilterPill === 'recommended' ? '#ffffff' : '#94a3b8',
          border: activeFilterPill === 'recommended' ? '1px solid #f43f5e' : '1px solid rgba(255, 255, 255, 0.08)',
        }}
      >
        Recommended
      </button>

      <button
        type="button"
        onClick={() => setActiveFilterPill('nearby')}
        style={{
          padding: '6px 14px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: 700,
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          transition: 'all 0.15s ease',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '5px',
          background: activeFilterPill === 'nearby' ? '#f43f5e' : '#191c24',
          color: activeFilterPill === 'nearby' ? '#ffffff' : '#94a3b8',
          border: activeFilterPill === 'nearby' ? '1px solid #f43f5e' : '1px solid rgba(255, 255, 255, 0.08)',
        }}
      >
        <span>Nearby</span>
      </button>

      <button
        type="button"
        onClick={() => setActiveFilterPill('online')}
        style={{
          padding: '6px 14px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: 700,
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          transition: 'all 0.15s ease',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '6px',
          background: activeFilterPill === 'online' ? 'rgba(34, 197, 94, 0.2)' : '#191c24',
          color: activeFilterPill === 'online' ? '#22c55e' : '#94a3b8',
          border: activeFilterPill === 'online' ? '1px solid #22c55e' : '1px solid rgba(255, 255, 255, 0.08)',
        }}
      >
        <span
          style={{
            width: '6px',
            height: '6px',
            borderRadius: '50%',
            background: '#22c55e',
          }}
        />
        <span>Online</span>
      </button>

      <button
        type="button"
        onClick={() => setActiveFilterPill('interests')}
        style={{
          padding: '6px 14px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: 700,
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          transition: 'all 0.15s ease',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '5px',
          background: activeFilterPill === 'interests' ? '#f43f5e' : '#191c24',
          color: activeFilterPill === 'interests' ? '#ffffff' : '#94a3b8',
          border: activeFilterPill === 'interests' ? '1px solid #f43f5e' : '1px solid rgba(255, 255, 255, 0.08)',
        }}
      >
        <Sparkles size={12} />
        <span>Interests</span>
      </button>

      <button
        type="button"
        onClick={() => setShowMoreFiltersModal(true)}
        style={{
          padding: '6px 14px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: 700,
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          transition: 'all 0.15s ease',
          display: 'inline-flex',
          alignItems: 'center',
          gap: '5px',
          background: '#191c24',
          color: '#94a3b8',
          border: '1px solid rgba(255, 255, 255, 0.08)',
        }}
      >
        <SlidersHorizontal size={12} />
        <span>More</span>
      </button>
    </div>
  );

  // Random Call timer effect
  useEffect(() => {
    let interval: ReturnType<typeof setInterval> | null = null;
    if (randomCallState === 'connected') {
      interval = setInterval(() => {
        setRandomCallTimer((prev) => {
          if (prev >= 180) { // 3-minute icebreaker limit
            setRandomCallState('idle');
            return 0;
          }
          return prev + 1;
        });
      }, 1000);
    } else {
      setRandomCallTimer(0);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [randomCallState]);

  const formatTimer = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleStartRandomCall = (mode: 'audio' | 'video' = 'audio', partner?: RandomCallAvatarProfile) => {
    if (partner) {
      const pIdx = RANDOM_CALL_AVATAR_PROFILES.findIndex((p) => p.id === partner.id);
      if (pIdx !== -1) {
        setRandomProfileIndex(pIdx);
      }
    }
    setCurrentCallMode(mode);
    setRandomCallState('searching');
    setTimeout(() => {
      setRandomCallState('connected');
      setHasLikedCallPartner(false);
      try {
        confetti({
          particleCount: 30,
          spread: 50,
          origin: { y: 0.6 },
          colors: ['#38bdf8', '#0284c7', '#ffffff'],
        });
      } catch { }
    }, 1200);
  };

  const handleEndCall = () => {
    setRandomCallState('idle');
    setRandomCallTimer(0);
  };

  // Like Back Handler in Partially Restricted Modal
  const handleLikePartiallyRestricted = () => {
    if (!partiallyRestrictedProfile) return;
    try {
      confetti({
        particleCount: 50,
        spread: 60,
        origin: { y: 0.6 },
        colors: ['#22c55e', '#f43f5e', '#ffd700'],
      });
    } catch { }

    const target = DEMO_PROFILES.find((p) => p.user_id === partiallyRestrictedProfile.actor_id);
    if (target && onMutualMatch) {
      onMutualMatch(target);
    }
    setPartiallyRestrictedProfile(null);
  };

  const handleDislikePartiallyRestricted = () => {
    setPartiallyRestrictedProfile(null);
  };

  // Send first move text message
  const handleSendFirstMoveText = () => {
    if (!firstMoveChatMatch || !firstMoveMessage.trim()) return;
    onOpenChat('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', firstMoveMessage);
    setFirstMoveMessage('');
    setFirstMoveChatMatch(null);
  };

  // Send first move icebreaker
  const handleSendIcebreaker = (prompt: string) => {
    if (!firstMoveIcebreakerMatch) return;
    onOpenChat('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', prompt);
    setFirstMoveIcebreakerMatch(null);
  };

  // Toggle voice recording
  const handleToggleVoiceRecord = () => {
    if (!isRecordingVoice) {
      setIsRecordingVoice(true);
    } else {
      setIsRecordingVoice(false);
      setVoiceRecordedToast(true);
      setTimeout(() => setVoiceRecordedToast(false), 1800);
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        padding: '12px 16px 84px',
        minHeight: '100%',
        color: '#f8fafc',
        backgroundColor: '#111318',
        boxSizing: 'border-box',
      }}
    >
      {/* =================================================================== */}
      {/* 1. TOP 3-BUTTON SEGMENTED TAB BAR IN EXACT ORDER: Likes | Matches | Random Call */}
      {/* =================================================================== */}
      <div className="seg-tabs" style={{ marginBottom: '12px' }}>
        <button
          type="button"
          onClick={() => setActiveSubTab('random_call')}
          className={`seg-tab ${activeSubTab === 'random_call' ? 'active' : ''}`}
        >
          Random call
        </button>
        <button
          type="button"
          onClick={() => setActiveSubTab('likes')}
          className={`seg-tab ${activeSubTab === 'likes' ? 'active' : ''}`}
        >
          Likes
        </button>
        <button
          type="button"
          onClick={() => setActiveSubTab('matches')}
          className={`seg-tab ${activeSubTab === 'matches' ? 'active' : ''}`}
        >
          Matches
        </button>
      </div>

      {/* =================================================================== */}
      {/* SUB-TAB 1: LIKES TAB (WORKFLOW: SPARKS, WEEKLY METRICS, LIKES HISTORY) */}
      {/* =================================================================== */}
      {activeSubTab === 'likes' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* SECTION 1: SPARK / CRUSH TAB (HORIZONTAL SLIDING GRID) */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Flame size={16} color="#ef4444" fill="#ef4444" />
                <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                  Sparks & Mega Crushes ({sparkCrushList.length})
                </span>
              </div>
              <span style={{ fontSize: '10.5px', color: '#ef4444', fontWeight: 700 }}>Priority Matches</span>
            </div>

            <div
              style={{
                display: 'flex',
                gap: '10px',
                overflowX: 'auto',
                paddingBottom: '4px',
                scrollbarWidth: 'none',
              }}
            >
              {sparkCrushList.map((sc) => (
                <div
                  key={sc.id}
                  onClick={() => {
                    setPartiallyRestrictedProfile({
                      name: sc.name,
                      avatar: sc.avatar,
                      age: sc.age,
                      is_verified: true,
                      interests: sc.interests,
                      actor_id: sc.id,
                    });
                  }}
                  style={{
                    flexShrink: 0,
                    width: '130px',
                    borderRadius: '14px',
                    background: sc.type === 'mega_crush' ? 'rgba(239, 68, 68, 0.12)' : 'rgba(251, 191, 36, 0.12)',
                    border: sc.type === 'mega_crush' ? '1.5px solid rgba(239, 68, 68, 0.4)' : '1.5px solid rgba(251, 191, 36, 0.4)',
                    padding: '8px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    cursor: 'pointer',
                    boxShadow: sc.type === 'mega_crush' ? '0 4px 14px rgba(239, 68, 68, 0.18)' : '0 4px 14px rgba(251, 191, 36, 0.18)',
                  }}
                >
                  <div style={{ position: 'relative', width: '56px', height: '56px', marginBottom: '6px' }}>
                    <img
                      src={sc.avatar}
                      alt={sc.name}
                      style={{
                        width: '100%',
                        height: '100%',
                        borderRadius: '50%',
                        objectFit: 'cover',
                        border: sc.type === 'mega_crush' ? '2px solid #ef4444' : '2px solid #fbbf24',
                      }}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        bottom: '-3px',
                        right: '-2px',
                        borderRadius: '50%',
                        padding: '3px',
                        background: sc.type === 'mega_crush' ? '#ef4444' : '#fbbf24',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      {sc.type === 'mega_crush' ? <Flame size={10} color="#fff" fill="#fff" /> : <Zap size={10} color="#000" fill="#000" />}
                    </div>
                  </div>

                  <div style={{ fontSize: '12px', fontWeight: 800, color: '#f8fafc', textAlign: 'center' }}>
                    {sc.name}, {sc.age}
                  </div>
                  <div style={{ fontSize: '9.5px', color: sc.type === 'mega_crush' ? '#ef4444' : '#fbbf24', fontWeight: 700, marginTop: '1px' }}>
                    {sc.type === 'mega_crush' ? '🔥 Mega Crush' : '⚡ Spark Sent'}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 2: WEEKLY METRICS & ACTIVITY INSIGHTS */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                Weekly Activity & Insights
              </span>
              <span style={{ fontSize: '10px', color: '#22c55e', fontWeight: 700 }}>
                Live Analytics
              </span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '8px', textAlign: 'center' }}>
              <div>
                <div style={{ fontSize: '18px', fontWeight: 900, color: '#f8fafc' }}>24</div>
                <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '2px', fontWeight: 600 }}>Likes Sent</div>
                <div style={{ fontSize: '9px', color: '#22c55e', fontWeight: 700 }}>+18% ↗</div>
              </div>
              <div>
                <div style={{ fontSize: '18px', fontWeight: 900, color: '#fbbf24' }}>6</div>
                <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '2px', fontWeight: 600 }}>Sparks</div>
                <div style={{ fontSize: '9px', color: '#fbbf24', fontWeight: 700 }}>+25% ↗</div>
              </div>
              <div>
                <div style={{ fontSize: '18px', fontWeight: 900, color: '#ef4444' }}>3</div>
                <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '2px', fontWeight: 600 }}>Mega Crushes</div>
                <div style={{ fontSize: '9px', color: '#ef4444', fontWeight: 700 }}>100% ✨</div>
              </div>
              <div>
                <div style={{ fontSize: '18px', fontWeight: 900, color: '#22c55e' }}>8</div>
                <div style={{ fontSize: '10px', color: '#94a3b8', marginTop: '2px', fontWeight: 600 }}>Matches/Wk</div>
                <div style={{ fontSize: '9px', color: '#22c55e', fontWeight: 700 }}>92% rate</div>
              </div>
            </div>

            {/* Weekly Reset Line strictly from workflow */}
            <div
              style={{
                fontSize: '11px',
                color: '#64748b',
                textAlign: 'center',
                marginTop: '12px',
                paddingTop: '10px',
                borderTop: '1px solid rgba(255, 255, 255, 0.05)',
                lineHeight: 1.35,
              }}
            >
              This data is for 1 week only and refreshes automatically every week.
            </div>
          </div>

          {/* SECTION 3: "X LIKES YOU" TAB (HORIZONTAL SLIDING VIEW WITH FREE TIER ACTIVE BADGE) */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <div>
                <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                  {likesYouList.length} People Liked You
                </span>
                <div style={{ fontSize: '10px', color: '#22c55e', fontWeight: 600, marginTop: '2px' }}>
                  ✓ Free Tier v1: Full View Active
                </div>
              </div>
              <span
                style={{
                  fontSize: '9.5px',
                  fontWeight: 700,
                  background: 'rgba(34, 197, 94, 0.15)',
                  border: '1px solid rgba(34, 197, 94, 0.35)',
                  color: '#22c55e',
                  padding: '3px 8px',
                  borderRadius: '999px',
                }}
              >
                10 Views Daily
              </span>
            </div>

            {/* Horizontal 5-visible circular story profiles */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px', overflowX: 'auto', paddingBottom: '4px' }}>
              {likesYouList.slice(0, 5).map((admirer) => (
                <div
                  key={admirer.user_id}
                  onClick={() => {
                    setPartiallyRestrictedProfile({
                      name: admirer.nickname,
                      avatar: admirer.photo_urls[0],
                      age: admirer.age || 24,
                      is_verified: admirer.is_verified,
                      interests: admirer.shared_interests || ['Coffee', 'Music'],
                      actor_id: admirer.user_id,
                    });
                  }}
                  title={`Tap to view ${admirer.nickname}'s profile`}
                  style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '5px',
                    cursor: 'pointer',
                    flexShrink: 0,
                  }}
                >
                  <div
                    style={{
                      width: '56px',
                      height: '56px',
                      borderRadius: '50%',
                      padding: '2px',
                      background: 'linear-gradient(135deg, #f43f5e 0%, #fb7185 100%)',
                      boxShadow: '0 2px 10px rgba(244, 63, 94, 0.22)',
                    }}
                  >
                    <img
                      src={admirer.photo_urls[0]}
                      alt={admirer.nickname}
                      style={{
                        width: '100%',
                        height: '100%',
                        borderRadius: '50%',
                        objectFit: 'cover',
                        border: '2px solid #111318',
                      }}
                    />
                  </div>
                  <span
                    style={{
                      fontSize: '11px',
                      fontWeight: 600,
                      color: '#f8fafc',
                      maxWidth: '54px',
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      textAlign: 'center',
                    }}
                  >
                    {admirer.nickname.split(' ')[0]}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 3: LIKES HISTORY TAB (VERTICAL LIST, MAX-HEIGHT: 240PX, MAX 50 ITEMS) */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                Likes History ({likesHistory.length})
              </span>
              <span style={{ fontSize: '10.5px', color: '#94a3b8' }}>Max 50 recent</span>
            </div>

            {/* Contained Vertical Scrollable Box (max-height: 240px) */}
            <div
              style={{
                maxHeight: '240px',
                overflowY: 'auto',
                borderRadius: '16px',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                padding: '10px',
                background: '#14161f',
                display: 'flex',
                flexDirection: 'column',
                gap: '8px',
              }}
            >
              {likesHistory.map((item) => {
                const isPassed = item.type === 'passed';
                return (
                  <div
                    key={item.id}
                    onClick={() => {
                      if (isPassed) {
                        // Workflow: Dislike / Passed side shows Restricted lock card
                        setRestrictedProfile({ name: item.name, avatar: item.avatar });
                      } else {
                        // Workflow: Like side opens Partially Restricted Modal
                        setPartiallyRestrictedProfile({
                          name: item.name,
                          avatar: item.avatar,
                          age: item.age,
                          is_verified: true,
                          interests: item.interests,
                          actor_id: item.userId,
                        });
                      }
                    }}
                    style={{
                      background: '#1e222d',
                      borderRadius: '12px',
                      padding: '8px 12px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      border: '1px solid rgba(255, 255, 255, 0.04)',
                      cursor: 'pointer',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0 }}>
                      <div style={{ position: 'relative' }}>
                        <img
                          src={item.avatar}
                          alt={item.name}
                          style={{
                            width: '36px',
                            height: '36px',
                            borderRadius: '50%',
                            objectFit: 'cover',
                            border: '1px solid rgba(255, 255, 255, 0.12)',
                            filter: isPassed ? 'grayscale(0.6)' : 'none',
                          }}
                        />
                        {isPassed && (
                          <div
                            style={{
                              position: 'absolute',
                              bottom: '-2px',
                              right: '-2px',
                              background: '#ef4444',
                              borderRadius: '50%',
                              padding: '2px',
                            }}
                          >
                            <Lock size={9} color="#fff" />
                          </div>
                        )}
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <div style={{ fontSize: '12.5px', fontWeight: 800, color: '#f8fafc' }}>
                          {item.name}, {item.age}
                        </div>
                        <div style={{ fontSize: '10px', color: '#94a3b8' }}>
                          {item.city.split(',')[0]} • {item.timestamp}
                        </div>
                      </div>
                    </div>

                    <span
                      style={{
                        fontSize: '9.5px',
                        fontWeight: 700,
                        padding: '3px 8px',
                        borderRadius: '999px',
                        background:
                          item.type === 'mega_crush'
                            ? 'rgba(239, 68, 68, 0.2)'
                            : item.type === 'spark'
                              ? 'rgba(251, 191, 36, 0.2)'
                              : item.type === 'passed'
                                ? 'rgba(100, 116, 139, 0.2)'
                                : 'rgba(34, 197, 94, 0.2)',
                        color:
                          item.type === 'mega_crush'
                            ? '#ef4444'
                            : item.type === 'spark'
                              ? '#fbbf24'
                              : item.type === 'passed'
                                ? '#94a3b8'
                                : '#22c55e',
                      }}
                    >
                      {item.type === 'mega_crush'
                        ? '🔥 Mega Crush'
                        : item.type === 'spark'
                          ? '⚡ Spark'
                          : item.type === 'passed'
                            ? '🔒 Passed'
                            : '❤️ Liked'}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* SUB-TAB 2: MATCHES TAB (WORKFLOW: SCOREBOARD, HISTORY, FIRST MOVE, POTENTIAL, RECENT) */}
      {/* =================================================================== */}
      {activeSubTab === 'matches' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* Horizontal category filter strip for matches & connections */}
          {renderFilterStrip()}

          {/* SECTION 1: "MATCHED & VIBED" SCOREBOARD */}
          <div
            style={{
              background: 'linear-gradient(135deg, rgba(244, 63, 94, 0.15) 0%, rgba(25, 28, 36, 0.95) 75%)',
              borderRadius: '20px',
              border: '1.5px solid rgba(244, 63, 94, 0.35)',
              padding: '14px 16px',
              boxShadow: '0 6px 20px rgba(244, 63, 94, 0.15)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Trophy size={16} color="#fbbf24" />
                <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                  Weekly Vibe Scoreboard
                </span>
              </div>
              <span style={{ fontSize: '10px', color: '#fbbf24', fontWeight: 700 }}>Top 3 Vibed</span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px' }}>
              {topVibedWeekly.map((item, idx) => (
                <div
                  key={item.id}
                  onClick={() => setFullProfile(item)}
                  style={{
                    background: 'rgba(255, 255, 255, 0.05)',
                    borderRadius: '14px',
                    padding: '8px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    cursor: 'pointer',
                    position: 'relative',
                    border: idx === 0 ? '1.5px solid #fbbf24' : '1px solid rgba(255, 255, 255, 0.1)',
                  }}
                >
                  {/* Rank badge */}
                  <div
                    style={{
                      position: 'absolute',
                      top: '-6px',
                      left: '6px',
                      background: idx === 0 ? '#fbbf24' : idx === 1 ? '#94a3b8' : '#b45309',
                      color: idx === 0 ? '#000' : '#fff',
                      fontSize: '9px',
                      fontWeight: 900,
                      padding: '1px 5px',
                      borderRadius: '6px',
                    }}
                  >
                    #{idx + 1}
                  </div>

                  <img
                    src={item.avatar}
                    alt={item.name}
                    style={{ width: '46px', height: '46px', borderRadius: '50%', objectFit: 'cover', marginTop: '4px' }}
                  />

                  <div style={{ fontSize: '12px', fontWeight: 800, color: '#f8fafc', marginTop: '4px' }}>
                    {item.name}
                  </div>

                  {/* Vibe meter bar */}
                  <div style={{ width: '100%', height: '5px', background: 'rgba(255, 255, 255, 0.1)', borderRadius: '999px', marginTop: '4px', overflow: 'hidden' }}>
                    <div
                      style={{
                        width: `${item.vibeScore}%`,
                        height: '100%',
                        background: 'linear-gradient(90deg, #f43f5e 0%, #22c55e 100%)',
                      }}
                    />
                  </div>
                  <div style={{ fontSize: '9px', color: '#22c55e', fontWeight: 700, marginTop: '2px' }}>
                    {item.vibeScore}% Vibe
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 2: MATCHES HISTORY (RECENT MUTUAL MATCHES — MAX 50) */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                Matches History ({filteredMatchHistory.length})
              </span>
              <span style={{ fontSize: '10px', color: '#94a3b8' }}>Max 50 recent</span>
            </div>

            {/* Compact scrollable container */}
            <div
              style={{
                maxHeight: '260px',
                overflowY: 'auto',
                borderRadius: '16px',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                padding: '10px',
                background: '#14161f',
                display: 'flex',
                flexDirection: 'column',
                gap: '8px',
              }}
            >
              {filteredMatchHistory.map((match) => (
                <div
                  key={match.id}
                  style={{
                    background: '#1e222d',
                    borderRadius: '12px',
                    padding: '8px 12px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    border: '1px solid rgba(255, 255, 255, 0.04)',
                  }}
                >
                  <div
                    onClick={() => setFullProfile(match)}
                    style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0, cursor: 'pointer', flex: 1 }}
                  >
                    <img
                      src={match.avatar}
                      alt={match.name}
                      style={{
                        width: '38px',
                        height: '38px',
                        borderRadius: '50%',
                        objectFit: 'cover',
                        border: '1.5px solid rgba(34, 197, 94, 0.4)',
                        flexShrink: 0,
                      }}
                    />
                    <div style={{ minWidth: 0 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                        <span style={{ fontSize: '13px', fontWeight: 800, color: '#f8fafc', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {match.name}, {match.age}
                        </span>
                        <span style={{ fontSize: '10px', color: '#22c55e', fontWeight: 700 }}>
                          • {match.matchPercentage}%
                        </span>
                      </div>
                      <div style={{ fontSize: '10px', color: '#94a3b8', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {match.city.split(',')[0]} • {match.lastActive}
                      </div>
                    </div>
                  </div>

                  {/* Right: Direct 1-on-1 Call and Chat icons */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexShrink: 0 }}>
                    <button
                      type="button"
                      onClick={() => onStartCall?.(match.userId, match.name, match.avatar)}
                      title={`Call ${match.name}`}
                      style={{
                        background: 'transparent',
                        border: 'none',
                        color: '#38bdf8',
                        padding: '6px',
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        cursor: 'pointer',
                      }}
                    >
                      <Phone size={17} />
                    </button>

                    <button
                      type="button"
                      onClick={() => onOpenChat('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')}
                      title={`Chat with ${match.name}`}
                      style={{
                        background: 'transparent',
                        border: 'none',
                        color: '#f43f5e',
                        padding: '6px',
                        borderRadius: '50%',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        cursor: 'pointer',
                      }}
                    >
                      <MessageCircle size={17} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 3: "MAKE FIRST MOVE" (CHAT & ICEBREAKER OPTIONS) */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Sparkles size={15} color="#38bdf8" />
                <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                  Make First Move
                </span>
              </div>
              <span style={{ fontSize: '10.5px', color: '#38bdf8' }}>Break the ice</span>
            </div>

            <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '4px' }}>
              {matches.slice(0, 4).map((m) => (
                <div
                  key={m.id}
                  style={{
                    flexShrink: 0,
                    width: '140px',
                    borderRadius: '14px',
                    background: '#222631',
                    padding: '10px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    border: '1px solid rgba(255, 255, 255, 0.06)',
                  }}
                >
                  <img
                    src={m.avatar}
                    alt={m.name}
                    style={{ width: '42px', height: '42px', borderRadius: '50%', objectFit: 'cover' }}
                  />
                  <div style={{ fontSize: '12px', fontWeight: 800, color: '#f8fafc', marginTop: '4px' }}>
                    {m.name}
                  </div>
                  <div style={{ fontSize: '9.5px', color: '#22c55e', fontWeight: 700 }}>
                    {m.matchPercentage}% Match
                  </div>

                  <div style={{ display: 'flex', gap: '6px', marginTop: '8px', width: '100%' }}>
                    {/* Trigger 1: Chat Button (opens Text Box Overlay with Voice Note button) */}
                    <button
                      type="button"
                      onClick={() => setFirstMoveChatMatch(m)}
                      title="Open Text Box Overlay"
                      style={{
                        flex: 1,
                        background: 'rgba(56, 189, 248, 0.15)',
                        border: '1px solid rgba(56, 189, 248, 0.4)',
                        color: '#38bdf8',
                        padding: '4px 0',
                        borderRadius: '8px',
                        fontSize: '10px',
                        fontWeight: 700,
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '3px',
                      }}
                    >
                      <MessageCircle size={11} />
                      <span>Chat</span>
                    </button>

                    {/* Trigger 2: Icebreaker Icon (opens horizontal sliding list of prompts) */}
                    <button
                      type="button"
                      onClick={() => setFirstMoveIcebreakerMatch(m)}
                      title="Select Icebreaker Prompt"
                      style={{
                        flex: 1,
                        background: 'rgba(244, 63, 94, 0.15)',
                        border: '1px solid rgba(244, 63, 94, 0.4)',
                        color: '#f43f5e',
                        padding: '4px 0',
                        borderRadius: '8px',
                        fontSize: '10px',
                        fontWeight: 700,
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '3px',
                      }}
                    >
                      <Sparkles size={11} />
                      <span>Prompt</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 4: "POTENTIAL MATCHES" -> LIMITED VISIBILITY ONCLICK */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
              <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                Potential Matches ({potentialMatches.length})
              </span>
              <span style={{ fontSize: '10px', color: '#94a3b8' }}>Tap for preview</span>
            </div>

            <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '4px' }}>
              {potentialMatches.map((pm) => (
                <div
                  key={pm.user_id}
                  onClick={() => {
                    // Limited Visibility OnClick: ONLY Nickname, Age & Gender, General Distance, Top 3 Interests
                    setLimitedProfile({
                      nickname: pm.nickname,
                      age: pm.age || 24,
                      gender: pm.gender || 'female',
                      distance_km: pm.distance_km || 3.5,
                      interests: pm.shared_interests ? pm.shared_interests.slice(0, 3) : ['Coffee', 'Music', 'Art'],
                    });
                  }}
                  style={{
                    flexShrink: 0,
                    width: '60px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '4px',
                    cursor: 'pointer',
                  }}
                >
                  <img
                    src={pm.photo_urls[0]}
                    alt={pm.nickname}
                    style={{
                      width: '52px',
                      height: '52px',
                      borderRadius: '50%',
                      objectFit: 'cover',
                      border: '1.5px solid rgba(255, 255, 255, 0.2)',
                    }}
                  />
                  <span style={{ fontSize: '10.5px', fontWeight: 600, color: '#f8fafc', textAlign: 'center', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', width: '100%' }}>
                    {pm.nickname}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* SECTION 5: "MATCHED RECENTLY METRICS" -> FULL VISIBILITY ONCLICK */}
          <div
            style={{
              background: '#191c24',
              borderRadius: '18px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
              <div>
                <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                  Matched Recently Metrics
                </span>
                <div style={{ fontSize: '10.5px', color: '#22c55e', fontWeight: 600, marginTop: '2px' }}>
                  18.4% swipe-to-match • 94% avg compatibility
                </div>
              </div>
              <span style={{ fontSize: '10px', color: '#38bdf8' }}>Full Profile</span>
            </div>

            {/* Constellation floating avatars row */}
            <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '4px' }}>
              {matchedRecentlyList.map((m) => (
                <div
                  key={m.id}
                  onClick={() => {
                    // Full Visibility Modal: Nickname, Age, Gender, Verified, Distance, Last Active, All Preferences, Full Interests, Bio, Chat / Call
                    setFullProfile(m);
                  }}
                  className="constellation-avatar-float"
                  style={{
                    flexShrink: 0,
                    width: '60px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: '4px',
                    cursor: 'pointer',
                  }}
                >
                  <div style={{ position: 'relative' }}>
                    <img
                      src={m.avatar}
                      alt={m.name}
                      style={{
                        width: '54px',
                        height: '54px',
                        borderRadius: '50%',
                        objectFit: 'cover',
                        border: '2px solid #22c55e',
                      }}
                    />
                    <span
                      style={{
                        position: 'absolute',
                        bottom: '-2px',
                        right: '-2px',
                        background: '#22c55e',
                        color: '#000',
                        fontSize: '8.5px',
                        fontWeight: 900,
                        padding: '1px 3px',
                        borderRadius: '4px',
                      }}
                    >
                      {m.matchPercentage}%
                    </span>
                  </div>
                  <span style={{ fontSize: '10.5px', fontWeight: 600, color: '#f8fafc' }}>
                    {m.name}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* SUB-TAB 3: RANDOM CALL TAB (FLOATING BUBBLE CANVAS + TAP-TO-CALL MODAL) */}
      {/* =================================================================== */}
      {activeSubTab === 'random_call' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {/* Horizontal filter strip for Random Call category refining */}
          {renderFilterStrip()}

          {randomCallState === 'idle' && (
            <div
              style={{
                background: '#191c24',
                borderRadius: '20px',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                padding: '16px 14px 20px',
                boxShadow: '0 6px 20px rgba(0, 0, 0, 0.35)',
                overflow: 'hidden',
                userSelect: 'none',
              }}
            >
              {/* Header with live indicator */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px', padding: '0 2px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.2px' }}>
                    Floating Connections
                  </span>
                  <span style={{ fontSize: '9px', fontWeight: 700, color: '#10b981', background: 'rgba(16, 185, 129, 0.15)', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '1px 6px', borderRadius: '999px' }}>
                    Live
                  </span>
                </div>
                <span style={{ fontSize: '10.5px', color: '#94a3b8' }}>Tap bubble to connect</span>
              </div>

              {/* Buoyant Floating Balloon Canvas: Multiple emoji/sticker avatars drifting smoothly */}
              <div
                style={{
                  display: 'flex',
                  gap: '16px',
                  overflowX: 'auto',
                  overflowY: 'hidden',
                  padding: '10px 4px 14px',
                  scrollbarWidth: 'none',
                  WebkitOverflowScrolling: 'touch',
                  alignItems: 'center',
                }}
              >
                {filteredRandomCallProfiles.map((prof, pIdx) => (
                  <div
                    key={prof.id}
                    onClick={() => setSelectedRandomCallProfile(prof)}
                    className="subtle-bubble-float"
                    style={{
                      flexShrink: 0,
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      gap: '6px',
                      cursor: 'pointer',
                      userSelect: 'none',
                      animationDelay: `${(pIdx % 6) * 0.3}s`,
                      transition: 'transform 0.18s ease',
                    }}
                  >
                    {/* Floating Bubble Avatar Circle with playful emoji character */}
                    <div
                      style={{
                        position: 'relative',
                        width: '58px',
                        height: '58px',
                        borderRadius: '50%',
                        background: `radial-gradient(circle at 35% 35%, rgba(255, 255, 255, 0.22), rgba(20, 23, 32, 0.95))`,
                        border: `2px solid ${prof.ringColor}`,
                        boxShadow: `0 4px 16px ${prof.ringColor.replace('0.75', '0.35')}, inset 0 2px 6px rgba(255, 255, 255, 0.15)`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '26px',
                      }}
                    >
                      <span style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.45))' }}>{prof.sticker}</span>
                      {/* Online Green Indicator Dot */}
                      <div
                        style={{
                          position: 'absolute',
                          bottom: '1px',
                          right: '1px',
                          width: '10px',
                          height: '10px',
                          borderRadius: '50%',
                          background: '#10b981',
                          border: '2px solid #111318',
                          boxShadow: '0 0 6px #10b981',
                        }}
                      />
                    </div>

                    {/* Profile Name */}
                    <span
                      style={{
                        fontSize: '11px',
                        fontWeight: 700,
                        color: '#f8fafc',
                        maxWidth: '68px',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        letterSpacing: '-0.2px',
                      }}
                    >
                      {prof.name.split(' ')[0]}
                    </span>

                    {/* Language Badge */}
                    <span
                      style={{
                        fontSize: '9px',
                        fontWeight: 700,
                        padding: '2px 7px',
                        borderRadius: '999px',
                        background: 'rgba(56, 189, 248, 0.12)',
                        color: '#38bdf8',
                        border: '1px solid rgba(56, 189, 248, 0.25)',
                        lineHeight: 1,
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {prof.language}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Searching Radar State */}
          {randomCallState === 'searching' && (
            <div
              style={{
                background: '#191c24',
                borderRadius: '20px',
                border: '1px solid rgba(56, 189, 248, 0.25)',
                padding: '30px 20px',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
              }}
            >
              <div
                style={{
                  width: '80px',
                  height: '80px',
                  borderRadius: '50%',
                  background: 'rgba(56, 189, 248, 0.15)',
                  border: '2px dashed #38bdf8',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: '16px',
                }}
              >
                <Compass size={34} color="#38bdf8" />
              </div>

              <h3 style={{ fontSize: '16px', fontWeight: 800, color: '#f8fafc', margin: '0 0 4px' }}>
                Connecting to {currentAvatarProfile.name}...
              </h3>
              <p style={{ fontSize: '12px', color: '#94a3b8', margin: '0 0 16px' }}>
                Starting {currentCallMode === 'video' ? 'encrypted HD Video' : 'clear Voice'} connection with {currentAvatarProfile.countryFlag} {currentAvatarProfile.countryName}...
              </p>

              <button
                type="button"
                onClick={handleEndCall}
                style={{
                  padding: '7px 18px',
                  borderRadius: '999px',
                  background: '#222631',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: '#94a3b8',
                  fontSize: '11.5px',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Cancel Call
              </button>
            </div>
          )}

          {/* Connected State with 3D Avatar & Controls */}
          {randomCallState === 'connected' && (
            <div
              style={{
                background: '#191c24',
                borderRadius: '20px',
                border: '1.5px solid #22c55e',
                padding: '24px 20px',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                boxShadow: '0 8px 30px rgba(34, 197, 94, 0.25)',
              }}
            >
              <div style={{ position: 'relative', marginBottom: '10px' }}>
                <img
                  src={currentAvatarProfile.avatar}
                  alt={currentAvatarProfile.name}
                  style={{
                    width: '74px',
                    height: '74px',
                    borderRadius: '20px',
                    objectFit: 'contain',
                    background: 'linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(244, 63, 94, 0.2))',
                    border: '2.5px solid #22c55e',
                    boxShadow: '0 0 16px rgba(34, 197, 94, 0.45)',
                  }}
                />
                <div
                  style={{
                    position: 'absolute',
                    bottom: '-4px',
                    right: '-4px',
                    background: currentCallMode === 'video' ? '#f43f5e' : '#38bdf8',
                    borderRadius: '50%',
                    width: '22px',
                    height: '22px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#ffffff',
                    border: '2px solid #191c24',
                  }}
                >
                  {currentCallMode === 'video' ? <Video size={11} /> : <PhoneCall size={11} />}
                </div>
              </div>

              <div style={{ fontSize: '17px', fontWeight: 800, color: '#f8fafc' }}>
                {currentAvatarProfile.name}
              </div>
              <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '2px' }}>
                {currentAvatarProfile.countryFlag} {currentAvatarProfile.countryName} • {currentCallMode === 'video' ? 'HD Video Call' : 'Encrypted Voice Call'}
              </div>

              {/* 3-Minute Icebreaker Timer */}
              <div
                style={{
                  fontSize: '17px',
                  fontWeight: 900,
                  color: '#22c55e',
                  marginTop: '8px',
                  fontVariantNumeric: 'tabular-nums',
                }}
              >
                {formatTimer(randomCallTimer)}
              </div>

              {/* Controls */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '16px' }}>
                <button
                  type="button"
                  onClick={() => setIsMuted(!isMuted)}
                  style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    background: isMuted ? 'rgba(239, 68, 68, 0.2)' : '#222631',
                    border: isMuted ? '1px solid #ef4444' : '1px solid rgba(255, 255, 255, 0.1)',
                    color: isMuted ? '#ef4444' : '#f8fafc',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  {isMuted ? <MicOff size={17} /> : <Mic size={17} />}
                </button>

                <button
                  type="button"
                  onClick={() => setIsSpeaker(!isSpeaker)}
                  style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    background: isSpeaker ? 'rgba(56, 189, 248, 0.2)' : '#222631',
                    border: isSpeaker ? '1px solid #38bdf8' : '1px solid rgba(255, 255, 255, 0.1)',
                    color: isSpeaker ? '#38bdf8' : '#f8fafc',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  {isSpeaker ? <Volume2 size={17} /> : <VolumeX size={17} />}
                </button>

                {/* Green Heart Like button */}
                <button
                  type="button"
                  onClick={() => {
                    setHasLikedCallPartner(true);
                    try {
                      confetti({
                        particleCount: 35,
                        spread: 50,
                        origin: { y: 0.5 },
                        colors: ['#22c55e', '#f43f5e', '#ffd700'],
                      });
                    } catch { }
                  }}
                  disabled={hasLikedCallPartner}
                  style={{
                    padding: '8px 14px',
                    borderRadius: '999px',
                    background: hasLikedCallPartner ? 'rgba(34, 197, 94, 0.2)' : 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)',
                    border: 'none',
                    color: '#ffffff',
                    fontSize: '11px',
                    fontWeight: 700,
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                    cursor: hasLikedCallPartner ? 'default' : 'pointer',
                  }}
                >
                  <Heart size={13} fill={hasLikedCallPartner ? '#22c55e' : '#ffffff'} />
                  <span>{hasLikedCallPartner ? 'Liked!' : 'Send Like'}</span>
                </button>

                <button
                  type="button"
                  onClick={handleEndCall}
                  style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    background: '#ef4444',
                    border: 'none',
                    color: '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  <PhoneOff size={17} />
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* =================================================================== */}
      {/* MODAL 1: PARTIALLY RESTRICTED VIEW MODAL (LIKE SIDE ONCLICK) */}
      {/* =================================================================== */}
      {partiallyRestrictedProfile && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 120,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '320px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(244, 63, 94, 0.4)',
              padding: '22px 18px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.6)',
              position: 'relative',
            }}
          >
            <button
              type="button"
              onClick={() => setPartiallyRestrictedProfile(null)}
              style={{
                position: 'absolute',
                top: '12px',
                right: '12px',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '28px',
                height: '28px',
                color: '#94a3b8',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <X size={15} />
            </button>

            {/* Avatar / Bitmoji with gradient frame */}
            <div style={{ width: '80px', height: '80px', borderRadius: '50%', padding: '2.5px', background: 'linear-gradient(135deg, #f43f5e 0%, #fb7185 100%)', marginBottom: '10px' }}>
              <img
                src={partiallyRestrictedProfile.avatar}
                alt={partiallyRestrictedProfile.name}
                style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
              />
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <span style={{ fontSize: '17px', fontWeight: 800, color: '#f8fafc' }}>
                {partiallyRestrictedProfile.name}, {partiallyRestrictedProfile.age}
              </span>
              {partiallyRestrictedProfile.is_verified && <CheckCircle2 size={16} color="#38bdf8" />}
            </div>

            <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '2px', textAlign: 'center' }}>
              Liked your profile • Expressed interest
            </div>

            {/* Top 3 Matched Interests */}
            <div style={{ width: '100%', marginTop: '14px', borderTop: '1px solid rgba(255, 255, 255, 0.08)', paddingTop: '10px' }}>
              <div style={{ fontSize: '11px', fontWeight: 700, color: '#f8fafc', marginBottom: '6px', textAlign: 'center' }}>
                Top Matched Interests
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px', justifyContent: 'center' }}>
                {partiallyRestrictedProfile.interests.slice(0, 3).map((item, idx) => (
                  <span
                    key={idx}
                    style={{
                      fontSize: '10.5px',
                      fontWeight: 600,
                      background: 'rgba(255, 255, 255, 0.08)',
                      padding: '3px 8px',
                      borderRadius: '999px',
                      color: '#cbd5e1',
                    }}
                  >
                    {item}
                  </span>
                ))}
              </div>
            </div>

            {/* Like / Dislike CTA Buttons */}
            <div style={{ display: 'flex', gap: '12px', marginTop: '18px', width: '100%' }}>
              <button
                type="button"
                onClick={handleDislikePartiallyRestricted}
                style={{
                  flex: 1,
                  padding: '9px 0',
                  borderRadius: '12px',
                  background: 'rgba(239, 68, 68, 0.12)',
                  border: '1px solid rgba(239, 68, 68, 0.35)',
                  color: '#ef4444',
                  fontSize: '12.5px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                }}
              >
                <X size={15} />
                <span>Pass</span>
              </button>

              <button
                type="button"
                onClick={handleLikePartiallyRestricted}
                style={{
                  flex: 1,
                  padding: '9px 0',
                  borderRadius: '12px',
                  background: 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)',
                  border: 'none',
                  color: '#ffffff',
                  fontSize: '12.5px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                  boxShadow: '0 4px 14px rgba(34, 197, 94, 0.35)',
                }}
              >
                <Heart size={15} fill="#ffffff" />
                <span>Like Back</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* MODAL 2: RESTRICTED MODAL (DISLIKE / PASSED SIDE ONCLICK) */}
      {/* =================================================================== */}
      {restrictedProfile && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 120,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '300px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(100, 116, 139, 0.4)',
              padding: '22px 18px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.6)',
              position: 'relative',
            }}
          >
            <button
              type="button"
              onClick={() => setRestrictedProfile(null)}
              style={{
                position: 'absolute',
                top: '12px',
                right: '12px',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '28px',
                height: '28px',
                color: '#94a3b8',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <X size={15} />
            </button>

            <div
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '50%',
                background: 'rgba(239, 68, 68, 0.15)',
                border: '1.5px solid #ef4444',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '12px',
              }}
            >
              <Lock size={24} color="#ef4444" />
            </div>

            <h4 style={{ fontSize: '15.5px', fontWeight: 800, color: '#f8fafc', margin: '0 0 6px' }}>
              Profile Restricted
            </h4>

            <p style={{ fontSize: '12px', color: '#94a3b8', margin: '0 0 16px', lineHeight: 1.45 }}>
              You previously passed on <strong>{restrictedProfile.name}</strong>'s profile. In accordance with mutual privacy rules, full details are restricted.
            </p>

            <button
              type="button"
              onClick={() => setRestrictedProfile(null)}
              style={{
                width: '100%',
                padding: '9px 0',
                borderRadius: '12px',
                background: '#222631',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                color: '#f8fafc',
                fontSize: '12px',
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Understood
            </button>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* MODAL 3: LIMITED VISIBILITY MODAL (POTENTIAL MATCHES ONCLICK) */}
      {/* =================================================================== */}
      {limitedProfile && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 120,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '300px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(56, 189, 248, 0.35)',
              padding: '22px 18px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.6)',
              position: 'relative',
            }}
          >
            <button
              type="button"
              onClick={() => setLimitedProfile(null)}
              style={{
                position: 'absolute',
                top: '12px',
                right: '12px',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '28px',
                height: '28px',
                color: '#94a3b8',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <X size={15} />
            </button>

            <span
              style={{
                fontSize: '10px',
                fontWeight: 700,
                color: '#38bdf8',
                background: 'rgba(56, 189, 248, 0.15)',
                padding: '2px 8px',
                borderRadius: '999px',
                marginBottom: '10px',
              }}
            >
              Limited Visibility Card
            </span>

            {/* ONLY: Nickname, Age & Gender, General Distance Away, Top 3 Interests */}
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#f8fafc' }}>
              {limitedProfile.nickname}
            </div>

            <div style={{ fontSize: '12px', color: '#cbd5e1', marginTop: '2px' }}>
              {limitedProfile.age} yrs • {limitedProfile.gender}
            </div>

            <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
              ~{limitedProfile.distance_km} km away
            </div>

            <div style={{ width: '100%', marginTop: '14px', borderTop: '1px solid rgba(255, 255, 255, 0.08)', paddingTop: '10px' }}>
              <div style={{ fontSize: '11px', fontWeight: 700, color: '#f8fafc', marginBottom: '6px', textAlign: 'center' }}>
                Top 3 Interests
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px', justifyContent: 'center' }}>
                {limitedProfile.interests.map((tag, idx) => (
                  <span
                    key={idx}
                    style={{
                      fontSize: '10.5px',
                      background: 'rgba(255, 255, 255, 0.08)',
                      padding: '3px 8px',
                      borderRadius: '999px',
                      color: '#cbd5e1',
                    }}
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>

            <button
              type="button"
              onClick={() => setLimitedProfile(null)}
              style={{
                width: '100%',
                padding: '9px 0',
                borderRadius: '12px',
                background: '#222631',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                color: '#f8fafc',
                fontSize: '12px',
                fontWeight: 700,
                cursor: 'pointer',
                marginTop: '16px',
              }}
            >
              Close
            </button>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* MODAL 4: FULL VISIBILITY MODAL (MATCHED RECENTLY ONCLICK) */}
      {/* =================================================================== */}
      {fullProfile && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 120,
            background: 'rgba(0, 0, 0, 0.85)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '330px',
              maxHeight: '90vh',
              overflowY: 'auto',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(34, 197, 94, 0.4)',
              padding: '20px 18px',
              display: 'flex',
              flexDirection: 'column',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.7)',
              position: 'relative',
            }}
          >
            <button
              type="button"
              onClick={() => setFullProfile(null)}
              style={{
                position: 'absolute',
                top: '12px',
                right: '12px',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '28px',
                height: '28px',
                color: '#94a3b8',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                zIndex: 10,
              }}
            >
              <X size={15} />
            </button>

            {/* Profile Image with Verified Badge */}
            <div style={{ width: '100%', height: '170px', borderRadius: '16px', overflow: 'hidden', position: 'relative', marginBottom: '12px' }}>
              <img
                src={fullProfile.avatar}
                alt={fullProfile.name}
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />
              <div
                style={{
                  position: 'absolute',
                  bottom: '8px',
                  left: '8px',
                  background: '#22c55e',
                  color: '#000',
                  fontSize: '10px',
                  fontWeight: 900,
                  padding: '2px 6px',
                  borderRadius: '6px',
                }}
              >
                {fullProfile.matchPercentage}% Compatibility
              </div>
            </div>

            {/* Nickname, Age, Gender, Verified Badge */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ fontSize: '18px', fontWeight: 900, color: '#f8fafc' }}>
                {fullProfile.name}, {fullProfile.age}
              </span>
              <CheckCircle2 size={16} color="#38bdf8" />
              <span style={{ fontSize: '11px', color: '#94a3b8' }}>({fullProfile.gender})</span>
            </div>

            {/* General Distance Away & Last Active status */}
            <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '2px' }}>
              ~{fullProfile.distance_km} km away ({fullProfile.city}) • {fullProfile.lastActive}
            </div>

            {/* Preferences */}
            <div style={{ marginTop: '8px' }}>
              <span
                style={{
                  fontSize: '10px',
                  fontWeight: 700,
                  background: 'rgba(244, 63, 94, 0.2)',
                  border: '1px solid rgba(244, 63, 94, 0.4)',
                  color: '#ff8da1',
                  padding: '2px 8px',
                  borderRadius: '999px',
                }}
              >
                Preference: {fullProfile.preferences}
              </span>
            </div>

            {/* Bio */}
            <p style={{ fontSize: '11.5px', color: '#cbd5e1', margin: '10px 0 8px', lineHeight: 1.45 }}>
              "{fullProfile.bio}"
            </p>

            {/* Full Interests list */}
            <div style={{ marginBottom: '14px' }}>
              <div style={{ fontSize: '11px', fontWeight: 700, color: '#f8fafc', marginBottom: '5px' }}>
                Full Interests
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
                {fullProfile.sharedInterests.map((interest, idx) => (
                  <span
                    key={idx}
                    style={{
                      fontSize: '10px',
                      background: 'rgba(255, 255, 255, 0.08)',
                      padding: '2px 7px',
                      borderRadius: '999px',
                      color: '#e2e8f0',
                    }}
                  >
                    {interest}
                  </span>
                ))}
              </div>
            </div>

            {/* Direct Chat / Voice Call options */}
            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                type="button"
                onClick={() => {
                  setFullProfile(null);
                  onOpenChat('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
                }}
                style={{
                  flex: 1,
                  padding: '9px 0',
                  borderRadius: '12px',
                  background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                  border: 'none',
                  color: '#ffffff',
                  fontSize: '12px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                }}
              >
                <MessageCircle size={14} />
                <span>Chat</span>
              </button>

              <button
                type="button"
                onClick={() => {
                  const target = fullProfile;
                  setFullProfile(null);
                  onStartCall?.(target.userId, target.name, target.avatar);
                }}
                style={{
                  flex: 1,
                  padding: '9px 0',
                  borderRadius: '12px',
                  background: 'linear-gradient(135deg, #38bdf8 0%, #0284c7 100%)',
                  border: 'none',
                  color: '#ffffff',
                  fontSize: '12px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                }}
              >
                <Phone size={14} />
                <span>Voice Call</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* OVERLAY: "MAKE FIRST MOVE" TEXT BOX OVERLAY (Chat OnClick) */}
      {/* =================================================================== */}
      {firstMoveChatMatch && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 125,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '320px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(56, 189, 248, 0.4)',
              padding: '18px',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.7)',
              position: 'relative',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <img
                  src={firstMoveChatMatch.avatar}
                  alt={firstMoveChatMatch.name}
                  style={{ width: '32px', height: '32px', borderRadius: '50%', objectFit: 'cover' }}
                />
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 800, color: '#f8fafc' }}>
                    Message {firstMoveChatMatch.name}
                  </div>
                  <div style={{ fontSize: '10px', color: '#22c55e' }}>Make First Move</div>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setFirstMoveChatMatch(null)}
                style={{ background: 'transparent', border: 'none', color: '#94a3b8', cursor: 'pointer' }}
              >
                <X size={16} />
              </button>
            </div>

            {/* Text Input Box */}
            <textarea
              rows={3}
              value={firstMoveMessage}
              onChange={(e) => setFirstMoveMessage(e.target.value)}
              placeholder={`Say something thoughtful to ${firstMoveChatMatch.name}...`}
              style={{
                width: '100%',
                background: '#14161f',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                borderRadius: '12px',
                padding: '10px',
                color: '#f8fafc',
                fontSize: '12px',
                resize: 'none',
                outline: 'none',
                boxSizing: 'border-box',
                marginBottom: '10px',
              }}
            />

            {voiceRecordedToast && (
              <div style={{ fontSize: '10.5px', color: '#22c55e', marginBottom: '8px', textAlign: 'center' }}>
                ✓ Voice note recorded (0:08s attached)
              </div>
            )}

            {/* Action Buttons: Voice Note Recording & Send */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <button
                type="button"
                onClick={handleToggleVoiceRecord}
                title={isRecordingVoice ? 'Stop recording voice note' : 'Record voice note'}
                style={{
                  height: '38px',
                  padding: '0 12px',
                  borderRadius: '10px',
                  background: isRecordingVoice ? 'rgba(239, 68, 68, 0.25)' : 'rgba(255, 255, 255, 0.08)',
                  border: isRecordingVoice ? '1px solid #ef4444' : '1px solid rgba(255, 255, 255, 0.1)',
                  color: isRecordingVoice ? '#ef4444' : '#f8fafc',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  cursor: 'pointer',
                  fontSize: '11px',
                  fontWeight: 600,
                }}
              >
                {isRecordingVoice ? <Square size={13} fill="#ef4444" /> : <Mic size={13} />}
                <span>{isRecordingVoice ? 'Stop' : 'Voice'}</span>
              </button>

              <button
                type="button"
                onClick={handleSendFirstMoveText}
                style={{
                  flex: 1,
                  height: '38px',
                  borderRadius: '10px',
                  background: 'linear-gradient(135deg, #38bdf8 0%, #0284c7 100%)',
                  border: 'none',
                  color: '#ffffff',
                  fontSize: '12px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                  cursor: 'pointer',
                }}
              >
                <Send size={13} />
                <span>Send Message</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* DRAWER: "MAKE FIRST MOVE" ICEBREAKER PROMPTS (Prompt OnClick) */}
      {/* =================================================================== */}
      {firstMoveIcebreakerMatch && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 125,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '320px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1.5px solid rgba(244, 63, 94, 0.4)',
              padding: '18px',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.7)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Sparkles size={16} color="#f43f5e" />
                <span style={{ fontSize: '13px', fontWeight: 800, color: '#f8fafc' }}>
                  Pick Prompt for {firstMoveIcebreakerMatch.name}
                </span>
              </div>
              <button
                type="button"
                onClick={() => setFirstMoveIcebreakerMatch(null)}
                style={{ background: 'transparent', border: 'none', color: '#94a3b8', cursor: 'pointer' }}
              >
                <X size={16} />
              </button>
            </div>

            {/* Horizontal sliding list of curated prompts */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {ICEBREAKER_PROMPTS.map((prompt, idx) => (
                <div
                  key={idx}
                  style={{
                    background: '#222631',
                    borderRadius: '10px',
                    padding: '8px 10px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    gap: '8px',
                    border: '1px solid rgba(255, 255, 255, 0.05)',
                  }}
                >
                  <span style={{ fontSize: '11px', color: '#f8fafc', lineHeight: 1.35, flex: 1 }}>
                    {prompt}
                  </span>
                  <button
                    type="button"
                    onClick={() => handleSendIcebreaker(prompt)}
                    style={{
                      background: 'rgba(244, 63, 94, 0.2)',
                      border: '1px solid rgba(244, 63, 94, 0.4)',
                      color: '#f43f5e',
                      padding: '4px 8px',
                      borderRadius: '6px',
                      fontSize: '10px',
                      fontWeight: 700,
                      cursor: 'pointer',
                      flexShrink: 0,
                    }}
                  >
                    Send 💬
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* FILTER BOTTOM SHEET ("MORE" FILTERS MODAL) */}
      {/* =================================================================== */}
      {showMoreFiltersModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 130,
            background: 'rgba(0, 0, 0, 0.8)',
            backdropFilter: 'blur(10px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            style={{
              width: '100%',
              maxWidth: '330px',
              background: '#191c24',
              borderRadius: '22px',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              padding: '20px',
              boxShadow: '0 12px 36px rgba(0, 0, 0, 0.7)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
              <div style={{ fontSize: '15px', fontWeight: 800, color: '#f8fafc' }}>
                Discovery & Connect Filters
              </div>
              <button
                type="button"
                onClick={() => setShowMoreFiltersModal(false)}
                style={{ background: 'transparent', border: 'none', color: '#94a3b8', cursor: 'pointer' }}
              >
                <X size={18} />
              </button>
            </div>

            {/* Filter 1: Age Range Single-Bar Slider */}
            <div style={{ marginBottom: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', fontWeight: 600, color: '#f8fafc', marginBottom: '6px' }}>
                <span>Max Age</span>
                <span style={{ color: '#38bdf8' }}>Up to {ageRange} yrs</span>
              </div>
              <input
                type="range"
                min="18"
                max="45"
                value={ageRange}
                onChange={(e) => setAgeRange(Number(e.target.value))}
                style={{ width: '100%', accentColor: '#38bdf8' }}
              />
            </div>

            {/* Filter 2: Maximum Distance Single-Bar Slider */}
            <div style={{ marginBottom: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', fontWeight: 600, color: '#f8fafc', marginBottom: '6px' }}>
                <span>Maximum Distance</span>
                <span style={{ color: '#38bdf8' }}>Within {maxDistanceKm} km</span>
              </div>
              <input
                type="range"
                min="5"
                max="100"
                value={maxDistanceKm}
                onChange={(e) => setMaxDistanceKm(Number(e.target.value))}
                style={{ width: '100%', accentColor: '#38bdf8' }}
              />
            </div>

            {/* Preference Filters */}
            <div style={{ marginBottom: '16px' }}>
              <div style={{ fontSize: '12px', fontWeight: 600, color: '#f8fafc', marginBottom: '6px' }}>
                Relationship Goal
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px' }}>
                {['All', 'Long-term', 'Casual', 'Friendship'].map((p) => {
                  const isSel = selectedRelationshipPref === p;
                  return (
                    <button
                      key={p}
                      type="button"
                      onClick={() => setSelectedRelationshipPref(p)}
                      className={`filter-pill ${isSel ? 'active' : ''}`}
                    >
                      {p}
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Language & Interests */}
            <div style={{ marginBottom: '20px' }}>
              <div style={{ fontSize: '12px', fontWeight: 600, color: '#f8fafc', marginBottom: '6px' }}>
                Top Interests & Tags
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px' }}>
                {['Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨', 'Late Night Vibes 🌙', 'Tech Startups 🚀'].map((tag) => {
                  const isSel = selectedTopics.includes(tag);
                  return (
                    <button
                      key={tag}
                      type="button"
                      onClick={() => {
                        setSelectedTopics((prev) =>
                          isSel ? prev.filter((t) => t !== tag) : [...prev, tag]
                        );
                      }}
                      className={`filter-pill ${isSel ? 'active' : ''}`}
                    >
                      {tag}
                    </button>
                  );
                })}
              </div>
            </div>

            <button
              type="button"
              onClick={() => setShowMoreFiltersModal(false)}
              style={{
                width: '100%',
                padding: '10px 0',
                borderRadius: '12px',
                border: 'none',
                background: 'linear-gradient(135deg, #38bdf8 0%, #0284c7 100%)',
                color: '#ffffff',
                fontSize: '13px',
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Apply All Filters
            </button>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* DIRECT CALL POPUP MODAL (TAP-TO-CONNECT DUAL-CALL) */}
      {/* =================================================================== */}
      {selectedRandomCallProfile && (
        <div
          onClick={() => setSelectedRandomCallProfile(null)}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 140,
            background: 'rgba(6, 8, 14, 0.78)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '320px',
              background: '#151821',
              border: '1.5px solid rgba(255, 255, 255, 0.12)',
              borderRadius: '24px',
              padding: '24px 20px',
              boxShadow: '0 16px 40px rgba(0, 0, 0, 0.65)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              position: 'relative',
              boxSizing: 'border-box',
            }}
          >
            {/* Close button */}
            <button
              type="button"
              onClick={() => setSelectedRandomCallProfile(null)}
              aria-label="Close modal"
              style={{
                position: 'absolute',
                top: '12px',
                right: '12px',
                width: '30px',
                height: '30px',
                borderRadius: '50%',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                color: '#94a3b8',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              ✕
            </button>

            {/* Circular Avatar with Glowing Online Ring & playful sticker */}
            <div
              style={{
                position: 'relative',
                width: '76px',
                height: '76px',
                borderRadius: '50%',
                background: `radial-gradient(circle at 35% 35%, rgba(255, 255, 255, 0.2), rgba(20, 24, 34, 0.95))`,
                border: `2.5px solid ${selectedRandomCallProfile.ringColor}`,
                boxShadow: `0 8px 24px ${selectedRandomCallProfile.ringColor.replace('0.75', '0.4')}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '38px',
                marginBottom: '14px',
              }}
            >
              <span>{selectedRandomCallProfile.sticker}</span>
              <div
                style={{
                  position: 'absolute',
                  bottom: '2px',
                  right: '2px',
                  width: '12px',
                  height: '12px',
                  borderRadius: '50%',
                  background: '#10b981',
                  border: '2px solid #151821',
                  boxShadow: '0 0 8px #10b981',
                }}
              />
            </div>

            {/* User details */}
            <div style={{ textAlign: 'center' }}>
              <div style={{ fontSize: '18px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.3px' }}>
                {selectedRandomCallProfile.name}, {selectedRandomCallProfile.age || 24}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', marginTop: '4px' }}>
                <span style={{ fontSize: '11.5px', color: '#38bdf8', fontWeight: 700, background: 'rgba(56, 189, 248, 0.12)', padding: '2px 8px', borderRadius: '999px', border: '1px solid rgba(56, 189, 248, 0.25)' }}>
                  {selectedRandomCallProfile.language}
                </span>
                <span style={{ fontSize: '11.5px', color: '#10b981', fontWeight: 600 }}>
                  ● Online now
                </span>
              </div>
            </div>

            {/* Direct Call Options: Audio and Video */}
            <div style={{ display: 'flex', gap: '10px', width: '100%', marginTop: '20px' }}>
              <button
                type="button"
                onClick={() => {
                  const target = selectedRandomCallProfile;
                  setSelectedRandomCallProfile(null);
                  if (onStartCall) {
                    onStartCall(target.id, target.name, target.avatar, 'audio');
                  } else {
                    handleStartRandomCall('audio', target as any);
                  }
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  padding: '12px 10px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, #0284c7 0%, #0369a1 100%)',
                  border: '1px solid rgba(56, 189, 248, 0.4)',
                  color: '#ffffff',
                  fontSize: '13px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  boxShadow: '0 4px 14px rgba(2, 132, 199, 0.35)',
                }}
              >
                <Phone size={15} />
                <span>Audio Call</span>
              </button>

              <button
                type="button"
                onClick={() => {
                  const target = selectedRandomCallProfile;
                  setSelectedRandomCallProfile(null);
                  if (onStartCall) {
                    onStartCall(target.id, target.name, target.avatar, 'video');
                  } else {
                    handleStartRandomCall('video', target as any);
                  }
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  padding: '12px 10px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, #e11d48 0%, #be123c 100%)',
                  border: '1px solid rgba(244, 63, 94, 0.4)',
                  color: '#ffffff',
                  fontSize: '13px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  boxShadow: '0 4px 14px rgba(225, 29, 72, 0.35)',
                }}
              >
                <Video size={15} />
                <span>Video Call</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
