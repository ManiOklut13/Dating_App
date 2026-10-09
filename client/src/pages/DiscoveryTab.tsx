import React, { useState, useEffect } from 'react';
import { X, Heart, Sparkles, RotateCcw, Moon, Volume2, MapPin, ShieldCheck, Zap, Radar } from 'lucide-react';
import { CandidateCard } from '../types';

interface DiscoveryTabProps {
  onMutualMatch: (profile: CandidateCard) => void;
  onCoinDeducted: (newBalance: number) => void;
}

export const DiscoveryTab: React.FC<DiscoveryTabProps> = ({ onMutualMatch, onCoinDeducted }) => {
  const [deck, setDeck] = useState<CandidateCard[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState<'cards' | 'radar'>('cards');
  const [audioPlaying, setAudioPlaying] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const fetchDeck = async () => {
    setLoading(true);
    try {
      const res = await fetch('/v1/discovery/deck?user_id=11111111-1111-1111-1111-111111111111&radius_km=50');
      const data = await res.json();
      if (data.success && data.deck) {
        setDeck(data.deck);
      }
    } catch (err) {
      console.error('Failed to fetch deck', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDeck();
  }, []);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const currentCandidate = deck[currentIndex];

  const handleSwipe = async (action: 'like' | 'dislike' | 'spark' | 'snooze') => {
    if (!currentCandidate) return;

    try {
      const res = await fetch('/v1/swipes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: '11111111-1111-1111-1111-111111111111',
          target_id: currentCandidate.user_id,
          action,
        }),
      });
      const data = await res.json();

      if (data.coins_deducted > 0) {
        showToast(`🪙 ${data.coins_deducted} coins deducted for ${action.toUpperCase()}`);
      }

      if (data.is_match) {
        onMutualMatch(currentCandidate);
      }

      setCurrentIndex((prev) => prev + 1);
    } catch (err) {
      console.error(err);
    }
  };

  const handleRevert = async () => {
    try {
      const res = await fetch('/v1/swipes/revert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: '11111111-1111-1111-1111-111111111111' }),
      });
      const data = await res.json();
      if (data.success) {
        if (currentIndex > 0) {
          setCurrentIndex((prev) => prev - 1);
        }
        showToast(data.coins_deducted > 0 ? `Restored previous card (-5 coins)` : 'Candidate card restored!');
      } else {
        showToast(data.error || 'Cannot revert further');
      }
    } catch (err) {
      showToast('Error reverting swipe');
    }
  };

  const playVoiceNote = () => {
    setAudioPlaying(true);
    // Web Audio synthesizer simulation of natural voice note chime
    const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(440, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 1.2);
    gain.gain.setValueAtTime(0.3, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 1.2);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 1.2);

    setTimeout(() => setAudioPlaying(false), 2000);
    showToast(`🎙️ Playing ${currentCandidate?.nickname}'s voice note prompt`);
  };

  return (
    <div style={{ maxWidth: '480px', margin: '20px auto', padding: '0 16px', position: 'relative' }}>
      
      {/* Toast Alert */}
      {toastMessage && (
        <div style={{ position: 'absolute', top: '-10px', left: '50%', transform: 'translateX(-50%)', background: 'rgba(20, 24, 38, 0.95)', border: '1px solid rgba(255, 45, 85, 0.4)', borderRadius: 'var(--radius-full)', padding: '8px 18px', fontSize: '13px', fontWeight: 600, color: '#ffffff', zIndex: 30, boxShadow: 'var(--shadow-glow)', whiteSpace: 'nowrap' }}>
          {toastMessage}
        </div>
      )}

      {/* Discovery Header Controls */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
        <div>
          <h1 style={{ fontSize: '20px', fontWeight: 800 }}>Discovery Deck</h1>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>PostGIS Geo-Filtered: <strong>Mumbai &lt; 50 km</strong></p>
        </div>

        {/* Card / Map Radar Toggle */}
        <div style={{ display: 'flex', background: 'rgba(255, 255, 255, 0.05)', borderRadius: 'var(--radius-full)', padding: '3px', border: '1px solid var(--border-glass)' }}>
          <button
            onClick={() => setViewMode('cards')}
            style={{
              padding: '6px 14px',
              borderRadius: 'var(--radius-full)',
              border: 'none',
              fontSize: '12px',
              fontWeight: 600,
              cursor: 'pointer',
              background: viewMode === 'cards' ? 'var(--gradient-flame)' : 'transparent',
              color: '#ffffff',
            }}
          >
            Cards
          </button>
          <button
            onClick={() => setViewMode('radar')}
            style={{
              padding: '6px 14px',
              borderRadius: 'var(--radius-full)',
              border: 'none',
              fontSize: '12px',
              fontWeight: 600,
              cursor: 'pointer',
              background: viewMode === 'radar' ? 'var(--gradient-cyan)' : 'transparent',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
            }}
          >
            <Radar size={14} />
            Radar
          </button>
        </div>
      </div>

      {/* Mode 1: Swipe Cards Deck */}
      {viewMode === 'cards' && (
        <>
          {loading ? (
            <div className="glass-panel" style={{ height: '520px', borderRadius: 'var(--radius-lg)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <div style={{ color: 'var(--text-secondary)' }}>Prefetching hot-path candidate deck from Redis...</div>
            </div>
          ) : currentCandidate ? (
            <div
              className="glass-panel"
              style={{
                position: 'relative',
                height: '540px',
                borderRadius: 'var(--radius-lg)',
                overflow: 'hidden',
                boxShadow: 'var(--shadow-lg)',
                border: '1px solid var(--border-glass)',
              }}
            >
              {/* Photo */}
              <img
                src={currentCandidate.photo_urls[0] || '/ananya.jpg'}
                alt={currentCandidate.nickname}
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />

              {/* Gradient Bottom Overlay */}
              <div style={{ position: 'absolute', inset: 0, background: 'var(--gradient-card-overlay)', pointerEvents: 'none' }} />

              {/* Top Badges */}
              <div style={{ position: 'absolute', top: '16px', left: '16px', right: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div className="badge-vibe">
                  <Zap size={14} />
                  {currentCandidate.vibe_score || 94}% Vibe Score
                </div>

                {currentCandidate.is_verified && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', background: 'rgba(29, 161, 242, 0.2)', padding: '4px 10px', borderRadius: 'var(--radius-full)', border: '1px solid rgba(29, 161, 242, 0.4)', color: '#1da1f2', fontSize: '11px', fontWeight: 700 }}>
                    <ShieldCheck size={14} />
                    Blue Tick
                  </div>
                )}
              </div>

              {/* Bottom Card Content */}
              <div style={{ position: 'absolute', bottom: '16px', left: '20px', right: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <h2 style={{ fontSize: '26px', fontWeight: 800 }}>{currentCandidate.nickname}</h2>
                  <span style={{ fontSize: '20px', color: 'var(--text-secondary)' }}>24</span>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--cyan-vibe)', fontSize: '13px', margin: '4px 0 10px' }}>
                  <MapPin size={14} />
                  <span>{currentCandidate.distance_km} km away • {currentCandidate.city}</span>
                </div>

                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.4, marginBottom: '14px' }}>
                  {currentCandidate.bio}
                </p>

                {/* Voice Note Button */}
                <button
                  onClick={playVoiceNote}
                  className="glass-pill"
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '6px',
                    padding: '6px 14px',
                    fontSize: '12px',
                    fontWeight: 600,
                    color: audioPlaying ? '#ff2d55' : '#ffffff',
                    border: '1px solid rgba(255, 255, 255, 0.15)',
                    cursor: 'pointer',
                  }}
                >
                  <Volume2 size={16} />
                  <span>{audioPlaying ? 'Playing Audio Note...' : 'Voice Prompt (0:14)'}</span>
                </button>
              </div>
            </div>
          ) : (
            <div className="glass-panel" style={{ height: '520px', borderRadius: 'var(--radius-lg)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '24px' }}>
              <div style={{ fontSize: '48px', marginBottom: '16px' }}>✨</div>
              <h3 style={{ fontSize: '20px', fontWeight: 700, marginBottom: '8px' }}>You've explored all nearby candidates!</h3>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>Expand PostGIS radius or revert previously swiped cards.</p>
              <button onClick={() => { setCurrentIndex(0); fetchDeck(); }} className="btn-primary" style={{ padding: '10px 24px' }}>
                Refresh Deck
              </button>
            </div>
          )}

          {/* Swipe Action Controls Bar */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '14px', marginTop: '20px' }}>
            {/* Revert Button */}
            <button
              onClick={handleRevert}
              title="Revert previous swipe (10 free/day or 5 coins)"
              className="action-btn-circle btn-revert"
            >
              <RotateCcw size={22} />
            </button>

            {/* Dislike / Pass */}
            <button
              onClick={() => handleSwipe('dislike')}
              title="Pass"
              className="action-btn-circle btn-dislike"
            >
              <X size={26} />
            </button>

            {/* Like */}
            <button
              onClick={() => handleSwipe('like')}
              title="Like"
              className="action-btn-circle btn-like"
            >
              <Heart size={34} fill="#ffffff" />
            </button>

            {/* Spark / Mega-Crush */}
            <button
              onClick={() => handleSwipe('spark')}
              title="Spark / Mega-Crush (20 free/day or 15 coins)"
              className="action-btn-circle btn-spark"
            >
              <Sparkles size={24} />
            </button>

            {/* Snooze */}
            <button
              onClick={() => handleSwipe('snooze')}
              title="Snooze"
              className="action-btn-circle btn-snooze"
            >
              <Moon size={22} />
            </button>
          </div>
        </>
      )}

      {/* Mode 2: Interactive PostGIS Radar / Map View */}
      {viewMode === 'radar' && (
        <div className="glass-panel" style={{ height: '540px', borderRadius: 'var(--radius-lg)', padding: '24px', position: 'relative', overflow: 'hidden', textAlign: 'center' }}>
          <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '4px' }}>PostGIS Spatial Radar</h3>
          <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '20px' }}>Real-time ST_DWithin geospatial tracking (Mumbai Center: 19.0596° N, 72.8295° E)</p>

          {/* Radar Screen with Grid Rings */}
          <div style={{ position: 'relative', width: '300px', height: '300px', margin: '0 auto', borderRadius: '50%', border: '2px solid rgba(0, 229, 255, 0.4)', background: 'radial-gradient(circle, rgba(0, 229, 255, 0.08) 0%, rgba(8, 10, 16, 0.95) 70%)', overflow: 'hidden' }}>
            
            {/* Concentric distance rings */}
            <div style={{ position: 'absolute', inset: '50px', borderRadius: '50%', border: '1px dashed rgba(0, 229, 255, 0.25)' }} />
            <div style={{ position: 'absolute', inset: '100px', borderRadius: '50%', border: '1px dashed rgba(0, 229, 255, 0.2)' }} />

            {/* Sweeping radar scanner */}
            <div
              className="radar-spinner"
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: '100%',
                background: 'conic-gradient(from 0deg at 50% 50%, rgba(0, 229, 255, 0.35) 0deg, transparent 60deg)',
                borderRadius: '50%',
                pointerEvents: 'none',
              }}
            />

            {/* Center User Dot (Arjun) */}
            <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', width: '14px', height: '14px', borderRadius: '50%', background: '#ff2d55', border: '2px solid #ffffff', boxShadow: '0 0 12px #ff2d55', zIndex: 10 }} />

            {/* Pin 1: Ananya (Bandra Pali Hill, 0.8 km) */}
            <div
              onClick={() => { setViewMode('cards'); setCurrentIndex(0); }}
              style={{ position: 'absolute', top: '42%', left: '54%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
              title="Ananya (0.8 km away • Bandra)"
            >
              <div style={{ width: '32px', height: '32px', borderRadius: '50%', border: '2px solid #00e5ff', overflow: 'hidden', boxShadow: '0 0 10px #00e5ff' }}>
                <img src="/ananya.jpg" alt="Ananya" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              </div>
            </div>

            {/* Pin 2: Rohit (Juhu, 5.3 km) */}
            <div
              onClick={() => { setViewMode('cards'); setCurrentIndex(1); }}
              style={{ position: 'absolute', top: '25%', left: '46%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
              title="Rohit (5.3 km away • Juhu)"
            >
              <div style={{ width: '30px', height: '30px', borderRadius: '50%', border: '2px solid #ffd700', overflow: 'hidden' }}>
                <img src="/rohit.jpg" alt="Rohit" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              </div>
            </div>

            {/* Pin 3: Riya (Colaba, 15.2 km) */}
            <div
              onClick={() => { setViewMode('cards'); setCurrentIndex(2); }}
              style={{ position: 'absolute', bottom: '18%', left: '58%', transform: 'translate(-50%, -50%)', cursor: 'pointer', zIndex: 12 }}
              title="Riya (15.2 km away • Colaba)"
            >
              <div style={{ width: '30px', height: '30px', borderRadius: '50%', border: '2px solid #9b51e0', overflow: 'hidden' }}>
                <img src="/riya.jpg" alt="Riya" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              </div>
            </div>
          </div>

          <div style={{ marginTop: '20px', fontSize: '13px', color: 'var(--text-secondary)' }}>
            Tap any candidate pin on the radar to view their profile card.
          </div>
        </div>
      )}

    </div>
  );
};
