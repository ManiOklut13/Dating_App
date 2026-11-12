import React, { useState, useEffect } from 'react';
import { X, Camera, Mic, CheckCircle2, ShieldCheck, Sparkles, RefreshCw } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const VerificationModal: React.FC = () => {
  const {
    isVerificationModalOpen,
    setIsVerificationModalOpen,
    completeVerificationDemo,
  } = useProfile();

  const [step, setStep] = useState<'intro' | 'face' | 'voice' | 'success'>('intro');
  const [faceProgress, setFaceProgress] = useState(0);
  const [isBlinking, setIsBlinking] = useState(false);
  const [voiceProgress, setVoiceProgress] = useState(0);
  const [isRecordingVoice, setIsRecordingVoice] = useState(false);

  useEffect(() => {
    if (!isVerificationModalOpen) {
      setStep('intro');
      setFaceProgress(0);
      setVoiceProgress(0);
      setIsRecordingVoice(false);
    }
  }, [isVerificationModalOpen]);

  // Face Liveness Simulator
  useEffect(() => {
    let timer: any;
    if (step === 'face') {
      timer = setInterval(() => {
        setFaceProgress((prev) => {
          if (prev >= 60 && !isBlinking) {
            setIsBlinking(true);
          }
          if (prev >= 100) {
            clearInterval(timer);
            setTimeout(() => setStep('voice'), 800);
            return 100;
          }
          return prev + 10;
        });
      }, 400);
    }
    return () => clearInterval(timer);
  }, [step, isBlinking]);

  // Voice Verification Simulator
  useEffect(() => {
    let timer: any;
    if (isRecordingVoice) {
      timer = setInterval(() => {
        setVoiceProgress((prev) => {
          if (prev >= 100) {
            clearInterval(timer);
            setIsRecordingVoice(false);
            setTimeout(() => setStep('success'), 600);
            return 100;
          }
          return prev + 20;
        });
      }, 400);
    }
    return () => clearInterval(timer);
  }, [isRecordingVoice]);

  if (!isVerificationModalOpen) return null;

  const handleFinish = () => {
    completeVerificationDemo('verified');
    setIsVerificationModalOpen(false);
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 99999,
        background: 'rgba(5, 6, 12, 0.88)',
        backdropFilter: 'blur(20px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
      }}
      onClick={() => setIsVerificationModalOpen(false)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '460px',
          borderRadius: 'var(--radius-lg)',
          overflow: 'hidden',
          border: '1px solid rgba(29, 161, 242, 0.4)',
          boxShadow: '0 0 50px rgba(29, 161, 242, 0.25)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          style={{
            padding: '16px 20px',
            background: 'var(--bg-surface)',
            borderBottom: '1px solid var(--border-glass)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldCheck size={20} color="#1da1f2" />
            <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Profile Verification Flow</h3>
          </div>
          <button
            onClick={() => setIsVerificationModalOpen(false)}
            style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Modal Body depending on Step */}
        <div style={{ padding: '24px', textAlign: 'center' }}>
          
          {/* STEP 1: INTRO */}
          {step === 'intro' && (
            <div>
              <div
                style={{
                  width: '68px',
                  height: '68px',
                  borderRadius: '50%',
                  background: 'rgba(29, 161, 242, 0.15)',
                  border: '2px solid #1da1f2',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                }}
              >
                <Camera size={32} color="#1da1f2" />
              </div>

              <h3 style={{ fontSize: '20px', fontWeight: 800, marginBottom: '8px' }}>
                Get Your Blue Tick Badge
              </h3>

              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5, marginBottom: '20px' }}>
                Verification confirms your photos belong to you, preventing catfishing and impersonation across YoUnMe.
              </p>

              <div
                style={{
                  textAlign: 'left',
                  background: 'var(--surface-soft)',
                  padding: '14px',
                  borderRadius: 'var(--radius-md)',
                  marginBottom: '20px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '8px',
                  fontSize: '12px',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ color: '#00e676', fontWeight: 700 }}>1.</span>
                  <span>Face oval alignment & quick eye blink check</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ color: '#00e676', fontWeight: 700 }}>2.</span>
                  <span>Short 3-second voice passphrase</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ color: '#00e676', fontWeight: 700 }}>3.</span>
                  <span>Instant verified badge applied to your profile</span>
                </div>
              </div>

              <button
                onClick={() => setStep('face')}
                className="btn-primary"
                style={{ width: '100%', padding: '12px', fontSize: '14px' }}
              >
                Start Face Scan
              </button>
            </div>
          )}

          {/* STEP 2: FACE SCAN SIMULATION */}
          {step === 'face' && (
            <div>
              <div
                style={{
                  position: 'relative',
                  width: '180px',
                  height: '220px',
                  borderRadius: '50% / 60%',
                  border: `3px solid ${faceProgress === 100 ? '#00e676' : '#1da1f2'}`,
                  margin: '0 auto 20px',
                  overflow: 'hidden',
                  background: 'radial-gradient(circle at 50% 50%, rgba(29, 161, 242, 0.15) 0%, var(--card-base) 100%)',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 0 30px rgba(29, 161, 242, 0.3)',
                }}
              >
                <img
                  src="/aditya.jpg"
                  alt="Face align"
                  style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.7 }}
                />

                {/* Animated Scanner Bar */}
                <div
                  style={{
                    position: 'absolute',
                    top: `${faceProgress}%`,
                    left: 0,
                    right: 0,
                    height: '2px',
                    background: '#00e5ff',
                    boxShadow: '0 0 12px #00e5ff',
                    transition: 'top 0.4s ease',
                  }}
                />

                <div
                  style={{
                    position: 'absolute',
                    bottom: '12px',
                    background: 'rgba(0,0,0,0.7)',
                    padding: '4px 10px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '11px',
                    fontWeight: 700,
                    color: '#00e676',
                  }}
                >
                  {faceProgress < 60 ? 'Aligning Face...' : faceProgress < 100 ? 'Blink Eyes Twice! 👀' : 'Liveness Confirmed! ✓'}
                </div>
              </div>

              <h4 style={{ fontSize: '16px', fontWeight: 800, marginBottom: '6px' }}>
                Analyzing Biometric Geometry
              </h4>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                Please look directly into the camera frame and blink naturally.
              </p>
            </div>
          )}

          {/* STEP 3: VOICE PASSPHRASE SIMULATION */}
          {step === 'voice' && (
            <div>
              <div
                style={{
                  width: '74px',
                  height: '74px',
                  borderRadius: '50%',
                  background: isRecordingVoice ? 'rgba(255, 45, 85, 0.2)' : 'rgba(0, 229, 255, 0.15)',
                  border: isRecordingVoice ? '2px solid #ff2d55' : '2px solid #00e5ff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                  cursor: 'pointer',
                  animation: isRecordingVoice ? 'pulseGlow 1s infinite ease-in-out' : 'none',
                }}
                onClick={() => !isRecordingVoice && setIsRecordingVoice(true)}
              >
                <Mic size={32} color={isRecordingVoice ? '#ff2d55' : '#00e5ff'} />
              </div>

              <h4 style={{ fontSize: '17px', fontWeight: 800, marginBottom: '8px' }}>
                Voice Passphrase Verification
              </h4>

              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                Tap the microphone below and read the phrase aloud:
              </p>

              <div
                style={{
                  padding: '12px 16px',
                  borderRadius: 'var(--radius-md)',
                  background: 'var(--surface-soft)',
                  border: '1px solid var(--border-glass)',
                  fontSize: '14px',
                  fontWeight: 700,
                  color: '#ffd700',
                  marginBottom: '20px',
                }}
              >
                “YoUnMe confirms my authentic identity and presence.”
              </div>

              {/* Audio Waveform Simulator */}
              {isRecordingVoice ? (
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '4px', height: '30px', marginBottom: '16px' }}>
                  {[12, 24, 30, 16, 28, 14, 22, 29, 18, 12].map((h, i) => (
                    <div
                      key={i}
                      style={{
                        width: '4px',
                        height: `${h}px`,
                        background: 'var(--gradient-flame)',
                        borderRadius: '2px',
                        animation: 'pulseGlow 0.5s infinite alternate',
                      }}
                    />
                  ))}
                </div>
              ) : (
                <button
                  onClick={() => setIsRecordingVoice(true)}
                  className="btn-primary"
                  style={{ width: '100%', padding: '12px', fontSize: '13px', gap: '6px' }}
                >
                  <Mic size={16} />
                  Tap to Record Passphrase
                </button>
              )}
            </div>
          )}

          {/* STEP 4: SUCCESS CONFIRMATION */}
          {step === 'success' && (
            <div>
              <div
                style={{
                  width: '74px',
                  height: '74px',
                  borderRadius: '50%',
                  background: 'rgba(0, 230, 118, 0.15)',
                  border: '2px solid #00e676',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 16px',
                }}
              >
                <CheckCircle2 size={38} color="#00e676" />
              </div>

              <h3 style={{ fontSize: '20px', fontWeight: 800, marginBottom: '8px' }}>
                Verification Successful! 🎉
              </h3>

              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5, marginBottom: '24px' }}>
                Liveness and voice tests matched with 99% confidence. The Blue Tick verified badge is now active on your dating profile.
              </p>

              <button
                onClick={handleFinish}
                className="btn-primary"
                style={{ width: '100%', padding: '12px', fontSize: '14px' }}
              >
                Apply Verified Badge to Profile
              </button>
            </div>
          )}

        </div>
      </div>
    </div>
  );
};
