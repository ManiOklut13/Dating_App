import React, { useEffect } from 'react';
import { Heart, MessageSquare, PhoneCall, X, Sparkles } from 'lucide-react';
import confetti from 'canvas-confetti';
import { CandidateCard } from '../types';

interface MatchModalProps {
  isOpen: boolean;
  onClose: () => void;
  matchedProfile: CandidateCard | null;
  onStartChat: () => void;
  onStartCall: () => void;
}

export const MatchModal: React.FC<MatchModalProps> = ({
  isOpen,
  onClose,
  matchedProfile,
  onStartChat,
  onStartCall,
}) => {
  useEffect(() => {
    if (isOpen) {
      confetti({
        particleCount: 120,
        spread: 90,
        origin: { y: 0.5 },
      });
    }
  }, [isOpen]);

  if (!isOpen || !matchedProfile) return null;

  return (
    <div style={{ position: 'fixed', inset: 0, zIndex: 60, display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(0, 0, 0, 0.85)', backdropFilter: 'blur(12px)', padding: '16px' }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '460px', borderRadius: 'var(--radius-lg)', padding: '32px 24px', textAlign: 'center', position: 'relative', border: '1px solid rgba(255, 45, 85, 0.4)', boxShadow: '0 0 50px rgba(255, 45, 85, 0.3)' }}>
        
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '16px', right: '16px', background: 'rgba(255, 255, 255, 0.1)', border: 'none', borderRadius: '50%', width: '32px', height: '32px', color: '#ffffff', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'inline-flex', padding: '6px 14px', borderRadius: 'var(--radius-full)', background: 'rgba(255, 45, 85, 0.15)', border: '1px solid rgba(255, 45, 85, 0.35)', color: '#ff2d55', fontSize: '13px', fontWeight: 700, gap: '6px', alignItems: 'center', marginBottom: '12px' }}>
          <Sparkles size={16} />
          MUTUAL CONNECTION FOUND
        </div>

        <h2 style={{ fontSize: '28px', fontWeight: 800, background: 'var(--gradient-flame)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', marginBottom: '8px' }}>
          It's a Vibe Match!
        </h2>
        <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '28px' }}>
          You and <strong>{matchedProfile.nickname}</strong> liked each other!
        </p>

        {/* Dual Avatars with Heart Connector */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '20px', marginBottom: '32px', position: 'relative' }}>
          <div style={{ width: '90px', height: '90px', borderRadius: '50%', padding: '3px', background: 'var(--gradient-flame)', boxShadow: 'var(--shadow-glow)' }}>
            <img src="/aditya.jpg" alt="You" style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} />
          </div>

          <div style={{ width: '44px', height: '44px', borderRadius: '50%', background: 'var(--gradient-flame)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 20px #ff2d55', zIndex: 10 }}>
            <Heart size={22} fill="#ffffff" color="#ffffff" />
          </div>

          <div style={{ width: '90px', height: '90px', borderRadius: '50%', padding: '3px', background: 'var(--gradient-cyan)', boxShadow: '0 0 20px rgba(0, 229, 255, 0.4)' }}>
            <img src={matchedProfile.photo_urls[0] || '/ananya.jpg'} alt={matchedProfile.nickname} style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} />
          </div>
        </div>

        {/* Compatibility Pill */}
        <div style={{ display: 'inline-block', marginBottom: '24px', padding: '6px 16px', borderRadius: 'var(--radius-full)', background: 'rgba(0, 229, 255, 0.12)', border: '1px solid rgba(0, 229, 255, 0.3)', color: 'var(--cyan-vibe)', fontSize: '13px', fontWeight: 700 }}>
          ⚡ {matchedProfile.vibe_score || 94}% Compatibility Score
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <button
            onClick={() => { onClose(); onStartChat(); }}
            className="btn-primary"
            style={{ width: '100%', padding: '14px', fontSize: '15px' }}
          >
            <MessageSquare size={18} />
            Send Direct Message
          </button>

          <button
            onClick={() => { onClose(); onStartCall(); }}
            className="btn-ghost"
            style={{ width: '100%', padding: '12px', fontSize: '14px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
          >
            <PhoneCall size={16} />
            Start Live Audio Call (20 coins/min)
          </button>
        </div>

      </div>
    </div>
  );
};
