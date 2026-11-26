import React from 'react';

interface AndroidNavBarProps {
  onBack?: () => void;
  onHome?: () => void;
  onRecents?: () => void;
}

export const AndroidNavBar: React.FC<AndroidNavBarProps> = ({ onBack, onHome, onRecents }) => {
  return (
    <div
      style={{
        height: '42px',
        background: '#06080E',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        padding: '0 32px',
        borderTop: '1px solid rgba(255, 255, 255, 0.05)',
        zIndex: 50,
        userSelect: 'none',
      }}
    >
      {/* Back Button (Triangle pointing left) */}
      <button
        type="button"
        onClick={onBack}
        title="Back"
        style={{
          background: 'transparent',
          border: 'none',
          color: '#8C8C9E',
          cursor: 'pointer',
          padding: '8px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'color 0.15s ease',
        }}
        onMouseEnter={(e) => (e.currentTarget.style.color = '#FFFFFF')}
        onMouseLeave={(e) => (e.currentTarget.style.color = '#8C8C9E')}
      >
        <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
          <polygon points="19,4 6,12 19,20" />
        </svg>
      </button>

      {/* Home Button (Circle) */}
      <button
        type="button"
        onClick={onHome}
        title="Home"
        style={{
          background: 'transparent',
          border: 'none',
          color: '#8C8C9E',
          cursor: 'pointer',
          padding: '8px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'color 0.15s ease',
        }}
        onMouseEnter={(e) => (e.currentTarget.style.color = '#FFFFFF')}
        onMouseLeave={(e) => (e.currentTarget.style.color = '#8C8C9E')}
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <circle cx="12" cy="12" r="9" />
        </svg>
      </button>

      {/* Recents Button (Square) */}
      <button
        type="button"
        onClick={onRecents}
        title="Recent Apps"
        style={{
          background: 'transparent',
          border: 'none',
          color: '#8C8C9E',
          cursor: 'pointer',
          padding: '8px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'color 0.15s ease',
        }}
        onMouseEnter={(e) => (e.currentTarget.style.color = '#FFFFFF')}
        onMouseLeave={(e) => (e.currentTarget.style.color = '#8C8C9E')}
      >
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <rect x="5" y="5" width="14" height="14" rx="2" />
        </svg>
      </button>
    </div>
  );
};

