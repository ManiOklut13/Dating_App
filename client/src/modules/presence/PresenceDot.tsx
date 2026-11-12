import React from 'react';
import { usePresence, PresenceStatus } from './PresenceContext';
import { useProfile } from '../profile/ProfileContext';

/* ==========================================================================
   PresenceDot
   --------------------------------------------------------------------------
   The online / offline indicator drawn on the bottom-right of a profile photo.

   Colour rules (never two at once, never a guess):
     online   -> green  (#00e676, --emerald-live)
     offline  -> red    (#ff4757)
     unknown  -> grey   (--text-muted) — used while presence is loading or the
                realtime service is unreachable, so a missing connection is
                never reported as "offline".

   The ring around the dot uses --bg-surface rather than a hardcoded dark
   colour, so the indicator stays legible in both the dark and light themes.
   ========================================================================== */

export const PRESENCE_COLORS: Record<PresenceStatus, string> = {
  online: '#00e676',
  offline: '#ff4757',
  unknown: '#5e6682',
};

export const PRESENCE_LABELS: Record<PresenceStatus, string> = {
  online: 'Active now',
  offline: 'Offline',
  unknown: '',
};

export interface PresenceDotProps {
  userId: string;
  /** Diameter of the indicator in px. Defaults to 12. */
  size?: number;
  /**
   * Set for the authenticated user's own photo. When their Activity Status
   * privacy setting is off, their presence is hidden and renders as unknown.
   */
  isSelf?: boolean;
  className?: string;
  style?: React.CSSProperties;
}

export const PresenceDot: React.FC<PresenceDotProps> = ({
  userId,
  size = 12,
  isSelf = false,
  className,
  style,
}) => {
  const { getStatus, connection } = usePresence();
  const { profile } = useProfile();

  const hidesOwnActivity = isSelf && !profile.privacy.showOnlineStatus;
  const status: PresenceStatus = hidesOwnActivity ? 'unknown' : getStatus(userId);

  const label = hidesOwnActivity
    ? 'Activity status hidden'
    : `${PRESENCE_LABELS[status]}${connection === 'fallback' ? ' (live presence unavailable)' : ''}`;

  return (
    <span
      role="status"
      aria-label={label}
      title={label}
      className={className}
      data-presence={status}
      style={{
        position: 'absolute',
        bottom: 0,
        right: 0,
        width: size,
        height: size,
        borderRadius: '50%',
        background: PRESENCE_COLORS[status],
        // Theme-aware ring so the dot separates from the photo in both themes.
        border: `2px solid var(--bg-surface, var(--bg-surface))`,
        boxShadow: '0 0 0 1px rgba(0, 0, 0, 0.35)',
        pointerEvents: 'none',
        zIndex: 2,
        ...style,
      }}
    />
  );
};

/**
 * Text label paired with a PresenceDot: "Active now" when online, "Offline"
 * when offline, and a neutral "Status unavailable" while loading.
 */
export const PresenceLabel: React.FC<{
  userId: string;
  isSelf?: boolean;
  suffix?: string;
}> = ({ userId, isSelf = false, suffix }) => {
  const { getStatus, connection } = usePresence();
  const { profile } = useProfile();

  const hidesOwnActivity = isSelf && !profile.privacy.showOnlineStatus;
  const status: PresenceStatus = hidesOwnActivity ? 'unknown' : getStatus(userId);

  const text = hidesOwnActivity
    ? 'Activity status hidden'
    : PRESENCE_LABELS[status] || '';

  return (
    <span
      style={{
        fontSize: '11px',
        color: status === 'online' ? '#00e676' : 'var(--text-muted)',
        display: 'inline-flex',
        alignItems: 'center',
        gap: '4px',
      }}
    >
      {text}
      {suffix && status !== 'unknown' ? ` • ${suffix}` : ''}
    </span>
  );
};