import React, { useEffect, useRef, useState } from 'react';
import {
  PhoneOff,
  Mic,
  MicOff,
  Volume2,
  VolumeX,
  Video,
  VideoOff,
  SwitchCamera,
  LayoutGrid,
  Sparkles,
  ShieldCheck,
  X,
  Delete,
} from 'lucide-react';
import { useChat } from './ChatContext';
import {
  playRingback,
  stopRingback,
  playConnectBeep,
  playDisconnect,
  playDtmf,
  playClick,
} from './callAudio';

/* Simulated real-time call overlay screens (audio + video).
   Realistic call lifecycle: Calling -> Ringing (ringback tone)
   -> connected (timer counts up). DTMF keypad tones, toggle clicks
   and disconnection sounds are synthesized with the Web Audio API.
   Ending a call animates the overlay out before restoring the
   previous screen. */

const CALL_EXIT_MS = 300;
const DIALING_MS = 1200;
const RINGING_MS = 3200; // moment the call "connects"
const PIP_W = 110;
const PIP_H = 150;

type CallPhase = 'dialing' | 'ringing' | 'connected';

export const CallModals: React.FC = () => {
  const {
    audioCallTarget,
    setAudioCallTarget,
    videoCallTarget,
    setVideoCallTarget,
    showToast,
  } = useChat();

  // Audio Call States
  const [audioPhase, setAudioPhase] = useState<CallPhase>('dialing');
  const [audioSeconds, setAudioSeconds] = useState(0);
  const [audioMuted, setAudioMuted] = useState(false);
  const [speakerOn, setSpeakerOn] = useState(true);
  const [audioClosing, setAudioClosing] = useState(false);

  // Video Call States
  const [videoPhase, setVideoPhase] = useState<CallPhase>('dialing');
  const [videoSeconds, setVideoSeconds] = useState(0);
  const [videoMuted, setVideoMuted] = useState(false);
  const [cameraOn, setCameraOn] = useState(true);
  const [isFrontCamera, setIsFrontCamera] = useState(true);
  const [videoClosing, setVideoClosing] = useState(false);

  /* ---- Draggable picture-in-picture state (video call) ---- */
  const [pipPos, setPipPos] = useState<{ x: number; y: number } | null>(null);
  const pipDragRef = useRef<{ dx: number; dy: number } | null>(null);

  /* ---- Local webcam integration for the PiP self-view ---- */
  const [webcamError, setWebcamError] = useState(false); // true => fallback to static self avatar
  const [isFlipping, setIsFlipping] = useState(false);
  const localVideoRef = useRef<HTMLVideoElement | null>(null);

  /* ---- DTMF keypad modal state (audio call) ---- */
  const [isKeypadOpen, setIsKeypadOpen] = useState(false);
  const [dialpadDigits, setDialpadDigits] = useState('');

  /* Reset audio call state when a target opens/closes */
  useEffect(() => {
    if (audioCallTarget) {
      setAudioPhase('dialing');
      setAudioSeconds(0);
      setAudioMuted(false);
      setSpeakerOn(true);
      setAudioClosing(false);
      setIsKeypadOpen(false);
      setDialpadDigits('');
      return;
    }
    setAudioPhase('dialing');
    setAudioSeconds(0);
    setAudioClosing(false);
  }, [audioCallTarget]);

  /* Reset video call state when a target opens/closes */
  useEffect(() => {
    if (videoCallTarget) {
      setVideoPhase('dialing');
      setVideoSeconds(0);
      setVideoMuted(false);
      setCameraOn(true);
      setIsFrontCamera(true);
      setVideoClosing(false);
      setPipPos(null);
      return;
    }
    setVideoPhase('dialing');
    setVideoSeconds(0);
    setVideoClosing(false);
    setWebcamError(false);
  }, [videoCallTarget]);

  /* ---- Live local webcam stream for the PiP (image fallback on failure) ---- */
  useEffect(() => {
    if (!videoCallTarget || videoClosing || !cameraOn) return;
    if (!navigator.mediaDevices?.getUserMedia) {
      setWebcamError(true);
      return;
    }
    let stream: MediaStream | null = null;
    let cancelled = false;
    (async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: isFrontCamera ? 'user' : 'environment' },
          audio: false,
        });
        if (cancelled) {
          stream.getTracks().forEach((t) => t.stop());
          return;
        }
        if (localVideoRef.current) {
          localVideoRef.current.srcObject = stream;
          setWebcamError(false);
        }
      } catch {
        if (!cancelled) setWebcamError(true);
      }
    })();
    return () => {
      cancelled = true;
      stream?.getTracks().forEach((t) => t.stop());
    };
  }, [videoCallTarget, videoClosing, cameraOn, isFrontCamera]);

  /* Flip camera with a 3D rotate animation before swapping the stream */
  const handleFlipCamera = () => {
    if (isFlipping) return;
    setIsFlipping(true);
    window.setTimeout(() => {
      setIsFrontCamera((prev) => !prev);
      showToast({ type: 'info', text: `Switched to ${isFrontCamera ? 'Rear' : 'Front'} Camera` });
    }, 225);
    window.setTimeout(() => setIsFlipping(false), 460);
  };

  /* Audio lifecycle: Calling -> Ringing(ringback) -> Connected(beep) */
  useEffect(() => {
    if (!audioCallTarget || audioClosing) {
      stopRingback();
      return;
    }
    const ringingTimer = window.setTimeout(() => {
      setAudioPhase('ringing');
      playRingback();
    }, DIALING_MS);
    const connectTimer = window.setTimeout(() => {
      setAudioPhase('connected');
      stopRingback();
      playConnectBeep();
    }, RINGING_MS + DIALING_MS);
    return () => {
      window.clearTimeout(ringingTimer);
      window.clearTimeout(connectTimer);
      stopRingback();
    };
  }, [audioCallTarget, audioClosing]);

  /* Video lifecycle: Connecting -> Ringing(ringback) -> Connected(beep) */
  useEffect(() => {
    if (!videoCallTarget || videoClosing) {
      stopRingback();
      return;
    }
    const ringingTimer = window.setTimeout(() => {
      setVideoPhase('ringing');
      playRingback();
    }, DIALING_MS);
    const connectTimer = window.setTimeout(() => {
      setVideoPhase('connected');
      stopRingback();
      playConnectBeep();
    }, RINGING_MS + DIALING_MS);
    return () => {
      window.clearTimeout(ringingTimer);
      window.clearTimeout(connectTimer);
      stopRingback();
    };
  }, [videoCallTarget, videoClosing]);

  // Duration timers start counting up 00:00 -> 00:01... only once connected
  useEffect(() => {
    if (audioPhase !== 'connected' || !audioCallTarget || audioClosing) return;
    const interval = setInterval(() => setAudioSeconds((s) => s + 1), 1000);
    return () => clearInterval(interval);
  }, [audioPhase, audioCallTarget, audioClosing]);

  useEffect(() => {
    if (videoPhase !== 'connected' || !videoCallTarget || videoClosing) return;
    const interval = setInterval(() => setVideoSeconds((s) => s + 1), 1000);
    return () => clearInterval(interval);
  }, [videoPhase, videoCallTarget, videoClosing]);

  /* Simulated video-stream particle fallback (animated canvas) */
  const particleCanvasRef = useRef<HTMLCanvasElement | null>(null);
  useEffect(() => {
    const canvas = particleCanvasRef.current;
    if (!videoCallTarget || videoClosing || !canvas) return;
    const ac = canvas.getContext('2d');
    if (!ac) return;

    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const resize = () => {
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;
      ac.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();

    /* Simulated remote HD stream: matrix-style falling glyph streams
       blended with drifting neon glow particles over the contact feed. */
    const GLYPHS = '01アイウエオカキクケコサシスセソHOST';
    const fontSize = 14;
    const cols = Math.ceil(window.innerWidth / 18);
    const drops = Array.from({ length: cols }, () => ({
      y: Math.random() * window.innerHeight,
      speed: 1.2 + Math.random() * 2.6,
      seed: Math.floor(Math.random() * 97),
    }));
    const particles = Array.from({ length: 24 }, () => ({
      x: Math.random() * window.innerWidth,
      y: Math.random() * window.innerHeight,
      r: 1 + Math.random() * 2.2,
      vy: -(0.08 + Math.random() * 0.35),
      sway: Math.random() * Math.PI * 2,
      hue: Math.random() > 0.5 ? '0, 229, 255' : '255, 45, 85',
      alpha: 0.05 + Math.random() * 0.09,
    }));

    let raf = 0;
    const draw = () => {
      ac.clearRect(0, 0, window.innerWidth, window.innerHeight);

      // Glyph streams
      ac.font = `${fontSize}px monospace`;
      drops.forEach((d, i) => {
        const x = i * 18 + 2;
        const head = GLYPHS[(d.seed + Math.floor(d.y / fontSize)) % GLYPHS.length];
        const tail = GLYPHS[(d.seed + Math.floor(d.y / fontSize) + 3) % GLYPHS.length];
        ac.fillStyle = 'rgba(0, 229, 255, 0.32)';
        ac.fillText(head, x, d.y);
        ac.fillStyle = 'rgba(0, 229, 255, 0.13)';
        ac.fillText(tail, x, d.y - fontSize);
        d.y += d.speed;
        if (d.y > window.innerHeight + fontSize) {
          d.y = -fontSize * (1 + Math.random() * 3);
          d.speed = 1.2 + Math.random() * 2.6;
          d.seed = Math.floor(Math.random() * 97);
        }
      });

      // Soft glow particles
      particles.forEach((p) => {
        p.sway += 0.008;
        p.x += Math.sin(p.sway) * 0.25;
        p.y += p.vy;
        if (p.y < -6) {
          p.y = window.innerHeight + 6;
          p.x = Math.random() * window.innerWidth;
        }
        ac.beginPath();
        ac.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ac.fillStyle = `rgba(${p.hue}, ${p.alpha})`;
        ac.shadowColor = `rgba(${p.hue}, 0.8)`;
        ac.shadowBlur = 8;
        ac.fill();
      });

      raf = window.requestAnimationFrame(draw);
    };
    draw();

    window.addEventListener('resize', resize);
    return () => {
      window.cancelAnimationFrame(raf);
      window.removeEventListener('resize', resize);
    };
  }, [videoCallTarget, videoClosing]);

  const formatDuration = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  /* ---- Draggable PiP handlers ---- */
  const pipDefault = () => ({
    x: Math.max(8, window.innerWidth - PIP_W - 20),
    y: 96,
  });

  const clampPip = (x: number, y: number) => ({
    x: Math.min(Math.max(8, x), Math.max(8, window.innerWidth - PIP_W - 8)),
    y: Math.min(Math.max(8, y), Math.max(8, window.innerHeight - PIP_H - 8)),
  });

  const onPipPointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    e.currentTarget.setPointerCapture(e.pointerId);
    const base = pipPos ? clampPip(pipPos.x, pipPos.y) : pipDefault();
    pipDragRef.current = { dx: e.clientX - base.x, dy: e.clientY - base.y };
    setPipPos(base);
  };

  const onPipPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const drag = pipDragRef.current;
    if (!drag) return;
    setPipPos(clampPip(e.clientX - drag.dx, e.clientY - drag.dy));
  };

  const onPipPointerUp = () => {
    pipDragRef.current = null;
  };

  /* End-call flows: disconnection sound + exit animation, then unmount */
  const handleEndAudioCall = () => {
    if (!audioCallTarget || audioClosing) return;
    setAudioClosing(true);
    stopRingback();
    playDisconnect();
    const name = audioCallTarget.counterpart.nickname;
    const secs = audioSeconds;
    window.setTimeout(() => {
      showToast({
        type: 'info',
        text: `Audio call with ${name} ended (${formatDuration(secs)})`,
      });
      setAudioCallTarget(null);
    }, CALL_EXIT_MS);
  };

  const handleEndVideoCall = () => {
    if (!videoCallTarget || videoClosing) return;
    setVideoClosing(true);
    stopRingback();
    playDisconnect();
    const name = videoCallTarget.counterpart.nickname;
    const secs = videoSeconds;
    window.setTimeout(() => {
      showToast({
        type: 'info',
        text: `Video call with ${name} ended (${formatDuration(secs)})`,
      });
      setVideoCallTarget(null);
    }, CALL_EXIT_MS);
  };

  const audioScreenAnim = audioClosing ? 'call-screen-out' : 'call-screen-in';
  const videoScreenAnim = videoClosing ? 'call-screen-out' : 'call-screen-in';

  const statusLabel = (phase: CallPhase, seconds: number, connectingText: string) => {
    if (phase === 'connected') return formatDuration(seconds);
    if (phase === 'ringing') return 'Ringing...';
    return connectingText;
  };
  const statusColor = (phase: CallPhase, connectedColor: string) =>
    phase === 'connected' ? connectedColor : phase === 'ringing' ? '#ffd700' : '#ffa502';

  return (
    <>
      {/* ================= AUDIO CALL SCREEN ================= */}
      {audioCallTarget && (
        <div
          className={audioScreenAnim}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'var(--bg-dark)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '40px 24px',
            overflow: 'hidden',
          }}
        >
          {/* Dark blurred profile backdrop with subtle ambient pulsing */}
          <div
            className="ambient-pulse"
            style={{
              position: 'absolute',
              inset: '-40px',
              zIndex: 0,
              background: `url(${audioCallTarget.counterpart.avatar}) center/cover no-repeat`,
              filter: 'blur(38px) brightness(0.35) saturate(1.2)',
              transform: 'scale(1.15)',
            }}
          />
          <div
            style={{
              position: 'absolute',
              inset: 0,
              zIndex: 1,
              background:
                'linear-gradient(180deg, rgba(8,10,16,0.55) 0%, rgba(8,10,16,0.15) 40%, rgba(8,10,16,0.9) 100%)',
            }}
          />

          {/* Header Security Badge */}
          <div
            style={{
              position: 'relative',
              zIndex: 2,
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 14px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(15, 18, 29, 0.7)',
              backdropFilter: 'blur(10px)',
              border: '1px solid var(--border-glass)',
              fontSize: '12px',
              color: 'var(--text-secondary)',
            }}
          >
            <ShieldCheck size={14} color="#00e676" />
            <span>Encrypted LiveKit Voice Stream</span>
          </div>

          {/* Caller Details & Visualizer */}
          <div
            style={{
              position: 'relative',
              zIndex: 2,
              textAlign: 'center',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
            }}
          >
            {/* Glowing Avatar with multi-layered pulsing call rings */}
            <div
              style={{
                position: 'relative',
                width: '150px',
                height: '150px',
                marginBottom: '26px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {/* Expanding pulse rings (staggered layers) */}
              {['0s', '0.66s', '1.32s'].map((delay) => (
                <div
                  key={delay}
                  className="call-ring"
                  style={{
                    position: 'absolute',
                    inset: 0,
                    borderRadius: '50%',
                    border: '2px solid rgba(255, 45, 85, 0.7)',
                    animationDelay: delay,
                  }}
                />
              ))}

              <div
                style={{
                  position: 'absolute',
                  inset: '-12px',
                  borderRadius: '50%',
                  background: 'var(--gradient-flame)',
                  opacity: 0.45,
                  filter: 'blur(18px)',
                  animation: 'pulseGlow 2s infinite ease-in-out',
                }}
              />

              <img
                src={audioCallTarget.counterpart.avatar}
                alt={audioCallTarget.counterpart.nickname}
                style={{
                  width: '124px',
                  height: '124px',
                  borderRadius: '50%',
                  objectFit: 'cover',
                  position: 'relative',
                  border: '3px solid #ff2d55',
                  boxShadow: '0 0 40px rgba(255, 45, 85, 0.45)',
                }}
              />

              {audioCallTarget.counterpart.is_verified && (
                <div
                  className="badge-blue-tick"
                  style={{
                    position: 'absolute',
                    bottom: '10px',
                    right: '10px',
                    width: '24px',
                    height: '24px',
                    fontSize: '14px',
                    zIndex: 3,
                  }}
                >
                  ✓
                </div>
              )}
            </div>

            <h2 style={{ fontSize: '25px', fontWeight: 800, marginBottom: '6px', textShadow: '0 2px 10px rgba(0,0,0,0.7)' }}>
              {audioCallTarget.counterpart.nickname}
            </h2>

            <div style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
              {audioCallTarget.counterpart.city}
            </div>

            {/* Live call state: Calling... -> Ringing... -> stopwatch */}
            <div
              style={{
                fontSize: '16px',
                fontWeight: 700,
                color: statusColor(audioPhase, '#00e676'),
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                fontVariantNumeric: 'tabular-nums',
              }}
            >
              <span
                style={{
                  width: '8px',
                  height: '8px',
                  borderRadius: '50%',
                  background: statusColor(audioPhase, '#00e676'),
                  display: 'inline-block',
                  animation: audioPhase === 'connected' ? 'none' : 'pulseGlow 1.2s infinite',
                }}
              />
              {statusLabel(audioPhase, audioSeconds, 'Calling...')}
            </div>

            {/* Live Audio Visualizer — dynamic frequency-bounce bars */}
            {audioPhase === 'connected' && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'flex-end',
                  gap: '4px',
                  height: '36px',
                  marginTop: '28px',
                }}
              >
                {[14, 28, 36, 20, 32, 16, 24, 34, 18, 30].map((h, i) => (
                  <div
                    key={i}
                    className="viz-bar"
                    style={{
                      width: '4px',
                      height: `${h}px`,
                      background: 'var(--gradient-flame)',
                      borderRadius: '2px',
                      opacity: audioMuted ? 0.35 : 0.9,
                      transform: audioMuted ? 'scaleY(0.35)' : undefined,
                      animationDelay: `${i * 0.055}s`,
                      animationDuration: `${0.55 + (i % 5) * 0.12}s`,
                      transition: 'opacity 0.25s ease',
                    }}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Bottom Action Bar: frosted glass, 4 evenly spaced buttons */}
          <div
            style={{
              position: 'relative',
              zIndex: 2,
              width: '100%',
              maxWidth: '340px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-evenly',
            }}
          >
            {/* 1. Mute / Microphone Toggle */}
            <button
              onClick={() => {
                setAudioMuted(!audioMuted);
                playClick();
                showToast({
                  type: 'info',
                  text: !audioMuted ? 'Microphone muted' : 'Microphone unmuted',
                });
              }}
              aria-label="Mute microphone"
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '50%',
                background: audioMuted ? 'rgba(255, 71, 87, 0.22)' : 'rgba(255,255,255,0.08)',
                border: audioMuted ? '1px solid #ff4757' : '1px solid var(--border-glass)',
                color: audioMuted ? '#ff4757' : '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                backdropFilter: 'blur(10px)',
                WebkitBackdropFilter: 'blur(10px)',
              }}
            >
              {audioMuted ? <MicOff size={22} /> : <Mic size={22} />}
            </button>

            {/* 2. Speaker Toggle */}
            <button
              onClick={() => {
                setSpeakerOn(!speakerOn);
                playClick();
                showToast({
                  type: 'info',
                  text: speakerOn ? 'Earpiece mode active' : 'Speakerphone active',
                });
              }}
              aria-label="Toggle speaker"
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '50%',
                background: speakerOn ? 'rgba(0, 229, 255, 0.16)' : 'rgba(255,255,255,0.08)',
                border: speakerOn ? '1px solid #00e5ff' : '1px solid var(--border-glass)',
                color: speakerOn ? '#00e5ff' : '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                backdropFilter: 'blur(10px)',
                WebkitBackdropFilter: 'blur(10px)',
              }}
            >
              {speakerOn ? <Volume2 size={22} /> : <VolumeX size={22} />}
            </button>

            {/* 3. Keypad / Add Call (opens DTMF dialpad) */}
            <button
              onClick={() => {
                playClick();
                setIsKeypadOpen(true);
              }}
              aria-label="Open keypad"
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '50%',
                background: 'rgba(255,255,255,0.08)',
                border: '1px solid var(--border-glass)',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                backdropFilter: 'blur(10px)',
                WebkitBackdropFilter: 'blur(10px)',
              }}
            >
              <LayoutGrid size={22} />
            </button>

            {/* 4. Red End Call */}
            <button
              onClick={handleEndAudioCall}
              aria-label="End call"
              style={{
                width: '66px',
                height: '66px',
                borderRadius: '50%',
                background: '#ff2d55',
                border: 'none',
                color: '#ffffff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                boxShadow: '0 0 30px rgba(255, 45, 85, 0.6)',
              }}
            >
              <PhoneOff size={28} />
            </button>
          </div>

          {/* ---- DTMF Keypad Modal (audio feedback per key) ---- */}
          {isKeypadOpen && (
            <div
              style={{
                position: 'absolute',
                inset: 0,
                zIndex: 30,
                background: 'rgba(5, 6, 12, 0.7)',
                backdropFilter: 'blur(8px)',
                display: 'flex',
                alignItems: 'flex-end',
                justifyContent: 'center',
                padding: '24px',
              }}
              onClick={() => setIsKeypadOpen(false)}
            >
              <div
                className="glass-panel"
                style={{
                  width: '100%',
                  maxWidth: '300px',
                  borderRadius: 'var(--radius-lg)',
                  border: '1px solid var(--border-glass)',
                  background: 'rgba(15, 18, 29, 0.96)',
                  padding: '18px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '12px',
                }}
                onClick={(e) => e.stopPropagation()}
              >
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                  }}
                >
                  <span style={{ fontSize: '14px', fontWeight: 800 }}>Keypad</span>
                  <button
                    onClick={() => setIsKeypadOpen(false)}
                    aria-label="Close keypad"
                    style={{
                      background: 'transparent',
                      border: 'none',
                      color: 'var(--text-secondary)',
                      cursor: 'pointer',
                      display: 'flex',
                    }}
                  >
                    <X size={18} />
                  </button>
                </div>

                {/* Dialed digits display */}
                <div
                  style={{
                    height: '28px',
                    textAlign: 'center',
                    letterSpacing: '3px',
                    fontSize: '18px',
                    fontWeight: 700,
                    color: 'var(--text-primary)',
                    opacity: 0.9,
                  }}
                >
                  {dialpadDigits}
                </div>

                {/* Digits grid */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px' }}>
                  {['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'].map((key) => (
                    <button
                      key={key}
                      onClick={() => {
                        playDtmf(key);
                        setDialpadDigits((prev) => (prev + key).slice(-10));
                      }}
                      aria-label={`DTMF key ${key}`}
                      style={{
                        height: '52px',
                        borderRadius: '50%',
                        background: 'rgba(255,255,255,0.07)',
                        border: '1px solid var(--border-glass)',
                        color: '#ffffff',
                        fontSize: '20px',
                        fontWeight: 700,
                        cursor: 'pointer',
                        transition: 'transform 0.08s ease',
                      }}
                      onPointerDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
                      onPointerUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
                      onPointerLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
                    >
                      {key}
                    </button>
                  ))}
                </div>

                {/* Backspace */}
                <button
                  onClick={() => {
                    playClick();
                    setDialpadDigits((prev) => prev.slice(0, -1));
                  }}
                  aria-label="Backspace"
                  style={{
                    margin: '0 auto',
                    width: '52px',
                    height: '52px',
                    borderRadius: '50%',
                    background: 'rgba(255,255,255,0.07)',
                    border: '1px solid var(--border-glass)',
                    color: 'var(--text-secondary)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                  }}
                >
                  <Delete size={20} />
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ================= VIDEO CALL SCREEN ================= */}
      {videoCallTarget && (
        <div
          className={videoScreenAnim}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'var(--bg-dark)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            overflow: 'hidden',
          }}
        >
          {/* Remote Video Canvas (Simulated stream / particle fallback) */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              zIndex: 1,
              background: `linear-gradient(180deg, rgba(8,10,16,0.25) 0%, rgba(8,10,16,0.8) 100%), url(${videoCallTarget.counterpart.avatar}) center/cover no-repeat`,
              filter: videoPhase === 'connected' ? 'none' : 'blur(10px)',
              transition: 'filter 0.6s ease',
            }}
          />

          {/* Animated particle layer simulating a live feed */}
          <canvas
            ref={particleCanvasRef}
            style={{
              position: 'absolute',
              inset: 0,
              zIndex: 2,
              width: '100%',
              height: '100%',
              pointerEvents: 'none',
              opacity: videoPhase === 'connected' ? 1 : 0.35,
              transition: 'opacity 0.6s ease',
            }}
          />

          {/* Top Bar: Caller Info, Call Duration & Camera Flip */}
          <div
            style={{
              position: 'relative',
              zIndex: 10,
              padding: '24px 20px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              background: 'linear-gradient(180deg, rgba(8,10,16,0.8) 0%, transparent 100%)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ position: 'relative', width: '42px', height: '42px' }}>
                <img
                  src={videoCallTarget.counterpart.avatar}
                  alt={videoCallTarget.counterpart.nickname}
                  style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
                />
              </div>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <span style={{ fontWeight: 800, fontSize: '16px' }}>{videoCallTarget.counterpart.nickname}</span>
                  {videoCallTarget.counterpart.is_verified && <span className="badge-blue-tick">✓</span>}
                </div>
                <div
                  style={{
                    fontSize: '12px',
                    color: statusColor(videoPhase, '#00e676'),
                    fontWeight: 600,
                    fontVariantNumeric: 'tabular-nums',
                  }}
                >
                  {videoPhase === 'connected'
                    ? `Live • ${formatDuration(videoSeconds)}`
                    : statusLabel(videoPhase, 0, 'Connecting HD Video...')}
                </div>
              </div>
            </div>

            {/* Right cluster: Vibe pill + camera flip icon */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  padding: '6px 12px',
                  borderRadius: 'var(--radius-full)',
                  background: 'rgba(255, 215, 0, 0.15)',
                  border: '1px solid rgba(255, 215, 0, 0.4)',
                  color: '#ffd700',
                  fontSize: '12px',
                  fontWeight: 700,
                }}
              >
                <Sparkles size={14} />
                <span>{videoCallTarget.counterpart.vibe_score}% Match</span>
              </div>

              <button
                onClick={() => {
                  playClick();
                  handleFlipCamera();
                }}
                aria-label="Switch camera"
                style={{
                  width: '38px',
                  height: '38px',
                  borderRadius: '50%',
                  background: 'rgba(15, 18, 29, 0.7)',
                  backdropFilter: 'blur(10px)',
                  border: '1px solid var(--border-glass)',
                  color: '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <SwitchCamera size={18} />
              </button>
            </div>
          </div>

          {/* Local User Picture-In-Picture Feed — touch-draggable, 3D flip camera */}
          {cameraOn && (
            <div className="flip-3d-wrap"
              onPointerDown={onPipPointerDown}
              onPointerMove={onPipPointerMove}
              onPointerUp={onPipPointerUp}
              onPointerCancel={onPipPointerUp}
              style={{
                position: 'absolute',
                zIndex: 10,
                ...(pipPos ? { left: `${pipPos.x}px`, top: `${pipPos.y}px` } : { top: '96px', right: '20px' }),
                width: `${PIP_W}px`,
                height: `${PIP_H}px`,
                borderRadius: 'var(--radius-md)',
                overflow: 'hidden',
                boxShadow: 'var(--shadow-lg)',
                border: '2px solid rgba(255, 255, 255, 0.25)',
                background: 'var(--bg-card)',
                touchAction: 'none',
                cursor: 'grab',
                userSelect: 'none',
                WebkitUserSelect: 'none',
              }}
            >
              <div
                className="flip-3d"
                style={{
                  width: '100%',
                  height: '100%',
                  borderRadius: 'inherit',
                  overflow: 'hidden',
                  transform: `rotateY(${isFlipping ? 90 : isFrontCamera ? 0 : 180}deg)`,
                }}
              >
                <video
                  ref={localVideoRef}
                  autoPlay
                  muted
                  playsInline
                  style={{
                    display: webcamError ? 'none' : 'block',
                    width: '100%',
                    height: '100%',
                    objectFit: 'cover',
                    transform: isFrontCamera ? 'scaleX(-1)' : 'none',
                  }}
                />
                {webcamError && (
                  <img
                    src="/aditya.jpg"
                    alt="My Camera"
                    draggable={false}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  />
                )}
              </div>
              <div
                style={{
                  position: 'absolute',
                  bottom: '4px',
                  left: '6px',
                  fontSize: '9px',
                  color: 'var(--text-primary)',
                  background: 'rgba(0,0,0,0.6)',
                  padding: '1px 4px',
                  borderRadius: '4px',
                  pointerEvents: 'none',
                }}
              >
                You ({isFrontCamera ? 'Front' : 'Back'})
              </div>
            </div>
          )}
          {cameraOn === false && (
            <div
              style={{
                position: 'absolute',
                zIndex: 10,
                top: '96px',
                right: '20px',
                width: `${PIP_W}px`,
                height: `${PIP_H}px`,
                borderRadius: 'var(--radius-md)',
                overflow: 'hidden',
                border: '2px solid rgba(255, 71, 87, 0.35)',
                background: 'rgba(15, 18, 29, 0.9)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                gap: '6px',
                color: 'var(--text-muted)',
                fontSize: '10px',
              }}
            >
              <VideoOff size={24} />
              <span>Cam Off</span>
            </div>
          )}

          {/* Bottom Floating Glassmorphism Control Bar */}
          <div
            style={{
              position: 'relative',
              zIndex: 10,
              padding: '24px',
              background: 'linear-gradient(0deg, rgba(8,10,16,0.75) 0%, transparent 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '18px',
                padding: '12px 20px',
                borderRadius: '999px',
                background: 'rgba(255, 255, 255, 0.07)',
                backdropFilter: 'blur(16px)',
                WebkitBackdropFilter: 'blur(16px)',
                border: '1px solid rgba(255, 255, 255, 0.14)',
                boxShadow: '0 12px 40px rgba(0, 0, 0, 0.45)',
              }}
            >
              {/* Flip Camera */}
              <button
                onClick={() => {
                  playClick();
                  handleFlipCamera();
                }}
                aria-label="Flip camera"
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.18)',
                  color: 'var(--text-primary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <SwitchCamera size={20} />
              </button>

              {/* Toggle Camera (PiP self-view on/off) */}
              <button
                onClick={() => {
                  playClick();
                  setCameraOn(!cameraOn);
                  showToast({
                    type: 'info',
                    text: cameraOn ? 'Camera turned off' : 'Camera turned on',
                  });
                }}
                aria-label="Toggle camera"
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: cameraOn ? 'rgba(255,255,255,0.08)' : 'rgba(255, 71, 87, 0.22)',
                  border: cameraOn ? '1px solid rgba(255, 255, 255, 0.18)' : '1px solid #ff4757',
                  color: cameraOn ? '#ffffff' : '#ff4757',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                {cameraOn ? <Video size={20} /> : <VideoOff size={20} />}
              </button>

              {/* Toggle Mic */}
              <button
                onClick={() => {
                  setVideoMuted(!videoMuted);
                  playClick();
                  showToast({
                    type: 'info',
                    text: !videoMuted ? 'Microphone muted' : 'Microphone unmuted',
                  });
                }}
                aria-label="Mute microphone"
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: videoMuted ? 'rgba(255, 71, 87, 0.22)' : 'rgba(255,255,255,0.08)',
                  border: videoMuted ? '1px solid #ff4757' : '1px solid rgba(255, 255, 255, 0.18)',
                  color: videoMuted ? '#ff4757' : '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                {videoMuted ? <MicOff size={20} /> : <Mic size={20} />}
              </button>

              {/* End Video Call */}
              <button
                onClick={handleEndVideoCall}
                aria-label="End call"
                style={{
                  width: '62px',
                  height: '62px',
                  borderRadius: '50%',
                  background: '#ff2d55',
                  border: 'none',
                  color: '#ffffff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  boxShadow: '0 0 30px rgba(255, 45, 85, 0.6)',
                }}
              >
                <PhoneOff size={26} />
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
