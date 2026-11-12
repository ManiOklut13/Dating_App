import React, { useEffect, useRef, useState } from 'react';
import {
  ArrowLeft,
  MoreVertical,
  Sparkles,
  MapPin,
  Briefcase,
  Phone,
  Video,
  Calendar,
  ShieldCheck,
} from 'lucide-react';
import { useChat } from './ChatContext';

export const UserProfileModal: React.FC = () => {
  const {
    profilePreviewUser,
    setProfilePreviewUser,
    conversations,
    setAudioCallTarget,
    setVideoCallTarget,
    setDatePlannerConv,
  } = useChat();

  /* ---- Media carousel state (avatar + profile photos) ---- */
  const [activeIdx, setActiveIdx] = useState(0);
  const slideDirRef = useRef<1 | -1>(1);

  const carouselMedia = profilePreviewUser
    ? [profilePreviewUser.avatar, ...(profilePreviewUser.photos || [])].filter(Boolean)
    : [];

  /* Auto-slide every 2s, bouncing back and forth between slides */
  useEffect(() => {
    if (!profilePreviewUser || carouselMedia.length <= 1) return;
    const timer = window.setInterval(() => {
      setActiveIdx((prev) => {
        const dir = slideDirRef.current;
        let next = prev + dir;
        if (next >= carouselMedia.length || next < 0) {
          const flipped: 1 | -1 = dir === 1 ? -1 : 1;
          slideDirRef.current = flipped;
          next = prev + flipped;
        }
        return next;
      });
    }, 2000);
    return () => window.clearInterval(timer);
  }, [profilePreviewUser?.id, carouselMedia.length]);

  /* Reset to the first slide whenever a different user is opened */
  useEffect(() => {
    slideDirRef.current = 1;
    setActiveIdx(0);
  }, [profilePreviewUser?.id]);

  if (!profilePreviewUser) return null;

  const targetConv = conversations.find((c) => c.counterpart.id === profilePreviewUser.id) || null;

  /* ---- Uniform bottom action buttons ---- */
  const ACTION_BUTTON_STYLE: React.CSSProperties = {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '6px',
    height: '44px',
    padding: '0 12px',
    borderRadius: 'var(--radius-md)',
    fontSize: '13px',
    fontWeight: 700,
    cursor: 'pointer',
    transition: 'transform 0.15s ease, filter 0.15s ease',
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'rgba(5, 6, 12, 0.85)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 'max(16px, env(safe-area-inset-top)) 16px max(16px, env(safe-area-inset-bottom))',
        overflowY: 'auto',
      }}
      onClick={() => setProfilePreviewUser(null)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '480px',
          maxHeight: '90vh',
          height: 'auto',
          margin: 'auto',
          borderRadius: 'var(--radius-lg)',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          border: '1px solid var(--border-glass)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Cover & Media Carousel Header */}
        <div
          style={{
            position: 'relative',
            height: 'clamp(230px, 36vh, 340px)',
            flexShrink: 0,
            background: 'var(--bg-card)',
          }}
        >
          {/* Sliding media track */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                display: 'flex',
                height: '100%',
                width: `${carouselMedia.length * 100}%`,
                transform: `translateX(-${(activeIdx * 100) / carouselMedia.length}%)`,
                transition: 'transform 0.55s cubic-bezier(0.4, 0, 0.2, 1)',
              }}
            >
              {carouselMedia.map((url, idx) => (
                <img
                  key={`media-${idx}-${url}`}
                  src={url}
                  alt={idx === 0 ? profilePreviewUser.nickname : `${profilePreviewUser.nickname} photo ${idx}`}
                  style={{
                    width: `${100 / carouselMedia.length}%`,
                    height: '100%',
                    objectFit: 'cover',
                    flexShrink: 0,
                  }}
                />
              ))}
            </div>
          </div>

          {/* Gradient overlay for readability */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              background:
                'linear-gradient(180deg, rgba(8,10,16,0.35) 0%, transparent 30%, rgba(8,10,16,0.95) 100%)',
              pointerEvents: 'none',
            }}
          />

          {/* Top Navigation Bar: back (left) & 3-dot menu (right) */}
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              zIndex: 30,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '14px 16px',
              background: 'linear-gradient(180deg, rgba(8,10,16,0.55) 0%, transparent 100%)',
              pointerEvents: 'none',
            }}
          >
            <button
              onClick={() => setProfilePreviewUser(null)}
              aria-label="Back"
              style={{
                pointerEvents: 'auto',
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: 'rgba(0, 0, 0, 0.5)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <ArrowLeft size={18} />
            </button>

            <button
              aria-label="More options"
              style={{
                pointerEvents: 'auto',
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: 'rgba(0, 0, 0, 0.5)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <MoreVertical size={18} />
            </button>
          </div>

          {/* Pagination Dots */}
          {carouselMedia.length > 1 && (
            <div
              style={{
                position: 'absolute',
                bottom: '10px',
                left: '50%',
                transform: 'translateX(-50%)',
                zIndex: 20,
                display: 'flex',
                gap: '6px',
                pointerEvents: 'none',
              }}
              aria-label="Media slides indicator"
            >
              {carouselMedia.map((_, idx) => (
                <span
                  key={`dot-${idx}`}
                  style={{
                    width: idx === activeIdx ? '18px' : '6px',
                    height: '6px',
                    borderRadius: '3px',
                    background: idx === activeIdx ? '#ffffff' : 'rgba(255,255,255,0.45)',
                    transition: 'all 0.3s ease',
                  }}
                />
              ))}
            </div>
          )}

          {/* User Basic Info on overlay */}
          <div style={{ position: 'absolute', bottom: '22px', left: '20px', right: '20px', zIndex: 25 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <h2 style={{ fontSize: '24px', fontWeight: 800, textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
                {profilePreviewUser.nickname}, {profilePreviewUser.age}
              </h2>
              {profilePreviewUser.is_verified && <span className="badge-blue-tick">✓</span>}
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '4px', fontSize: '13px', color: 'rgba(255,255,255,0.9)' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <MapPin size={14} color="#ff2d55" />
                {profilePreviewUser.city}
              </span>
              <span>•</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <Briefcase size={14} color="#00e5ff" />
                {profilePreviewUser.occupation}
              </span>
            </div>
          </div>
        </div>

        {/* Profile Content */}
        <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '18px' }}>

          {/* Vibe Score Card */}
          <div
            style={{
              padding: '12px 16px',
              borderRadius: 'var(--radius-md)',
              background: 'rgba(0, 229, 255, 0.08)',
              border: '1px solid rgba(0, 229, 255, 0.25)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Sparkles size={18} color="#00e5ff" />
              <div>
                <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)' }}>Vibe Compatibility</div>
                <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Based on shared interests and music taste</div>
              </div>
            </div>
            <div style={{ fontSize: '18px', fontWeight: 800, color: '#00e5ff' }}>
              {profilePreviewUser.vibe_score}%
            </div>
          </div>

          {/* Bio */}
          <div>
            <div style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '6px' }}>
              About
            </div>
            <p style={{ fontSize: '13.5px', lineHeight: 1.6, color: 'var(--text-primary)' }}>
              {profilePreviewUser.bio}
            </p>
          </div>

          {/* Interests */}
          {profilePreviewUser.interests && profilePreviewUser.interests.length > 0 && (
            <div>
              <div style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '8px' }}>
                Interests & Vibes
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {profilePreviewUser.interests.map((interest, i) => (
                  <span
                    key={i}
                    style={{
                      padding: '4px 10px',
                      borderRadius: 'var(--radius-full)',
                      background: 'var(--surface-muted)',
                      border: '1px solid var(--border-glass)',
                      fontSize: '11px',
                      fontWeight: 600,
                      color: 'var(--text-secondary)',
                    }}
                  >
                    #{interest}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Trust & Verification Badge */}
          <div
            style={{
              padding: '10px 14px',
              borderRadius: 'var(--radius-md)',
              background: 'rgba(0, 230, 118, 0.08)',
              border: '1px solid rgba(0, 230, 118, 0.2)',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              fontSize: '12px',
              color: '#00e676',
            }}
          >
            <ShieldCheck size={16} />
            <span>YoUnMe ID & Photo Verified Profile</span>
          </div>

        </div>

        {/* Bottom Action Bar — uniform Plan Date / Audio / Video buttons */}
        {targetConv && (
          <div
            style={{
              padding: '14px 20px',
              background: 'var(--bg-dark)',
              borderTop: '1px solid var(--border-glass)',
              display: 'flex',
              gap: '10px',
            }}
          >
            <button
              onClick={() => {
                setProfilePreviewUser(null);
                setDatePlannerConv(targetConv);
              }}
              style={{
                ...ACTION_BUTTON_STYLE,
                background: 'rgba(255, 45, 85, 0.14)',
                border: '1px solid rgba(255, 45, 85, 0.4)',
                color: '#ff2d55',
              }}
            >
              <Calendar size={16} />
              <span>Plan Date</span>
            </button>

            <button
              onClick={() => {
                setProfilePreviewUser(null);
                setAudioCallTarget(targetConv);
              }}
              aria-label="Audio call"
              style={{
                ...ACTION_BUTTON_STYLE,
                background: 'rgba(0, 229, 255, 0.14)',
                border: '1px solid rgba(0, 229, 255, 0.4)',
                color: '#00e5ff',
              }}
            >
              <Phone size={16} />
              <span>Audio</span>
            </button>

            <button
              onClick={() => {
                setProfilePreviewUser(null);
                setVideoCallTarget(targetConv);
              }}
              aria-label="Video call"
              style={{
                ...ACTION_BUTTON_STYLE,
                background: 'rgba(155, 81, 224, 0.16)',
                border: '1px solid rgba(155, 81, 224, 0.45)',
                color: '#c084fc',
              }}
            >
              <Video size={16} />
              <span>Video</span>
            </button>
          </div>
        )}

      </div>
    </div>
  );
};
