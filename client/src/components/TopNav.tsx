import React from 'react';
import { Flame, Bell, Gem } from 'lucide-react';

interface TopNavProps {
  rubyBalance?: number;
  coinBalance?: number; // fallback support
  streakDays: number;
  onOpenRubies?: () => void;
  onOpenStore?: () => void; // backwards compat
  onOpenStreak?: () => void;
  onOpenWheel?: () => void; // backwards compat
  onOpenNotifications?: () => void;
  onLogoClick?: () => void;
}

export const TopNav: React.FC<TopNavProps> = ({
  rubyBalance,
  coinBalance = 250,
  streakDays,
  onOpenRubies,
  onOpenStore,
  onOpenStreak,
  onOpenWheel,
  onOpenNotifications,
  onLogoClick,
}) => {
  const currentRubies = rubyBalance !== undefined ? rubyBalance : coinBalance;
  const handleRubiesClick = onOpenRubies || onOpenStore || (() => {});
  const handleStreakClick = onOpenStreak || onOpenWheel || (() => {});

  return (
    <header
      style={{
        position: 'sticky',
        top: 0,
        zIndex: 40,
        width: '100%',
        backgroundColor: '#111318',
        borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
        padding: '10px 14px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        boxSizing: 'border-box',
      }}
    >
      {/* Left Side: Clean YoUnMe App Icon and App Name */}
      <div
        onClick={onLogoClick}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          cursor: onLogoClick ? 'pointer' : 'default',
          userSelect: 'none',
        }}
      >
        <img
          src="/younme-logo.png"
          alt="YoUnMe App Icon"
          style={{
            width: '32px',
            height: '32px',
            borderRadius: '9px',
            objectFit: 'cover',
            boxShadow: '0 2px 10px rgba(255, 77, 136, 0.45)',
            border: '1px solid rgba(255, 141, 161, 0.3)',
            display: 'block',
          }}
        />
        <span
          style={{
            fontSize: '18px',
            fontWeight: 800,
            letterSpacing: '-0.3px',
            color: '#f8fafc',
          }}
        >
          YoUnMe
        </span>
      </div>

      {/* Right Side: Exactly 3 small, clean icons in exact order:
          1. Rubies Icon + Count
          2. Daily Streak Icon + Count (in the middle)
          3. Notifications Icon */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
        {/* 1. Rubies Icon + Count */}
        <button
          type="button"
          onClick={handleRubiesClick}
          title="YoUnMe Rubies Balance & Store"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            padding: '5px 10px',
            borderRadius: '999px',
            background: '#191c24',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            color: '#f8fafc',
            cursor: 'pointer',
            transition: 'all 0.15s ease',
          }}
        >
          <Gem size={13} color="#f43f5e" />
          <span style={{ fontSize: '12px', fontWeight: 700, color: '#f8fafc' }}>
            {currentRubies}
          </span>
        </button>

        {/* 2. Daily Streak Badge: Clean fire symbol with clearly visible, legible numeric count */}
        <button
          type="button"
          onClick={handleStreakClick}
          title={`Daily Login Streak: Day ${streakDays}`}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            padding: '5px 10px',
            borderRadius: '999px',
            background: 'rgba(25, 28, 36, 0.95)',
            border: '1.5px solid rgba(249, 115, 22, 0.5)',
            color: '#f8fafc',
            cursor: 'pointer',
            boxShadow: '0 2px 10px rgba(249, 115, 22, 0.25)',
            transition: 'all 0.15s ease',
          }}
        >
          {/* Clean Fire/Streak Symbol */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: '18px',
              height: '18px',
              filter: 'drop-shadow(0 2px 4px rgba(249, 115, 22, 0.6))',
            }}
          >
            <Flame size={17} color="#f97316" fill="#f97316" strokeWidth={1.5} />
          </div>
          {/* Numeric Daily Streak Count (Clearly visible, properly aligned, crisp and legible) */}
          <span
            style={{
              fontSize: '13.5px',
              fontWeight: 800,
              color: '#ffffff',
              letterSpacing: '0.2px',
              lineHeight: 1,
            }}
          >
            {streakDays}
          </span>
        </button>

        {/* 3. Notifications Icon (Right) */}
        <button
          type="button"
          onClick={onOpenNotifications}
          title="Notifications & Activity"
          style={{
            width: '32px',
            height: '32px',
            borderRadius: '999px',
            background: '#191c24',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            color: '#94a3b8',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            position: 'relative',
            transition: 'all 0.15s ease',
          }}
        >
          <Bell size={15} color="#94a3b8" />
          {/* Subtle unread dot */}
          <span
            style={{
              position: 'absolute',
              top: '6px',
              right: '6px',
              width: '6px',
              height: '6px',
              borderRadius: '50%',
              background: '#f43f5e',
            }}
          />
        </button>
      </div>
    </header>
  );
};
