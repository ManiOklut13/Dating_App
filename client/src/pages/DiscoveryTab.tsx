import React, { useState, useEffect } from 'react';
import {
  X,
  Heart,
  Sparkles,
  RotateCcw,
  Moon,
  Volume2,
  MapPin,
  ShieldCheck,
  Zap,
  Radar,
  Flame,
  Check,
  Gift,
  Compass,
  Coins,
  Bell,
} from 'lucide-react';
import { CandidateCard } from '../types';
import { DailyIcebreakerCard } from '../components/DailyIcebreakerCard';

export interface DiscoveryTabProps {
  onMutualMatch: (profile: CandidateCard) => void;
  onCoinDeducted: (newBalance: number) => void;
  coinBalance?: number;
  streakDays?: number;
  onOpenStore?: () => void;
  onOpenWheel?: () => void;
  onOpenChat?: (convId: string) => void;
}

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
];

const suggestedAvatars = [
  {
    id: '22222222-2222-2222-2222-222222222222',
    name: 'Ananya',
    avatar: '/ananya.jpg',
    tag: 'Bandra • 95% Vibe',
    online: true,
    deckIndex: 0,
  },
  {
    id: '33333333-3333-3333-3333-333333333333',
    name: 'Rohit',
    avatar: '/rohit.jpg',
    tag: 'Juhu • 88% Vibe',
    online: true,
    deckIndex: 1,
  },
  {
    id: '44444444-4444-4444-4444-444444444444',
    name: 'Riya',
    avatar: '/riya.jpg',
    tag: 'Colaba • 92% Vibe',
    online: false,
    deckIndex: 2,
  },
  {
    id: 'radar-nearby-explore',
    name: 'Explore Radar',
    avatar: '/aditya.jpg',
    tag: 'Geospatial Map',
    online: true,
    isRadar: true,
  },
];

export const DiscoveryTab: React.FC<DiscoveryTabProps> = ({
  onMutualMatch,
  onCoinDeducted,
  coinBalance = 250,
  streakDays = 4,
  onOpenStore,
  onOpenWheel,
}) => {
  const [deck, setDeck] = useState<CandidateCard[]>(defaultCandidates);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [activePhotoIndex, setActivePhotoIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState<'cards' | 'radar'>('cards');
  const [audioPlaying, setAudioPlaying] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [swipeStamp, setSwipeStamp] = useState<'like' | 'dislike' | 'spark' | null>(null);
  const [hasClaimedToday, setHasClaimedToday] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [hasUnreadNotifications, setHasUnreadNotifications] = useState(true);

  const notifications = [
    { id: 1, title: '🔥 Daily Streak Active', desc: `Day ${streakDays} streak unlocked with a 1.4x multiplier!`, time: 'Just now' },
    { id: 2, title: '❤️ Secret Admirer', desc: 'Someone liked your profile in Connect. Unlock stack to reveal.', time: '20m ago' },
    { id: 3, title: '🎙️ New Audio Prompt', desc: 'Ananya uploaded a new voice prompt in Bandra.', time: '1h ago' },
  ];

  const fetchDeck = async () => {
    setLoading(true);
    try {
      const res = await fetch('/v1/discovery/deck?user_id=11111111-1111-1111-1111-111111111111&radius_km=50');
      const data = await res.json();
      if (data.success && data.deck && data.deck.length > 0) {
        setDeck(data.deck);
      } else {
        setDeck(defaultCandidates);
      }
    } catch (err) {
      setDeck(defaultCandidates);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDeck();
  }, []);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3200);
  };

  const currentCandidate = deck[currentIndex];

  const handleSwipe = async (action: 'like' | 'dislike' | 'spark' | 'snooze') => {
    if (!currentCandidate) return;

    if (action === 'like' || action === 'dislike' || action === 'spark') {
      setSwipeStamp(action);
      setTimeout(() => setSwipeStamp(null), 450);
    }

    try {
      const res = await fetch('/v1/swipes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: '11111111-1111-1111-1111-111111111111',
          target_id: currentCandidate.user_id,
          action,
        }),
      });
      const data = await res.json();

      if (data && data.coins_deducted > 0) {
        showToast(`🪙 ${data.coins_deducted} coins deducted for ${action.toUpperCase()}`);
        if (data.new_balance !== undefined) {
          onCoinDeducted(data.new_balance);
        }
      }

      if (data && data.is_match) {
        onMutualMatch(currentCandidate);
      }

      setCurrentIndex((prev) => prev + 1);
      setActivePhotoIndex(0);
    } catch (err) {
      if (action === 'spark' || action === 'like') {
        showToast(`Liked ${currentCandidate.nickname}!`);
      }
      setCurrentIndex((prev) => prev + 1);
      setActivePhotoIndex(0);
    }
  };

  const handleRevert = async () => {
    try {
      const res = await fetch('/v1/swipes/revert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: '11111111-1111-1111-1111-111111111111' }),
      });
      const data = await res.json();
      if (data && data.success) {
        if (currentIndex > 0) {
          setCurrentIndex((prev) => prev - 1);
          setActivePhotoIndex(0);
        }
        showToast(data.coins_deducted > 0 ? 'Restored previous card (-5 coins)' : 'Candidate card restored!');
      } else {
        if (currentIndex > 0) {
          setCurrentIndex((prev) => prev - 1);
          setActivePhotoIndex(0);
          showToast('Candidate card restored!');
        } else {
          showToast(data?.error || 'No previous card to revert.');
        }
      }
    } catch (err) {
      if (currentIndex > 0) {
        setCurrentIndex((prev) => prev - 1);
        setActivePhotoIndex(0);
        showToast('Candidate card restored!');
      } else {
        showToast('No previous card to revert.');
      }
    }
  };

  const playVoiceNote = () => {
    setAudioPlaying(true);
    try {
      const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(440, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 1.2);
      gain.gain.setValueAtTime(0.3, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 1.2);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 1.2);

      setTimeout(() => setAudioPlaying(false), 1400);
      showToast(`🎙️ Playing ${currentCandidate?.nickname}'s voice note prompt`);
    } catch (e) {
      setTimeout(() => setAudioPlaying(false), 1000);
    }
  };

  const handleClaimReward = () => {
    if (hasClaimedToday) return;
    if (onOpenWheel) {
      onOpenWheel();
    }
    setHasClaimedToday(true);
  };

  // 7-day streak rewards
  const streakRewards = [
    { day: 1, label: '+10 🪙' },
    { day: 2, label: '+15 🪙' },
    { day: 3, label: '+20 🪙' },
    { day: 4, label: '+25 🪙' },
    { day: 5, label: '+30 🪙' },
    { day: 6, label: '+40 🪙' },
    { day: 7, label: '🎁 Mystery' },
  ];

  const currentPhotos = currentCandidate?.photo_urls || ['/ananya.jpg'];

  return (
    <div
      className="home-container"
      style={{
        maxWidth: '500px',
        margin: '0 auto',
        padding: '12px 16px 100px',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        gap: '18px',
      }}
    >
      {/* Toast Alert */}
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
            zIndex: 70,
            boxShadow: 'var(--shadow-glow)',
            whiteSpace: 'nowrap',
            backdropFilter: 'blur(16px)',
          }}
        >
          {toastMessage}
        </div>
      )}

      {/* Mobile Brand Header with Coin Balance & Notifications */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '2px 0 4px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div style={{ width: '34px', height: '34px', borderRadius: '10px', background: 'var(--gradient-flame)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-glow)' }}>
            <Flame size={20} color="#ffffff" />
          </div>
          <div>
            <div style={{ fontFamily: 'var(--font-heading)', fontSize: '20px', fontWeight: '800', background: 'var(--gradient-flame)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', letterSpacing: '-0.5px', lineHeight: 1.1 }}>
              YoUnMe
            </div>
            <div style={{ fontSize: '9px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.8px', fontWeight: 600 }}>
              Live Dating
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', position: 'relative' }}>
          {/* Coin Balance Pill */}
          <button
            onClick={onOpenStore}
            title="YoUnMe Coins Wallet Store"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '5px',
              padding: '6px 12px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(255, 215, 0, 0.1)',
              border: '1px solid rgba(255, 215, 0, 0.35)',
              color: '#ffd700',
              fontWeight: '700',
              fontSize: '12px',
              cursor: 'pointer',
              boxShadow: 'var(--shadow-gold)',
            }}
          >
            <Coins size={14} />
            <span>{coinBalance}</span>
            <span style={{ background: '#ffd700', color: '#000', borderRadius: '50%', width: '14px', height: '14px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', fontWeight: 'bold' }}>+</span>
          </button>

          {/* Notifications Shortcut */}
          <button
            onClick={() => {
              setShowNotifications(!showNotifications);
              setHasUnreadNotifications(false);
            }}
            title="Notifications & Activity"
            className="glass-pill"
            style={{
              width: '34px',
              height: '34px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: '#ffffff',
              position: 'relative',
              border: '1px solid var(--border-glass)',
            }}
          >
            <Bell size={15} />
            {hasUnreadNotifications && (
              <span
                style={{
                  position: 'absolute',
                  top: '6px',
                  right: '6px',
                  width: '7px',
                  height: '7px',
                  borderRadius: '50%',
                  background: '#ff2d55',
                  boxShadow: '0 0 6px #ff2d55',
                }}
              />
            )}
          </button>

          {/* Notifications Dropdown Popover */}
          {showNotifications && (
            <div
              className="glass-panel"
              style={{
                position: 'absolute',
                top: '42px',
                right: '0',
                width: '290px',
                borderRadius: 'var(--radius-md)',
                padding: '14px',
                zIndex: 60,
                boxShadow: 'var(--shadow-lg)',
                border: '1px solid rgba(255, 255, 255, 0.15)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
                <span style={{ fontWeight: 700, fontSize: '13px' }}>Notifications & Alerts</span>
                <button
                  onClick={() => setShowNotifications(false)}
                  style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
                >
                  <X size={15} />
                </button>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {notifications.map((n) => (
                  <div
                    key={n.id}
                    style={{
                      background: 'rgba(255, 255, 255, 0.04)',
                      padding: '8px 10px',
                      borderRadius: 'var(--radius-sm)',
                      fontSize: '11px',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: 600, color: '#ffffff', marginBottom: '2px' }}>
                      <span>{n.title}</span>
                      <span style={{ fontSize: '9px', color: 'var(--text-muted)' }}>{n.time}</span>
                    </div>
                    <p style={{ color: 'var(--text-secondary)', margin: 0 }}>{n.desc}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* 1. DAILY STREAK TRACKER CARD */}
      <div
        className="glass-panel"
        style={{
          borderRadius: 'var(--radius-lg)',
          padding: '16px',
          border: '1px solid rgba(255, 153, 0, 0.25)',
          background: 'radial-gradient(circle at 90% 10%, rgba(255, 153, 0, 0.08) 0%, rgba(20, 24, 38, 0.85) 100%)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px', flexWrap: 'wrap', gap: '8px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div
              style={{
                width: '32px',
                height: '32px',
                borderRadius: '8px',
                background: 'linear-gradient(135deg, #ff9900, #ff5e3a)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 0 12px rgba(255, 153, 0, 0.4)',
              }}
            >
              <Flame size={18} color="#ffffff" />
            </div>
            <div>
              <h3 style={{ fontSize: '15px', fontWeight: 800 }}>Daily Login Streak</h3>
              <div style={{ fontSize: '11px', color: '#ffa502', fontWeight: 600 }}>
                Day {streakDays} 🔥 • {(1 + streakDays * 0.1).toFixed(1)}x Multiplier
              </div>
            </div>
          </div>

          <button
            onClick={handleClaimReward}
            disabled={hasClaimedToday}
            className={hasClaimedToday ? 'btn-ghost' : 'btn-gold'}
            style={{
              padding: '8px 14px',
              fontSize: '12px',
              opacity: hasClaimedToday ? 0.6 : 1,
              cursor: hasClaimedToday ? 'default' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            {hasClaimedToday ? (
              <>
                <Check size={14} color="#00e676" />
                <span>Claimed ✓</span>
              </>
            ) : (
              <>
                <Sparkles size={14} />
                <span>Spin Wheel</span>
              </>
            )}
          </button>
        </div>

        {/* 7-Day Visual Progress Row */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            gap: '4px',
            background: 'rgba(0, 0, 0, 0.25)',
            padding: '10px 6px',
            borderRadius: 'var(--radius-md)',
            border: '1px solid rgba(255, 255, 255, 0.05)',
          }}
        >
          {streakRewards.map((item) => {
            const isCompleted = item.day < streakDays;
            const isCurrent = item.day === streakDays;

            return (
              <div
                key={item.day}
                className="streak-step-node"
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  padding: '6px 2px',
                  borderRadius: 'var(--radius-sm)',
                  background: isCurrent
                    ? 'linear-gradient(180deg, rgba(255, 153, 0, 0.25) 0%, rgba(255, 45, 85, 0.2) 100%)'
                    : isCompleted
                    ? 'rgba(0, 230, 118, 0.1)'
                    : 'rgba(255, 255, 255, 0.03)',
                  border: isCurrent
                    ? '1.5px solid #ff9900'
                    : isCompleted
                    ? '1px solid rgba(0, 230, 118, 0.3)'
                    : '1px solid rgba(255, 255, 255, 0.06)',
                  boxShadow: isCurrent ? '0 0 10px rgba(255, 153, 0, 0.4)' : 'none',
                }}
              >
                <div style={{ fontSize: '9px', color: 'var(--text-muted)', marginBottom: '2px', fontWeight: 600 }}>
                  D{item.day}
                </div>
                <div style={{ marginBottom: '3px' }}>
                  {isCompleted ? (
                    <Check size={12} color="#00e676" />
                  ) : isCurrent ? (
                    <Flame size={13} color="#ff9900" />
                  ) : (
                    <Gift size={12} color="var(--text-muted)" />
                  )}
                </div>
                <div
                  style={{
                    fontSize: '8px',
                    fontWeight: 700,
                    color: isCurrent ? '#ffd700' : isCompleted ? '#00e676' : 'var(--text-secondary)',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {item.label}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 2. ACTIVE EXPLORERS NEARBY (AVATAR DISCOVERY WITHOUT CALLS) */}
      <div
        className="glass-panel"
        style={{
          borderRadius: 'var(--radius-lg)',
          padding: '14px',
          border: '1px solid rgba(0, 229, 255, 0.18)',
          background: 'radial-gradient(circle at 10% 10%, rgba(0, 229, 255, 0.05) 0%, rgba(20, 24, 38, 0.8) 100%)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
          <div>
            <h3 style={{ fontSize: '14px', fontWeight: 800, display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Compass size={15} color="#00e5ff" />
              Active Explorers Nearby
            </h3>
            <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
              Verified profiles in Mumbai • Tap to inspect card
            </p>
          </div>
        </div>

        {/* Horizontal Touch Scroll Avatars */}
        <div
          style={{
            display: 'flex',
            gap: '10px',
            overflowX: 'auto',
            paddingBottom: '4px',
            WebkitOverflowScrolling: 'touch',
            scrollbarWidth: 'none',
          }}
        >
          {suggestedAvatars.map((person) => (
            <div
              key={person.id}
              onClick={() => {
                if (person.isRadar) {
                  setViewMode('radar');
                } else if (person.deckIndex !== undefined) {
                  setCurrentIndex(person.deckIndex);
                  setViewMode('cards');
                  setActivePhotoIndex(0);
                }
              }}
              className="call-avatar-card glass-panel"
              style={{
                flexShrink: 0,
                width: '100px',
                borderRadius: 'var(--radius-md)',
                padding: '10px 6px',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '4px',
                cursor: 'pointer',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                background: 'rgba(255, 255, 255, 0.02)',
              }}
            >
              {/* Avatar thumbnail with online dot */}
              <div style={{ position: 'relative', width: '44px', height: '44px' }}>
                <img
                  src={person.avatar}
                  alt={person.name}
                  style={{
                    width: '100%',
                    height: '100%',
                    borderRadius: '50%',
                    objectFit: 'cover',
                    border: '2px solid rgba(0, 229, 255, 0.4)',
                  }}
                />
                {person.online && (
                  <span
                    className="status-dot-online"
                    style={{ position: 'absolute', bottom: '0px', right: '0px' }}
                  />
                )}
              </div>

              <div style={{ fontSize: '12px', fontWeight: 700, color: '#ffffff', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', width: '100%' }}>
                {person.name}
              </div>
              <div style={{ fontSize: '10px', color: 'var(--cyan-vibe)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', width: '100%' }}>
                {person.tag}
              </div>
              <span
                style={{
                  marginTop: '2px',
                  fontSize: '9px',
                  fontWeight: 600,
                  color: 'var(--text-muted)',
                  background: 'rgba(255, 255, 255, 0.05)',
                  padding: '2px 6px',
                  borderRadius: 'var(--radius-full)',
                }}
              >
                {person.isRadar ? 'Open Radar' : 'View Profile'}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* 3. DISCOVER PEOPLE (SWIPE CARDS DECK / POSTGIS RADAR VIEW) */}
      <section style={{ display: 'flex', flexDirection: 'column' }}>
        {/* Header Controls */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
          <div>
            <h2 style={{ fontSize: '18px', fontWeight: 800, letterSpacing: '-0.3px' }}>Discovery Deck</h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: 'var(--text-secondary)' }}>
              <MapPin size={12} color="#00e5ff" />
              <span>PostGIS Filter: <strong>Mumbai &lt; 50 km</strong></span>
            </div>
          </div>

          {/* Cards / Radar Switch */}
          <div
            style={{
              display: 'flex',
              background: 'rgba(255, 255, 255, 0.05)',
              borderRadius: 'var(--radius-full)',
              padding: '2px',
              border: '1px solid var(--border-glass)',
            }}
          >
            <button
              onClick={() => setViewMode('cards')}
              style={{
                padding: '6px 12px',
                borderRadius: 'var(--radius-full)',
                border: 'none',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
                background: viewMode === 'cards' ? 'var(--gradient-flame)' : 'transparent',
                color: '#ffffff',
                transition: 'all var(--transition-fast)',
              }}
            >
              Cards
            </button>
            <button
              onClick={() => setViewMode('radar')}
              style={{
                padding: '6px 12px',
                borderRadius: 'var(--radius-full)',
                border: 'none',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
                background: viewMode === 'radar' ? 'var(--gradient-cyan)' : 'transparent',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                gap: '3px',
                transition: 'all var(--transition-fast)',
              }}
            >
              <Radar size={13} />
              Radar
            </button>
          </div>
        </div>

        {/* MODE 1: SWIPE CARDS DECK */}
        {viewMode === 'cards' && (
          <>
            {loading ? (
              <div
                className="glass-panel"
                style={{
                  height: '480px',
                  borderRadius: 'var(--radius-lg)',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '12px',
                }}
              >
                <div className="radar-spinner" style={{ width: '36px', height: '36px', borderRadius: '50%', border: '3px solid #ff2d55', borderTopColor: 'transparent' }} />
                <div style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>
                  Prefetching candidate deck from Redis...
                </div>
              </div>
            ) : currentCandidate ? (
              <div
                className="glass-panel"
                style={{
                  position: 'relative',
                  height: '510px',
                  borderRadius: 'var(--radius-lg)',
                  overflow: 'hidden',
                  boxShadow: 'var(--shadow-lg)',
                  border: '1px solid var(--border-glass)',
                }}
              >
                {/* Photo Carousel Image */}
                <img
                  src={currentPhotos[activePhotoIndex] || '/ananya.jpg'}
                  alt={currentCandidate.nickname}
                  style={{
                    width: '100%',
                    height: '100%',
                    objectFit: 'cover',
                    display: 'block',
                    transition: 'opacity 0.2s ease-in-out',
                  }}
                />

                {/* Multi-Photo Carousel Tap Regions */}
                {currentPhotos.length > 1 && (
                  <>
                    <div
                      onClick={() => setActivePhotoIndex((p) => Math.max(0, p - 1))}
                      style={{ position: 'absolute', top: 0, bottom: '140px', left: 0, width: '40%', zIndex: 15, cursor: 'pointer' }}
                      title="Previous Photo"
                    />
                    <div
                      onClick={() => setActivePhotoIndex((p) => Math.min(currentPhotos.length - 1, p + 1))}
                      style={{ position: 'absolute', top: 0, bottom: '140px', right: 0, width: '40%', zIndex: 15, cursor: 'pointer' }}
                      title="Next Photo"
                    />
                  </>
                )}

                {/* Gradient Card Overlay */}
                <div style={{ position: 'absolute', inset: 0, background: 'var(--gradient-card-overlay)', pointerEvents: 'none' }} />

                {/* Story Progress Indicators at Top of Photo */}
                {currentPhotos.length > 1 && (
                  <div style={{ position: 'absolute', top: '10px', left: '14px', right: '14px', display: 'flex', gap: '4px', zIndex: 20 }}>
                    {currentPhotos.map((_, idx) => (
                      <div
                        key={idx}
                        style={{
                          flex: 1,
                          height: '3px',
                          borderRadius: '2px',
                          background: idx === activePhotoIndex ? '#ffffff' : 'rgba(255, 255, 255, 0.3)',
                          transition: 'background 0.2s',
                        }}
                      />
                    ))}
                  </div>
                )}

                {/* Top Badges */}
                <div
                  style={{
                    position: 'absolute',
                    top: currentPhotos.length > 1 ? '22px' : '14px',
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
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '5px',
                        background: 'rgba(0, 0, 0, 0.5)',
                        padding: '3px 8px',
                        borderRadius: 'var(--radius-full)',
                        fontSize: '11px',
                        fontWeight: 600,
                        backdropFilter: 'blur(8px)',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                      }}
                    >
                      <span className="status-dot-online" />
                      <span>Online</span>
                    </div>

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
                          backdropFilter: 'blur(8px)',
                        }}
                      >
                        <ShieldCheck size={13} />
                        Verified
                      </div>
                    )}
                  </div>
                </div>

                {/* Swipe Action Visual Stamp Overlay */}
                {swipeStamp && (
                  <div
                    style={{
                      position: 'absolute',
                      top: '40%',
                      left: '50%',
                      transform: `translate(-50%, -50%) rotate(${swipeStamp === 'like' ? '-12deg' : swipeStamp === 'spark' ? '0deg' : '12deg'})`,
                      padding: '8px 24px',
                      borderRadius: 'var(--radius-md)',
                      fontSize: '28px',
                      fontWeight: 900,
                      letterSpacing: '2px',
                      textTransform: 'uppercase',
                      border: `4px solid ${swipeStamp === 'like' ? '#2ed573' : swipeStamp === 'spark' ? '#ffa502' : '#ff4757'}`,
                      color: swipeStamp === 'like' ? '#2ed573' : swipeStamp === 'spark' ? '#ffa502' : '#ff4757',
                      background: 'rgba(8, 10, 16, 0.85)',
                      boxShadow: '0 0 30px rgba(0,0,0,0.8)',
                      zIndex: 35,
                      pointerEvents: 'none',
                    }}
                  >
                    {swipeStamp === 'like' ? 'LIKE' : swipeStamp === 'spark' ? 'SPARK' : 'PASS'}
                  </div>
                )}

                {/* Bottom Card Content */}
                <div style={{ position: 'absolute', bottom: '14px', left: '16px', right: '16px', zIndex: 20 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '2px' }}>
                    <h2 style={{ fontSize: '24px', fontWeight: 800 }}>{currentCandidate.nickname}</h2>
                    <span style={{ fontSize: '20px', color: 'var(--text-secondary)' }}>
                      {currentCandidate.age || 24}
                    </span>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '5px', color: 'var(--cyan-vibe)', fontSize: '12px', marginBottom: '6px' }}>
                    <MapPin size={13} />
                    <span>{currentCandidate.distance_km} km away • {currentCandidate.city}</span>
                  </div>

                  {/* Shared Interests Tag Pills */}
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px', marginBottom: '8px' }}>
                    {(currentCandidate.shared_interests || ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨']).map((tag, i) => (
                      <span
                        key={i}
                        style={{
                          background: 'rgba(255, 255, 255, 0.08)',
                          backdropFilter: 'blur(8px)',
                          border: '1px solid rgba(255, 255, 255, 0.12)',
                          borderRadius: 'var(--radius-full)',
                          padding: '2px 8px',
                          fontSize: '11px',
                          color: '#ffffff',
                          fontWeight: 500,
                        }}
                      >
                        {tag}
                      </span>
                    ))}
                  </div>

                  <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.35, marginBottom: '10px' }}>
                    {currentCandidate.bio}
                  </p>

                  {/* Voice Note Button */}
                  <button
                    onClick={playVoiceNote}
                    className="glass-pill"
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '5px',
                      padding: '5px 12px',
                      fontSize: '11px',
                      fontWeight: 600,
                      color: audioPlaying ? '#ff2d55' : '#ffffff',
                      border: '1px solid rgba(255, 255, 255, 0.18)',
                      cursor: 'pointer',
                      background: audioPlaying ? 'rgba(255, 45, 85, 0.15)' : 'rgba(255, 255, 255, 0.06)',
                    }}
                  >
                    <Volume2 size={14} />
                    <span>{audioPlaying ? 'Playing Audio Prompt...' : 'Voice Prompt (0:14)'}</span>
                  </button>
                </div>
              </div>
            ) : (
              <div
                className="glass-panel"
                style={{
                  height: '480px',
                  borderRadius: 'var(--radius-lg)',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  textAlign: 'center',
                  padding: '24px',
                }}
              >
                <div style={{ fontSize: '42px', marginBottom: '14px' }}>✨</div>
                <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '6px' }}>
                  You've explored all nearby candidates!
                </h3>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '18px', maxWidth: '300px' }}>
                  Expand PostGIS discovery radius or restore previously swiped candidate cards.
                </p>
                <button
                  onClick={() => {
                    setCurrentIndex(0);
                    fetchDeck();
                  }}
                  className="btn-primary"
                  style={{ padding: '10px 22px', fontSize: '13px' }}
                >
                  Refresh Candidate Deck
                </button>
              </div>
            )}

            {/* Action Buttons Bar - Large Thumb Touch Targets */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '12px',
                marginTop: '14px',
              }}
            >
              <button
                onClick={handleRevert}
                title="Revert previous swipe"
                className="action-btn-circle btn-revert"
                style={{ width: '52px', height: '52px' }}
              >
                <RotateCcw size={19} />
              </button>

              <button
                onClick={() => handleSwipe('dislike')}
                title="Pass"
                className="action-btn-circle btn-dislike"
                style={{ width: '56px', height: '56px' }}
              >
                <X size={24} />
              </button>

              <button
                onClick={() => handleSwipe('like')}
                title="Like"
                className="action-btn-circle btn-like"
                style={{ width: '66px', height: '66px' }}
              >
                <Heart size={32} fill="#ffffff" />
              </button>

              <button
                onClick={() => handleSwipe('spark')}
                title="Spark / Mega-Crush"
                className="action-btn-circle btn-spark"
                style={{ width: '56px', height: '56px' }}
              >
                <Sparkles size={22} />
              </button>

              <button
                onClick={() => handleSwipe('snooze')}
                title="Snooze"
                className="action-btn-circle btn-snooze"
                style={{ width: '52px', height: '52px' }}
              >
                <Moon size={19} />
              </button>
            </div>
          </>
        )}

        {/* MODE 2: POSTGIS SPATIAL RADAR VIEW */}
        {viewMode === 'radar' && (
          <div
            className="glass-panel"
            style={{
              height: '480px',
              borderRadius: 'var(--radius-lg)',
              padding: '20px',
              position: 'relative',
              overflow: 'hidden',
              textAlign: 'center',
            }}
          >
            <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '2px' }}>PostGIS Spatial Radar</h3>
            <p style={{ fontSize: '11px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              Real-time ST_DWithin tracking (Mumbai: 19.0596° N, 72.8295° E)
            </p>

            {/* Radar Grid Screen */}
            <div
              style={{
                position: 'relative',
                width: '270px',
                height: '270px',
                margin: '0 auto',
                borderRadius: '50%',
                border: '2px solid rgba(0, 229, 255, 0.4)',
                background: 'radial-gradient(circle, rgba(0, 229, 255, 0.08) 0%, rgba(8, 10, 16, 0.95) 70%)',
                overflow: 'hidden',
              }}
            >
              <div style={{ position: 'absolute', inset: '45px', borderRadius: '50%', border: '1px dashed rgba(0, 229, 255, 0.25)' }} />
              <div style={{ position: 'absolute', inset: '90px', borderRadius: '50%', border: '1px dashed rgba(0, 229, 255, 0.2)' }} />

              {/* Sweeping Radar Beam */}
              <div
                className="radar-spinner"
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  width: '100%',
                  height: '100%',
                  background: 'conic-gradient(from 0deg at 50% 50%, rgba(0, 229, 255, 0.35) 0deg, transparent 60deg)',
                  borderRadius: '50%',
                  pointerEvents: 'none',
                }}
              />

              {/* Center User Dot (Arjun) */}
              <div
                style={{
                  position: 'absolute',
                  top: '50%',
                  left: '50%',
                  transform: 'translate(-50%, -50%)',
                  width: '12px',
                  height: '12px',
                  borderRadius: '50%',
                  background: '#ff2d55',
                  border: '2px solid #ffffff',
                  boxShadow: '0 0 10px #ff2d55',
                  zIndex: 10,
                }}
                title="Your Location"
              />

              {/* Pin 1: Ananya */}
              <div
                onClick={() => {
                  setViewMode('cards');
                  setCurrentIndex(0);
                }}
                style={{ position: 'absolute', top: '42%', left: '55%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
                title="Ananya (0.8 km • Bandra)"
              >
                <div style={{ width: '32px', height: '32px', borderRadius: '50%', border: '2px solid #00e5ff', overflow: 'hidden', boxShadow: '0 0 10px #00e5ff' }}>
                  <img src="/ananya.jpg" alt="Ananya" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                </div>
              </div>

              {/* Pin 2: Rohit */}
              <div
                onClick={() => {
                  setViewMode('cards');
                  setCurrentIndex(1);
                }}
                style={{ position: 'absolute', top: '25%', left: '45%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
                title="Rohit (5.3 km • Juhu)"
              >
                <div style={{ width: '30px', height: '30px', borderRadius: '50%', border: '2px solid #ffd700', overflow: 'hidden' }}>
                  <img src="/rohit.jpg" alt="Rohit" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                </div>
              </div>

              {/* Pin 3: Riya */}
              <div
                onClick={() => {
                  setViewMode('cards');
                  setCurrentIndex(2);
                }}
                style={{ position: 'absolute', bottom: '18%', left: '58%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
                title="Riya (15.2 km • Colaba)"
              >
                <div style={{ width: '30px', height: '30px', borderRadius: '50%', border: '2px solid #9b51e0', overflow: 'hidden' }}>
                  <img src="/riya.jpg" alt="Riya" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                </div>
              </div>
            </div>

            <div style={{ marginTop: '16px', fontSize: '12px', color: 'var(--text-secondary)' }}>
              Tap any candidate pin on the radar to view their profile card.
            </div>
          </div>
        )}
      </section>

      {/* 4. DAILY ICEBREAKER PROMPT CARD */}
      <DailyIcebreakerCard />
    </div>
  );
};
