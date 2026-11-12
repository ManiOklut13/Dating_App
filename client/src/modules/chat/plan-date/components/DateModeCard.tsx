import React from 'react';
import { Video, MapPin } from 'lucide-react';
import { planDateTheme } from '../theme';
import { DateMode } from '../types';

interface DateModeCardProps {
  mode: DateMode;
  onModeChange: (mode: DateMode) => void;
}

export const DateModeCard: React.FC<DateModeCardProps> = ({ mode, onModeChange }) => {
  const hintText = mode === 'virtual' ? 'Video call from anywhere' : 'Meet in person';

  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '12px',
        }}
      >
        <h3
          style={{
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          Date Mode
        </h3>
        <span
          style={{
            fontSize: '12px',
            color: planDateTheme.colors.muted,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          {hintText}
        </span>
      </div>

      <div
        style={{
          display: 'flex',
          backgroundColor: planDateTheme.colors.innerField,
          border: `1px solid ${planDateTheme.colors.innerFieldBorder}`,
          borderRadius: `${planDateTheme.borderRadius.large}px`,
          padding: '5px',
          gap: '6px',
        }}
      >
        <button
          onClick={() => onModeChange('virtual')}
          aria-label="Virtual date mode"
          style={{
            flex: 1,
            height: `${planDateTheme.sizes.segmentButtonHeight}px`,
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            background: mode === 'virtual' ? planDateTheme.gradients.primary : 'transparent',
            border: 'none',
            color: mode === 'virtual' ? '#FFFFFF' : planDateTheme.colors.softText,
            fontSize: '14px',
            fontWeight: planDateTheme.typography.weights.bold,
            fontFamily: planDateTheme.typography.fontFamily,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            cursor: 'pointer',
            boxShadow: mode === 'virtual' ? planDateTheme.colors.selectedShadow : 'none',
            transition: 'all 0.2s ease',
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
          }}
        >
          <Video size={18} />
          Virtual
        </button>
        <button
          onClick={() => onModeChange('offline')}
          aria-label="Offline date mode"
          style={{
            flex: 1,
            height: `${planDateTheme.sizes.segmentButtonHeight}px`,
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            background: mode === 'offline' ? planDateTheme.gradients.primary : 'transparent',
            border: 'none',
            color: mode === 'offline' ? '#FFFFFF' : planDateTheme.colors.softText,
            fontSize: '14px',
            fontWeight: planDateTheme.typography.weights.bold,
            fontFamily: planDateTheme.typography.fontFamily,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            cursor: 'pointer',
            boxShadow: mode === 'offline' ? planDateTheme.colors.selectedShadow : 'none',
            transition: 'all 0.2s ease',
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
            minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
          }}
        >
          <MapPin size={18} />
          Offline
        </button>
      </div>
    </div>
  );
};
