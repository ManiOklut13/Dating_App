import React, { useState, useEffect, useRef } from 'react';
import {
  PhoneCall,
  Mic,
  MicOff,
  PhoneOff,
  Star,
  X,
  CheckCircle2,
  ArrowLeft,
  Volume2,
  VolumeX,
  Video,
  VideoOff,
  Sparkles,
  Heart,
  Smile,
} from 'lucide-react';

export interface CallsTabProps {
  currentBalance: number;
  onCoinsDeducted: (newBalance: number) => void;
  directCallTarget?: { calleeId: string; name: string; avatar: string; mode?: 'audio' | 'video' } | null;
  onClose?: () => void;
}

interface FloatingReaction {
  id: number;
  emoji: string;
  left: number;
}

export const CallsTab: React.FC<CallsTabProps> = ({
  currentBalance,
  onCoinsDeducted,
  directCallTarget,
  onClose,
}) => {
  const [callPhase, setCallPhase] = useState<'ringing' | 'connected' | 'ended'>('ringing');
  const [callDuration, setCallDuration] = useState(0);
  const [callId, setCallId] = useState<string | null>(null);
  const [micMuted, setMicMuted] = useState(false);
  const [speakerOn, setSpeakerOn] = useState(true);
  const [videoOn, setVideoOn] = useState(false);
  const [billingToast, setBillingToast] = useState<string | null>(null);
  const [miniGameQuestion, setMiniGameQuestion] = useState('If you could teleport right now, where in Mumbai would we go?');
  const [selectedRating, setSelectedRating] = useState<number>(0);
  const [floatingReactions, setFloatingReactions] = useState<FloatingReaction[]>([]);

  const calleeName = directCallTarget?.name || 'Ananya';
  const calleeAvatar = directCallTarget?.avatar || '/ananya.jpg';
  const hasInitiatedRef = useRef(false);
  const audioCtxRef = useRef<AudioContext | null>(null);

  // Play realistic ringing tone synthesizer
  const playRingChime = () => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      audioCtxRef.current = ctx;

      const osc1 = ctx.createOscillator();
      const osc2 = ctx.createOscillator();
      const gain = ctx.createGain();

      osc1.type = 'sine';
      osc2.type = 'sine';
      osc1.frequency.setValueAtTime(440, ctx.currentTime);
      osc2.frequency.setValueAtTime(480, ctx.currentTime);

      gain.gain.setValueAtTime(0.04, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 1.2);

      osc1.connect(gain);
      osc2.connect(gain);
      gain.connect(ctx.destination);

      osc1.start();
      osc2.start();
      osc1.stop(ctx.currentTime + 1.2);
      osc2.stop(ctx.currentTime + 1.2);
    } catch {
      // Audio autoplay policy fallback
    }
  };

  // Play soft connected chime
  const playConnectedChime = () => {
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
      osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.3); // A5
      gain.gain.setValueAtTime(0.05, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.4);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start();
      osc.stop(ctx.currentTime + 0.4);
    } catch {}
  };

  // Automatically initiate realistic call flow upon entering
  useEffect(() => {
    if (!hasInitiatedRef.current) {
      hasInitiatedRef.current = true;
      startCallSession();
    }
  }, [directCallTarget]);

  const startCallSession = async () => {
    setCallPhase('ringing');
    if (directCallTarget?.mode === 'video') {
      setVideoOn(true);
    }
    playRingChime();

    try {
      const res = await fetch('/v1/calls/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          caller_id: '11111111-1111-1111-1111-111111111111',
          callee_id: directCallTarget?.calleeId || '22222222-2222-2222-2222-222222222222',
          kind: directCallTarget?.mode || 'audio',
          anonymous_avatar: false,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        alert(data.error || 'Failed to connect call');
        onClose?.();
        return;
      }

      setCallId(data.call_id);

      // Realistic 2-second ringing delay before user picks up
      setTimeout(() => {
        playConnectedChime();
        setCallPhase('connected');
        setCallDuration(0);
        setBillingToast(`Connected with ${calleeName} • 20 coins/min`);
        setTimeout(() => setBillingToast(null), 3500);
      }, 2100);
    } catch {
      alert('Network error initiating direct call.');
      onClose?.();
    }
  };

  // Timer & 60s Billing Tick while connected
  useEffect(() => {
    let timer: any;
    if (callPhase === 'connected') {
      timer = setInterval(() => {
        setCallDuration((prev) => {
          const next = prev + 1;
          if (next > 0 && next % 60 === 0 && callId) {
            triggerBillingHeartbeat(callId, next);
          }
          return next;
        });
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [callPhase, callId]);

  const triggerBillingHeartbeat = async (activeCallId: string, _seconds: number) => {
    try {
      const res = await fetch(`/v1/calls/${activeCallId}/heartbeat`, {
        method: 'POST',
      });
      const data = await res.json();
      if (data.success) {
        onCoinsDeducted(data.caller_balance);
        setBillingToast(`🪙 60s Heartbeat: -${data.rate_per_min} Coins. Balance: ${data.caller_balance}`);
        setTimeout(() => setBillingToast(null), 3500);
      } else if (data.call_status === 'dropped') {
        endCall();
        setBillingToast('⚠️ Call terminated due to insufficient coin balance.');
      }
    } catch (err) {
      console.error('Heartbeat error', err);
    }
  };

  const endCall = async () => {
    if (callId) {
      try {
        await fetch(`/v1/calls/${callId}/end`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ rating: selectedRating || 5 }),
        });
      } catch (err) {
        console.error(err);
      }
    }
    setCallPhase('ended');
  };

  const handleRatingSubmit = async (stars: number) => {
    setSelectedRating(stars);
    if (callId) {
      try {
        await fetch(`/v1/calls/${callId}/end`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ rating: stars }),
        });
      } catch (err) {
        console.error(err);
      }
    }
    setTimeout(() => {
      onClose?.();
    }, 600);
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
      "Filter coffee with sunset chats or iced latte at midnight?",
      "What is the best dish you can cook from scratch in 15 minutes?",
    ];
    setMiniGameQuestion(questions[Math.floor(Math.random() * questions.length)]);
  };

  const handleSendReaction = (emoji: string) => {
    const newReaction: FloatingReaction = {
      id: Date.now() + Math.random(),
      emoji,
      left: Math.random() * 60 + 20, // 20% to 80% horizontal range
    };
    setFloatingReactions((prev) => [...prev.slice(-8), newReaction]);
  };

  return (
    <div style={{ maxWidth: '440px', margin: '6px auto', padding: '0 12px', position: 'relative' }}>
      {/* Toast Alert */}
      {billingToast && (
        <div
          style={{
            position: 'absolute',
            top: '10px',
            left: '20px',
            right: '20px',
            zIndex: 100,
            background: 'rgba(255, 45, 85, 0.96)',
            border: '1px solid #ffffff',
            borderRadius: '999px',
            padding: '8px 16px',
            fontSize: '11.5px',
            fontWeight: 700,
            color: '#ffffff',
            textAlign: 'center',
            boxShadow: '0 4px 14px rgba(255, 45, 85, 0.45)',
          }}
        >
          {billingToast}
        </div>
      )}

      {/* =================================================================== */}
      {/* 1. CALLING / RINGING REALISTIC SCREEN                                */}
      {/* =================================================================== */}
      {callPhase === 'ringing' && (
        <div
          className="glass-panel"
          style={{
            height: '590px',
            borderRadius: '24px',
            padding: '28px 20px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            alignItems: 'center',
            textAlign: 'center',
            background: 'radial-gradient(circle at 50% 30%, rgba(56, 189, 248, 0.22) 0%, rgba(14, 16, 24, 0.98) 75%)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          {/* Top Bar */}
          <div style={{ width: '100%', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <button
              type="button"
              onClick={onClose}
              style={{
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '36px',
                height: '36px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#ffffff',
                cursor: 'pointer',
              }}
            >
              <ArrowLeft size={18} />
            </button>
            <span
              style={{
                fontSize: '11px',
                fontWeight: 700,
                color: '#38bdf8',
                background: 'rgba(56, 189, 248, 0.14)',
                padding: '4px 10px',
                borderRadius: '999px',
                border: '1px solid rgba(56, 189, 248, 0.3)',
              }}
            >
              YoUnMe HD Voice • Ringing...
            </span>
            <div style={{ width: '36px' }} />
          </div>

          {/* Center Pulsating Profile Ring */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', position: 'relative' }}>
            <div style={{ position: 'relative', width: '130px', height: '130px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {/* Outer Ripple Wave 1 */}
              <div
                className="call-pulse-ring"
                style={{
                  position: 'absolute',
                  inset: 0,
                  borderRadius: '50%',
                  border: '2px solid rgba(56, 189, 248, 0.65)',
                }}
              />
              {/* Outer Ripple Wave 2 */}
              <div
                className="call-pulse-ring"
                style={{
                  position: 'absolute',
                  inset: '-14px',
                  borderRadius: '50%',
                  border: '1.5px solid rgba(244, 63, 94, 0.45)',
                  animationDelay: '0.6s',
                }}
              />
              {/* Profile Avatar */}
              <div
                style={{
                  width: '116px',
                  height: '116px',
                  borderRadius: '50%',
                  padding: '3px',
                  background: 'linear-gradient(135deg, #38bdf8 0%, #f43f5e 100%)',
                  boxShadow: '0 8px 32px rgba(56, 189, 248, 0.45)',
                  zIndex: 2,
                }}
              >
                <img
                  src={calleeAvatar}
                  alt={calleeName}
                  style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
                />
              </div>
            </div>

            <h2 style={{ fontSize: '23px', fontWeight: 800, color: '#f8fafc', margin: '20px 0 4px' }}>
              {calleeName}
            </h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ fontSize: '13px', color: '#38bdf8', fontWeight: 700 }}>
                Ringing...
              </span>
              <span className="status-dot-online" style={{ width: '6px', height: '6px', background: '#38bdf8' }} />
            </div>
          </div>

          {/* Cancel Call Button */}
          <div style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
            <button
              type="button"
              onClick={onClose}
              title="Decline / Cancel call"
              style={{
                width: '64px',
                height: '64px',
                borderRadius: '50%',
                background: '#ef4444',
                border: 'none',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                boxShadow: '0 4px 20px rgba(239, 68, 68, 0.55)',
                transition: 'transform 0.15s ease',
              }}
              onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
              onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
            >
              <PhoneOff size={26} />
            </button>
            <span style={{ fontSize: '11px', color: '#94a3b8', fontWeight: 600 }}>Decline</span>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* 2. ACTIVE LIVE CALL SCREEN (REALISTIC DEMO)                         */}
      {/* =================================================================== */}
      {callPhase === 'connected' && (
        <div
          className="glass-panel"
          style={{
            height: '590px',
            borderRadius: '24px',
            position: 'relative',
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            padding: '18px 16px',
            background: 'radial-gradient(circle at 50% 25%, rgba(244, 63, 94, 0.22) 0%, rgba(10, 12, 18, 0.98) 75%)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
          }}
        >
          {/* Subtle Blurred Background of Callee for Real Call Immersion */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              backgroundImage: `url(${calleeAvatar})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              filter: 'blur(36px) brightness(0.24)',
              transform: 'scale(1.2)',
              pointerEvents: 'none',
              zIndex: 0,
            }}
          />

          {/* Floating Live Reaction Emojis */}
          <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 12, overflow: 'hidden' }}>
            {floatingReactions.map((item) => (
              <span
                key={item.id}
                className="call-reaction-float"
                style={{
                  position: 'absolute',
                  bottom: '120px',
                  left: `${item.left}%`,
                  fontSize: '28px',
                  userSelect: 'none',
                }}
              >
                {item.emoji}
              </span>
            ))}
          </div>

          {/* Header Bar */}
          <div style={{ position: 'relative', zIndex: 5, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <button
              type="button"
              onClick={endCall}
              title="Leave call"
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: 'rgba(255, 255, 255, 0.1)',
                border: 'none',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <ArrowLeft size={18} />
            </button>

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                background: 'rgba(0, 0, 0, 0.55)',
                padding: '4px 12px',
                borderRadius: '999px',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                backdropFilter: 'blur(8px)',
              }}
            >
              <div
                style={{
                  width: '7px',
                  height: '7px',
                  borderRadius: '50%',
                  background: '#22c55e',
                  boxShadow: '0 0 8px #22c55e',
                }}
              />
              <span style={{ fontSize: '10.5px', fontWeight: 700, color: '#22c55e', letterSpacing: '0.3px' }}>
                LIVE HD VOICE
              </span>
            </div>

            <div
              style={{
                fontSize: '13px',
                fontWeight: 800,
                color: '#ffffff',
                background: 'rgba(255, 255, 255, 0.1)',
                padding: '4px 12px',
                borderRadius: '999px',
                fontVariantNumeric: 'tabular-nums',
                backdropFilter: 'blur(8px)',
              }}
            >
              {formatTime(callDuration)}
            </div>
          </div>

          {/* Callee Center Presentation */}
          <div style={{ position: 'relative', zIndex: 5, textAlign: 'center', marginTop: '6px' }}>
            <div
              style={{
                width: '120px',
                height: '120px',
                margin: '0 auto 12px',
                borderRadius: '50%',
                padding: '3px',
                background: 'linear-gradient(135deg, #f43f5e 0%, #38bdf8 100%)',
                boxShadow: '0 8px 30px rgba(244, 63, 94, 0.45)',
                position: 'relative',
              }}
            >
              <img
                src={calleeAvatar}
                alt={calleeName}
                style={{
                  width: '100%',
                  height: '100%',
                  borderRadius: '50%',
                  objectFit: 'cover',
                  display: 'block',
                }}
              />
            </div>

            <h2 style={{ fontSize: '22px', fontWeight: 800, color: '#f8fafc', margin: 0 }}>
              {calleeName}
            </h2>
            <div style={{ fontSize: '11px', color: '#4ade80', marginTop: '4px', fontWeight: 700 }}>
              ● Connected • Speaking...
            </div>

            {/* Realistic Audio Equalizer Frequency Wave */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '5px',
                height: '32px',
                marginTop: '10px',
              }}
            >
              {[0.1, 0.35, 0.2, 0.5, 0.25, 0.4, 0.15].map((delay, idx) => (
                <div
                  key={idx}
                  style={{
                    width: '4px',
                    borderRadius: '999px',
                    background: micMuted
                      ? '#64748b'
                      : 'linear-gradient(180deg, #38bdf8 0%, #f43f5e 100%)',
                    animation: micMuted ? 'none' : 'voiceWaveBar 0.9s ease-in-out infinite alternate',
                    animationDelay: `${delay}s`,
                    height: micMuted ? '4px' : undefined,
                  }}
                />
              ))}
            </div>
          </div>

          {/* In-Call Quick Reaction Bar */}
          <div
            style={{
              position: 'relative',
              zIndex: 5,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '10px',
              padding: '6px 10px',
              background: 'rgba(0, 0, 0, 0.45)',
              borderRadius: '999px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              backdropFilter: 'blur(10px)',
              margin: '0 auto',
            }}
          >
            {['❤️', '🔥', '👋', '☕', '✨'].map((emoji) => (
              <button
                key={emoji}
                type="button"
                onClick={() => handleSendReaction(emoji)}
                title={`Send ${emoji}`}
                style={{
                  background: 'none',
                  border: 'none',
                  fontSize: '18px',
                  cursor: 'pointer',
                  padding: '2px 4px',
                  transition: 'transform 0.15s ease',
                }}
                onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(1.25)')}
                onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
              >
                {emoji}
              </button>
            ))}
          </div>

          {/* Icebreaker Mini-Game Card */}
          <div
            style={{
              position: 'relative',
              zIndex: 5,
              background: 'rgba(255, 255, 255, 0.05)',
              borderRadius: '16px',
              padding: '10px 14px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              backdropFilter: 'blur(10px)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
              <span style={{ fontSize: '9.5px', color: '#38bdf8', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.8px' }}>
                ⚡ Icebreaker Topic
              </span>
              <button
                type="button"
                onClick={nextMiniGame}
                style={{
                  background: 'none',
                  border: 'none',
                  color: '#94a3b8',
                  fontSize: '10.5px',
                  cursor: 'pointer',
                  textDecoration: 'underline',
                }}
              >
                Next
              </button>
            </div>
            <p style={{ fontSize: '11.5px', color: '#f1f5f9', fontWeight: 600, margin: 0, lineHeight: 1.35 }}>
              "{miniGameQuestion}"
            </p>
          </div>

          {/* Realistic Control Bar */}
          <div
            style={{
              position: 'relative',
              zIndex: 5,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-around',
              padding: '6px 10px',
              background: 'rgba(0, 0, 0, 0.65)',
              borderRadius: '20px',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              backdropFilter: 'blur(16px)',
            }}
          >
            {/* Mute Mic */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '3px' }}>
              <button
                type="button"
                onClick={() => setMicMuted(!micMuted)}
                title={micMuted ? 'Unmute' : 'Mute'}
                style={{
                  width: '46px',
                  height: '46px',
                  borderRadius: '50%',
                  background: micMuted ? '#ef4444' : 'rgba(255, 255, 255, 0.12)',
                  border: 'none',
                  color: '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                }}
              >
                {micMuted ? <MicOff size={20} /> : <Mic size={20} />}
              </button>
              <span style={{ fontSize: '10px', color: micMuted ? '#ef4444' : '#cbd5e1', fontWeight: 600 }}>
                {micMuted ? 'Muted' : 'Mute'}
              </span>
            </div>

            {/* Speaker Toggle */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '3px' }}>
              <button
                type="button"
                onClick={() => setSpeakerOn(!speakerOn)}
                title="Toggle Speakerphone"
                style={{
                  width: '46px',
                  height: '46px',
                  borderRadius: '50%',
                  background: speakerOn ? 'rgba(56, 189, 248, 0.25)' : 'rgba(255, 255, 255, 0.12)',
                  border: speakerOn ? '1.5px solid #38bdf8' : 'none',
                  color: speakerOn ? '#38bdf8' : '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                }}
              >
                {speakerOn ? <Volume2 size={20} /> : <VolumeX size={20} />}
              </button>
              <span style={{ fontSize: '10px', color: '#cbd5e1', fontWeight: 600 }}>
                {speakerOn ? 'Speaker' : 'Earpiece'}
              </span>
            </div>

            {/* Video Camera Toggle */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '3px' }}>
              <button
                type="button"
                onClick={() => setVideoOn(!videoOn)}
                title="Toggle Camera"
                style={{
                  width: '46px',
                  height: '46px',
                  borderRadius: '50%',
                  background: videoOn ? 'rgba(244, 63, 94, 0.25)' : 'rgba(255, 255, 255, 0.12)',
                  border: videoOn ? '1.5px solid #f43f5e' : 'none',
                  color: videoOn ? '#f43f5e' : '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                }}
              >
                {videoOn ? <Video size={20} /> : <VideoOff size={20} />}
              </button>
              <span style={{ fontSize: '10px', color: '#cbd5e1', fontWeight: 600 }}>
                {videoOn ? 'Video On' : 'Camera'}
              </span>
            </div>

            {/* End Call Button */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '3px' }}>
              <button
                type="button"
                onClick={endCall}
                title="End Call"
                style={{
                  width: '54px',
                  height: '54px',
                  borderRadius: '50%',
                  background: '#ff2d55',
                  border: 'none',
                  color: '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  boxShadow: '0 4px 22px rgba(255, 45, 85, 0.65)',
                  transition: 'transform 0.15s ease',
                }}
                onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
                onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
              >
                <PhoneOff size={24} />
              </button>
              <span style={{ fontSize: '10px', color: '#ff2d55', fontWeight: 700 }}>End</span>
            </div>
          </div>
        </div>
      )}

      {/* =================================================================== */}
      {/* 3. CALL ENDED SUMMARY & QUALITY RATING                              */}
      {/* =================================================================== */}
      {callPhase === 'ended' && (
        <div
          className="glass-panel"
          style={{
            height: '590px',
            borderRadius: '24px',
            padding: '28px 20px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            alignItems: 'center',
            textAlign: 'center',
            background: 'radial-gradient(circle at 50% 25%, rgba(34, 197, 94, 0.12) 0%, rgba(14, 16, 24, 0.98) 75%)',
            border: '1px solid rgba(255, 255, 255, 0.08)',
          }}
        >
          {/* Top Dismiss */}
          <div style={{ width: '100%', display: 'flex', justifyContent: 'flex-end' }}>
            <button
              type="button"
              onClick={onClose}
              style={{
                background: 'rgba(255, 255, 255, 0.08)',
                border: 'none',
                borderRadius: '50%',
                width: '34px',
                height: '34px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#94a3b8',
                cursor: 'pointer',
              }}
            >
              <X size={16} />
            </button>
          </div>

          {/* Center Details */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '82px',
                height: '82px',
                borderRadius: '50%',
                padding: '3px',
                background: 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)',
                boxShadow: '0 4px 18px rgba(34, 197, 94, 0.35)',
              }}
            >
              <img
                src={calleeAvatar}
                alt={calleeName}
                style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
              />
            </div>

            <div>
              <h2 style={{ fontSize: '21px', fontWeight: 800, color: '#f8fafc', margin: 0 }}>
                Call Ended
              </h2>
              <p style={{ fontSize: '13px', color: '#94a3b8', marginTop: '3px' }}>
                Audio session with <span style={{ color: '#ffffff', fontWeight: 700 }}>{calleeName}</span>
              </p>
              <div
                style={{
                  display: 'inline-block',
                  marginTop: '8px',
                  padding: '4px 12px',
                  borderRadius: '999px',
                  background: 'rgba(255, 255, 255, 0.06)',
                  fontSize: '12px',
                  color: '#e2e8f0',
                  fontWeight: 600,
                }}
              >
                Duration: {formatTime(callDuration)}
              </div>
            </div>

            {/* Star Rating */}
            <div style={{ marginTop: '12px' }}>
              <p style={{ fontSize: '12px', color: '#94a3b8', marginBottom: '8px' }}>
                Rate connection quality with {calleeName}:
              </p>
              <div style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    type="button"
                    onClick={() => handleRatingSubmit(star)}
                    style={{
                      background: 'rgba(255, 255, 255, 0.04)',
                      border: '1px solid rgba(255, 255, 255, 0.08)',
                      borderRadius: '10px',
                      padding: '7px',
                      cursor: 'pointer',
                      transition: 'transform 0.15s ease',
                    }}
                  >
                    <Star
                      size={22}
                      fill={star <= selectedRating ? '#ffd700' : 'none'}
                      color={star <= selectedRating ? '#ffd700' : '#64748b'}
                    />
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Return CTA */}
          <button
            type="button"
            onClick={onClose}
            style={{
              width: '100%',
              padding: '13px',
              borderRadius: '14px',
              background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
              border: 'none',
              color: '#ffffff',
              fontSize: '13.5px',
              fontWeight: 800,
              cursor: 'pointer',
              boxShadow: '0 4px 16px rgba(244, 63, 94, 0.35)',
            }}
          >
            Return to Discovery
          </button>
        </div>
      )}
    </div>
  );
};
