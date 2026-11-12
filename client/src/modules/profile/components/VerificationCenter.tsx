import React from 'react';
import { ShieldCheck, ShieldAlert, Camera, Mic, Sparkles, RefreshCw, CheckCircle, Clock } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const VerificationCenter: React.FC = () => {
  const { profile, setIsVerificationModalOpen, completeVerificationDemo } = useProfile();

  const status = profile.verification.status;

  return (
    <div
      id="section-verification"
      className="glass-panel"
      style={{
        borderRadius: 'var(--radius-lg)',
        padding: '24px',
        border: status === 'verified' ? '1px solid rgba(29, 161, 242, 0.35)' : '1px solid var(--border-glass)',
        background: status === 'verified'
          ? 'radial-gradient(circle at 10% 20%, rgba(29, 161, 242, 0.08) 0%, var(--card-base) 100%)'
          : 'var(--bg-card)',
      }}
    >
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '50%',
              background: status === 'verified' ? 'rgba(29, 161, 242, 0.15)' : 'rgba(255, 170, 0, 0.15)',
              color: status === 'verified' ? '#1da1f2' : '#ffa502',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {status === 'verified' ? <ShieldCheck size={20} /> : <ShieldAlert size={20} />}
          </div>
          <div>
            <h3 style={{ fontSize: '18px', fontWeight: 800 }}>Verification Center</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Blue Tick verification boosts connection discovery by 3.4x
            </p>
          </div>
        </div>

        {/* Current Status Pill */}
        <div>
          {status === 'verified' && (
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '5px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(29, 161, 242, 0.15)',
                border: '1px solid #1da1f2',
                color: '#1da1f2',
                fontSize: '11px',
                fontWeight: 700,
              }}
            >
              <CheckCircle size={13} />
              Verified (Blue Tick)
            </span>
          )}
          {status === 'not_verified' && (
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '5px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(255, 71, 87, 0.15)',
                border: '1px solid #ff4757',
                color: '#ff4757',
                fontSize: '11px',
                fontWeight: 700,
              }}
            >
              Not Verified
            </span>
          )}
          {status === 'in_progress' && (
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '5px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(255, 215, 0, 0.15)',
                border: '1px solid #ffd700',
                color: '#ffd700',
                fontSize: '11px',
                fontWeight: 700,
              }}
            >
              <RefreshCw size={13} className="radar-spinner" />
              In Progress
            </span>
          )}
          {status === 'requires_review' && (
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: '5px',
                padding: '4px 12px',
                borderRadius: 'var(--radius-full)',
                background: 'rgba(255, 165, 2, 0.15)',
                border: '1px solid #ffa502',
                color: '#ffa502',
                fontSize: '11px',
                fontWeight: 700,
              }}
            >
              <Clock size={13} />
              Manual Review Needed
            </span>
          )}
        </div>
      </div>

      {/* Verification Steps Breakdown */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px', marginBottom: '20px' }}>
        
        {/* Step 1: Liveness Face Check */}
        <div style={{ padding: '14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-soft)', border: '1px solid var(--border-glass)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
            <Camera size={16} color="#00e5ff" />
            <span style={{ fontSize: '13px', fontWeight: 700 }}>Face Liveness Test</span>
          </div>
          <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
            Biometric oval alignment with real-time eye blink confirmation.
          </p>
          <div style={{ marginTop: '8px', fontSize: '11px', color: profile.verification.faceVerified ? '#00e676' : '#ffa502', fontWeight: 700 }}>
            {profile.verification.faceVerified ? '✓ Liveness Score: 98%' : '• Pending Scan'}
          </div>
        </div>

        {/* Step 2: Voice Verification Sample */}
        <div style={{ padding: '14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-soft)', border: '1px solid var(--border-glass)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
            <Mic size={16} color="#ff2d55" />
            <span style={{ fontSize: '13px', fontWeight: 700 }}>Voice Authentication</span>
          </div>
          <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
            3-second voice passphrase for secure call identity.
          </p>
          <div style={{ marginTop: '8px', fontSize: '11px', color: profile.verification.voiceVerified ? '#00e676' : '#ffa502', fontWeight: 700 }}>
            {profile.verification.voiceVerified ? '✓ Voice Passphrase Linked' : '• Pending'}
          </div>
        </div>

        {/* Step 3: Avatar Privacy Mode */}
        <div style={{ padding: '14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-soft)', border: '1px solid var(--border-glass)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
            <Sparkles size={16} color="#ffd700" />
            <span style={{ fontSize: '13px', fontWeight: 700 }}>Anonymous 3D Avatar</span>
          </div>
          <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
            Optional face-mesh masking for blind audio/video dating.
          </p>
          <div style={{ marginTop: '8px', fontSize: '11px', color: '#00e5ff', fontWeight: 700 }}>
            ✓ Ready for WebRTC
          </div>
        </div>

      </div>

      {/* Action CTA */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', gap: '8px' }}>
          {status === 'verified' ? (
            <button
              onClick={() => completeVerificationDemo('not_verified')}
              className="btn-ghost"
              style={{ padding: '8px 14px', fontSize: '12px' }}
            >
              Reset to Not Verified
            </button>
          ) : (
            <button
              onClick={() => setIsVerificationModalOpen(true)}
              className="btn-primary"
              style={{ padding: '8px 20px', fontSize: '13px', gap: '6px' }}
            >
              <Camera size={14} />
              Start Verification Flow
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
