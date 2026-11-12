import React, { useState, useRef } from 'react';
import {
  X,
  Heart,
  Flame,
  Star,
  Sparkles,
  MapPin,
  CheckCircle2,
  Briefcase,
  GraduationCap,
  Coffee,
  Wine,
  Cigarette,
  Dog,
  Compass,
  ArrowLeft,
  ChevronRight,
  Shield,
  MessageCircle,
} from 'lucide-react';
import { CandidateCard } from '../types';

interface FullProfileModalProps {
  isOpen: boolean;
  profile: CandidateCard | null;
  onClose: () => void;
  onLike?: (profile: CandidateCard) => void;
  onPass?: (profile: CandidateCard) => void;
  onMegaCrush?: (profile: CandidateCard) => void;
  onDirectMessage?: (profile: CandidateCard) => void;
}

export const FullProfileModal: React.FC<FullProfileModalProps> = ({
  isOpen,
  profile,
  onClose,
  onLike,
  onPass,
  onMegaCrush,
  onDirectMessage,
}) => {
  const [activePhotoIdx, setActivePhotoIdx] = useState(0);
  const [dragOffset, setDragOffset] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const dragStartRef = useRef<{ x: number; y: number } | null>(null);

  if (!isOpen || !profile) return null;

  const photoList = profile.photo_urls && profile.photo_urls.length > 0 ? profile.photo_urls : ['/ananya.jpg'];

  // Touch / pointer gesture handlers for Swipe-to-dismiss (swipe left or pull down)
  const handlePointerDown = (e: React.PointerEvent) => {
    // Only initiate drag if on top bar / non-scrolling header area
    const target = e.target as HTMLElement;
    if (target.closest('.no-swipe-dismiss')) return;

    dragStartRef.current = { x: e.clientX, y: e.clientY };
    setIsDragging(true);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDragging || !dragStartRef.current) return;
    const dx = e.clientX - dragStartRef.current.x;
    const dy = e.clientY - dragStartRef.current.y;
    // Allow dragging left (dismiss) or downwards (dismiss)
    setDragOffset({
      x: Math.min(0, dx),
      y: Math.max(0, dy),
    });
  };

  const handlePointerUp = () => {
    if (isDragging) {
      // Threshold: swiped left > 75px or pulled down > 90px
      if (dragOffset.x < -75 || dragOffset.y > 90) {
        onClose();
      }
    }
    setIsDragging(false);
    setDragOffset({ x: 0, y: 0 });
    dragStartRef.current = null;
  };

  return (
    <div
      onClick={onClose}
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 120,
        background: 'rgba(7, 9, 15, 0.65)',
        backdropFilter: 'blur(16px)',
        WebkitBackdropFilter: 'blur(16px)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-end',
        alignItems: 'center',
        padding: '0',
        overflow: 'hidden',
      }}
    >
      {/* Floating Modal Card (Underlying Discovery visibly blurred behind) */}
      <div
        onClick={(e) => e.stopPropagation()}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        style={{
          width: '100%',
          maxWidth: '440px',
          height: '92%',
          background: '#131620',
          borderTopLeftRadius: '26px',
          borderTopRightRadius: '26px',
          border: '1.5px solid rgba(255, 255, 255, 0.12)',
          borderBottom: 'none',
          boxShadow: '0 -16px 48px rgba(0, 0, 0, 0.85), 0 0 20px rgba(244, 63, 94, 0.1)',
          display: 'flex',
          flexDirection: 'column',
          position: 'relative',
          overflow: 'hidden',
          transform: `translate3d(${dragOffset.x}px, ${dragOffset.y}px, 0)`,
          transition: isDragging ? 'none' : 'transform 0.28s cubic-bezier(0.16, 1, 0.3, 1)',
        }}
      >
        {/* Grab Handle Bar (Swipe down / left hint) */}
        <div
          style={{
            padding: '10px 16px 6px',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            cursor: 'grab',
            userSelect: 'none',
          }}
        >
          <div
            style={{
              width: '38px',
              height: '4px',
              borderRadius: '999px',
              background: 'rgba(255, 255, 255, 0.25)',
              marginBottom: '8px',
            }}
          />
        </div>

        {/* Sticky Header with Title and Close Action */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '2px 18px 12px',
            borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '18px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.3px' }}>
              {profile.nickname}, {profile.age || 24}
            </span>
            {profile.is_verified && (
              <div
                title="Verified Profile"
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  background: 'linear-gradient(135deg, #0284c7 0%, #38bdf8 100%)',
                  borderRadius: '50%',
                  width: '18px',
                  height: '18px',
                  boxShadow: '0 0 8px rgba(56, 189, 248, 0.6)',
                }}
              >
                <CheckCircle2 size={13} color="#ffffff" strokeWidth={3} />
              </div>
            )}
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Close Profile"
            style={{
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              borderRadius: '50%',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#94a3b8',
              cursor: 'pointer',
              transition: 'background 0.15s ease',
            }}
          >
            <X size={16} />
          </button>
        </div>

        {/* Scrollable Content Body */}
        <div
          className="no-swipe-dismiss"
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: '16px 18px 100px',
            display: 'flex',
            flexDirection: 'column',
            gap: '16px',
            WebkitOverflowScrolling: 'touch',
          }}
        >
          {/* Side-by-Side / Horizontally Scrollable Photo Gallery */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
              <span style={{ fontSize: '11.5px', fontWeight: 800, color: '#f43f5e', textTransform: 'uppercase', letterSpacing: '0.6px' }}>
                Photos ({photoList.length})
              </span>
              <span style={{ fontSize: '10.5px', color: '#94a3b8' }}>Swipe side-by-side</span>
            </div>

            <div
              style={{
                display: 'flex',
                gap: '12px',
                overflowX: 'auto',
                scrollSnapType: 'x mandatory',
                paddingBottom: '6px',
                scrollbarWidth: 'none',
                WebkitOverflowScrolling: 'touch',
              }}
            >
              {photoList.map((photo, pIdx) => (
                <div
                  key={pIdx}
                  onClick={() => setActivePhotoIdx(pIdx)}
                  style={{
                    flex: '0 0 82%',
                    height: '340px',
                    borderRadius: '20px',
                    overflow: 'hidden',
                    position: 'relative',
                    scrollSnapAlign: 'start',
                    boxShadow: '0 6px 20px rgba(0, 0, 0, 0.45)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    background: '#181b26',
                  }}
                >
                  <img
                    src={photo}
                    alt={`${profile.nickname} photo ${pIdx + 1}`}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  />
                  {pIdx === 0 && (
                    <div
                      style={{
                        position: 'absolute',
                        bottom: '12px',
                        left: '12px',
                        padding: '4px 10px',
                        borderRadius: '999px',
                        background: 'rgba(10, 12, 18, 0.75)',
                        backdropFilter: 'blur(8px)',
                        border: '1px solid rgba(244, 63, 94, 0.4)',
                        color: '#f43f5e',
                        fontSize: '11px',
                        fontWeight: 800,
                      }}
                    >
                      {profile.vibe_score || 96}% Vibe Match 🔥
                    </div>
                  )}
                  <div
                    style={{
                      position: 'absolute',
                      top: '10px',
                      right: '10px',
                      padding: '3px 8px',
                      borderRadius: '999px',
                      background: 'rgba(0, 0, 0, 0.6)',
                      fontSize: '10px',
                      fontWeight: 700,
                      color: '#ffffff',
                    }}
                  >
                    {pIdx + 1} / {photoList.length}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* About Me / Bio Card */}
          <div
            style={{
              borderRadius: '16px',
              background: 'rgba(25, 28, 38, 0.7)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
            }}
          >
            <div style={{ fontSize: '11px', color: '#f43f5e', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.6px' }}>
              About Me
            </div>
            <p style={{ fontSize: '13.5px', color: '#e2e8f0', lineHeight: 1.5, margin: '8px 0 0' }}>
              {profile.bio || "Enthusiastic explorer, passionate about indie cafes, good architecture, and honest conversations."}
            </p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '12px', fontSize: '11.5px', color: '#94a3b8' }}>
              <MapPin size={13} color="#38bdf8" />
              <span>{profile.city} • {profile.distance_km} km away</span>
            </div>
          </div>

          {/* Career & Lifestyle Badges */}
          <div
            style={{
              borderRadius: '16px',
              background: 'rgba(25, 28, 38, 0.7)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
              display: 'flex',
              flexDirection: 'column',
              gap: '10px',
            }}
          >
            <div style={{ fontSize: '11px', color: '#f43f5e', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.6px' }}>
              Work & Lifestyle
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11.5px', color: '#e2e8f0' }}>
                <Briefcase size={14} color="#38bdf8" />
                <span>UI/UX Architect</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11.5px', color: '#e2e8f0' }}>
                <GraduationCap size={14} color="#a855f7" />
                <span>Design Institute</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11.5px', color: '#e2e8f0' }}>
                <Coffee size={14} color="#fbbf24" />
                <span>Specialty Coffee</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11.5px', color: '#e2e8f0' }}>
                <Dog size={14} color="#4ade80" />
                <span>Dog Lover 🐾</span>
              </div>
            </div>
          </div>

          {/* Relationship Intent, Languages & Orientation */}
          <div
            style={{
              borderRadius: '16px',
              background: 'rgba(25, 28, 38, 0.7)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              padding: '14px 16px',
              display: 'flex',
              flexDirection: 'column',
              gap: '10px',
            }}
          >
            <div style={{ fontSize: '11px', color: '#f43f5e', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.6px' }}>
              Relationship & Identity
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '9px', fontSize: '12px', color: '#e2e8f0' }}>
                <Heart size={14} color="#f43f5e" />
                <span><strong style={{ color: '#94a3b8' }}>Looking for:</strong> {profile.preference || 'Long-term relationship'}</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '9px', fontSize: '12px', color: '#e2e8f0' }}>
                <Compass size={14} color="#38bdf8" />
                <span><strong style={{ color: '#94a3b8' }}>Orientation:</strong> Straight</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '9px', fontSize: '12px', color: '#e2e8f0' }}>
                <Sparkles size={14} color="#fbbf24" />
                <span><strong style={{ color: '#94a3b8' }}>Languages:</strong> English, Telugu, Hindi</span>
              </div>
            </div>
          </div>

          {/* Compatibility Vibe Prompt */}
          <div
            style={{
              borderRadius: '16px',
              background: 'linear-gradient(135deg, rgba(244, 63, 94, 0.12) 0%, rgba(20, 24, 34, 0.8) 100%)',
              border: '1px solid rgba(244, 63, 94, 0.25)',
              padding: '14px 16px',
            }}
          >
            <div style={{ fontSize: '10.5px', color: '#fb7185', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              My Simple Pleasures
            </div>
            <p style={{ fontSize: '13px', color: '#ffffff', fontWeight: 600, margin: '6px 0 0', lineHeight: 1.4 }}>
              "Saturday mornings hunting for rare vinyl records, followed by a double espresso at a sunlit corner booth."
            </p>
          </div>

          {/* Shared Interests & Passions */}
          {profile.shared_interests && profile.shared_interests.length > 0 && (
            <div
              style={{
                borderRadius: '16px',
                background: 'rgba(25, 28, 38, 0.7)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                padding: '14px 16px',
              }}
            >
              <div style={{ fontSize: '11px', color: '#f43f5e', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '10px' }}>
                Passions & Interests
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                {profile.shared_interests.map((interest, idx) => (
                  <div
                    key={idx}
                    style={{
                      padding: '5px 12px',
                      borderRadius: '999px',
                      background: 'rgba(244, 63, 94, 0.12)',
                      border: '1px solid rgba(244, 63, 94, 0.3)',
                      color: '#fb7185',
                      fontSize: '11.5px',
                      fontWeight: 700,
                    }}
                  >
                    {interest}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Floating Action Dock at Bottom */}
        <div
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
            background: 'rgba(19, 22, 32, 0.95)',
            backdropFilter: 'blur(16px)',
            borderTop: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '12px 24px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-around',
            zIndex: 30,
          }}
        >
          {/* Pass Action */}
          <button
            type="button"
            onClick={() => {
              onClose();
              onPass?.(profile);
            }}
            title="Pass"
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '50%',
              background: 'rgba(239, 68, 68, 0.15)',
              border: '1.5px solid rgba(239, 68, 68, 0.5)',
              color: '#ef4444',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <X size={22} strokeWidth={2.4} />
          </button>

          {/* Mega Crush Action */}
          <button
            type="button"
            onClick={() => {
              onClose();
              onMegaCrush?.(profile);
            }}
            title="Mega Crush"
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '50%',
              background: 'radial-gradient(circle, rgba(239, 68, 68, 0.35) 0%, rgba(249, 115, 22, 0.25) 55%, rgba(25, 28, 36, 0.95) 100%)',
              border: '2px solid #ef4444',
              color: '#ef4444',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 0 20px rgba(239, 68, 68, 0.5)',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <Flame size={28} color="#f97316" fill="#f97316" />
          </button>

          {/* Like Action */}
          <button
            type="button"
            onClick={() => {
              onClose();
              onLike?.(profile);
            }}
            title="Like"
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '50%',
              background: 'rgba(34, 197, 94, 0.15)',
              border: '1.5px solid rgba(34, 197, 94, 0.5)',
              color: '#22c55e',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'transform 0.15s ease',
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
            onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            <Heart size={24} color="#22c55e" fill="#22c55e" />
          </button>
        </div>
      </div>
    </div>
  );
};
