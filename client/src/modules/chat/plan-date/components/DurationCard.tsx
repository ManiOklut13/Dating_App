import React from 'react';
import { Minus, Plus } from 'lucide-react';
import { planDateTheme } from '../theme';

interface DurationCardProps {
  duration: number;
  onDurationChange: (duration: number) => void;
  min?: number;
  max?: number;
  step?: number;
  quickChips?: number[];
}

export const DurationCard: React.FC<DurationCardProps> = ({
  duration,
  onDurationChange,
  min = 15,
  max = 240,
  step = 15,
  quickChips = [30, 60, 90, 120],
}) => {
  const decrease = () => {
    const newVal = duration - step;
    if (newVal >= min) onDurationChange(newVal);
  };

  const increase = () => {
    const newVal = duration + step;
    if (newVal <= max) onDurationChange(newVal);
  };

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
        Duration
      </h3>

      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '16px',
          marginBottom: '12px',
        }}
      >
        <button
          onClick={decrease}
          aria-label="Decrease duration"
          disabled={duration <= min}
          style={{
            width: `${planDateTheme.sizes.durationButton}px`,
            height: `${planDateTheme.sizes.durationButton}px`,
            borderRadius: `${planDateTheme.borderRadius.medium}px`,
            backgroundColor: planDateTheme.colors.raisedButton,
            border: `1px solid ${planDateTheme.colors.raisedButtonBorder}`,
            color: duration <= min ? planDateTheme.colors.disabledText : planDateTheme.colors.text,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: duration <= min ? 'not-allowed' : 'pointer',
            padding: 0,
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
          }}
        >
          <Minus size={20} />
        </button>

        <div style={{ textAlign: 'center', minWidth: '100px' }}>
          <div
            style={{
              fontSize: '30px',
              fontWeight: planDateTheme.typography.weights.extrabold,
              color: planDateTheme.colors.text,
              fontFamily: planDateTheme.typography.fontFamily,
              lineHeight: '1',
            }}
          >
            {duration}
          </div>
          <div
            style={{
              fontSize: '14px',
              fontWeight: planDateTheme.typography.weights.semibold,
              color: planDateTheme.colors.muted,
              fontFamily: planDateTheme.typography.fontFamily,
              marginTop: '4px',
            }}
          >
            minutes
          </div>
        </div>

        <button
          onClick={increase}
          aria-label="Increase duration"
          disabled={duration >= max}
          style={{
            width: `${planDateTheme.sizes.durationButton}px`,
            height: `${planDateTheme.sizes.durationButton}px`,
            borderRadius: `${planDateTheme.borderRadius.medium}px`,
            background: planDateTheme.gradients.primary,
            border: 'none',
            color: '#FFFFFF',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: duration >= max ? 'not-allowed' : 'pointer',
            padding: 0,
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
            opacity: duration >= max ? 0.5 : 1,
          }}
        >
          <Plus size={20} />
        </button>
      </div>

      <div style={{ display: 'flex', gap: '8px' }}>
        {quickChips.map((chip) => (
          <button
            key={chip}
            onClick={() => onDurationChange(chip)}
            style={{
              flex: 1,
              height: `${planDateTheme.sizes.chipHeight}px`,
              borderRadius: `${planDateTheme.borderRadius.small}px`,
              backgroundColor: duration === chip ? planDateTheme.colors.raisedButton : planDateTheme.colors.idleChip,
              border: `1px solid ${duration === chip ? planDateTheme.colors.raisedButtonBorder : planDateTheme.colors.idleChipBorder}`,
              color: planDateTheme.colors.softText,
              fontSize: '14px',
              fontWeight: planDateTheme.typography.weights.semibold,
              fontFamily: planDateTheme.typography.fontFamily,
              cursor: 'pointer',
              transition: 'all 0.2s ease',
              minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            }}
          >
            {chip}
          </button>
        ))}
      </div>
    </div>
  );
};
