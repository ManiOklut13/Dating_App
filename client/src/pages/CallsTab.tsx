import React, { useState, useEffect } from 'react';
import { PhoneCall, Video, UserX, Mic, MicOff, PhoneOff, Zap, ShieldCheck, Star } from 'lucide-react';

interface CallsTabProps {
  currentBalance: number;
  onCoinsDeducted: (newBalance: number) => void;
  directCallTarget?: { calleeId: string; name: string; avatar: string } | null;
}

export const CallsTab: React.FC<CallsTabProps> = ({
  currentBalance,
  onCoinsDeducted,
  directCallTarget,
}) => {
  const [inCall, setInCall] = useState(false);
  const [callKind, setCallKind] = useState<'audio' | 'video'>('audio');
  const [anonymousAvatar, setAnonymousAvatar] = useState(true);
  const [callDuration, setCallDuration] = useState(0);
  const [callId, setCallId] = useState<string | null>(null);
  const [micMuted, setMicMuted] = useState(false);
  const [billingToast, setBillingToast] = useState<string | null>(null);
  const [miniGameQuestion, setMiniGameQuestion] = useState('If you could teleport right now, where in Mumbai would we go?');
  const [callEndedRating, setCallEndedRating] = useState(false);

  const calleeName = directCallTarget?.name || 'Ananya';
  const calleeAvatar = directCallTarget?.avatar || '/ananya.jpg';

  // Timer & 60s Billing Tick
  useEffect(() => {
    let timer: any;
    if (inCall) {
      timer = setInterval(() => {
        setCallDuration((prev) => {
          const next = prev + 1;
          // Check for 60-second billing interval
          if (next > 0 && next % 60 === 0 && callId) {
            triggerBillingHeartbeat(callId, next);
          }
          return next;
        });
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [inCall, callId]);

  const triggerBillingHeartbeat = async (activeCallId: string, seconds: number) => {
    try {
      const res = await fetch(`/v1/calls/${activeCallId}/heartbeat`, {
        method: 'POST',
      });
      const data = await res.json();
      if (data.success) {
        onCoinsDeducted(data.caller_balance);
        setBillingToast(`🪙 60s Heartbeat: -${data.rate_per_min} Coins billed. New Balance: ${data.caller_balance}`);
        setTimeout(() => setBillingToast(null), 4000);
      } else if (data.call_status === 'dropped') {
        endCall();
        setBillingToast('⚠️ Call terminated due to insufficient coin balance.');
      }
    } catch (err) {
      console.error('Heartbeat error', err);
    }
  };

  const startCall = async (kind: 'audio' | 'video') => {
    setCallKind(kind);
    setCallEndedRating(false);
    try {
      const res = await fetch('/v1/calls/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          caller_id: '11111111-1111-1111-1111-111111111111',
          callee_id: directCallTarget?.calleeId || '22222222-2222-2222-2222-222222222222',
          kind,
          anonymous_avatar: anonymousAvatar,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        alert(data.error || 'Failed to start call');
        return;
      }

      setCallId(data.call_id);
      setCallDuration(0);
      setInCall(true);
      setBillingToast(`LiveKit SFU Connected. Billing rate: ${data.rates.spend} coins/min.`);
      setTimeout(() => setBillingToast(null), 4000);
    } catch (err) {
      alert('Network error initiating call.');
    }
  };

  const endCall = async () => {
    if (callId) {
      try {
        await fetch(`/v1/calls/${callId}/end`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ rating: 5 }),
        });
      } catch (err) {
        console.error(err);
      }
    }
    setInCall(false);
    setCallEndedRating(true);
  };

  const formatTime = (secs: number) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  };

  const nextMiniGame = () => {
    const questions = [
      "Subko or Blue Tokai: Which one wins your vote?",
      "Would you rather never have coffee again or never listen to music?",
      "What is your ultimate go-to guilty pleasure Bollywood track?",
      "If we planned a spontaneous road trip this weekend, where to?",
    ];
    setMiniGameQuestion(questions[Math.floor(Math.random() * questions.length)]);
  };

  return (
    <div style={{ maxWidth: '680px', margin: '20px auto', padding: '0 16px' }}>
      
      {/* Toast Alert */}
      {billingToast && (
        <div style={{ background: 'rgba(255, 45, 85, 0.95)', border: '1px solid #ffffff', borderRadius: 'var(--radius-full)', padding: '10px 20px', fontSize: '13px', fontWeight: 700, color: '#ffffff', textAlign: 'center', marginBottom: '16px', boxShadow: 'var(--shadow-glow)' }}>
          {billingToast}
        </div>
      )}

      {/* Screen 1: Active LiveKit Call Screen */}
      {inCall ? (
        <div className="glass-panel" style={{ height: '600px', borderRadius: 'var(--radius-lg)', position: 'relative', overflow: 'hidden', display: 'flex', flexDirection: 'column', justifyContent: 'space-between', padding: '24px', background: 'radial-gradient(circle at 50% 30%, rgba(255, 45, 85, 0.15) 0%, rgba(8, 10, 16, 0.98) 80%)' }}>
          
          {/* Call Header */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'rgba(0, 0, 0, 0.5)', padding: '6px 14px', borderRadius: 'var(--radius-full)', border: '1px solid var(--border-glass)' }}>
              <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#00e676', animation: 'pulseGlow 1.5s infinite' }} />
              <span style={{ fontSize: '12px', fontWeight: 700, color: '#00e676' }}>LIVEKIT SFU ENCRYPTED</span>
            </div>

            <div style={{ fontSize: '15px', fontWeight: 800, color: '#ffffff', background: 'rgba(255, 255, 255, 0.1)', padding: '6px 14px', borderRadius: 'var(--radius-full)' }}>
              {formatTime(callDuration)}
            </div>
          </div>

          {/* Callee Center Display */}
          <div style={{ textAlign: 'center' }}>
            <div style={{ width: '140px', height: '140px', margin: '0 auto 16px', borderRadius: '50%', padding: '4px', background: anonymousAvatar ? 'var(--gradient-cyan)' : 'var(--gradient-flame)', boxShadow: 'var(--shadow-glow)' }}>
              <img
                src={anonymousAvatar ? '/aditya.jpg' : calleeAvatar}
                alt="Callee"
                style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
              />
            </div>

            <h2 style={{ fontSize: '24px', fontWeight: 800 }}>
              {anonymousAvatar ? 'Anonymous Call Mask' : calleeName}
            </h2>
            <div style={{ fontSize: '13px', color: '#ffd700', marginTop: '4px' }}>
              Billed at {callKind === 'audio' ? '20' : '50'} coins / min • Creator earns {callKind === 'audio' ? '5' : '10'} coins
            </div>
          </div>

          {/* In-Call Interactive Mini-Game */}
          <div style={{ background: 'rgba(255, 255, 255, 0.05)', borderRadius: 'var(--radius-md)', padding: '14px 18px', border: '1px solid var(--border-glass)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
              <span style={{ fontSize: '11px', color: 'var(--cyan-vibe)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '1px' }}>
                ⚡ In-Call Icebreaker Mini-Game
              </span>
              <button onClick={nextMiniGame} style={{ background: 'none', border: 'none', color: '#ffffff', fontSize: '11px', cursor: 'pointer', textDecoration: 'underline' }}>
                Next Question
              </button>
            </div>
            <p style={{ fontSize: '13px', color: '#ffffff', fontWeight: 600 }}>"{miniGameQuestion}"</p>
          </div>

          {/* Call Controls */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '20px' }}>
            <button
              onClick={() => setMicMuted(!micMuted)}
              style={{ width: '54px', height: '54px', borderRadius: '50%', background: micMuted ? '#ff4757' : 'rgba(255, 255, 255, 0.1)', border: 'none', color: '#ffffff', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}
            >
              {micMuted ? <MicOff size={22} /> : <Mic size={22} />}
            </button>

            <button
              onClick={endCall}
              style={{ width: '64px', height: '64px', borderRadius: '50%', background: '#ff2d55', border: 'none', color: '#ffffff', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', boxShadow: '0 0 25px #ff2d55' }}
            >
              <PhoneOff size={26} />
            </button>
          </div>

        </div>
      ) : (
        /* Screen 2: Pre-Call Dashboard & Matchmaking Lobby */
        <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '32px 24px' }}>
          
          <div style={{ textAlign: 'center', marginBottom: '28px' }}>
            <div style={{ width: '64px', height: '64px', margin: '0 auto 16px', borderRadius: '20px', background: 'var(--gradient-cyan)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 30px rgba(0, 229, 255, 0.4)' }}>
              <PhoneCall size={32} color="#ffffff" />
            </div>
            <h1 style={{ fontSize: '26px', fontWeight: 800 }}>LiveKit Real-Time Calls</h1>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Low-latency WebRTC peer-to-peer and SFU audio/video sessions
            </p>
          </div>

          {/* Rating Prompt if call just ended */}
          {callEndedRating && (
            <div style={{ background: 'rgba(0, 230, 118, 0.1)', border: '1px solid rgba(0, 230, 118, 0.3)', borderRadius: 'var(--radius-md)', padding: '16px', textAlign: 'center', marginBottom: '24px' }}>
              <h3 style={{ fontSize: '15px', fontWeight: 700, color: '#00e676' }}>Call Completed & Billed!</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', margin: '4px 0 10px' }}>Rate connection quality with {calleeName}:</p>
              <div style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
                {[1, 2, 3, 4, 5].map((star) => (
                  <button key={star} onClick={() => setCallEndedRating(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>
                    <Star size={22} fill="#ffd700" color="#ffd700" />
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Privacy & Safety Settings */}
          <div style={{ background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-md)', padding: '16px', marginBottom: '24px', border: '1px solid var(--border-glass)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <UserX size={20} color="var(--cyan-vibe)" />
                <div>
                  <div style={{ fontSize: '14px', fontWeight: 600 }}>Anonymous Call Avatar Mask</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Shields real camera stream with an avatar preset</div>
                </div>
              </div>

              <input
                type="checkbox"
                checked={anonymousAvatar}
                onChange={(e) => setAnonymousAvatar(e.target.checked)}
                style={{ width: '18px', height: '18px', accentColor: '#ff2d55', cursor: 'pointer' }}
              />
            </div>
          </div>

          {/* Call Options Grid */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px' }}>
            
            {/* Option 1: Audio Call */}
            <div style={{ borderRadius: 'var(--radius-md)', padding: '20px', background: 'rgba(255, 255, 255, 0.04)', border: '1px solid var(--border-glass)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <PhoneCall size={24} color="#00e5ff" />
                <span style={{ fontSize: '12px', color: '#ffd700', fontWeight: 700 }}>20 Coins / min</span>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Blind Audio Call</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Direct voice connection with compatibility-matched user. High privacy.
              </p>
              <button
                onClick={() => startCall('audio')}
                className="btn-primary"
                style={{ width: '100%', padding: '10px', fontSize: '13px', marginTop: 'auto' }}
              >
                Start Audio Call
              </button>
            </div>

            {/* Option 2: Video Call */}
            <div style={{ borderRadius: 'var(--radius-md)', padding: '20px', background: 'rgba(255, 255, 255, 0.04)', border: '1px solid var(--border-glass)', display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Video size={24} color="#ff2d55" />
                <span style={{ fontSize: '12px', color: '#ffd700', fontWeight: 700 }}>50 Coins / min</span>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: 700 }}>Safe Video Call</h3>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Protected with Google Cloud Vision AI preview safety scan.
              </p>
              <button
                onClick={() => startCall('video')}
                className="btn-primary"
                style={{ width: '100%', padding: '10px', fontSize: '13px', marginTop: 'auto', background: 'var(--gradient-cyan)' }}
              >
                Start Video Call
              </button>
            </div>

          </div>

        </div>
      )}

    </div>
  );
};
