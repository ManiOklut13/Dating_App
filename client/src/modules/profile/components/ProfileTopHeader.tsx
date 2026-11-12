import React from 'react';
import { ArrowLeft, Coins, Sparkles, Settings } from 'lucide-react';
import { useProfile } from '../ProfileContext';
import { useSettings } from '../../settings/SettingsContext';

interface ProfileTopHeaderProps {
  onOpenStore?: () => void;
  onOpenWheel?: () => void;
  onBack?: () => void;
}

export const ProfileTopHeader: React.FC<ProfileTopHeaderProps> = ({ onOpenStore, onOpenWheel, onBack }) => {
  const { profile } = useProfile();
  const { navigate } = useSettings();

  const primaryAvatar = profile.photos[0]?.url || '/aditya.jpg';

  return (
    <header
      className="profile-top-header"
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '10px 14px',
        background: 'linear-gradient(90deg, rgba(11,8,14,0.98) 0%, rgba(18,13,23,0.98) 100%)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        borderBottom: '1px solid #262030',
        position: 'sticky',
        top: 0,
        zIndex: 30,
        width: '100%',
        boxSizing: 'border-box',
      }}
    >
      {/* Top Left: Back arrow + User profile avatar + Title */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          minWidth: 0,
          flex: '1 1 auto',
        }}
      >
        {/* Back Button */}
        <button
          type="button"
          onClick={() => {
            if (onBack) {
              onBack();
            } else if (window.history.length > 1) {
              window.history.back();
            }
          }}
          aria-label="Back"
          title="Back"
          style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: '#1a141f',
            border: '1px solid #2a2030',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            flexShrink: 0,
            transition: 'all var(--transition-fast)',
            padding: 0,
          }}
        >
          <ArrowLeft size={18} />
        </button>

        {/* User Profile Avatar in top-left */}
        <div
          style={{
            position: 'relative',
            width: '38px',
            height: '38px',
            borderRadius: '50%',
            flexShrink: 0,
            padding: '2px',
            background: 'linear-gradient(135deg, #ff4d7e 0%, #a855f7 50%, #22d3ee 100%)',
            boxSizing: 'border-box',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <img
            src={primaryAvatar}
            alt={profile.nickname}
            style={{
              width: '100%',
              height: '100%',
              borderRadius: '50%',
              objectFit: 'cover',
              display: 'block',
              background: '#0b080e',
            }}
          />
          <div
            style={{
              position: 'absolute',
              bottom: '-1px',
              right: '-1px',
              width: '11px',
              height: '11px',
              borderRadius: '50%',
              background: '#2ed47a',
              border: '2px solid #0b080e',
              boxSizing: 'border-box',
            }}
          />
        </div>

        {/* Title and location subtitle */}
        <div style={{ minWidth: 0, overflow: 'hidden' }}>
          <h1
            style={{
              fontSize: '18px',
              fontWeight: 800,
              letterSpacing: '-0.4px',
              margin: 0,
              color: '#ffffff',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            My Profile
          </h1>
          <p
            style={{
              fontSize: '11px',
              color: 'rgba(255,255,255,0.6)',
              margin: '1px 0 0 0',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {profile.nickname} · {profile.location}
          </p>
        </div>
      </div>

      {/* Top Right: VIP, Coins and ONLY the single Settings Icon */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '6px',
          flexShrink: 0,
        }}
      >
        {/* VIP Shortcut */}
        <button
          type="button"
          onClick={onOpenWheel}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            padding: '6px 10px',
            borderRadius: '999px',
            background: 'rgba(255, 210, 74, 0.12)',
            border: '1px solid rgba(255, 210, 74, 0.5)',
            color: '#ffd24a',
            fontSize: '11.5px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
          title="Daily Streak & Spin Wheel"
        >
          <Sparkles size={13} />
          <span>VIP</span>
        </button>

        {/* Coins Balance Pill */}
        <button
          type="button"
          onClick={onOpenStore}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            padding: '6px 10px',
            borderRadius: '999px',
            background: 'rgba(255, 215, 0, 0.1)',
            border: '1px solid rgba(255, 215, 0, 0.5)',
            color: '#ffd24a',
            fontSize: '11.5px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
          title="Coins Store"
        >
          <Coins size={13} />
          <span>{profile.coinsBalance}</span>
          <span
            style={{
              background: '#ffd24a',
              color: '#000',
              borderRadius: '50%',
              width: '14px',
              height: '14px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '10px',
              fontWeight: 'bold',
            }}
          >
            +
          </span>
        </button>

        {/* Settings Icon */}
        <button
          type="button"
          onClick={() => navigate('settings')}
          aria-label="Settings"
          title="Settings"
          style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: '#1a141f',
            border: '1px solid #2a2030',
            color: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            transition: 'all var(--transition-fast)',
            flexShrink: 0,
            padding: 0,
          }}
        >
          <Settings size={18} />
        </button>
      </div>
    </header>
  );
};
