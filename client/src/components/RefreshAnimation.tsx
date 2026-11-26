import React from 'react';
import { Flame } from 'lucide-react';

interface RefreshAnimationProps {
  /** Optional custom message shown beneath the logo */
  message?: string;
  /** Optional subtitle */
  submessage?: string;
  /** Size variant */
  size?: 'normal' | 'large';
}

export const RefreshAnimation: React.FC<RefreshAnimationProps> = ({
  message = 'Finding Sparks & Connections...',
  submessage = 'Curating verified profiles in your area',
  size = 'large',
}) => {
  const isLarge = size === 'large';
  const logoBoxSize = isLarge ? 84 : 64;
  const flameIconSize = isLarge ? 44 : 32;

  return (
    <div
      role="status"
      aria-live="polite"
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: isLarge ? '56px 24px' : '36px 20px',
        width: '100%',
        boxSizing: 'border-box',
        textAlign: 'center',
      }}
    >
      {/* Outer Romantic Glowing Halo & Flame Aura */}
      <div
        style={{
          position: 'relative',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginBottom: '20px',
        }}
      >
        {/* Pulsing Backlight Flame Aura */}
        <div
          className="younme-flame-aura"
          style={{
            position: 'absolute',
            width: `${logoBoxSize + 32}px`,
            height: `${logoBoxSize + 32}px`,
            borderRadius: '50%',
            background: 'radial-gradient(circle, rgba(244, 63, 94, 0.45) 0%, rgba(249, 115, 22, 0.25) 50%, transparent 70%)',
            filter: 'blur(12px)',
            pointerEvents: 'none',
          }}
        />

        {/* Outer Ring Flame Ripple */}
        <div
          className="younme-flame-ring"
          style={{
            position: 'absolute',
            width: `${logoBoxSize + 16}px`,
            height: `${logoBoxSize + 16}px`,
            borderRadius: '28px',
            border: '2px solid rgba(244, 63, 94, 0.35)',
            boxShadow: '0 0 20px rgba(244, 63, 94, 0.35), inset 0 0 15px rgba(249, 115, 22, 0.2)',
            pointerEvents: 'none',
          }}
        />

        {/* Centered Large YoUnMe Brand Logo Box */}
        <div
          className="younme-logo-box"
          style={{
            width: `${logoBoxSize}px`,
            height: `${logoBoxSize}px`,
            borderRadius: '24px',
            background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 50%, #f97316 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 8px 32px rgba(244, 63, 94, 0.5), 0 0 16px rgba(249, 115, 22, 0.4)',
            zIndex: 2,
            position: 'relative',
          }}
        >
          <Flame size={flameIconSize} color="#ffffff" fill="#ffffff" style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.3))' }} />
        </div>
      </div>

      {/* Brand Label */}
      <div
        style={{
          fontSize: '18px',
          fontWeight: 900,
          letterSpacing: '-0.3px',
          color: '#f8fafc',
          marginBottom: '4px',
        }}
      >
        YoUnMe
      </div>

      {/* Dynamic Status Message */}
      <div
        style={{
          fontSize: '13px',
          fontWeight: 600,
          color: '#cbd5e1',
          marginBottom: '2px',
        }}
      >
        {message}
      </div>

      {submessage && (
        <div
          style={{
            fontSize: '11px',
            color: '#64748b',
            maxWidth: '260px',
            lineHeight: 1.4,
          }}
        >
          {submessage}
        </div>
      )}
    </div>
  );
};

