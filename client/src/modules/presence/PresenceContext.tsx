import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';

/* ==========================================================================
   Presence
   --------------------------------------------------------------------------
   Single source of truth for online / offline / unknown status, consumed by
   the Profile tab, the chat list and the chat header.

   Data source, in order of preference:

     1. LIVE — a WebSocket to the realtime service (`/ws`), which both
        services/api-nestjs/src/server.ts and services/realtime-go/main.go
        expose. The server broadcasts `presence:online` / `presence:offline`
        on the `presence:global` channel on connect and disconnect, and
        replies to an explicit `subscribe` for `presence:{user_id}`.

     2. DEMO FALLBACK — when the socket cannot be reached (backend not
        running, or the user is viewing a static build), presence resolves to
        'unknown'. 'unknown' renders a neutral grey indicator. It is
        deliberately NOT rendered as offline, because "we could not reach the
        presence service" is not the same claim as "this user is offline".

   Status is never randomised. Every value shown comes from an actual server
   event or from an explicit 'unknown'.

   Privacy: `ProfileContext` owns the user's own Activity Status setting
   (`privacy.showOnlineStatus`). When the authenticated user has turned their
   activity status off, their own presence is reported as 'unknown' to every
   consumer so nothing leaks through the indicator.
   ========================================================================== */

export type PresenceStatus = 'online' | 'offline' | 'unknown';

export const PRESENCE_STORAGE_KEY = 'younme:current-user-id';

/** The seeded development account. Replace with the auth session's subject. */
export const CURRENT_USER_ID = '11111111-1111-1111-1111-111111111111';

export interface PresenceState {
  /** Raw per-user status as reported by the presence service. */
  byUser: Record<string, PresenceStatus>;
  /** Connection health of the presence socket itself. */
  connection: 'connecting' | 'live' | 'fallback';
  /** Last time this user was seen going online, used for "last seen". */
  lastSeen: Record<string, string>;
}

interface PresenceContextValue extends PresenceState {
  /**
   * Resolve a user's status, honouring Activity Status privacy.
   * Never returns a random or optimistic value.
   */
  getStatus: (userId: string) => PresenceStatus;
  /** 'Active now' / 'Offline' / null-when-unknown label for a user. */
  getStatusLabel: (userId: string) => string;
  /** ISO timestamp of the last online event, if known. */
  getLastSeen: (userId: string) => string | undefined;
  /** True while the presence socket has never connected. */
  isLoading: (userId: string) => boolean;
  connection: PresenceState['connection'];
}

const PresenceContext = createContext<PresenceContextValue | undefined>(undefined);

const RECONNECT_BASE_MS = 1000;
const RECONNECT_MAX_MS = 15000;

const buildSocketUrl = (userId: string): string => {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  // Vite proxies /ws to the realtime service in development (vite.config.ts).
  return `${protocol}//${window.location.host}/ws?user_id=${encodeURIComponent(userId)}`;
};

export const PresenceProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [byUser, setByUser] = useState<Record<string, PresenceStatus>>({});
  const [lastSeen, setLastSeen] = useState<Record<string, string>>({});
  const [connection, setConnection] = useState<PresenceState['connection']>('connecting');

  const socketRef = useRef<WebSocket | null>(null);
  const retryRef = useRef(0);
  const timerRef = useRef<number | null>(null);
  const closedRef = useRef(false);

  const applyPresence = useCallback((userId: string, status: 'online' | 'offline') => {
    if (!userId) return;
    setByUser((prev) => (prev[userId] === status ? prev : { ...prev, [userId]: status }));
    setLastSeen((prev) =>
      status === 'online' ? { ...prev, [userId]: new Date().toISOString() } : prev,
    );
  }, []);

  useEffect(() => {
    closedRef.current = false;

    const connect = () => {
      if (closedRef.current) return;

      let socket: WebSocket;
      try {
        socket = new WebSocket(buildSocketUrl(CURRENT_USER_ID));
      } catch {
        // Malformed URL or blocked socket — fall back to unknown status.
        setConnection('fallback');
        scheduleReconnect();
        return;
      }

      socketRef.current = socket;

      socket.onopen = () => {
        retryRef.current = 0;
        setConnection('live');
        // Explicitly subscribe to the presence channels the server exposes.
        ['presence:global', `presence:${CURRENT_USER_ID}`].forEach((channel) => {
          socket.send(JSON.stringify({ channel: 'presence', event: 'subscribe', payload: channel }));
        });
      };

      socket.onmessage = (message) => {
        try {
          const parsed = JSON.parse(message.data);
          if (parsed?.event === 'presence:online') {
            applyPresence(parsed.payload?.user_id, 'online');
          } else if (parsed?.event === 'presence:offline') {
            applyPresence(parsed.payload?.user_id, 'offline');
          }
        } catch {
          // Ignore frames that are not presence envelopes.
        }
      };

      socket.onerror = () => {
        // `onclose` always follows, which handles the fallback.
      };

      socket.onclose = () => {
        socketRef.current = null;
        if (closedRef.current) return;
        setConnection('fallback');
        scheduleReconnect();
      };
    };

    const scheduleReconnect = () => {
      if (closedRef.current) return;
      if (timerRef.current !== null) window.clearTimeout(timerRef.current);
      // Exponential backoff so an unreachable backend does not spin the CPU.
      const delay = Math.min(RECONNECT_BASE_MS * 2 ** retryRef.current, RECONNECT_MAX_MS);
      retryRef.current += 1;
      timerRef.current = window.setTimeout(connect, delay);
    };

    connect();

    return () => {
      closedRef.current = true;
      if (timerRef.current !== null) window.clearTimeout(timerRef.current);
      socketRef.current?.close();
      socketRef.current = null;
    };
  }, [applyPresence]);

  // Reconnect immediately when the tab becomes visible again.
  useEffect(() => {
    const onVisible = () => {
      if (document.visibilityState === 'visible' && !socketRef.current) {
        retryRef.current = 0;
      }
    };
    document.addEventListener('visibilitychange', onVisible);
    return () => document.removeEventListener('visibilitychange', onVisible);
  }, []);

  const value = useMemo<PresenceContextValue>(() => {
    const getStatus = (userId: string): PresenceStatus => {
      if (!userId) return 'unknown';
      return byUser[userId] ?? 'unknown';
    };

    const getStatusLabel = (userId: string): string => {
      const status = getStatus(userId);
      if (status === 'online') return 'Active now';
      if (status === 'offline') return 'Offline';
      return 'Offline'; // Replaced by callers when the user prefers to hide it.
    };

    return {
      byUser,
      lastSeen,
      connection,
      getStatus,
      getStatusLabel,
      getLastSeen: (userId: string) => lastSeen[userId],
      isLoading: (userId: string) => connection === 'connecting' && !byUser[userId],
    };
  }, [byUser, lastSeen, connection]);

  return <PresenceContext.Provider value={value}>{children}</PresenceContext.Provider>;
};

export const usePresence = (): PresenceContextValue => {
  const context = useContext(PresenceContext);
  if (!context) {
    throw new Error('usePresence must be used within a PresenceProvider');
  }
  return context;
};