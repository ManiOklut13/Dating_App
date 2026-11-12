import React, { useState } from 'react';
import { Flame, Lock, ArrowRight } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const MockLoginPage: React.FC = () => {
  const { login } = useProfile();
  const [phone, setPhone] = useState('+91 98765 43210');

  return (
    <div
      style={{
        maxWidth: '440px',
        margin: '60px auto',
        padding: '0 16px',
        textAlign: 'center',
      }}
    >
      <div
        className="glass-panel"
        style={{
          borderRadius: 'var(--radius-lg)',
          padding: '36px 24px',
          border: '1px solid var(--border-glass)',
          boxShadow: 'var(--shadow-lg)',
        }}
      >
        {/* Brand Logo */}
        <div
          style={{
            width: '64px',
            height: '64px',
            borderRadius: '16px',
            background: 'var(--gradient-flame)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px',
            boxShadow: 'var(--shadow-glow)',
          }}
        >
          <Flame size={36} color="#ffffff" />
        </div>

        <h2 style={{ fontSize: '24px', fontWeight: 800, marginBottom: '6px' }}>
          Welcome to YoUnMe
        </h2>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '24px' }}>
          Real-time high-concurrency social discovery and verified dating
        </p>

        <div style={{ marginBottom: '20px', textAlign: 'left' }}>
          <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>
            Registered Mobile Number
          </label>
          <input
            type="text"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            style={{
              width: '100%',
              padding: '12px 14px',
              borderRadius: 'var(--radius-md)',
              background: 'var(--surface-muted)',
              border: '1px solid var(--border-glass)',
              color: 'var(--text-primary)',
              fontSize: '14px',
              outline: 'none',
            }}
          />
        </div>

        <button
          onClick={login}
          className="btn-primary"
          style={{ width: '100%', padding: '14px', fontSize: '14px', gap: '8px', borderRadius: 'var(--radius-full)' }}
        >
          <span>Log In as Alex</span>
          <ArrowRight size={16} />
        </button>
      </div>
    </div>
  );
};
