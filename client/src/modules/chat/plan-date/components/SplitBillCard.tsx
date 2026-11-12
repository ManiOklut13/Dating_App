import React from 'react';
import { planDateTheme } from '../theme';

interface SplitBillCardProps {
  yourShare: number;
  onYourShareChange: (share: number) => void;
  partnerName?: string;
}

export const SplitBillCard: React.FC<SplitBillCardProps> = ({
  yourShare,
  onYourShareChange,
  partnerName = 'Partner',
}) => {
  const partnerShare = 100 - yourShare;
  const presets = [
    { label: '50/50', your: 50 },
    { label: '70/30', your: 70 },
    { label: '30/70', your: 30 },
    { label: 'I pay all', your: 100 },
  ];

  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <h3
        style={{
          fontSize: '16px',
          fontWeight: planDateTheme.typography.weights.bold,
          color: planDateTheme.colors.text,
          margin: '0 0 12px 0',
          fontFamily: planDateTheme.typography.fontFamily,
        }}
      >
        Split Bill
      </h3>

      {/* Pill bar */}
      <div
        style={{
          height: '12px',
          borderRadius: '6px',
          backgroundColor: planDateTheme.colors.innerField,
          overflow: 'hidden',
          display: 'flex',
          marginBottom: '12px',
        }}
      >
        <div
          style={{
            width: `${yourShare}%`,
            background: planDateTheme.gradients.splitYou,
            height: '100%',
          }}
        />
        <div
          style={{
            width: `${partnerShare}%`,
            background: planDateTheme.gradients.splitPartner,
            height: '100%',
          }}
        />
      </div>

      {/* Percentages */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          marginBottom: '8px',
        }}
      >
        <div>
          <div
            style={{
              fontSize: '24px',
              fontWeight: planDateTheme.typography.weights.extrabold,
              color: planDateTheme.colors.accentText,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            {yourShare}%
          </div>
          <div
            style={{
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.semibold,
              color: planDateTheme.colors.muted,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            You (Proposer)
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div
            style={{
              fontSize: '24px',
              fontWeight: planDateTheme.typography.weights.extrabold,
              color: planDateTheme.colors.violetText,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            {partnerShare}%
          </div>
          <div
            style={{
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.semibold,
              color: planDateTheme.colors.muted,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            {partnerName}
          </div>
        </div>
      </div>

      {/* Preset chips */}
      <div style={{ display: 'flex', gap: '8px' }}>
        {presets.map((preset) => (
          <button
            key={preset.label}
            onClick={() => onYourShareChange(preset.your)}
            style={{
              flex: 1,
              height: `${planDateTheme.sizes.chipHeight}px`,
              borderRadius: `${planDateTheme.borderRadius.small}px`,
              backgroundColor: yourShare === preset.your ? planDateTheme.colors.raisedButton : planDateTheme.colors.idleChip,
              border: `1px solid ${yourShare === preset.your ? planDateTheme.colors.raisedButtonBorder : planDateTheme.colors.idleChipBorder}`,
              color: planDateTheme.colors.softText,
              fontSize: '13px',
              fontWeight: planDateTheme.typography.weights.semibold,
              fontFamily: planDateTheme.typography.fontFamily,
              cursor: 'pointer',
              transition: 'all 0.2s ease',
              minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            }}
          >
            {preset.label}
          </button>
        ))}
      </div>
    </div>
  );
};
