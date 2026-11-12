import React from 'react';
import { Send, Coins } from 'lucide-react';
import { planDateTheme } from '../theme';

interface CTAButtonProps {
  onClick: () => void;
  cost?: number;
  disabled?: boolean;
  partnerName?: string;
}

export const CTAButton: React.FC<CTAButtonProps> = ({
  onClick,
  cost = 150,
  disabled = false,
  partnerName,
}) => {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      aria-label={`Plan date with ${partnerName || 'partner'} for ${cost} coins`}
      style={{
        width: '100%',
        height: `${planDateTheme.sizes.ctaHeight}px`,
        borderRadius: `${planDateTheme.borderRadius.cta}px`,
        background: disabled ? planDateTheme.colors.disabledBg : planDateTheme.gradients.primary,
        border: disabled ? `1px solid ${planDateTheme.colors.disabledBorder}` : 'none',
        color: disabled ? planDateTheme.colors.disabledText : '#FFFFFF',
        fontSize: '16px',
        fontWeight: planDateTheme.typography.weights.extrabold,
        fontFamily: planDateTheme.typography.fontFamily,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '8px',
        cursor: disabled ? 'not-allowed' : 'pointer',
        boxShadow: disabled ? 'none' : planDateTheme.colors.ctaShadow,
        transition: 'all 0.2s ease',
        minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
        padding: '0 20px',
      }}
    >
      <Send size={18} />
      <span>Plan date with</span>
      {partnerName && (
        <span style={{ fontWeight: planDateTheme.typography.weights.extrabold }}>
          {partnerName}
        </span>
      )}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '4px',
          backgroundColor: 'rgba(255,255,255,.18)',
          borderRadius: `${planDateTheme.borderRadius.pill}px`,
          padding: '4px 10px',
        }}
      >
        <Coins size={16} color={planDateTheme.colors.coin} />
        <span style={{ fontSize: '14px', fontWeight: planDateTheme.typography.weights.bold }}>
          {cost} coins
        </span>
      </div>
    </button>
  );
};
