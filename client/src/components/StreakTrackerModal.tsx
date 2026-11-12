import React, { useState } from 'react';
import { X, Flame, CheckCircle2, Sparkles, Gem } from 'lucide-react';
import confetti from 'canvas-confetti';

interface StreakTrackerModalProps {
  isOpen: boolean;
  onClose: () => void;
  streakDays: number;
  rubyBalance?: number;
  onCoinsAwarded?: (newBalance: number) => void;
}

export const StreakTrackerModal: React.FC<StreakTrackerModalProps> = ({
  isOpen,
  onClose,
  streakDays = 5,
  rubyBalance = 250,
  onCoinsAwarded,
}) => {
  const [hasClaimed, setHasClaimed] = useState(false);
  const rewardAmount = Math.max(20, streakDays * 10);

  if (!isOpen) return null;

  const handleClaimReward = () => {
    if (hasClaimed) return;
    setHasClaimed(true);
    const newBal = rubyBalance + rewardAmount;
    onCoinsAwarded?.(newBal);

    try {
      confetti({
        particleCount: 45,
        spread: 55,
        origin: { y: 0.55 },
        colors: ['#f43f5e', '#fb7185', '#ffd700'],
      });
    } catch {}
  };

  return (
    <div
      onClick={onClose}
      style={{
        position: 'absolute',
        inset: 0,
        background: 'rgba(6, 8, 14, 0.72)',
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)',
        zIndex: 130,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '14px',
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          width: '100%',
          maxWidth: '280px',
          borderRadius: '20px',
          background: 'rgba(18, 21, 30, 0.95)',
          backdropFilter: 'blur(16px)',
          WebkitBackdropFilter: 'blur(16px)',
          border: '1px solid rgba(244, 63, 94, 0.3)',
          padding: '16px 14px',
          textAlign: 'center',
          boxShadow: '0 12px 32px rgba(0, 0, 0, 0.65), 0 0 16px rgba(244, 63, 94, 0.12)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          position: 'relative',
        }}
      >
        {/* Top-Right Dismiss Button */}
        <button
          type="button"
          onClick={onClose}
          aria-label="Close modal"
          title="Close"
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            width: '26px',
            height: '26px',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.08)',
            border: '1px solid rgba(255, 255, 255, 0.12)',
            color: '#94a3b8',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            transition: 'all 0.18s ease',
            zIndex: 10,
          }}
        >
          <X size={14} />
        </button>

        {/* Moving Tasteful Flame Animation Encased */}
        <div
          className="streak-flame-active"
          style={{
            width: '38px',
            height: '38px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '4px',
          }}
        >
          <Flame size={32} color="#f97316" fill="#f97316" />
        </div>

        <h3
          style={{
            fontSize: '16px',
            fontWeight: 800,
            margin: '0 0 2px',
            color: '#ffffff',
            letterSpacing: '-0.3px',
          }}
        >
          Day {streakDays} Streak! 🔥
        </h3>

        <p
          style={{
            fontSize: '11px',
            color: '#94a3b8',
            margin: '0 0 12px',
            lineHeight: 1.3,
          }}
        >
          Keep logging in daily to claim free Rubies!
        </p>

        {/* 7-Day Weekly Streak Display (All 7 days simultaneously) */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(7, 1fr)',
            gap: '4px',
            width: '100%',
            marginBottom: '14px',
          }}
        >
          {[1, 2, 3, 4, 5, 6, 7].map((day) => {
            const isPast = day < streakDays;
            const isCurrent = day === streakDays;

            return (
              <div
                key={day}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '3px',
                }}
              >
                {/* Day Label */}
                <span
                  style={{
                    fontSize: '8.5px',
                    color: isCurrent ? '#f43f5e' : '#64748b',
                    fontWeight: 700,
                  }}
                >
                  D{day}
                </span>

                {/* Numbered Circle (1-7) */}
                <div
                  className={isCurrent ? 'streak-flame-active' : undefined}
                  style={{
                    width: '30px',
                    height: '30px',
                    borderRadius: '50%',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '11px',
                    fontWeight: 800,
                    color: '#ffffff',
                    position: 'relative',
                    background: isCurrent
                      ? 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)'
                      : isPast
                      ? 'rgba(244, 63, 94, 0.22)'
                      : 'rgba(255, 255, 255, 0.04)',
                    border: isCurrent
                      ? '1.5px solid #ffd700'
                      : isPast
                      ? '1px solid rgba(244, 63, 94, 0.45)'
                      : '1px solid rgba(255, 255, 255, 0.08)',
                    boxShadow: isCurrent ? '0 2px 8px rgba(244, 63, 94, 0.35)' : 'none',
                  }}
                >
                  {isPast ? (
                    <CheckCircle2 size={13} color="#f43f5e" />
                  ) : isCurrent ? (
                    <span>{day}</span>
                  ) : (
                    <span style={{ color: '#64748b' }}>{day}</span>
                  )}
                </div>

                {/* Reward Indicator */}
                <span
                  style={{
                    fontSize: '8px',
                    color: isCurrent ? '#ffd700' : isPast ? '#94a3b8' : '#475569',
                    fontWeight: 700,
                  }}
                >
                  +{day * 10}💎
                </span>
              </div>
            );
          })}
        </div>

        {/* Claim Reward Action */}
        {hasClaimed ? (
          <div
            style={{
              width: '100%',
              padding: '8px 12px',
              borderRadius: '12px',
              background: 'rgba(34, 197, 94, 0.15)',
              border: '1px solid rgba(34, 197, 94, 0.35)',
              color: '#4ade80',
              fontSize: '11.5px',
              fontWeight: 800,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <CheckCircle2 size={14} />
            <span>+{rewardAmount} Rubies Credited!</span>
          </div>
        ) : (
          <button
            type="button"
            onClick={handleClaimReward}
            style={{
              width: '100%',
              height: '38px',
              borderRadius: '12px',
              border: 'none',
              background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
              color: '#ffffff',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              boxShadow: '0 3px 12px rgba(244, 63, 94, 0.35)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
              transition: 'all 0.18s ease',
            }}
          >
            <Gem size={14} color="#ffd700" />
            <span>Claim Day {streakDays} Bonus (+{rewardAmount} Rubies)</span>
          </button>
        )}
      </div>
    </div>
  );
};
