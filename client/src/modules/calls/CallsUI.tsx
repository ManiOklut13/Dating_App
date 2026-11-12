import React, { ReactNode } from 'react';
import { ArrowDownLeft, ArrowLeft, ArrowUpRight, Loader2, PhoneMissed, Search, X, AlertCircle, PhoneCall, Video } from 'lucide-react';
import {
  CALL_DIRECTION_META,
  CALL_STATUS_META,
  CallHistoryRecord,
  formatDuration,
  formatRelativeDay,
} from './types';

/* ==========================================================================
   Shared primitives for the Calls screens.

   Built from the same vocabulary as the rest of the app: the CSS custom
   properties in styles/index.css, the `.glass-panel` surface, inline styles
   (the convention used throughout client/src) and lucide-react icons.
   ========================================================================== */

/** Full-screen overlay shell used by every Calls route. */
export const CallsShell: React.FC<{ children: ReactNode }> = ({ children }) => (
  <div
    role="dialog"
    aria-modal="true"
    aria-label="Calls"
    style={{
      position: 'fixed',
      inset: 0,
      zIndex: 9500,
      background: 'var(--bg-dark, var(--bg-dark))',
      overflowY: 'auto',
      WebkitOverflowScrolling: 'touch',
    }}
  >
    <div
      style={{
        maxWidth: 860,
        margin: '0 auto',
        minHeight: '100%',
        padding: '0 16px calc(96px + env(safe-area-inset-bottom))',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {children}
    </div>
  </div>
);

export const CallsBackButton: React.FC<{ onClick: () => void; label: string }> = ({ onClick, label }) => (
  <button
    type="button"
    onClick={onClick}
    aria-label={label}
    title={label}
    style={{
      width: '40px',
      height: '40px',
      borderRadius: '50%',
      background: 'var(--surface-muted)',
      border: '1px solid var(--border-glass)',
      color: 'var(--text-primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      flexShrink: 0,
      transition: 'background var(--transition-fast)',
    }}
  >
    <ArrowLeft size={19} />
  </button>
);

/**
 * Sticky page header. Holds the back button, the title and an optional
 * subtitle, so every Calls page shares one header treatment.
 */
export const CallsHeader: React.FC<{
  title: string;
  subtitle?: string;
  icon?: ReactNode;
  accent?: string;
  onBack: () => void;
  backLabel?: string;
  action?: ReactNode;
}> = ({ title, subtitle, icon, accent = 'var(--cyan-vibe)', onBack, backLabel, action }) => (
  <div
    style={{
      position: 'sticky',
      top: 0,
      zIndex: 10,
      display: 'flex',
      alignItems: 'center',
      gap: '12px',
      padding: '14px 0',
      marginBottom: '8px',
      background: 'linear-gradient(to bottom, var(--bg-dark, var(--bg-dark)) 70%, transparent)',
      backdropFilter: 'blur(12px)',
    }}
  >
    <CallsBackButton onClick={onBack} label={backLabel ?? `Back from ${title}`} />
    {icon && (
      <div
        aria-hidden="true"
        style={{
          width: '40px',
          height: '40px',
          borderRadius: 'var(--radius-md)',
          background: `${accent}1f`,
          border: `1px solid ${accent}55`,
          color: accent,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
        }}
      >
        {icon}
      </div>
    )}
    <div style={{ minWidth: 0, flex: 1 }}>
      <h1
        style={{
          margin: 0,
          fontSize: '22px',
          fontWeight: 800,
          letterSpacing: '-0.4px',
          color: 'var(--text-primary)',
          fontFamily: 'var(--font-heading)',
        }}
      >
        {title}
      </h1>
      {subtitle && (
        <p style={{ margin: '2px 0 0', fontSize: '12px', color: 'var(--text-secondary)' }}>{subtitle}</p>
      )}
    </div>
    {action}
  </div>
);

export const CallsSearchInput: React.FC<{
  value: string;
  onChange: (value: string) => void;
  placeholder: string;
}> = ({ value, onChange, placeholder }) => (
  <div style={{ position: 'relative', marginBottom: '16px' }}>
    <Search
      size={16}
      aria-hidden="true"
      style={{
        position: 'absolute',
        left: '14px',
        top: '50%',
        transform: 'translateY(-50%)',
        color: 'var(--text-muted)',
        pointerEvents: 'none',
      }}
    />
    <input
      type="search"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      aria-label={placeholder}
      style={{
        width: '100%',
        padding: '12px 40px 12px 40px',
        borderRadius: 'var(--radius-full)',
        background: 'var(--bg-card)',
        border: '1px solid var(--border-glass)',
        color: 'var(--text-primary)',
        fontSize: '14px',
        fontFamily: 'var(--font-body)',
        outline: 'none',
      }}
    />
    {value && (
      <button
        type="button"
        onClick={() => onChange('')}
        aria-label="Clear search"
        style={{
          position: 'absolute',
          right: '10px',
          top: '50%',
          transform: 'translateY(-50%)',
          width: '26px',
          height: '26px',
          borderRadius: '50%',
          border: 'none',
          background: 'var(--surface-strong)',
          color: 'var(--text-secondary)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
        }}
      >
        <X size={13} />
      </button>
    )}
  </div>
);

export const CallsLoading: React.FC<{ label?: string }> = ({ label = 'Loading call history…' }) => (
  <div
    role="status"
    aria-live="polite"
    style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '12px',
      padding: '56px 20px',
      color: 'var(--text-secondary)',
      fontSize: '13px',
    }}
  >
    <Loader2 size={26} className="calls-spin" aria-hidden="true" style={{ color: 'var(--cyan-vibe)' }} />
    <span>{label}</span>
  </div>
);

export const CallsError: React.FC<{ message: string; onRetry: () => void }> = ({ message, onRetry }) => (
  <div
    role="alert"
    className="glass-panel"
    style={{
      borderRadius: 'var(--radius-lg)',
      padding: '32px 24px',
      textAlign: 'center',
      border: '1px solid rgba(255, 71, 87, 0.35)',
      background: 'rgba(255, 71, 87, 0.06)',
    }}
  >
    <AlertCircle size={30} aria-hidden="true" style={{ color: '#ff4757' }} />
    <p style={{ margin: '12px 0 4px', fontWeight: 700, color: 'var(--text-primary)' }}>
      Could not load call history
    </p>
    <p style={{ margin: 0, fontSize: '13px', color: 'var(--text-secondary)' }}>{message}</p>
    <button
      type="button"
      onClick={onRetry}
      className="btn-primary"
      style={{ marginTop: '16px', padding: '9px 20px', fontSize: '13px' }}
    >
      Try again
    </button>
  </div>
);

export const CallsEmptyState: React.FC<{
  icon: ReactNode;
  title: string;
  description: string;
  action?: ReactNode;
}> = ({ icon, title, description, action }) => (
  <div
    className="glass-panel"
    style={{
      borderRadius: 'var(--radius-lg)',
      padding: '48px 24px',
      textAlign: 'center',
      border: '1px solid var(--border-glass)',
    }}
  >
    <div
      aria-hidden="true"
      style={{
        width: '64px',
        height: '64px',
        margin: '0 auto 16px',
        borderRadius: '50%',
        background: 'var(--surface-soft)',
        border: '1px solid var(--border-glass)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'var(--text-muted)',
      }}
    >
      {icon}
    </div>
    <p style={{ margin: 0, fontWeight: 800, fontSize: '16px', color: 'var(--text-primary)' }}>{title}</p>
    <p style={{ margin: '6px auto 0', fontSize: '13px', color: 'var(--text-secondary)', maxWidth: 340 }}>
      {description}
    </p>
    {action && <div style={{ marginTop: '20px' }}>{action}</div>}
  </div>
);

/** Small pill used for call status / direction / type. */
export const CallsPill: React.FC<{ label: string; color: string; tint?: string }> = ({
  label,
  color,
  tint = `${color}26`,
}) => (
  <span
    style={{
      display: 'inline-flex',
      alignItems: 'center',
      gap: '4px',
      fontSize: '10.5px',
      fontWeight: 700,
      color,
      background: tint,
      border: `1px solid ${color}44`,
      padding: '2px 8px',
      borderRadius: 'var(--radius-full)',
      whiteSpace: 'nowrap',
    }}
  >
    {label}
  </span>
);

/**
 * A single row in an audio / video call history list.
 * Clicking it opens the matching Call Details page.
 */
export const CallHistoryCard: React.FC<{
  record: CallHistoryRecord;
  onOpen: () => void;
  onStartCall?: () => void;
}> = ({ record, onOpen, onStartCall }) => {
  const direction = CALL_DIRECTION_META[record.call_direction];
  const isVideo = record.call_type === 'video';
  const accent = isVideo ? '#ff2d55' : '#00e5ff';
  const isMissed = record.call_status === 'missed';
  const DirectionIcon =
    isMissed
      ? PhoneMissed
      : record.call_direction === 'outgoing'
        ? ArrowUpRight
        : ArrowDownLeft;
  const directionColor = isMissed
    ? '#ff4757'
    : record.call_direction === 'outgoing'
      ? '#00e5ff'
      : '#00e676';

  return (
    <div
      className="glass-panel"
      style={{
        borderRadius: 'var(--radius-md)',
        padding: '12px 14px',
        border: '1px solid var(--border-glass)',
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
        transition: 'transform var(--transition-fast), border-color var(--transition-fast)',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.transform = 'translateY(-1px)';
        e.currentTarget.style.borderColor = `${accent}66`;
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.transform = 'none';
        e.currentTarget.style.borderColor = 'var(--border-glass)';
      }}
    >
      {/* Contact photo — the whole block opens the detail page. */}
      <button
        type="button"
        onClick={onOpen}
        aria-label={`View call details with ${record.counterpart.nickname}`}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          flex: 1,
          minWidth: 0,
          background: 'transparent',
          border: 'none',
          padding: 0,
          cursor: 'pointer',
          textAlign: 'left',
          color: 'inherit',
        }}
      >
        <div style={{ position: 'relative', width: '46px', height: '46px', flexShrink: 0 }}>
          <img
            src={record.counterpart.avatar}
            alt={record.counterpart.nickname}
            loading="lazy"
            style={{
              width: '100%',
              height: '100%',
              borderRadius: '50%',
              objectFit: 'cover',
              border: `2px solid ${accent}66`,
            }}
          />
          <span
            aria-hidden="true"
            style={{
              position: 'absolute',
              bottom: -2,
              right: -2,
              width: '20px',
              height: '20px',
              borderRadius: '50%',
              background: 'var(--bg-dark)',
              border: '1px solid var(--border-glass)',
              color: accent,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {isVideo ? <Video size={10} /> : <PhoneCall size={10} />}
          </span>
        </div>

        <div style={{ minWidth: 0, flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexWrap: 'wrap' }}>
            <span
              style={{
                fontWeight: 700,
                fontSize: '14.5px',
                color: 'var(--text-primary)',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                maxWidth: '60vw',
              }}
            >
              {record.counterpart.nickname}
            </span>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              marginTop: '3px',
              fontSize: '11.5px',
              color: 'var(--text-secondary)',
              flexWrap: 'wrap',
            }}
          >
            <DirectionIcon
              size={14}
              aria-hidden="true"
              style={{ color: directionColor, flexShrink: 0 }}
            />
            <span>{formatRelativeDay(record.started_at)}</span>
            {record.duration_seconds > 0 && (
              <>
                <span aria-hidden="true">•</span>
                <span>{formatDuration(record.duration_seconds)}</span>
              </>
            )}
          </div>
        </div>
      </button>

      {onStartCall && (
        <button
          type="button"
          onClick={onStartCall}
          aria-label={`Start a new ${record.call_type} call with ${record.counterpart.nickname}`}
          title={`Call ${record.counterpart.nickname}`}
          style={{
            width: '38px',
            height: '38px',
            borderRadius: '50%',
            flexShrink: 0,
            background: `${accent}1f`,
            border: `1px solid ${accent}55`,
            color: accent,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            transition: 'background var(--transition-fast)',
          }}
        >
          {isVideo ? <Video size={16} /> : <PhoneCall size={16} />}
        </button>
      )}
    </div>
  );
};