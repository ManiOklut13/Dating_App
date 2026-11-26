import React, { useEffect } from 'react';
import { Heart, Sparkles, Flame, Zap } from 'lucide-react';
import confetti from 'canvas-confetti';
import { CandidateCard } from '../types';

interface MegaCrushCelebrationProps {
  isOpen: boolean;
  profile: CandidateCard | null;
  onClose: () => void;
}

export const MegaCrushCelebration: React.FC<MegaCrushCelebrationProps> = ({
  isOpen,
  profile,
  onClose,
}) => {
  useEffect(() => {
    if (isOpen) {
      // 1. Haptic feedback trigger (MODULE 5 Item 3)
      if (typeof window !== 'undefined' && 'navigator' in window && window.navigator.vibrate) {
        try {
          window.navigator.vibrate([40, 60, 120]);
        } catch {}
      }

      // 2. High-impact particle burst with multi-stage cannon blast
      // Stage 1: Central explosion
      confetti({
        particleCount: 80,
        spread: 90,
        origin: { y: 0.5 },
        colors: ['#f43f5e', '#ff8da1', '#ffd700', '#ffffff', '#a855f7'],
        scalar: 1.2,
      });

      // Stage 2: Left and right perimeter bursts after 120ms
      const t1 = setTimeout(() => {
        confetti({
          particleCount: 45,
          angle: 60,
          spread: 55,
          origin: { x: 0.1, y: 0.6 },
          colors: ['#f43f5e', '#ffd700'],
        });
        confetti({
          particleCount: 45,
          angle: 120,
          spread: 55,
          origin: { x: 0.9, y: 0.6 },
          colors: ['#ff8da1', '#ffffff'],
        });
      }, 120);

      // Auto-dismiss after celebration
      const timer = setTimeout(() => {
        onClose();
      }, 1500);

      return () => {
        clearTimeout(t1);
        clearTimeout(timer);
      };
    }
  }, [isOpen, onClose]);

  if (!isOpen || !profile) return null;

  return (
    <div
      onClick={onClose}
      style={{
        position: 'absolute',
        inset: 0,
        background: 'rgba(6, 8, 14, 0.82)',
        backdropFilter: 'blur(12px)',
        WebkitBackdropFilter: 'blur(12px)',
        zIndex: 120,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        cursor: 'pointer',
      }}
    >
      {/* Expanding shockwave halo animation behind central badge */}
      <div
        style={{
          position: 'absolute',
          width: '260px',
          height: '260px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(244, 63, 94, 0.45) 0%, rgba(255, 215, 0, 0.25) 50%, transparent 75%)',
          animation: 'shockwavePulse 1.2s cubic-bezier(0.16, 1, 0.3, 1) infinite',
          pointerEvents: 'none',
        }}
      />

      {/* Central Scale-up Badge Container with Spring Physics */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          textAlign: 'center',
          padding: '24px 28px',
          borderRadius: '28px',
          background: 'linear-gradient(145deg, rgba(32, 12, 24, 0.95) 0%, rgba(18, 12, 22, 0.98) 100%)',
          border: '2px solid rgba(244, 63, 94, 0.6)',
          boxShadow: '0 16px 50px rgba(244, 63, 94, 0.45), 0 0 35px rgba(255, 215, 0, 0.35)',
          maxWidth: '280px',
          position: 'relative',
          animation: 'scaleUpBadge 0.45s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards',
        }}
      >
        {/* Glowing Badge Crown */}
        <div
          style={{
            width: '68px',
            height: '68px',
            borderRadius: '22px',
            background: 'linear-gradient(135deg, #f43f5e 0%, #ffd700 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#ffffff',
            boxShadow: '0 6px 20px rgba(244, 63, 94, 0.6)',
            marginBottom: '12px',
            position: 'relative',
          }}
        >
          <Heart size={36} fill="#ffffff" color="#ffffff" strokeWidth={1.5} />
          <div
            style={{
              position: 'absolute',
              top: '-6px',
              right: '-6px',
              background: '#ffd700',
              borderRadius: '50%',
              width: '22px',
              height: '22px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 2px 6px rgba(0, 0, 0, 0.4)',
            }}
          >
            <Zap size={13} fill="#000000" color="#000000" />
          </div>
        </div>

        <h3
          style={{
            fontSize: '20px',
            fontWeight: 900,
            margin: '0 0 4px',
            color: '#ffffff',
            letterSpacing: '-0.3px',
            textShadow: '0 2px 10px rgba(244, 63, 94, 0.5)',
          }}
        >
          MEGA CRUSH! 💖⚡
        </h3>

        <p style={{ fontSize: '12px', color: '#ffd700', margin: '0 0 8px', fontWeight: 800 }}>
          High-Priority Match Dispatched
        </p>

        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            padding: '4px 12px',
            borderRadius: '999px',
            background: 'rgba(255, 255, 255, 0.08)',
            border: '1px solid rgba(255, 255, 255, 0.15)',
            fontSize: '11.5px',
            fontWeight: 700,
            color: '#ffffff',
          }}
        >
          <span>Sent to {profile.nickname}</span>
          <Sparkles size={12} color="#ffd700" />
        </div>
      </div>

      <style>{`
        @keyframes scaleUpBadge {
          0% {
            transform: scale(0.2) rotate(-8deg);
            opacity: 0;
          }
          70% {
            transform: scale(1.15) rotate(2deg);
            opacity: 1;
          }
          100% {
            transform: scale(1) rotate(0deg);
            opacity: 1;
          }
        }
        @keyframes shockwavePulse {
          0% {
            transform: scale(0.6);
            opacity: 0.8;
          }
          100% {
            transform: scale(1.6);
            opacity: 0;
          }
        }
      `}</style>
    </div>
  );
};
