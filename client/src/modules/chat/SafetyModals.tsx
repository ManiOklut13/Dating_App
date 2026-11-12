import React from 'react';
import { Shield, ShieldAlert, AlertTriangle, X, Edit3 } from 'lucide-react';
import { useChat } from './ChatContext';

export const SafetyModals: React.FC = () => {
  const {
    isScreenshotModalOpen,
    setIsScreenshotModalOpen,
    profanityAlert,
    setProfanityAlert,
    toast,
    clearToast,
  } = useChat();

  return (
    <>
      {/* Toast Banner */}
      {toast && (
        <div
          style={{
            position: 'fixed',
            top: '80px',
            left: '50%',
            transform: 'translateX(-50%)',
            zIndex: 9999,
            minWidth: '320px',
            maxWidth: '92vw',
            padding: '12px 18px',
            borderRadius: 'var(--radius-md)',
            background:
              toast.type === 'warning'
                ? 'rgba(255, 71, 87, 0.95)'
                : toast.type === 'success'
                ? 'rgba(0, 230, 118, 0.95)'
                : 'var(--bg-card)',
            color: 'var(--text-primary)',
            boxShadow: 'var(--shadow-lg)',
            border: '1px solid rgba(255, 255, 255, 0.2)',
            backdropFilter: 'blur(16px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
            animation: 'pulseGlow 2s infinite ease-in-out',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            {toast.type === 'warning' && <ShieldAlert size={20} />}
            {toast.type === 'success' && <Shield size={20} />}
            <span style={{ fontSize: '13.5px', fontWeight: 600 }}>{toast.text}</span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            {toast.actionText && (
              <button
                onClick={() => {
                  toast.onAction?.();
                  clearToast();
                }}
                style={{
                  background: 'rgba(255, 255, 255, 0.2)',
                  border: 'none',
                  color: 'var(--text-primary)',
                  padding: '4px 10px',
                  borderRadius: 'var(--radius-sm)',
                  fontSize: '12px',
                  fontWeight: 700,
                  cursor: 'pointer',
                }}
              >
                {toast.actionText}
              </button>
            )}
            <button
              onClick={clearToast}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'rgba(255, 255, 255, 0.8)',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
              }}
            >
              <X size={16} />
            </button>
          </div>
        </div>
      )}

      {/* Screenshot Warning Modal */}
      {isScreenshotModalOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'rgba(5, 6, 12, 0.85)',
            backdropFilter: 'blur(20px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
          onClick={() => setIsScreenshotModalOpen(false)}
        >
          <div
            className="glass-panel"
            style={{
              maxWidth: '440px',
              width: '100%',
              borderRadius: 'var(--radius-lg)',
              padding: '30px 24px',
              textAlign: 'center',
              position: 'relative',
              border: '1px solid rgba(255, 45, 85, 0.4)',
              boxShadow: '0 0 50px rgba(255, 45, 85, 0.3)',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              style={{
                width: '72px',
                height: '72px',
                borderRadius: '50%',
                background: 'rgba(255, 45, 85, 0.15)',
                border: '2px solid #ff2d55',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 20px',
                boxShadow: 'var(--shadow-glow)',
              }}
            >
              <Shield size={38} color="#ff2d55" />
            </div>

            <div
              style={{
                display: 'inline-block',
                background: 'rgba(255, 45, 85, 0.2)',
                color: '#ff2d55',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                fontSize: '11px',
                fontWeight: 700,
                letterSpacing: '0.5px',
                textTransform: 'uppercase',
                marginBottom: '12px',
              }}
            >
              Live Secure Guard Active
            </div>

            <h3 style={{ fontSize: '20px', fontWeight: 800, marginBottom: '10px' }}>
              Screenshot & Capture Restricted
            </h3>

            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.6, marginBottom: '22px' }}>
              To safeguard personal conversations, dating privacy, and photos, screenshot capturing and screen recording are strictly prohibited inside YoUnMe private chat rooms.
            </p>

            <button
              onClick={() => setIsScreenshotModalOpen(false)}
              className="btn-primary"
              style={{ width: '100%', padding: '12px', fontSize: '14px', borderRadius: 'var(--radius-full)' }}
            >
              I Understand & Agree
            </button>
          </div>
        </div>
      )}

      {/* Profanity Warning Modal */}
      {profanityAlert && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'rgba(5, 6, 12, 0.85)',
            backdropFilter: 'blur(20px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            className="glass-panel"
            style={{
              maxWidth: '440px',
              width: '100%',
              borderRadius: 'var(--radius-lg)',
              padding: '28px 24px',
              textAlign: 'center',
              border: '1px solid rgba(255, 170, 0, 0.4)',
              boxShadow: '0 0 40px rgba(255, 170, 0, 0.25)',
            }}
          >
            <div
              style={{
                width: '64px',
                height: '64px',
                borderRadius: '50%',
                background: 'rgba(255, 170, 0, 0.15)',
                border: '2px solid #ffd700',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 16px',
              }}
            >
              <AlertTriangle size={32} color="#ffd700" />
            </div>

            <h3 style={{ fontSize: '19px', fontWeight: 800, marginBottom: '8px' }}>
              Community Safety Warning
            </h3>

            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5, marginBottom: '16px' }}>
              Your message was blocked because it contains prohibited or disrespectful language:
            </p>

            <div
              style={{
                padding: '10px 14px',
                borderRadius: 'var(--radius-md)',
                background: 'rgba(255, 71, 87, 0.1)',
                border: '1px solid rgba(255, 71, 87, 0.3)',
                color: '#ff4757',
                fontWeight: 700,
                fontSize: '13px',
                marginBottom: '20px',
              }}
            >
              Flagged word: "{profanityAlert.word}"
            </div>

            <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '22px' }}>
              YoUnMe promotes kind, authentic, and consensual dating interactions. Please edit your message before sending.
            </p>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setProfanityAlert(null)}
                className="btn-ghost"
                style={{ flex: 1, padding: '12px', fontSize: '13px' }}
              >
                Cancel
              </button>
              <button
                onClick={() => setProfanityAlert(null)}
                className="btn-primary"
                style={{ flex: 1, padding: '12px', fontSize: '13px', gap: '6px' }}
              >
                <Edit3 size={15} />
                Edit Message
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
