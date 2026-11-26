import React, { useState } from 'react';
import { Sparkles, Shield, Lock, Phone, Mail, HelpCircle, X, ArrowRight, CheckCircle2 } from 'lucide-react';

interface SplashLandingPageProps {
  onGoToSignUp: () => void;
  onGoToSignIn: () => void;
}

export const SplashLandingPage: React.FC<SplashLandingPageProps> = ({
  onGoToSignUp,
  onGoToSignIn,
}) => {
  const [isRecoveryOpen, setIsRecoveryOpen] = useState(false);
  const [recoveryMethod, setRecoveryMethod] = useState<'phone' | 'email' | 'support'>('phone');
  const [recoveryInput, setRecoveryInput] = useState('');
  const [recoverySent, setRecoverySent] = useState(false);

  const handleSendRecovery = (e: React.FormEvent) => {
    e.preventDefault();
    if (!recoveryInput.trim()) return;
    setRecoverySent(true);
    setTimeout(() => {
      setRecoverySent(false);
      setIsRecoveryOpen(false);
      setRecoveryInput('');
    }, 2400);
  };

  return (
    <div
      style={{
        position: 'relative',
        minHeight: '100%',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: '32px 24px 28px',
        background: 'linear-gradient(180deg, #0e1017 0%, #12151e 50%, #151822 100%)',
        color: '#FFFFFF',
        boxSizing: 'border-box',
        overflow: 'hidden',
      }}
    >
      {/* Subtle calm ambient light */}
      <div
        style={{
          position: 'absolute',
          top: '-80px',
          right: '-50px',
          width: '260px',
          height: '260px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(244, 63, 94, 0.08) 0%, transparent 70%)',
          pointerEvents: 'none',
          filter: 'blur(50px)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: '15%',
          left: '-60px',
          width: '240px',
          height: '240px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(56, 189, 248, 0.06) 0%, transparent 70%)',
          pointerEvents: 'none',
          filter: 'blur(50px)',
        }}
      />

      {/* Top Header / Branding Pill */}
      <div style={{ display: 'flex', justifyContent: 'center', marginTop: '12px', zIndex: 2 }}>
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            padding: '5px 14px',
            borderRadius: '999px',
            background: 'rgba(255, 255, 255, 0.04)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(10px)',
            fontSize: '11px',
            fontWeight: 700,
            color: '#e2e8f0',
            letterSpacing: '0.8px',
            textTransform: 'uppercase',
          }}
        >
          <Sparkles size={12} color="#f43f5e" />
          <span>YoUnMe Dating App</span>
        </div>
      </div>

      {/* Hero Visual & Branding */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          textAlign: 'center',
          marginTop: 'auto',
          marginBottom: 'auto',
          padding: '24px 0',
          zIndex: 2,
        }}
      >
        {/* 1. App Icon with Slow Zoom Pop-up */}
        <div
          className="splash-icon-entrance"
          style={{
            position: 'relative',
            width: '110px',
            height: '110px',
            marginBottom: '18px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          {/* Clean App Icon Container with understated shadow and subtle border */}
          <div
            style={{
              width: '100%',
              height: '100%',
              borderRadius: '28px',
              padding: '2px',
              background: 'rgba(255, 255, 255, 0.07)',
              border: '1px solid rgba(255, 255, 255, 0.12)',
              boxShadow: '0 16px 36px rgba(0, 0, 0, 0.55), 0 0 1px rgba(255, 255, 255, 0.1)',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <img
              src="/younme-logo.png"
              alt="YoUnMe Official App Icon"
              style={{
                width: '100%',
                height: '100%',
                borderRadius: '26px',
                objectFit: 'cover',
                display: 'block',
              }}
            />
          </div>
        </div>

        {/* 2. Elegant YoUnMe App Name (Clean typography, no excessive heart pulse) */}
        <div className="splash-title-entrance" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <h1
            style={{
              fontSize: '36px',
              fontWeight: 900,
              margin: '0 0 6px',
              letterSpacing: '-0.5px',
              fontFamily: 'Outfit, sans-serif',
              color: '#f8fafc',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '2px',
            }}
          >
            <span>Yo</span>
            <span style={{ fontSize: '30px', color: '#f43f5e', opacity: 0.95 }}>Un</span>
            <span style={{ color: '#f43f5e' }}>M</span>
            <span>e</span>
          </h1>
        </div>

        <p
          style={{
            fontSize: '14px',
            lineHeight: 1.5,
            color: '#94a3b8',
            margin: '0 0 12px',
            maxWidth: '260px',
            fontWeight: 500,
          }}
        >
          Where Real Stories Begin
        </p>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '4px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '5px', fontSize: '11px', color: '#cbd5e1', fontWeight: 600 }}>
            <Shield size={12} color="#f43f5e" /> 100% Verified
          </div>
          <span style={{ color: 'rgba(255,255,255,0.18)' }}>•</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '5px', fontSize: '11px', color: '#cbd5e1', fontWeight: 600 }}>
            <Lock size={12} color="#38bdf8" /> Privacy First
          </div>
        </div>
      </div>

      {/* Action Buttons & Terms Footer */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', zIndex: 2 }}>
        {/* Legal disclaimer text above action buttons */}
        <p
          style={{
            fontSize: '11px',
            lineHeight: 1.45,
            color: '#64748b',
            textAlign: 'center',
            margin: '0 0 4px',
          }}
        >
          By continuing, you agree to our{' '}
          <span style={{ color: '#94a3b8', textDecoration: 'underline', cursor: 'pointer' }}>Terms of Service</span> &{' '}
          <span style={{ color: '#94a3b8', textDecoration: 'underline', cursor: 'pointer' }}>Privacy Policy</span>.
        </p>

        {/* Create account button (clean rose gradient) */}
        <button
          type="button"
          onClick={onGoToSignUp}
          style={{
            width: '100%',
            height: '50px',
            borderRadius: '999px',
            border: 'none',
            background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
            color: '#FFFFFF',
            fontSize: '15px',
            fontWeight: 700,
            letterSpacing: '0.2px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(244, 63, 94, 0.32)',
            transition: 'transform 0.15s ease, box-shadow 0.15s ease',
          }}
          onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.98)')}
          onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
        >
          <span>Create account</span>
          <ArrowRight size={17} />
        </button>

        {/* Sign in button (frosted glass outline) */}
        <button
          type="button"
          onClick={onGoToSignIn}
          style={{
            width: '100%',
            height: '48px',
            borderRadius: '999px',
            background: 'rgba(255, 255, 255, 0.04)',
            border: '1px solid rgba(255, 255, 255, 0.12)',
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            color: '#f8fafc',
            fontSize: '14.5px',
            fontWeight: 700,
            cursor: 'pointer',
            transition: 'background 0.15s ease, border-color 0.15s ease',
          }}
          onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(255, 255, 255, 0.08)')}
          onMouseLeave={(e) => (e.currentTarget.style.background = 'rgba(255, 255, 255, 0.04)')}
        >
          Sign in
        </button>

        {/* Trouble signing in? recovery modal link at the bottom */}
        <button
          type="button"
          onClick={() => setIsRecoveryOpen(true)}
          style={{
            background: 'transparent',
            border: 'none',
            color: '#94a3b8',
            fontSize: '12px',
            fontWeight: 600,
            cursor: 'pointer',
            padding: '6px',
            marginTop: '2px',
            textDecoration: 'none',
          }}
        >
          Trouble signing in?
        </button>
      </div>

      {/* Trouble Signing In Modal */}
      {isRecoveryOpen && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'rgba(6, 8, 14, 0.85)',
            backdropFilter: 'blur(12px)',
            zIndex: 100,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end',
          }}
        >
          <div
            style={{
              background: '#151822',
              borderRadius: '24px 24px 0 0',
              borderTop: '1px solid rgba(255, 255, 255, 0.12)',
              padding: '24px 20px 32px',
              boxShadow: '0 -10px 40px rgba(0, 0, 0, 0.6)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <HelpCircle size={18} color="#f43f5e" />
                <h3 style={{ fontSize: '16px', fontWeight: 800, margin: 0, color: '#FFFFFF' }}>Account Recovery</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsRecoveryOpen(false)}
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: 'none',
                  borderRadius: '50%',
                  width: '30px',
                  height: '30px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#FFFFFF',
                  cursor: 'pointer',
                }}
              >
                <X size={16} />
              </button>
            </div>

            {/* Recovery Method Segmented Tabs */}
            <div
              style={{
                display: 'flex',
                background: 'rgba(255, 255, 255, 0.05)',
                borderRadius: '12px',
                padding: '3px',
                marginBottom: '16px',
              }}
            >
              <button
                type="button"
                onClick={() => {
                  setRecoveryMethod('phone');
                  setRecoverySent(false);
                }}
                style={{
                  flex: 1,
                  padding: '8px 0',
                  borderRadius: '10px',
                  border: 'none',
                  background: recoveryMethod === 'phone' ? 'linear-gradient(135deg, #f43f5e, #e11d48)' : 'transparent',
                  color: '#FFFFFF',
                  fontSize: '12px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <Phone size={13} />
                <span>Phone</span>
              </button>
              <button
                type="button"
                onClick={() => {
                  setRecoveryMethod('email');
                  setRecoverySent(false);
                }}
                style={{
                  flex: 1,
                  padding: '8px 0',
                  borderRadius: '10px',
                  border: 'none',
                  background: recoveryMethod === 'email' ? 'linear-gradient(135deg, #f43f5e, #e11d48)' : 'transparent',
                  color: '#FFFFFF',
                  fontSize: '12px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <Mail size={13} />
                <span>Email</span>
              </button>
              <button
                type="button"
                onClick={() => {
                  setRecoveryMethod('support');
                  setRecoverySent(false);
                }}
                style={{
                  flex: 1,
                  padding: '8px 0',
                  borderRadius: '10px',
                  border: 'none',
                  background: recoveryMethod === 'support' ? 'linear-gradient(135deg, #f43f5e, #e11d48)' : 'transparent',
                  color: '#FFFFFF',
                  fontSize: '12px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <HelpCircle size={13} />
                <span>Support</span>
              </button>
            </div>

            {recoverySent ? (
              <div
                style={{
                  background: 'rgba(34, 197, 94, 0.12)',
                  border: '1px solid rgba(34, 197, 94, 0.3)',
                  borderRadius: '12px',
                  padding: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  color: '#22c55e',
                  fontSize: '13px',
                  fontWeight: 600,
                }}
              >
                <CheckCircle2 size={18} />
                <span>Recovery instructions dispatched! Check your messages.</span>
              </div>
            ) : recoveryMethod === 'support' ? (
              <div style={{ textAlign: 'center', padding: '12px 0' }}>
                <p style={{ fontSize: '13px', color: '#cbd5e1', margin: '0 0 14px' }}>
                  Need human help recovering your profile or verified credentials?
                </p>
                <a
                  href="mailto:support@younme.love"
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '6px',
                    padding: '10px 20px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.08)',
                    color: '#f43f5e',
                    textDecoration: 'none',
                    fontWeight: 700,
                    fontSize: '13px',
                  }}
                >
                  <Mail size={14} /> Contact support@younme.love
                </a>
              </div>
            ) : (
              <form onSubmit={handleSendRecovery} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                <p style={{ fontSize: '12px', color: '#94a3b8', margin: 0 }}>
                  {recoveryMethod === 'phone'
                    ? 'Enter your registered phone number to receive a secure login link via SMS or WhatsApp.'
                    : 'Enter your registered email address to receive password reset instructions.'}
                </p>
                <input
                  type={recoveryMethod === 'phone' ? 'tel' : 'email'}
                  value={recoveryInput}
                  onChange={(e) => setRecoveryInput(e.target.value)}
                  placeholder={recoveryMethod === 'phone' ? '+91 98765 43210' : 'name@example.com'}
                  style={{
                    width: '100%',
                    height: '44px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.05)',
                    border: '1px solid rgba(255, 255, 255, 0.12)',
                    padding: '0 14px',
                    color: '#FFFFFF',
                    fontSize: '13.5px',
                    outline: 'none',
                    boxSizing: 'border-box',
                  }}
                  required
                />
                <button
                  type="submit"
                  style={{
                    height: '44px',
                    borderRadius: '12px',
                    background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                    border: 'none',
                    color: '#FFFFFF',
                    fontWeight: 700,
                    fontSize: '13.5px',
                    cursor: 'pointer',
                    marginTop: '4px',
                  }}
                >
                  Send Recovery Link
                </button>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
