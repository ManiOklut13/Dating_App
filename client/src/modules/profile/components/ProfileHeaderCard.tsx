import React from 'react';
import { MapPin, ShieldCheck, Edit3, Heart } from 'lucide-react';
import { useProfile } from '../ProfileContext';
import { PresenceLabel } from '../../presence/PresenceDot';
import { CURRENT_USER_ID } from '../../presence/PresenceContext';

interface ProfileHeaderCardProps {
  onOpenMatches?: () => void;
}

export const ProfileHeaderCard: React.FC<ProfileHeaderCardProps> = ({ onOpenMatches }) => {
  const {
    profile,
    calculatedAge,
    setIsEditProfileOpen,
  } = useProfile();

  const primaryPhoto = profile.photos.find((p) => p.isPrimary) || profile.photos[0] || {
    url: '/aditya.jpg',
  };

  const isVerified = profile.verification.status === 'verified';

  return (
    <div
      style={{
        borderRadius: '22px',
        padding: '0 16px 16px',
        position: 'relative',
        overflow: 'hidden',
        border: '1px solid #262030',
        background: 'linear-gradient(180deg, #18121e 0%, #120d17 100%)',
        boxShadow: '0 10px 40px rgba(0,0,0,0.4)',
      }}
    >
      {/* Background gradient banner */}
      <div
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '90px',
          background: 'linear-gradient(90deg, #ff4d7e 0%, #a855f7 50%, #22d3ee 100%)',
          opacity: 0.9,
          filter: 'blur(0px)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          top: '60px',
          left: 0,
          right: 0,
          height: '60px',
          background: 'linear-gradient(180deg, transparent 0%, #18121e 100%)',
        }}
      />

      <div style={{ position: 'relative', zIndex: 1, marginTop: '40px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {/* Avatar */}
          <div style={{ position: 'relative', width: '104px', height: '104px', flexShrink: 0 }}>
            <div
              style={{
                width: '100%',
                height: '100%',
                borderRadius: '50%',
                padding: '3px',
                background: 'linear-gradient(135deg, #ff4d7e 0%, #a855f7 50%, #22d3ee 100%)',
                boxSizing: 'border-box',
              }}
            >
              <img
                src={primaryPhoto.url}
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
            </div>
          </div>

          {/* Identity */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
              <h2 style={{ fontSize: '25px', fontWeight: 800, letterSpacing: '-0.5px', color: '#ffffff' }}>
                {profile.nickname}, {calculatedAge}
              </h2>
              {isVerified ? (
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    fontSize: '11px',
                    background: 'rgba(79, 168, 255, 0.18)',
                    color: '#4fa8ff',
                    padding: '3px 10px',
                    borderRadius: '999px',
                    fontWeight: 700,
                    border: '1px solid rgba(79, 168, 255, 0.5)',
                  }}
                >
                  <ShieldCheck size={12} />
                  Verified
                </span>
              ) : null}
              {profile?.privacy?.showOnlineStatus && (
                <PresenceLabel userId={CURRENT_USER_ID} isSelf />
              )}
            </div>

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                marginTop: '6px',
                fontSize: '13px',
                color: 'rgba(255,255,255,0.7)',
                flexWrap: 'wrap',
              }}
            >
              <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <MapPin size={14} color="#ff4d7e" />
                {profile.location}
              </span>
              <span>•</span>
              <span style={{ color: '#22d3ee', fontWeight: 600 }}>{profile.neighborhood}</span>
              <span style={{ color: 'rgba(255,255,255,0.5)' }}>• {profile.distanceKm} km away</span>
            </div>

            <div style={{ marginTop: '10px', display: 'inline-flex' }}>
              <span
                style={{
                  fontSize: '12px',
                  color: 'rgba(255,255,255,0.8)',
                  padding: '6px 10px',
                  borderRadius: '10px',
                  background: 'rgba(255,255,255,0.04)',
                  border: '1px solid rgba(255,255,255,0.08)',
                }}
              >
                {profile.profession} {profile.company && `at ${profile.company}`}
              </span>
            </div>
          </div>

          {/* Action Buttons */}
          <div style={{ display: 'flex', gap: '10px' }}>
            <button
              onClick={() => setIsEditProfileOpen(true)}
              style={{
                flex: 1.4,
                height: '46px',
                borderRadius: '15px',
                background: 'linear-gradient(90deg, #ff4d7e 0%, #e0264f 100%)',
                border: 'none',
                color: '#ffffff',
                fontSize: '14px',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                cursor: 'pointer',
                boxShadow: '0 10px 30px rgba(255, 77, 126, 0.25)',
              }}
            >
              <Edit3 size={16} />
              Edit Profile
            </button>
            <button
              onClick={() => onOpenMatches?.()}
              style={{
                flex: 1,
                height: '46px',
                borderRadius: '15px',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#ffffff',
                fontSize: '14px',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                cursor: 'pointer',
              }}
              title="View your matches"
            >
              <Heart size={16} color="#ff4d7e" />
              Matches
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
