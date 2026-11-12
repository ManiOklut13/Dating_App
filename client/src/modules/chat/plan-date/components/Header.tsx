import React from 'react';
import { X, Calendar } from 'lucide-react';
import { planDateTheme } from '../theme';

interface HeaderProps {
  onClose: () => void;
  onCalendarClick?: () => void;
}

export const Header: React.FC<HeaderProps> = ({ onClose, onCalendarClick }) => {
  return (
    <header
      style={{
        height: `${planDateTheme.sizes.headerHeight}px`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: '8px',
      }}
    >
      <button
        onClick={onClose}
        aria-label="Close Plan a Date"
        style={{
          width: `${planDateTheme.sizes.iconButton}px`,
          height: `${planDateTheme.sizes.iconButton}px`,
          borderRadius: `${planDateTheme.borderRadius.inner}px`,
          backgroundColor: planDateTheme.colors.card,
          border: `1px solid ${planDateTheme.colors.cardBorder}`,
          color: planDateTheme.colors.text,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          padding: 0,
          minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
          minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
        }}
      >
        <X size={20} />
      </button>

      <h1
        style={{
          fontSize: '22px',
          fontWeight: planDateTheme.typography.weights.extrabold,
          fontFamily: planDateTheme.typography.fontFamily,
          color: planDateTheme.colors.text,
          margin: 0,
          textAlign: 'center',
          flex: 1,
        }}
      >
        Plan a{' '}
        <span
          style={{
            background: planDateTheme.gradients.dateText,
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
          }}
        >
          Date
        </span>
      </h1>

      <button
        onClick={onCalendarClick}
        aria-label="Open calendar"
        style={{
          width: `${planDateTheme.sizes.iconButton}px`,
          height: `${planDateTheme.sizes.iconButton}px`,
          borderRadius: `${planDateTheme.borderRadius.inner}px`,
          backgroundColor: planDateTheme.colors.card,
          border: `1px solid ${planDateTheme.colors.cardBorder}`,
          color: planDateTheme.colors.accentPink3,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          padding: 0,
          minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
          minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
        }}
      >
        <Calendar size={20} />
      </button>
    </header>
  );
};
