import React, { useEffect, useState } from 'react';
import { ArrowLeft, MoreVertical, MapPin, Briefcase, GraduationCap, Sparkles, ShieldCheck, Calendar, Phone, Video } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const ProfilePreviewModal: React.FC = () => {
  const {
    profile,
    calculatedAge,
    isPreviewProfileOpen,
    setIsPreviewProfileOpen,
  } = useProfile();

  const media = (profile.photos || []).map((p: any) => (typeof p === 'string' ? p : p.url)).filter(Boolean);
  const avatarUrl = media[0] || '/aditya.jpg';
  const carouselMedia = media.length ? media : [avatarUrl];
  const [activeIdx, setActiveIdx] = useState(0);

  useEffect(() => {
    if (!isPreviewProfileOpen || carouselMedia.length <= 1) return;
    const timer = window.setInterval(() => {
      setActiveIdx((prev) => (prev + 1) % carouselMedia.length);
    }, 2000);
    return () => window.clearInterval(timer);
  }, [isPreviewProfileOpen, carouselMedia.length]);

  useEffect(() => {
    if (!isPreviewProfileOpen) setActiveIdx(0);
  }, [isPreviewProfileOpen]);

  if (!isPreviewProfileOpen) return null;

  const currentMedia = carouselMedia[activeIdx] || carouselMedia[0];

  const { openSettingsMenu } = useProfile();

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'rgba(5, 6, 12, 0.95)',
        backdropFilter: 'blur(24px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 0,
      }}
      onClick={() => setIsPreviewProfileOpen(false)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '480px',
          height: '100%',
          maxHeight: '100dvh',
          borderRadius: 0,
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          border: 'none',
          boxShadow: 'var(--shadow-glow)',
          position: 'relative',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Top Navigation Bar: back arrow (left) & 3-dot menu (right) */}
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            zIndex: 50,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '14px 16px',
            background: 'linear-gradient(180deg, rgba(8,10,16,0.85) 0%, rgba(8,10,16,0.3) 70%, transparent 100%)',
          }}
        >
          <button
            onClick={() => setIsPreviewProfileOpen(false)}
            aria-label="Back"
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: 'rgba(15, 20, 30, 0.75)',
              border: '1px solid rgba(255, 255, 255, 0.25)',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 2px 8px rgba(0,0,0,0.5)',
              transition: 'background var(--transition-fast), transform var(--transition-fast)',
            }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255, 45, 85, 0.35)';
              (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1.05)';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(15, 20, 30, 0.75)';
              (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1)';
            }}
          >
            <ArrowLeft size={20} strokeWidth={2.2} />
          </button>

          <button
            onClick={() => {
              setIsPreviewProfileOpen(false);
              openSettingsMenu('top');
            }}
            aria-label="More options"
            title="More options"
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: 'rgba(15, 20, 30, 0.75)',
              border: '1px solid rgba(255, 255, 255, 0.25)',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 2px 8px rgba(0,0,0,0.5)',
              transition: 'background var(--transition-fast), transform var(--transition-fast)',
            }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(0, 229, 255, 0.35)';
              (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1.05)';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(15, 20, 30, 0.75)';
              (e.currentTarget as HTMLButtonElement).style.transform = 'scale(1)';
            }}
          >
            <MoreVertical size={20} strokeWidth={2.2} />
          </button>
        </div>

        {/* Scrollable Card Container */}
        <div style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>

          {/* Media Carousel */}
          <div style={{ position: 'relative', height: 'clamp(240px, 45vh, 420px)', flexShrink: 0, background: 'var(--bg-dark)', overflow: 'hidden' }}>
            <img
              src={currentMedia}
              alt={profile.nickname}
              style={{ width: '100%', height: '100%', objectFit: 'cover', transition: 'opacity 0.4s ease' }}
            />

            <div
              style={{
                position: 'absolute',
                inset: 0,
                background: 'linear-gradient(180deg, rgba(8,10,16,0.3) 0%, transparent 40%, rgba(8,10,16,0.95) 100%)',
              }}
            />

            {/* Hero Profile Info Overlay */}
            <div style={{ position: 'absolute', bottom: '16px', left: '20px', right: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <h1 style={{ fontSize: '26px', fontWeight: 800, textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
                  {profile.nickname}, {calculatedAge}
                </h1>
                {profile.verification.status === 'verified' && (
                  <span className="badge-blue-tick" style={{ width: '22px', height: '22px', fontSize: '13px' }}>
                    ✓
                  </span>
                )}
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px', fontSize: '13px', color: 'rgba(255,255,255,0.9)' }}>
                <MapPin size={14} color="#ff2d55" />
                <span>{profile.location} ({profile.neighborhood})</span>
                <span>•</span>
                <span style={{ color: 'var(--cyan-vibe)' }}>{profile.distanceKm} km away</span>
              </div>
            </div>

            {/* Pagination Dots */}
            {carouselMedia.length > 1 && (
              <div
                style={{
                  position: 'absolute',
                  bottom: '8px',
                  left: '50%',
                  transform: 'translateX(-50%)',
                  display: 'flex',
                  gap: '6px',
                  zIndex: 20,
                }}
              >
                {carouselMedia.map((_, idx) => (
                  <span
                    key={idx}
                    style={{
                      width: idx === activeIdx ? '18px' : '6px',
                      height: '6px',
                      borderRadius: '3px',
                      background: idx === activeIdx ? '#ffffff' : 'rgba(255,255,255,0.4)',
                      transition: 'all 0.3s ease',
                    }}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Card Body Details */}
          <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '18px' }}>

            {/* Bio */}
            <div>
              <div style={{ fontSize: '11px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', marginBottom: '6px' }}>
                About
              </div>
              <p style={{ fontSize: '14px', lineHeight: 1.6, color: 'var(--text-primary)' }}>
                {profile.bio}
              </p>
            </div>

            {/* Profession & Education */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                <Briefcase size={15} color="#ff2d55" />
                <span>{profile.profession} {profile.company && `at ${profile.company}`}</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                <GraduationCap size={15} color="#00e5ff" />
                <span>{profile.education}</span>
              </div>
            </div>

            {/* Interests Chips */}
            <div>
              <div style={{ fontSize: '11px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', marginBottom: '8px' }}>
                Interests & Passions
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {[...profile.interests, ...profile.customInterests].map((interest) => (
                  <span
                    key={interest}
                    style={{
                      padding: '4px 12px',
                      borderRadius: 'var(--radius-full)',
                      background: 'rgba(255, 45, 85, 0.12)',
                      border: '1px solid rgba(255, 45, 85, 0.3)',
                      color: 'var(--text-primary)',
                      fontSize: '12px',
                      fontWeight: 600,
                    }}
                  >
                    #{interest}
                  </span>
                ))}
              </div>
            </div>

            {/* Vibe & Compatibility */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '12px 14px',
                borderRadius: 'var(--radius-md)',
                background: 'rgba(0, 229, 255, 0.1)',
                border: '1px solid rgba(0, 229, 255, 0.3)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Sparkles size={16} color="#00e5ff" />
                <span style={{ fontSize: '12.5px', fontWeight: 700 }}>Vibe Compatibility</span>
              </div>
              <span style={{ fontSize: '12px', color: 'var(--cyan-vibe)', fontWeight: 600 }}>Discovery View</span>
            </div>

            {/* Verification Shield */}
            {profile.verification.status === 'verified' && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '10px 14px',
                  borderRadius: 'var(--radius-md)',
                  background: 'rgba(0, 230, 118, 0.08)',
                  border: '1px solid rgba(0, 230, 118, 0.25)',
                  fontSize: '12px',
                  color: '#00e676',
                  fontWeight: 600,
                }}
              >
                <ShieldCheck size={16} />
                <span>YoUnMe Liveness & Identity Verified Member</span>
              </div>
            )}

          </div>

        </div>

        {/* Bottom Action Bar */}
        <div
          style={{
            display: 'flex',
            gap: '10px',
            padding: '12px 16px',
            background: 'var(--bg-surface)',
            borderTop: '1px solid var(--border-glass)',
          }}
        >
          {[
            { label: 'Plan Date', icon: <Calendar size={18} />, color: '#ff2d55' },
            { label: 'Audio', icon: <Phone size={18} />, color: '#00e5ff' },
            { label: 'Video', icon: <Video size={18} />, color: '#ff2d55' },
          ].map((btn) => (
            <button
              key={btn.label}
              type="button"
              style={{
                flex: 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
                height: '44px',
                padding: '0 12px',
                borderRadius: 'var(--radius-md)',
                background: `${btn.color}1f`,
                border: `1px solid ${btn.color}55`,
                color: btn.color,
                fontSize: '13px',
                fontWeight: 700,
                cursor: 'pointer',
                transition: 'all var(--transition-fast)',
              }}
            >
              {btn.icon}
              <span>{btn.label}</span>
            </button>
          ))}
        </div>

      </div>
    </div>
  );
};
