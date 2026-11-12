import React, { useState, useEffect, useRef, useCallback } from 'react';
import { RefreshCw, AlertCircle, Sparkles, LayoutGrid, Heart, Flame, X, MapPin, CheckCircle2, PhoneCall, Video } from 'lucide-react';
import { CandidateCard, ScheduledDate } from '../types';
import { DEMO_PROFILES } from '../data/profilesData';
import { DiscoveryDeck } from '../components/DiscoveryDeck';
import { DateReminderCard } from '../components/DateReminderCard';
import { FullProfileModal } from '../components/FullProfileModal';
import { MegaCrushCelebration } from '../components/MegaCrushCelebration';
import { RefreshAnimation } from '../components/RefreshAnimation';

export interface DiscoveryTabProps {
  onMutualMatch: (profile: CandidateCard) => void;
  onCoinDeducted?: (newBalance: number) => void;
  coinBalance?: number;
  streakDays?: number;
  onOpenStore?: () => void;
  onOpenWheel?: () => void;
  onOpenChat?: (convId: string) => void;
  onStartCall?: (calleeId: string, name: string, avatar: string, mode?: 'audio' | 'video') => void;
  onOpenDatePlan?: (scheduledDate: ScheduledDate) => void;
  onGoToRandomCall?: () => void;
  scheduledDate?: ScheduledDate;
}

const BATCH_SIZE = 6;

export const DiscoveryTab: React.FC<DiscoveryTabProps> = ({
  onMutualMatch,
  onOpenChat,
  onOpenDatePlan,
  onOpenWheel,
  onOpenStore,
  onGoToRandomCall,
  onStartCall,
  streakDays = 4,
  scheduledDate,
}) => {
  const [profiles, setProfiles] = useState<CandidateCard[]>([]);
  const [loadState, setLoadState] = useState<'loading' | 'ready' | 'error'>('loading');
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [page, setPage] = useState(1);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const isSplitView = false;

  // Selected profile for full profile modal & mega crush celebration
  const [selectedProfileForModal, setSelectedProfileForModal] = useState<CandidateCard | null>(null);
  const [megaCrushProfile, setMegaCrushProfile] = useState<CandidateCard | null>(null);

  // Selected profile for Random Call Tap-to-Connect dual-call modal
  const [randomCallSelected, setRandomCallSelected] = useState<{
    profile: CandidateCard;
    sticker: string;
    lang: string;
    ringColor: string;
  } | null>(null);

  // Load initial batch
  const loadInitialBatch = useCallback(async () => {
    setLoadState('loading');
    setErrorMessage(null);
    try {
      // Attempt backend API fetch
      const res = await fetch('/v1/discovery/deck?radius_km=50&user_id=11111111-1111-1111-1111-111111111111');
      if (res.ok) {
        const data = await res.json();
        if (data.success && Array.isArray(data.deck) && data.deck.length > 0) {
          // Deduplicate
          const unique = Array.from(new Map(data.deck.map((p: CandidateCard) => [p.user_id, p])).values()) as CandidateCard[];
          setProfiles(unique);
          setHasMore(unique.length >= BATCH_SIZE);
          setLoadState('ready');
          return;
        }
      }
      throw new Error('Fallback to client repository data');
    } catch {
      // Fallback gracefully to rich DEMO_PROFILES (32 curated profiles)
      const initialSlice = DEMO_PROFILES.slice(0, BATCH_SIZE);
      setProfiles(initialSlice);
      setHasMore(initialSlice.length < DEMO_PROFILES.length);
      setLoadState('ready');
    }
  }, []);

  // Pagination: load next slice
  const loadMoreProfiles = useCallback(async () => {
    if (isLoadingMore || !hasMore) return;
    setIsLoadingMore(true);

    try {
      const nextPage = page + 1;
      const startIndex = nextPage * BATCH_SIZE - BATCH_SIZE;
      const nextBatch = DEMO_PROFILES.slice(startIndex, startIndex + BATCH_SIZE);

      if (nextBatch.length > 0) {
        setProfiles((prev) => {
          const existingIds = new Set(prev.map((p) => p.user_id));
          const additions = nextBatch.filter((p) => !existingIds.has(p.user_id));
          return [...prev, ...additions];
        });
        setPage(nextPage);
        setHasMore(startIndex + BATCH_SIZE < DEMO_PROFILES.length);
      } else {
        setHasMore(false);
      }
    } catch (err: any) {
      console.error('Failed to paginate discovery deck:', err);
    } finally {
      setIsLoadingMore(false);
    }
  }, [page, isLoadingMore, hasMore]);

  // Initial load
  useEffect(() => {
    loadInitialBatch();
  }, [loadInitialBatch]);

  const handleMegaCrush = (profile: CandidateCard) => {
    setMegaCrushProfile(profile);
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100%',
        color: '#f8fafc',
        backgroundColor: '#111318',
        boxSizing: 'border-box',
        overflowY: 'auto',
        overflowX: 'hidden',
        position: 'relative',
        paddingBottom: '24px',
      }}
    >
      {/* 1. DATE PLANNER WIDGET (when is_date = true) */}
      {scheduledDate && scheduledDate.is_date === true && (
        <DateReminderCard
          scheduledDate={scheduledDate}
          onOpenDatePlan={() => onOpenDatePlan?.(scheduledDate)}
          onStartCall={onStartCall}
        />
      )}

      {/* 2. RANDOM CALL OVERHAUL: FLOATING EMOJI BUBBLES CANVAS */}
      <div
        style={{
          margin: '2px 14px 4px',
          padding: '10px 14px 12px',
          borderRadius: '18px',
          background:
            'linear-gradient(135deg, rgba(22, 25, 35, 0.9) 0%, rgba(14, 16, 22, 0.95) 100%)',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          boxShadow: '0 4px 16px rgba(0, 0, 0, 0.35)',
          overflow: 'hidden',
          userSelect: 'none',
        }}
      >
        {/* Section Heading & Subtitle */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px', padding: '0 2px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '13px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.2px' }}>
              Random Call
            </span>
            <span style={{ fontSize: '9px', fontWeight: 700, color: '#10b981', background: 'rgba(16, 185, 129, 0.15)', border: '1px solid rgba(16, 185, 129, 0.3)', padding: '1px 6px', borderRadius: '999px' }}>
              Live
            </span>
          </div>
          <span style={{ fontSize: '10.5px', color: '#94a3b8' }}>Tap bubble to connect</span>
        </div>

        {/* Floating River Canvas: Multiple Circular Emoji Bubbles Floating Simultaneously */}
        <div
          style={{
            display: 'flex',
            gap: '16px',
            overflowX: 'auto',
            overflowY: 'hidden',
            padding: '6px 4px 10px',
            scrollbarWidth: 'none',
            WebkitOverflowScrolling: 'touch',
            alignItems: 'center',
          }}
        >
          {DEMO_PROFILES.slice(0, 12).map((prof, pIdx) => {
            const stickerEmojis = ['🦊', '🐰', '🐼', '🐱', '🦄', '🌸', '🐻', '🐯', '🍓', '🐨', '🦋', '🐥'];
            const sticker = stickerEmojis[pIdx % stickerEmojis.length];

            const languages = ['Telugu', 'Hindi', 'English', 'Tamil', 'Kannada', 'Malayalam'];
            const lang = languages[pIdx % languages.length];

            const ringColors = [
              'rgba(244, 63, 94, 0.75)',   // Rose
              'rgba(56, 189, 248, 0.75)',  // Sky blue
              'rgba(168, 85, 247, 0.75)',  // Purple
              'rgba(251, 146, 60, 0.75)',  // Orange
              'rgba(34, 197, 94, 0.75)',   // Mint
              'rgba(236, 72, 153, 0.75)',  // Pink
              'rgba(250, 204, 21, 0.75)',  // Gold
              'rgba(20, 184, 166, 0.75)',  // Teal
            ];
            const ringColor = ringColors[pIdx % ringColors.length];

            return (
              <div
                key={prof.user_id}
                onClick={() => setRandomCallSelected({ profile: prof, sticker, lang, ringColor })}
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
                {/* Floating Bubble Avatar Circle with fun emoji character */}
                <div
                  style={{
                    position: 'relative',
                    width: '56px',
                    height: '56px',
                    borderRadius: '50%',
                    background: `radial-gradient(circle at 35% 35%, rgba(255, 255, 255, 0.22), rgba(20, 23, 32, 0.95))`,
                    border: `2px solid ${ringColor}`,
                    boxShadow: `0 4px 16px ${ringColor.replace('0.75', '0.35')}, inset 0 2px 6px rgba(255, 255, 255, 0.15)`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '25px',
                  }}
                >
                  <span style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.45))' }}>{sticker}</span>
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
                    maxWidth: '64px',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    textAlign: 'center',
                    letterSpacing: '-0.2px',
                  }}
                >
                  {prof.nickname}
                </span>

                {/* Spoken Language Tag */}
                <span
                  style={{
                    fontSize: '9px',
                    fontWeight: 700,
                    color: '#94a3b8',
                    background: 'rgba(255, 255, 255, 0.06)',
                    padding: '1px 5px',
                    borderRadius: '4px',
                    lineHeight: 1.1,
                  }}
                >
                  {lang}
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {/* 3. DISCOVERY DECK HEADER */}
      <div
        style={{
          padding: '6px 26px 6px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexShrink: 0,
        }}
      >
        <h2 style={{ fontSize: '18px', fontWeight: 800, margin: 0, letterSpacing: '-0.3px', color: '#f8fafc' }}>
          Discovery
        </h2>
        <span style={{ fontSize: '11px', color: '#94a3b8', fontWeight: 600 }}>
          Swipe & Connect
        </span>
      </div>

      {/* 4. DISCOVERY BOX (WITH SIDE GUTTER SPACING FOR UP/DOWN PAGE SCROLLING) */}
      <div
        style={{
          margin: '4px 24px 28px',
          height: '610px',
          minHeight: '560px',
          borderRadius: '24px',
          border: '1.5px solid rgba(255, 255, 255, 0.12)',
          background: '#131620',
          boxShadow: '0 12px 36px rgba(0, 0, 0, 0.65), 0 0 20px rgba(244, 63, 94, 0.08)',
          position: 'relative',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          flexShrink: 0,
        }}
      >
        {/* 3. LOADING STATE WITH LARGE YOUNME REFRESH ANIMATION */}
        {loadState === 'loading' && (
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <RefreshAnimation
              size="large"
              message="Discovering Romantic Connections..."
              submessage="Tuning feed to your interests & vibe preferences"
            />
          </div>
        )}

        {/* 4. ERROR STATE */}
        {loadState === 'error' && (
          <div
            style={{
              margin: '40px 20px',
              padding: '24px',
              background: '#191c24',
              borderRadius: '20px',
              border: '1px solid rgba(239, 68, 68, 0.3)',
              textAlign: 'center',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
            }}
          >
            <AlertCircle size={40} color="#ef4444" style={{ marginBottom: '12px' }} />
            <h3 style={{ fontSize: '16px', fontWeight: 800, color: '#f8fafc', margin: '0 0 6px' }}>
              Unable to Load Feed
            </h3>
            <p style={{ fontSize: '12px', color: '#94a3b8', margin: '0 0 16px' }}>
              {errorMessage || 'Connection timed out. Please check your network and try again.'}
            </p>
            <button
              type="button"
              onClick={loadInitialBatch}
              style={{
                padding: '10px 20px',
                borderRadius: '999px',
                border: 'none',
                background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                color: '#ffffff',
                fontSize: '12.5px',
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Retry Connection
            </button>
          </div>
        )}

        {/* 5. MAIN VERTICAL FULL-BLEED PROFILE FEED (WHEN SPLIT VIEW IS OFF) */}
        {loadState === 'ready' && !isSplitView && (
          <DiscoveryDeck
            profiles={profiles}
            onMutualMatch={onMutualMatch}
            onMegaCrush={handleMegaCrush}
            onOpenFullProfile={(candidate) => setSelectedProfileForModal(candidate)}
            onDirectMessage={(_candidate) => {
              if (onOpenChat) {
                onOpenChat('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
              }
            }}
            onLoadMore={loadMoreProfiles}
            hasMore={hasMore}
            isLoadingMore={isLoadingMore}
            onOpenStore={onOpenStore}
          />
        )}

        {/* 5B. SPLIT DUAL-COLUMN PROFILE GRID (WHEN SPLIT VIEW IS ON) */}
        {loadState === 'ready' && isSplitView && (
          <div
            style={{
              flex: 1,
              overflowY: 'auto',
              padding: '6px 12px 20px',
              display: 'grid',
              gridTemplateColumns: '1fr 1fr',
              gap: '10px',
              alignContent: 'start',
            }}
          >
            {profiles.map((profile) => {
              const photo = profile.photo_urls?.[0] || '/ananya.jpg';
              return (
                <div
                  key={profile.user_id}
                  style={{
                    position: 'relative',
                    height: '240px',
                    borderRadius: '16px',
                    overflow: 'hidden',
                    background: '#191c24',
                    border: '1px solid rgba(255, 255, 255, 0.08)',
                    boxShadow: '0 4px 14px rgba(0, 0, 0, 0.35)',
                    cursor: 'pointer',
                    display: 'flex',
                    flexDirection: 'column',
                    justifyContent: 'space-between',
                  }}
                  onClick={() => setSelectedProfileForModal(profile)}
                >
                  <img
                    src={photo}
                    alt={profile.nickname}
                    style={{
                      position: 'absolute',
                      inset: 0,
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover',
                      filter: 'brightness(0.92)',
                    }}
                  />
                  <div
                    style={{
                      position: 'absolute',
                      inset: 0,
                      background: 'linear-gradient(to top, rgba(15, 23, 42, 0.95) 0%, rgba(15, 23, 42, 0.35) 45%, transparent 100%)',
                    }}
                  />

                  {/* Top Vibe Badge */}
                  <div
                    style={{
                      position: 'relative',
                      zIndex: 2,
                      padding: '8px 8px',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <span
                      style={{
                        fontSize: '9.5px',
                        fontWeight: 700,
                        background: 'rgba(0, 0, 0, 0.6)',
                        backdropFilter: 'blur(8px)',
                        padding: '2px 7px',
                        borderRadius: '999px',
                        border: '1px solid rgba(255, 255, 255, 0.15)',
                        color: '#f43f5e',
                      }}
                    >
                      {profile.vibe_score || 94}% Vibe
                    </span>
                    {profile.is_verified && (
                      <CheckCircle2 size={13} color="#38bdf8" fill="#0284c7" />
                    )}
                  </div>

                  {/* Bottom Info & Action Buttons */}
                  <div
                    style={{
                      position: 'relative',
                      zIndex: 2,
                      padding: '8px 10px',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#f8fafc' }}>
                        {profile.nickname}, {profile.age}
                      </span>
                    </div>
                    <div style={{ fontSize: '10px', color: '#94a3b8', display: 'flex', alignItems: 'center', gap: '3px', marginTop: '1px' }}>
                      <MapPin size={10} color="#f43f5e" />
                      <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {profile.city.split(',')[0]}
                      </span>
                    </div>

                    {/* Quick Split View Action Buttons */}
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        marginTop: '8px',
                        paddingTop: '6px',
                        borderTop: '1px solid rgba(255, 255, 255, 0.1)',
                      }}
                      onClick={(e) => e.stopPropagation()}
                    >
                      <button
                        type="button"
                        onClick={() => {
                          setProfiles((prev) => prev.filter((p) => p.user_id !== profile.user_id));
                        }}
                        style={{
                          width: '28px',
                          height: '28px',
                          borderRadius: '50%',
                          background: 'rgba(239, 68, 68, 0.15)',
                          border: '1px solid rgba(239, 68, 68, 0.3)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          cursor: 'pointer',
                        }}
                        title="Pass"
                      >
                        <X size={13} color="#ef4444" />
                      </button>

                      <button
                        type="button"
                        onClick={() => handleMegaCrush(profile)}
                        style={{
                          width: '30px',
                          height: '30px',
                          borderRadius: '50%',
                          background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                          border: 'none',
                          boxShadow: '0 0 10px rgba(244, 63, 94, 0.5)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          cursor: 'pointer',
                        }}
                        title="Mega Crush"
                      >
                        <Flame size={14} color="#ffffff" />
                      </button>

                      <button
                        type="button"
                        onClick={() => {
                          setProfiles((prev) => prev.filter((p) => p.user_id !== profile.user_id));
                          onMutualMatch(profile);
                        }}
                        style={{
                          width: '28px',
                          height: '28px',
                          borderRadius: '50%',
                          background: 'rgba(34, 197, 94, 0.15)',
                          border: '1px solid rgba(34, 197, 94, 0.3)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          cursor: 'pointer',
                        }}
                        title="Like"
                      >
                        <Heart size={13} color="#22c55e" fill="#22c55e" />
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Full Detailed Profile Modal (Triggered by the Right-Pointing Arrow on Card) */}
      <FullProfileModal
        isOpen={Boolean(selectedProfileForModal)}
        profile={selectedProfileForModal}
        onClose={() => setSelectedProfileForModal(null)}
        onLike={(p) => {
          setSelectedProfileForModal(null);
          onMutualMatch(p);
        }}
        onPass={() => setSelectedProfileForModal(null)}
        onMegaCrush={(p) => {
          setSelectedProfileForModal(null);
          handleMegaCrush(p);
        }}
      />

      {/* Compact Snappy Mega Crush Celebration */}
      <MegaCrushCelebration
        isOpen={Boolean(megaCrushProfile)}
        profile={megaCrushProfile}
        onClose={() => setMegaCrushProfile(null)}
      />

      {/* Tap-to-Connect Dual-Call Modal for Floating Random Call Bubbles */}
      {randomCallSelected && (
        <div
          onClick={() => setRandomCallSelected(null)}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 100,
            background: 'rgba(6, 8, 14, 0.75)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end',
            alignItems: 'center',
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '420px',
              background: '#171a23',
              borderTopLeftRadius: '26px',
              borderTopRightRadius: '26px',
              border: '1.5px solid rgba(255, 255, 255, 0.12)',
              borderBottom: 'none',
              padding: '22px 20px 28px',
              boxShadow: '0 -12px 40px rgba(0, 0, 0, 0.75)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              position: 'relative',
              gap: '14px',
            }}
          >
            {/* Close button */}
            <button
              type="button"
              onClick={() => setRandomCallSelected(null)}
              aria-label="Close modal"
              style={{
                position: 'absolute',
                top: '16px',
                right: '16px',
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '30px',
                height: '30px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#94a3b8',
                cursor: 'pointer',
              }}
            >
              <X size={16} />
            </button>

            {/* Selected Profile Emoji Bubble Avatar */}
            <div
              style={{
                width: '72px',
                height: '72px',
                borderRadius: '50%',
                background: `radial-gradient(circle at 35% 35%, rgba(255, 255, 255, 0.2), rgba(20, 24, 34, 0.95))`,
                border: `2.5px solid ${randomCallSelected.ringColor}`,
                boxShadow: `0 8px 24px ${randomCallSelected.ringColor.replace('0.75', '0.4')}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '34px',
                position: 'relative',
                marginTop: '4px',
              }}
            >
              <span>{randomCallSelected.sticker}</span>
              <div
                style={{
                  position: 'absolute',
                  bottom: '2px',
                  right: '2px',
                  width: '12px',
                  height: '12px',
                  borderRadius: '50%',
                  background: '#10b981',
                  border: '2px solid #171a23',
                  boxShadow: '0 0 6px #10b981',
                }}
              />
            </div>

            {/* Profile Identity */}
            <div style={{ textAlign: 'center' }}>
              <div style={{ fontSize: '18px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.3px' }}>
                {randomCallSelected.profile.nickname}, {randomCallSelected.profile.age || 24}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', marginTop: '4px' }}>
                <span style={{ fontSize: '11.5px', color: '#38bdf8', fontWeight: 700, background: 'rgba(56, 189, 248, 0.12)', padding: '2px 8px', borderRadius: '999px', border: '1px solid rgba(56, 189, 248, 0.25)' }}>
                  {randomCallSelected.lang}
                </span>
                <span style={{ fontSize: '11.5px', color: '#10b981', fontWeight: 600 }}>
                  Online Now 🟢
                </span>
              </div>
              <p style={{ fontSize: '12px', color: '#94a3b8', margin: '8px 0 0', lineHeight: 1.4 }}>
                Connect directly for a spontaneous conversation without sharing personal phone numbers.
              </p>
            </div>

            {/* Prominent Action Buttons: Audio Call & Video Call */}
            <div style={{ width: '100%', display: 'flex', gap: '12px', marginTop: '4px' }}>
              {/* Audio Call Button */}
              <button
                type="button"
                onClick={() => {
                  const target = randomCallSelected;
                  setRandomCallSelected(null);
                  if (onStartCall) {
                    onStartCall(target.profile.user_id, target.profile.nickname, target.profile.photo_urls[0], 'audio');
                  } else if (onGoToRandomCall) {
                    onGoToRandomCall();
                  }
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  padding: '13px 0',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, rgba(56, 189, 248, 0.2) 0%, rgba(2, 132, 199, 0.3) 100%)',
                  border: '1.5px solid rgba(56, 189, 248, 0.55)',
                  color: '#38bdf8',
                  fontSize: '13.5px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  boxShadow: '0 4px 16px rgba(56, 189, 248, 0.2)',
                  transition: 'transform 0.12s ease',
                }}
                onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.97)')}
                onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
              >
                <PhoneCall size={17} />
                <span>Audio Call</span>
              </button>

              {/* Video Call Button */}
              <button
                type="button"
                onClick={() => {
                  const target = randomCallSelected;
                  setRandomCallSelected(null);
                  if (onStartCall) {
                    onStartCall(target.profile.user_id, target.profile.nickname, target.profile.photo_urls[0], 'video');
                  } else if (onGoToRandomCall) {
                    onGoToRandomCall();
                  }
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  padding: '13px 0',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                  border: 'none',
                  color: '#ffffff',
                  fontSize: '13.5px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  boxShadow: '0 4px 18px rgba(244, 63, 94, 0.35)',
                  transition: 'transform 0.12s ease',
                }}
                onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.97)')}
                onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
              >
                <Video size={17} />
                <span>Video Call</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
