import React, { useState, useRef, useEffect, useCallback } from 'react';
import {
  Heart,
  X,
  RotateCcw,
  Sparkles,
  MapPin,
  CheckCircle2,
  Flame,
  MessageCircle,
  Gem,
  ArrowRight,
  MoreVertical,
  Flag,
  UserX,
  Share2,
  Copy,
  Check,
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { CandidateCard } from '../types';
import { RefreshAnimation } from './RefreshAnimation';

interface DiscoveryDeckProps {
  profiles: CandidateCard[];
  onMutualMatch: (profile: CandidateCard) => void;
  onMegaCrush: (profile: CandidateCard) => void;
  onOpenFullProfile: (profile: CandidateCard) => void;
  onDirectMessage?: (profile: CandidateCard) => void;
  onLoadMore?: () => Promise<CandidateCard[] | void>;
  hasMore?: boolean;
  isLoadingMore?: boolean;
  onOpenStore?: () => void;
}

interface FullBleedProfileItemProps {
  profile: CandidateCard;
  stackIndex: number;
  isActive: boolean;
  isDraggingCurrent: boolean;
  currentOffset: { x: number; y: number };
  parentDragOffset: { x: number; y: number };
  swipedState?: 'like' | 'pass' | 'mega_crush';
  revertDirection?: 'right' | 'left' | null;
  isGlowing: boolean;
  onPointerDown: (e: React.PointerEvent) => void;
  onPointerMove: (e: React.PointerEvent) => void;
  onPointerUp: (e?: React.PointerEvent) => void;
  onOpenFullProfile: (profile: CandidateCard) => void;
}

const FullBleedProfileItem: React.FC<FullBleedProfileItemProps> = ({
  profile,
  stackIndex,
  isActive,
  isDraggingCurrent,
  currentOffset,
  parentDragOffset,
  swipedState,
  revertDirection,
  isGlowing,
  onPointerDown,
  onPointerMove,
  onPointerUp,
  onOpenFullProfile,
}) => {
  const photoList = profile.photo_urls && profile.photo_urls.length > 0 ? profile.photo_urls : ['/ananya.jpg'];
  const [photoIndex, setPhotoIndex] = useState(0);
  const itemRef = useRef<HTMLDivElement>(null);
  const [isVisible, setIsVisible] = useState(false);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Intersection observer to pause timer when profile is not in the viewport
  useEffect(() => {
    const el = itemRef.current;
    if (!el || typeof IntersectionObserver === 'undefined') return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        setIsVisible(entry.isIntersecting);
      },
      { threshold: 0.55 }
    );
    observer.observe(el);

    return () => observer.disconnect();
  }, []);

  // Timer runner for automatic photo advance every 3 seconds (looping back to first)
  const startTimer = useCallback(() => {
    if (timerRef.current) clearInterval(timerRef.current);
    if (photoList.length <= 1) return;

    timerRef.current = setInterval(() => {
      if (!document.hidden && isVisible) {
        setPhotoIndex((prev) => (prev + 1) % photoList.length);
      }
    }, 3000);
  }, [photoList.length, isVisible]);

  // Handle visibility & autoplay lifecycle
  useEffect(() => {
    if (photoList.length > 1 && isVisible && isActive) {
      startTimer();
    } else {
      if (timerRef.current) clearInterval(timerRef.current);
    }

    const handleVisibilityChange = () => {
      if (document.hidden) {
        if (timerRef.current) clearInterval(timerRef.current);
      } else if (isVisible && isActive) {
        startTimer();
      }
    };

    document.addEventListener('visibilitychange', handleVisibilityChange);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [photoList.length, isVisible, isActive, startTimer]);

  // Reset photo index when profile becomes active
  useEffect(() => {
    if (isActive) {
      setPhotoIndex(0);
    }
  }, [isActive]);

  const handleManualNav = (idx: number, e: React.MouseEvent) => {
    e.stopPropagation();
    setPhotoIndex(idx);
    startTimer();
  };

  const rotation = currentOffset.x * 0.07;
  const likeOpacity = Math.min(Math.max(currentOffset.x / 65, 0), 1);
  const nopeOpacity = Math.min(Math.max(-currentOffset.x / 65, 0), 1);
  const currentPhoto = photoList[photoIndex] || photoList[0];

  // Stack Positioning & Layered Deck Physics ("one card back another back")
  let transformStyle = 'translate3d(0, 0, 0) scale(1)';
  let filterStyle = 'brightness(1)';
  let opacityStyle = 1;

  if (stackIndex === 0) {
    if (swipedState === 'like') {
      transformStyle = 'translate3d(140%, 0, 0) rotate(22deg)';
      opacityStyle = 0;
    } else if (swipedState === 'pass') {
      transformStyle = 'translate3d(-140%, 0, 0) rotate(-22deg)';
      opacityStyle = 0;
    } else if (swipedState === 'mega_crush') {
      transformStyle = 'translate3d(0, -140%, 0) scale(1.05)';
      opacityStyle = 0;
    } else if (isDraggingCurrent) {
      transformStyle = `translate3d(${currentOffset.x}px, ${currentOffset.y * 0.35}px, 0) rotate(${rotation}deg)`;
    }
  } else if (stackIndex === 1) {
    // Card directly behind front active card: scales up smoothly as top card is swiped
    const dragRatio = isDraggingCurrent ? Math.min(Math.abs(parentDragOffset.x) / 75, 1) : 0;
    const backScale = 0.96 + dragRatio * 0.04;
    const backY = 8 - dragRatio * 8;
    const backBrightness = 0.9 + dragRatio * 0.1;

    transformStyle = `translate3d(0, ${backY}px, 0) scale(${backScale})`;
    filterStyle = `brightness(${backBrightness})`;
  } else if (stackIndex === 2) {
    // 3rd card in deck
    const dragRatio = isDraggingCurrent ? Math.min(Math.abs(parentDragOffset.x) / 75, 1) : 0;
    const thirdScale = 0.92 + dragRatio * 0.04;
    const thirdY = 16 - dragRatio * 8;
    const thirdBrightness = 0.8 + dragRatio * 0.1;

    transformStyle = `translate3d(0, ${thirdY}px, 0) scale(${thirdScale})`;
    filterStyle = `brightness(${thirdBrightness})`;
  }

  return (
    <div
      ref={itemRef}
      onPointerDown={stackIndex === 0 ? onPointerDown : undefined}
      onPointerMove={stackIndex === 0 ? onPointerMove : undefined}
      onPointerUp={stackIndex === 0 ? onPointerUp : undefined}
      onPointerCancel={stackIndex === 0 ? onPointerUp : undefined}
      className={
        revertDirection === 'right'
          ? 'revert-animate-right'
          : revertDirection === 'left'
          ? 'revert-animate-left'
          : undefined
      }
      style={{
        position: 'absolute',
        inset: 0,
        width: '100%',
        height: '100%',
        borderRadius: '24px',
        overflow: 'hidden',
        userSelect: 'none',
        cursor: stackIndex === 0 ? (isDraggingCurrent ? 'grabbing' : 'grab') : 'default',
        pointerEvents: stackIndex === 0 ? 'auto' : 'none',
        zIndex: 10 - stackIndex,
        transform: transformStyle,
        filter: filterStyle,
        opacity: opacityStyle,
        transition: isDraggingCurrent && stackIndex === 0
          ? 'none'
          : 'transform 0.32s cubic-bezier(0.16, 1, 0.3, 1), filter 0.32s ease, opacity 0.28s ease',
        touchAction: 'pan-y',
        boxShadow: isGlowing
          ? 'inset 0 0 45px rgba(239, 68, 68, 0.7)'
          : stackIndex === 0
          ? '0 12px 32px rgba(0, 0, 0, 0.55)'
          : '0 8px 24px rgba(0, 0, 0, 0.45)',
      }}
    >
      {/* 1. FULL-BLEED PRIMARY PHOTO */}
      <img
        src={currentPhoto}
        alt={profile.nickname}
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          pointerEvents: 'none',
          display: 'block',
          transition: 'opacity 0.22s ease-in-out',
        }}
      />

      {/* 2. SUBTLE TRANSPARENT GRADIENT (NO BULKY CARD BACKGROUND) */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'linear-gradient(to top, rgba(11, 13, 20, 0.95) 0%, rgba(11, 13, 20, 0.6) 28%, rgba(11, 13, 20, 0.15) 55%, transparent 75%)',
          pointerEvents: 'none',
        }}
      />

      {/* 3. MULTI-PHOTO INDICATOR BARS AT TOP (ONLY IF MULTI-PHOTO) */}
      {photoList.length > 1 && (
        <div
          style={{
            position: 'absolute',
            top: '12px',
            left: '16px',
            right: '16px',
            display: 'flex',
            justifyContent: 'center',
            gap: '4px',
            zIndex: 15,
          }}
        >
          {photoList.map((_, pIdx) => (
            <div
              key={pIdx}
              onClick={(e) => handleManualNav(pIdx, e)}
              style={{
                flex: 1,
                height: '3px',
                borderRadius: '2px',
                background: pIdx === photoIndex ? '#ffffff' : 'rgba(255, 255, 255, 0.35)',
                boxShadow: '0 1px 4px rgba(0, 0, 0, 0.7)',
                cursor: 'pointer',
                transition: 'background 0.2s ease',
              }}
            />
          ))}
        </div>
      )}

      {/* 4. INVERTED VISUAL FEEDBACK GESTURE SYMBOLS (LEFT-SIDE GREEN HEART, RIGHT-SIDE RED CROSS) */}
      {isDraggingCurrent && (
        <>
          {/* Swipe Right -> Green Heart / Love Symbol (💚) rendered on the LEFT side of card */}
          {currentOffset.x > 15 && (() => {
            const dragProgress = Math.min(Math.max((currentOffset.x - 15) / 60, 0), 1);
            const scale = 0.82 + dragProgress * 0.35;
            const opacity = 0.25 + dragProgress * 0.72;
            return (
              <div
                style={{
                  position: 'absolute',
                  top: '32px',
                  left: '22px',
                  width: '56px',
                  height: '56px',
                  borderRadius: '50%',
                  border: '2.5px solid #22c55e',
                  background: 'rgba(34, 197, 94, 0.22)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transform: `rotate(-12deg) scale(${scale})`,
                  opacity,
                  pointerEvents: 'none',
                  zIndex: 20,
                  boxShadow: '0 6px 20px rgba(34, 197, 94, 0.4)',
                  backdropFilter: 'blur(8px)',
                  WebkitBackdropFilter: 'blur(8px)',
                }}
              >
                <span style={{ fontSize: '30px', lineHeight: 1, filter: 'drop-shadow(0 2px 6px rgba(0,0,0,0.4))' }}>
                  💚
                </span>
              </div>
            );
          })()}

          {/* Swipe Left -> Red Cross / Into Mark (✕) rendered on the RIGHT side of card */}
          {currentOffset.x < -15 && (() => {
            const dragProgress = Math.min(Math.max((-currentOffset.x - 15) / 60, 0), 1);
            const scale = 0.82 + dragProgress * 0.35;
            const opacity = 0.25 + dragProgress * 0.72;
            return (
              <div
                style={{
                  position: 'absolute',
                  top: '32px',
                  right: '22px',
                  width: '56px',
                  height: '56px',
                  borderRadius: '50%',
                  border: '2.5px solid #ef4444',
                  background: 'rgba(239, 68, 68, 0.22)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transform: `rotate(12deg) scale(${scale})`,
                  opacity,
                  pointerEvents: 'none',
                  zIndex: 20,
                  boxShadow: '0 6px 20px rgba(239, 68, 68, 0.4)',
                  backdropFilter: 'blur(8px)',
                  WebkitBackdropFilter: 'blur(8px)',
                }}
              >
                <span
                  style={{
                    fontSize: '28px',
                    fontWeight: 900,
                    color: '#ef4444',
                    lineHeight: 1,
                    filter: 'drop-shadow(0 2px 6px rgba(0,0,0,0.4))',
                  }}
                >
                  ✕
                </span>
              </div>
            );
          })()}

          {currentOffset.y < -35 && Math.abs(currentOffset.y) > Math.abs(currentOffset.x) && (
            <div
              style={{
                position: 'absolute',
                top: '28px',
                left: '50%',
                transform: 'translateX(-50%)',
                padding: '6px 14px',
                borderRadius: '10px',
                border: '2.5px solid #f97316',
                background: 'rgba(249, 115, 22, 0.25)',
                color: '#f97316',
                fontSize: '13px',
                fontWeight: 900,
                letterSpacing: '1px',
                opacity: Math.min(-currentOffset.y / 70, 0.9),
                pointerEvents: 'none',
                zIndex: 20,
                boxShadow: '0 4px 14px rgba(249, 115, 22, 0.35)',
              }}
            >
              MEGA CRUSH 🔥
            </div>
          )}
        </>
      )}

      {/* 6. COMPACT PROFILE INFORMATION OVERLAY (POSITIONED ABOVE THE FIXED DOCK) */}
      <div
        style={{
          position: 'absolute',
          bottom: '86px',
          left: '16px',
          right: '16px',
          zIndex: 15,
          display: 'flex',
          flexDirection: 'column',
          gap: '6px',
        }}
      >
        {/* Identity Row + Clickable Full Profile Arrow */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '9px', minWidth: 0 }}>
            {/* Small Round Avatar */}
            <img
              src={photoList[0]}
              alt={profile.nickname}
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                objectFit: 'cover',
                border: '1.5px solid rgba(255, 255, 255, 0.35)',
                boxShadow: '0 2px 8px rgba(0, 0, 0, 0.6)',
                flexShrink: 0,
              }}
            />
            <div style={{ minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                <span
                  style={{
                    fontSize: '18.5px',
                    fontWeight: 800,
                    color: '#ffffff',
                    textShadow: '0 2px 8px rgba(0, 0, 0, 0.85)',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                    letterSpacing: '-0.3px',
                  }}
                >
                  {profile.nickname}
                </span>
                <span
                  style={{
                    fontSize: '16px',
                    fontWeight: 600,
                    color: '#cbd5e1',
                    textShadow: '0 2px 8px rgba(0, 0, 0, 0.85)',
                  }}
                >
                  {profile.age || 24}
                </span>
                {/* Official Blue Verification Tick Mark (checkmark badge) */}
                <div
                  title="Verified Profile"
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginLeft: '3px',
                    flexShrink: 0,
                  }}
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="10" fill="#0284c7" />
                    <path
                      d="M8 12.2L10.8 15L16 9"
                      stroke="#ffffff"
                      strokeWidth="2.4"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
              </div>
              <div
                style={{
                  fontSize: '12px',
                  color: '#94a3b8',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  textShadow: '0 1px 4px rgba(0, 0, 0, 0.9)',
                  marginTop: '1px',
                }}
              >
                <MapPin size={11} color="#38bdf8" />
                <span>
                  {profile.city} • {profile.distance_km} km away
                </span>
              </div>
            </div>
          </div>

          {/* Profile Details Arrow: Full horizontal right-arrow with center shaft line (→), no circular background or border */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onOpenFullProfile(profile);
            }}
            aria-label="View Full Profile"
            title="View Full Profile"
            style={{
              background: 'transparent',
              border: 'none',
              padding: '8px',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              flexShrink: 0,
              filter: 'drop-shadow(0 2px 6px rgba(0, 0, 0, 0.8))',
              transition: 'transform 0.18s ease',
            }}
            onMouseEnter={(e) => (e.currentTarget.style.transform = 'translateX(4px)')}
            onMouseLeave={(e) => (e.currentTarget.style.transform = 'translateX(0)')}
          >
            <ArrowRight size={24} color="#ffffff" strokeWidth={2.4} />
          </button>
        </div>

        {/* Short About / Bio */}
        {profile.bio && (
          <p
            onClick={(e) => {
              e.stopPropagation();
              onOpenFullProfile(profile);
            }}
            style={{
              fontSize: '11px',
              color: '#e2e8f0',
              margin: 0,
              lineHeight: 1.35,
              textShadow: '0 1px 4px rgba(0, 0, 0, 0.9)',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
              cursor: 'pointer',
            }}
          >
            {profile.bio}
          </p>
        )}

        {/* Shared Interests Tag Pills */}
        {profile.shared_interests && profile.shared_interests.length > 0 && (
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px', marginTop: '2px' }}>
            {profile.shared_interests.slice(0, 3).map((item, idx) => (
              <span
                key={idx}
                style={{
                  fontSize: '9.5px',
                  fontWeight: 600,
                  background: 'rgba(11, 13, 20, 0.65)',
                  backdropFilter: 'blur(6px)',
                  border: '1px solid rgba(255, 255, 255, 0.15)',
                  color: '#f8fafc',
                  padding: '2px 7px',
                  borderRadius: '999px',
                }}
              >
                {item}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export const DiscoveryDeck: React.FC<DiscoveryDeckProps> = ({
  profiles,
  onMutualMatch,
  onMegaCrush,
  onOpenFullProfile,
  onDirectMessage,
  onLoadMore,
  hasMore = true,
  isLoadingMore = false,
  onOpenStore,
}) => {
  // Feed of remaining unswiped profiles
  interface SwipedHistoryItem {
    profile: CandidateCard;
    direction: 'right' | 'left';
  }

  const [feed, setFeed] = useState<CandidateCard[]>(profiles);
  const [revertedStack, setRevertedStack] = useState<SwipedHistoryItem[]>([]);
  const [revertCountUsed, setRevertCountUsed] = useState<number>(0);
  const [showRevertPaywall, setShowRevertPaywall] = useState<boolean>(false);
  const [revertingCardId, setRevertingCardId] = useState<string | null>(null);
  const [revertDirection, setRevertDirection] = useState<'right' | 'left' | null>(null);
  const [optionsProfile, setOptionsProfile] = useState<CandidateCard | null>(null);
  const [copiedLink, setCopiedLink] = useState<boolean>(false);
  const [isReportingOpen, setIsReportingOpen] = useState<boolean>(false);

  // Active index tracking in the single scroll container
  const [activeProfileIndex, setActiveProfileIndex] = useState<number>(0);

  // Swiping state tracked per card ID
  const [swipedCards, setSwipedCards] = useState<Record<string, 'like' | 'pass' | 'mega_crush'>>({});
  const [dragCardId, setDragCardId] = useState<string | null>(null);
  const [dragOffset, setDragOffset] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const dragStartRef = useRef<{ x: number; y: number } | null>(null);

  // Mega crush celebration state
  const [glowingCardId, setGlowingCardId] = useState<string | null>(null);
  const [directMsgToast, setDirectMsgToast] = useState<string | null>(null);

  // Scroll Container Ref
  const feedContainerRef = useRef<HTMLDivElement>(null);

  // Deduplicate and update feed when incoming profiles change
  useEffect(() => {
    setFeed((prevFeed) => {
      if (prevFeed.length === 0) return profiles;
      const existingIds = new Set(prevFeed.map((p) => p.user_id));
      const newUnique = profiles.filter((p) => !existingIds.has(p.user_id));
      return newUnique.length > 0 ? [...prevFeed, ...newUnique] : prevFeed;
    });
  }, [profiles]);

  // Handle Swipe/Action on a profile
  const handleCardAction = useCallback(
    (cardId: string, action: 'like' | 'pass' | 'mega_crush') => {
      const targetProfile = feed.find((p) => p.user_id === cardId);
      if (!targetProfile) return;

      const exitDirection: 'right' | 'left' = action === 'pass' ? 'left' : 'right';

      // Mark animation
      setSwipedCards((prev) => ({ ...prev, [cardId]: action }));

      // Store in revert stack (up to 5 items)
      setRevertedStack((prev) => [
        ...prev.slice(-4),
        { profile: targetProfile, direction: exitDirection },
      ]);

      // Delayed removal from feed to allow smooth vertical roller exit
      setTimeout(() => {
        setFeed((prev) => prev.filter((p) => p.user_id !== cardId));
        setSwipedCards((prev) => {
          const updated = { ...prev };
          delete updated[cardId];
          return updated;
        });
      }, 280);

      // Trigger respective domain actions
      if (action === 'like') {
        const willMatch = Math.random() < 0.2; // 20% match probability
        if (willMatch) {
          onMutualMatch(targetProfile);
        }
      } else if (action === 'mega_crush') {
        onMegaCrush(targetProfile);
      }
    },
    [feed, onMutualMatch, onMegaCrush]
  );

  // Revert / Undo functionality ("As It Goes, As It Comes", max 5 free per day)
  const isRevertStackEmpty = revertedStack.length === 0;

  const handleRevert = () => {
    // MODULE 6 Item 2: Intercept and trigger "Buy Rubies" modal when limit is reached
    if (revertCountUsed >= 5) {
      setShowRevertPaywall(true);
      return;
    }
    if (isRevertStackEmpty) return;

    const lastItem = revertedStack[revertedStack.length - 1];
    setRevertedStack((prev) => prev.slice(0, -1));
    setRevertCountUsed((prev) => prev + 1);

    setRevertingCardId(lastItem.profile.user_id);
    setRevertDirection(lastItem.direction);

    // Prepend profile back to the top of feed
    setFeed((prev) => [lastItem.profile, ...prev]);

    // Scroll to top of feed to see reverted card
    if (feedContainerRef.current) {
      feedContainerRef.current.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Clear revert animation class after entrance completes
    setTimeout(() => {
      setRevertingCardId(null);
      setRevertDirection(null);
    }, 400);
  };

  // Mega Crush Trigger with Glow & Pop-up Animation
  const handleMegaCrushClick = (cardId: string) => {
    const targetProfile = feed.find((p) => p.user_id === cardId);
    if (!targetProfile) return;

    setGlowingCardId(cardId);
    setTimeout(() => {
      setGlowingCardId(null);
      handleCardAction(cardId, 'mega_crush');
    }, 250);
  };

  // Direct Message Icon click
  const handleDirectMessageClick = (profile: CandidateCard) => {
    if (onDirectMessage) {
      onDirectMessage(profile);
    } else {
      setDirectMsgToast(`Opening chat with ${profile.nickname}...`);
      setTimeout(() => setDirectMsgToast(null), 2000);
    }
  };

  // Drag Gesture Handlers: Smooth 360° pan gesture with release capture
  const handlePointerDown = (e: React.PointerEvent, cardId: string) => {
    if (e.button !== 0) return;
    try {
      (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    } catch {}
    dragStartRef.current = { x: e.clientX, y: e.clientY };
    setDragCardId(cardId);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!dragCardId || !dragStartRef.current) return;
    const dx = e.clientX - dragStartRef.current.x;
    const dy = e.clientY - dragStartRef.current.y;
    setDragOffset({ x: dx, y: dy });
  };

  const handlePointerUp = (e?: React.PointerEvent) => {
    if (e) {
      try {
        (e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId);
      } catch {}
    }
    if (dragCardId) {
      const threshold = 75;
      if (dragOffset.x > threshold) {
        // Swiped RIGHT -> LIKE 💚
        handleCardAction(dragCardId, 'like');
      } else if (dragOffset.x < -threshold) {
        // Swiped LEFT -> PASS ✕
        handleCardAction(dragCardId, 'pass');
      } else if (dragOffset.y < -90 && Math.abs(dragOffset.y) > Math.abs(dragOffset.x)) {
        // Swiped UP -> MEGA CRUSH 🔥
        handleCardAction(dragCardId, 'mega_crush');
      }
    }
    setDragCardId(null);
    setDragOffset({ x: 0, y: 0 });
    dragStartRef.current = null;
  };

  useEffect(() => {
    const handleGlobalPointerUp = () => {
      if (dragCardId) {
        handlePointerUp();
      }
    };
    window.addEventListener('pointerup', handleGlobalPointerUp);
    window.addEventListener('pointercancel', handleGlobalPointerUp);
    window.addEventListener('touchend', handleGlobalPointerUp);
    window.addEventListener('touchcancel', handleGlobalPointerUp);
    return () => {
      window.removeEventListener('pointerup', handleGlobalPointerUp);
      window.removeEventListener('pointercancel', handleGlobalPointerUp);
      window.removeEventListener('touchend', handleGlobalPointerUp);
      window.removeEventListener('touchcancel', handleGlobalPointerUp);
    };
  }, [dragCardId, dragOffset]);

  // Auto-paginate when remaining cards in deck are low
  useEffect(() => {
    if (feed.length < 4 && hasMore && !isLoadingMore && onLoadMore) {
      onLoadMore();
    }
  }, [feed.length, hasMore, isLoadingMore, onLoadMore]);

  const currentActiveProfile = feed[0];

  if (feed.length === 0) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          height: '100%',
          padding: '32px 20px',
          textAlign: 'center',
          color: '#f8fafc',
          background: '#111318',
        }}
      >
        <Sparkles size={40} color="#f43f5e" style={{ marginBottom: '14px' }} />
        <h3 style={{ fontSize: '18px', fontWeight: 800, color: '#f8fafc', margin: '0 0 6px' }}>
          You're All Caught Up
        </h3>
        <p style={{ fontSize: '12px', color: '#94a3b8', margin: '0 0 20px', maxWidth: '240px', lineHeight: 1.45 }}>
          You've explored all available profiles in your radius. Reshuffle to discover more connections.
        </p>
        <button
          type="button"
          onClick={() => {
            setFeed(profiles);
            setRevertCountUsed(0);
          }}
          style={{
            padding: '10px 22px',
            borderRadius: '999px',
            border: 'none',
            background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
            color: '#FFFFFF',
            fontSize: '12.5px',
            fontWeight: 700,
            cursor: 'pointer',
            boxShadow: '0 4px 14px rgba(244, 63, 94, 0.35)',
          }}
        >
          Reshuffle Feed
        </button>
      </div>
    );
  }

  return (
    <div
      style={{
        position: 'relative',
        width: '100%',
        height: '100%',
        overflow: 'hidden',
        background: '#111318',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* Toast Notice for Direct Message */}
      {directMsgToast && (
        <div
          style={{
            position: 'absolute',
            top: '16px',
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 60,
            background: '#222631',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            color: '#f8fafc',
            padding: '6px 14px',
            borderRadius: '999px',
            fontSize: '11px',
            fontWeight: 600,
            boxShadow: '0 4px 16px rgba(0, 0, 0, 0.5)',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            whiteSpace: 'nowrap',
          }}
        >
          <MessageCircle size={13} color="#f43f5e" />
          <span>{directMsgToast}</span>
        </div>
      )}

      {/* 1. LAYERED 3D CARD DECK CONTAINER ("one card back another back") */}
      <div
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          overflow: 'hidden',
          borderRadius: '24px',
        }}
      >
        {/* Render visible 3 cards in reverse order so feed[0] is rendered last (on top) */}
        {feed.slice(0, 3).map((profile, index) => {
          const stackIndex = index;
          const isDraggingCurrent = dragCardId === profile.user_id && stackIndex === 0;
          const currentOffset = isDraggingCurrent ? dragOffset : { x: 0, y: 0 };
          const swipedState = swipedCards[profile.user_id];
          const isGlowing = glowingCardId === profile.user_id;
          const cardRevertDir = revertingCardId === profile.user_id ? revertDirection : null;

          return (
            <FullBleedProfileItem
              key={profile.user_id}
              profile={profile}
              stackIndex={stackIndex}
              isActive={stackIndex === 0}
              isDraggingCurrent={isDraggingCurrent}
              currentOffset={currentOffset}
              parentDragOffset={dragOffset}
              swipedState={swipedState}
              revertDirection={cardRevertDir}
              isGlowing={isGlowing}
              onPointerDown={(e) => handlePointerDown(e, profile.user_id)}
              onPointerMove={handlePointerMove}
              onPointerUp={handlePointerUp}
              onOpenFullProfile={onOpenFullProfile}
            />
          );
        }).reverse()}
      </div>

      {/* 2. FIXED BOTTOM ACTION BAR (DOES NOT SCROLL WITH PROFILES) */}
      {currentActiveProfile && (
        <div
          style={{
            position: 'absolute',
            bottom: '12px',
            left: 0,
            right: 0,
            zIndex: 25,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '14px',
            padding: '4px 14px',
            pointerEvents: 'auto',
          }}
        >
          {/* 1. Revert with Paywall Intercept when limit is reached */}
          <button
            type="button"
            onClick={handleRevert}
            disabled={isRevertStackEmpty && revertCountUsed < 5}
            title={
              revertCountUsed >= 5
                ? '5/5 Reverts used today — Tap to refill with Rubies!'
                : isRevertStackEmpty
                ? 'No previous swipe to undo'
                : `Undo last swipe (${5 - revertCountUsed} left)`
            }
            aria-label="Undo last swipe"
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background:
                revertCountUsed >= 5
                  ? 'linear-gradient(135deg, rgba(244, 63, 94, 0.3), rgba(249, 115, 22, 0.25))'
                  : 'rgba(25, 28, 36, 0.88)',
              backdropFilter: 'blur(8px)',
              border:
                revertCountUsed >= 5
                  ? '1.5px solid rgba(244, 63, 94, 0.65)'
                  : '1px solid rgba(255, 255, 255, 0.12)',
              color: revertCountUsed >= 5 ? '#f43f5e' : '#cbd5e1',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: isRevertStackEmpty && revertCountUsed < 5 ? 'default' : 'pointer',
              opacity: isRevertStackEmpty && revertCountUsed < 5 ? 0.35 : 1,
              boxShadow:
                revertCountUsed >= 5
                  ? '0 0 14px rgba(244, 63, 94, 0.45)'
                  : '0 4px 12px rgba(0, 0, 0, 0.4)',
              transition: 'all 0.15s ease',
              position: 'relative',
            }}
          >
            <RotateCcw size={18} />
            {revertCountUsed >= 5 && (
              <span
                style={{
                  position: 'absolute',
                  top: '-4px',
                  right: '-4px',
                  background: '#f43f5e',
                  borderRadius: '50%',
                  width: '13px',
                  height: '13px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '8px',
                  color: '#ffffff',
                  boxShadow: '0 1px 4px rgba(0, 0, 0, 0.5)',
                }}
              >
                💎
              </span>
            )}
          </button>

          {/* 2. Reject X */}
          <button
            type="button"
            onClick={() => handleCardAction(currentActiveProfile.user_id, 'pass')}
            title="Reject / Pass Profile"
            aria-label="Pass profile"
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '50%',
              background: 'rgba(25, 28, 36, 0.92)',
              backdropFilter: 'blur(8px)',
              border: '1.5px solid rgba(239, 68, 68, 0.55)',
              color: '#ef4444',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 4px 16px rgba(239, 68, 68, 0.28)',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <X size={24} strokeWidth={2.4} />
          </button>

          {/* 3. Glowing Centerpiece Mega Crush */}
          <button
            type="button"
            onClick={() => handleMegaCrushClick(currentActiveProfile.user_id)}
            title="Mega Flash / Mega Crush"
            aria-label="Mega Flash"
            style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background:
                'radial-gradient(circle, rgba(239, 68, 68, 0.35) 0%, rgba(249, 115, 22, 0.25) 55%, rgba(25, 28, 36, 0.95) 100%)',
              backdropFilter: 'blur(8px)',
              border: '2px solid #ef4444',
              color: '#ef4444',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow:
                '0 0 24px rgba(239, 68, 68, 0.6), 0 0 12px rgba(249, 115, 22, 0.45)',
              transition: 'all 0.15s ease',
              position: 'relative',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <div
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Flame
                size={32}
                color="#f97316"
                fill="#f97316"
                style={{ filter: 'drop-shadow(0 0 6px #ef4444)' }}
              />
              <Sparkles
                size={13}
                color="#fbbf24"
                style={{
                  position: 'absolute',
                  top: '-2px',
                  right: '-4px',
                  filter: 'drop-shadow(0 0 4px #f59e0b)',
                }}
              />
              <Heart
                size={15}
                color="#ef4444"
                fill="#ef4444"
                style={{
                  position: 'absolute',
                  top: '9px',
                  filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.9))',
                }}
              />
            </div>
          </button>

          {/* 4. Green Heart Like */}
          <button
            type="button"
            onClick={() => handleCardAction(currentActiveProfile.user_id, 'like')}
            title="Like Profile"
            aria-label="Like profile"
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '50%',
              background: 'rgba(25, 28, 36, 0.92)',
              backdropFilter: 'blur(8px)',
              border: '2px solid #22c55e',
              color: '#22c55e',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 4px 16px rgba(34, 197, 94, 0.28)',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <Heart size={26} color="#22c55e" fill="#22c55e" />
          </button>

          {/* 5. Direct Message */}
          <button
            type="button"
            onClick={() => handleDirectMessageClick(currentActiveProfile)}
            title="Direct Message"
            aria-label="Direct message"
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: 'rgba(25, 28, 36, 0.88)',
              backdropFilter: 'blur(8px)',
              border: '1px solid rgba(255, 255, 255, 0.12)',
              color: '#94a3b8',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.4)',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <MessageCircle size={18} />
          </button>
        </div>
      )}

      {/* =================================================================== */}
      {/* MODULE 6 ITEM 2: BUY RUBIES REVERT LIMIT PAYWALL BOTTOM-SHEET MODAL */}
      {/* =================================================================== */}
      {showRevertPaywall && (
        <div
          onClick={() => setShowRevertPaywall(false)}
          style={{
            position: 'absolute',
            inset: 0,
            background: 'rgba(6, 8, 14, 0.8)',
            backdropFilter: 'blur(10px)',
            WebkitBackdropFilter: 'blur(10px)',
            zIndex: 100,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end',
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              background: '#191c24',
              borderTopLeftRadius: '24px',
              borderTopRightRadius: '24px',
              borderTop: '2px solid rgba(244, 63, 94, 0.4)',
              padding: '20px 18px 24px',
              boxShadow: '0 -8px 32px rgba(0, 0, 0, 0.65)',
              display: 'flex',
              flexDirection: 'column',
              gap: '14px',
            }}
          >
            {/* Modal Header */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <div
                  style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '12px',
                    background: 'linear-gradient(135deg, #f43f5e, #fb7185)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#ffffff',
                    boxShadow: '0 4px 12px rgba(244, 63, 94, 0.4)',
                  }}
                >
                  <RotateCcw size={18} />
                </div>
                <div>
                  <h3 style={{ fontSize: '16px', fontWeight: 800, margin: 0, color: '#ffffff' }}>
                    Buy Rubies / Unlock Unlimited Reverts 💎
                  </h3>
                  <span style={{ fontSize: '11px', color: '#fb7185', fontWeight: 600 }}>
                    5/5 Daily Free Rewinds Used
                  </span>
                </div>
              </div>

              <button
                type="button"
                onClick={() => setShowRevertPaywall(false)}
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: 'none',
                  borderRadius: '50%',
                  width: '28px',
                  height: '28px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#94a3b8',
                  cursor: 'pointer',
                }}
              >
                <X size={16} />
              </button>
            </div>

            <p style={{ fontSize: '12px', color: '#cbd5e1', margin: 0, lineHeight: 1.4 }}>
              Get Rubies to rewind unlimited profiles, undo accidental passes, and never miss a match!
            </p>

            {/* Purchasable Ruby Coin Packs */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {[
                { name: 'Starter Refill', rubies: 100, price: '₹99', tag: '+5 Instant Reverts' },
                { name: 'Popular Flame', rubies: 500, price: '₹399', tag: 'Most Popular • +25 Reverts', popular: true },
                { name: 'VIP Inferno', rubies: 1200, price: '₹799', tag: 'Unlimited Rewinds 💎' },
              ].map((pack, pIdx) => (
                <div
                  key={pIdx}
                  onClick={() => {
                    setRevertCountUsed(0);
                    setShowRevertPaywall(false);
                    try {
                      confetti({
                        particleCount: 50,
                        spread: 60,
                        origin: { y: 0.6 },
                        colors: ['#f43f5e', '#ffd700', '#22c55e'],
                      });
                    } catch {}
                  }}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '10px 14px',
                    borderRadius: '14px',
                    background: pack.popular
                      ? 'linear-gradient(135deg, rgba(244, 63, 94, 0.18), rgba(225, 29, 72, 0.1))'
                      : 'rgba(255, 255, 255, 0.04)',
                    border: pack.popular
                      ? '1.5px solid rgba(244, 63, 94, 0.5)'
                      : '1px solid rgba(255, 255, 255, 0.08)',
                    cursor: 'pointer',
                    transition: 'all 0.18s ease',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div
                      style={{
                        width: '32px',
                        height: '32px',
                        borderRadius: '10px',
                        background: 'rgba(244, 63, 94, 0.2)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: '#f43f5e',
                      }}
                    >
                      <Gem size={17} />
                    </div>
                    <div>
                      <div style={{ fontSize: '13px', fontWeight: 800, color: '#ffffff' }}>
                        {pack.rubies} Rubies
                      </div>
                      <div style={{ fontSize: '10.5px', color: '#fb7185', fontWeight: 600 }}>
                        {pack.tag}
                      </div>
                    </div>
                  </div>

                  <div
                    style={{
                      padding: '6px 14px',
                      borderRadius: '999px',
                      background: pack.popular
                        ? 'linear-gradient(135deg, #f43f5e, #e11d48)'
                        : 'rgba(255, 255, 255, 0.08)',
                      color: '#ffffff',
                      fontSize: '12px',
                      fontWeight: 800,
                    }}
                  >
                    {pack.price}
                  </div>
                </div>
              ))}
            </div>

            {onOpenStore && (
              <button
                type="button"
                onClick={() => {
                  setShowRevertPaywall(false);
                  onOpenStore();
                }}
                style={{
                  width: '100%',
                  padding: '10px 0',
                  borderRadius: '12px',
                  background: 'transparent',
                  border: '1px solid rgba(255, 255, 255, 0.12)',
                  color: '#94a3b8',
                  fontSize: '11.5px',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                View All Coin & Ruby Store Packs →
              </button>
            )}
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* 3-DOT MENU: PROFILE SAFETY, BLOCK, REPORT & SHARE OPTIONS SHEET    */}
      {/* =================================================================== */}
      {optionsProfile && (
        <div
          onClick={() => {
            setOptionsProfile(null);
            setCopiedLink(false);
            setIsReportingOpen(false);
          }}
          style={{
            position: 'absolute',
            inset: 0,
            background: 'rgba(7, 9, 15, 0.75)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            zIndex: 110,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end',
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              background: '#191c24',
              borderTopLeftRadius: '24px',
              borderTopRightRadius: '24px',
              borderTop: '1px solid rgba(255, 255, 255, 0.12)',
              padding: '18px 16px 24px',
              boxShadow: '0 -10px 36px rgba(0, 0, 0, 0.75)',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
            }}
          >
            {/* Header with profile mini info */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: '8px', borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <img
                  src={optionsProfile.photo_urls?.[0] || '/ananya.jpg'}
                  alt={optionsProfile.nickname}
                  style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    objectFit: 'cover',
                    border: '1.5px solid rgba(255, 255, 255, 0.2)',
                  }}
                />
                <div>
                  <div style={{ fontSize: '15px', fontWeight: 800, color: '#f8fafc' }}>
                    {optionsProfile.nickname}, {optionsProfile.age || 24}
                  </div>
                  <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                    {optionsProfile.city}
                  </div>
                </div>
              </div>

              <button
                type="button"
                onClick={() => {
                  setOptionsProfile(null);
                  setCopiedLink(false);
                  setIsReportingOpen(false);
                }}
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: 'none',
                  borderRadius: '50%',
                  width: '28px',
                  height: '28px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#94a3b8',
                  cursor: 'pointer',
                }}
              >
                <X size={16} />
              </button>
            </div>

            {/* Actions List or Report Categories View */}
            {isReportingOpen ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '4px' }}>
                  <span style={{ fontSize: '13px', fontWeight: 800, color: '#f8fafc' }}>
                    Select a reason to report
                  </span>
                  <button
                    type="button"
                    onClick={() => setIsReportingOpen(false)}
                    style={{
                      background: 'transparent',
                      border: 'none',
                      color: '#38bdf8',
                      fontSize: '11.5px',
                      fontWeight: 700,
                      cursor: 'pointer',
                    }}
                  >
                    Back
                  </button>
                </div>

                {['Fake Account', 'Inappropriate Content', 'Harassment'].map((category) => (
                  <button
                    key={category}
                    type="button"
                    onClick={() => {
                      const name = optionsProfile.nickname;
                      setOptionsProfile(null);
                      setIsReportingOpen(false);
                      setDirectMsgToast(`Report for ${name} (${category}) submitted. Our safety team will review.`);
                      setTimeout(() => setDirectMsgToast(null), 3200);
                    }}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '12px 14px',
                      borderRadius: '12px',
                      background: 'rgba(239, 68, 68, 0.08)',
                      border: '1px solid rgba(239, 68, 68, 0.22)',
                      color: '#fca5a5',
                      fontSize: '13px',
                      fontWeight: 700,
                      cursor: 'pointer',
                      textAlign: 'left',
                    }}
                  >
                    <span>{category}</span>
                    <Flag size={15} color="#ef4444" />
                  </button>
                ))}
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                {/* 1. Report Profile */}
                <button
                  type="button"
                  onClick={() => setIsReportingOpen(true)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '12px',
                    background: 'rgba(239, 68, 68, 0.08)',
                    border: '1px solid rgba(239, 68, 68, 0.2)',
                    color: '#fca5a5',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    textAlign: 'left',
                  }}
                >
                  <Flag size={17} color="#ef4444" />
                  <span>Report Profile</span>
                </button>

                {/* 2. Block User */}
                <button
                  type="button"
                  onClick={() => {
                    const targetId = optionsProfile.user_id;
                    const name = optionsProfile.nickname;
                    setFeed((prev) => prev.filter((p) => p.user_id !== targetId));
                    setOptionsProfile(null);
                    setDirectMsgToast(`Blocked ${name}. You will no longer see this profile.`);
                    setTimeout(() => setDirectMsgToast(null), 3000);
                  }}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '12px',
                    background: 'rgba(239, 68, 68, 0.08)',
                    border: '1px solid rgba(239, 68, 68, 0.2)',
                    color: '#fca5a5',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    textAlign: 'left',
                  }}
                >
                  <UserX size={17} color="#ef4444" />
                  <span>Block {optionsProfile.nickname}</span>
                </button>

                {/* 3. Share Profile */}
                <button
                  type="button"
                  onClick={() => {
                    setCopiedLink(true);
                    if (navigator.clipboard) {
                      navigator.clipboard.writeText(`https://younme.app/u/${optionsProfile.user_id}`);
                    }
                    setTimeout(() => setCopiedLink(false), 2200);
                  }}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.04)',
                    border: '1px solid rgba(255, 255, 255, 0.06)',
                    color: '#f8fafc',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    textAlign: 'left',
                  }}
                >
                  {copiedLink ? <Check size={17} color="#22c55e" /> : <Share2 size={17} color="#cbd5e1" />}
                  <span>{copiedLink ? 'Profile Link Copied!' : 'Share Profile'}</span>
                </button>

                {/* 4. View Complete Profile */}
                <button
                  type="button"
                  onClick={() => {
                    const p = optionsProfile;
                    setOptionsProfile(null);
                    onOpenFullProfile(p);
                  }}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.04)',
                    border: '1px solid rgba(255, 255, 255, 0.06)',
                    color: '#f8fafc',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    textAlign: 'left',
                  }}
                >
                  <ArrowRight size={17} color="#38bdf8" />
                  <span>View Complete Profile</span>
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
