import React, { useState, useEffect } from 'react';
import { Heart, Lock, Zap, MessageSquare, PhoneCall, ShieldCheck, Sparkles } from 'lucide-react';
import { MatchItem } from '../types';

interface ConnectTabProps {
  onOpenChat: (convId: string) => void;
  onOpenCall: (calleeId: string, name: string, avatar: string) => void;
  onOpenStore: () => void;
}

export const ConnectTab: React.FC<ConnectTabProps> = ({ onOpenChat, onOpenCall, onOpenStore }) => {
  const [matches, setMatches] = useState<MatchItem[]>([]);
  const [likesStack, setLikesStack] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadConnectData = async () => {
      try {
        const [resMatches, resLikes] = await Promise.all([
          fetch('/v1/matches?user_id=11111111-1111-1111-1111-111111111111'),
          fetch('/v1/connect/likes-you?user_id=11111111-1111-1111-1111-111111111111'),
        ]);
        const dataMatches = await resMatches.json();
        const dataLikes = await resLikes.json();

        if (dataMatches.success) setMatches(dataMatches.matches);
        if (dataLikes.success) setLikesStack(dataLikes.likes_stack);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    loadConnectData();
  }, []);

  return (
    <div style={{ maxWidth: '800px', margin: '20px auto', padding: '0 16px' }}>
      
      {/* Page Title */}
      <div style={{ marginBottom: '24px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 800 }}>Connect & Match Hub</h1>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Reciprocal connections, Vibe radar, and incoming likes</p>
      </div>

      {/* Section 1: Active Mutual Matches */}
      <div style={{ marginBottom: '32px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Heart size={18} color="#ff2d55" fill="#ff2d55" />
            Mutual Matches ({matches.length})
          </h2>
          <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Ready to chat & call</span>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '16px' }}>
          {matches.map((m) => (
            <div
              key={m.id}
              className="glass-panel"
              style={{
                borderRadius: 'var(--radius-md)',
                padding: '16px',
                display: 'flex',
                flexDirection: 'column',
                gap: '12px',
                border: '1px solid rgba(255, 45, 85, 0.25)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ position: 'relative', width: '56px', height: '56px' }}>
                  <img
                    src={m.counterpart.avatar}
                    alt={m.counterpart.nickname}
                    style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
                  />
                  {m.counterpart.is_verified && (
                    <div className="badge-blue-tick" style={{ position: 'absolute', bottom: 0, right: 0 }}>
                      ✓
                    </div>
                  )}
                </div>
                <div>
                  <h3 style={{ fontSize: '16px', fontWeight: 700 }}>{m.counterpart.nickname}</h3>
                  <div style={{ fontSize: '12px', color: 'var(--cyan-vibe)' }}>{m.counterpart.city}</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{m.message_pair_count} messages exchanged</div>
                </div>
              </div>

              {m.last_message && (
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)', background: 'rgba(255, 255, 255, 0.03)', padding: '8px 10px', borderRadius: 'var(--radius-sm)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  💬 "{m.last_message.body}"
                </div>
              )}

              {/* Actions */}
              <div style={{ display: 'flex', gap: '8px', marginTop: 'auto' }}>
                <button
                  onClick={() => onOpenChat(m.id)}
                  className="btn-primary"
                  style={{ flex: 1, padding: '8px', fontSize: '12px' }}
                >
                  <MessageSquare size={14} />
                  Chat
                </button>
                <button
                  onClick={() => onOpenCall(m.counterpart.user_id, m.counterpart.nickname, m.counterpart.avatar)}
                  className="btn-ghost"
                  style={{ padding: '8px 12px', fontSize: '12px' }}
                  title="Audio/Video Call (LiveKit)"
                >
                  <PhoneCall size={14} color="#00e5ff" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Section 2: 'Likes You' Blurred Stack */}
      <div style={{ marginBottom: '32px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Sparkles size={18} color="#ffd700" />
            'Likes You' Blurred Stack
          </h2>
          <span style={{ fontSize: '12px', color: '#ffd700', fontWeight: 600 }}>Secret Admirers</span>
        </div>

        <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '24px', border: '1px solid rgba(255, 215, 0, 0.25)', background: 'radial-gradient(circle at 50% 0%, rgba(255, 215, 0, 0.08) 0%, rgba(15, 18, 29, 0.95) 100%)' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              {/* Blurred Avatar Stack */}
              <div style={{ display: 'flex', position: 'relative' }}>
                {['/ananya.jpg', '/riya.jpg', '/rohit.jpg'].map((img, i) => (
                  <div
                    key={i}
                    style={{
                      width: '64px',
                      height: '64px',
                      borderRadius: '50%',
                      overflow: 'hidden',
                      marginLeft: i > 0 ? '-24px' : '0',
                      border: '3px solid #0f121d',
                      boxShadow: 'var(--shadow-sm)',
                    }}
                  >
                    <img
                      src={img}
                      alt="Secret Admirer"
                      style={{ width: '100%', height: '100%', objectFit: 'cover', filter: 'blur(8px)' }}
                    />
                  </div>
                ))}
              </div>

              <div>
                <h3 style={{ fontSize: '18px', fontWeight: 700 }}>3 People Liked Your Profile</h3>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                  Reveal who liked you and match instantly without waiting in the swipe deck.
                </p>
              </div>
            </div>

            <button
              onClick={onOpenStore}
              className="btn-gold"
              style={{ padding: '12px 20px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px' }}
            >
              <Lock size={15} />
              Unlock Stack (50 Coins)
            </button>
          </div>
        </div>
      </div>

      {/* Section 3: Dynamic Vibe Match ML Scoring Details */}
      <div>
        <h2 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Zap size={18} color="#00e5ff" />
          Vibe Compatibility Algorithm
        </h2>

        <div className="glass-panel" style={{ borderRadius: 'var(--radius-md)', padding: '20px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>🎵 Music & Indie Vinyl Taste</span>
                <strong style={{ color: '#00e5ff' }}>95%</strong>
              </div>
              <div style={{ width: '100%', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                <div style={{ width: '95%', height: '100%', background: 'var(--gradient-cyan)' }} />
              </div>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>☕ Cafe Culture & City Vibes</span>
                <strong style={{ color: '#ff2d55' }}>92%</strong>
              </div>
              <div style={{ width: '100%', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                <div style={{ width: '92%', height: '100%', background: 'var(--gradient-flame)' }} />
              </div>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-secondary)' }}>💬 Wit & Conversation Depth</span>
                <strong style={{ color: '#ffd700' }}>88%</strong>
              </div>
              <div style={{ width: '100%', height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                <div style={{ width: '88%', height: '100%', background: 'var(--gradient-gold)' }} />
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  );
};
