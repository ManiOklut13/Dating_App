import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';

/* ==========================================================================
   Calls router + data store
   --------------------------------------------------------------------------
   The project has no router library. This follows the exact pattern already
   established by modules/settings/SettingsContext.tsx: a window.location.hash
   pseudo-router with popstate tracking, so browser back / forward work and a
   page refresh on a deep link restores correctly.

   Routes (mirrored in the URL as #/calls/...):
     calls                 -> Calls hub (Audio / Video chooser)
     calls/audio           -> Audio call history
     calls/video           -> Video call history
     calls/audio/:callId   -> Audio call details
     calls/video/:callId   -> Video call details

   Audio and video histories are kept strictly separate: the router carries the
   call_type segment, and the data store keys each list by that type, so an
   audio record can never surface on the video page.
   ========================================================================== */

export const CALLS_ROUTE_PREFIX = 'calls';

export type CallsRoute =
  | { name: 'calls' }
  | { name: 'audio' }
  | { name: 'video' }
  | { name: 'audio-detail'; callId: string }
  | { name: 'video-detail'; callId: string };

const parseRoute = (hash: string): CallsRoute | null => {
  const path = hash.replace(/^#\/?/, '').replace(/\/+$/, '');
  if (path !== CALLS_ROUTE_PREFIX && !path.startsWith(`${CALLS_ROUTE_PREFIX}/`)) return null;

  const segments = path.split('/');
  // segments[0] === 'calls'
  if (segments.length === 1) return { name: 'calls' };

  const type = segments[1];
  if (type !== 'audio' && type !== 'video') return { name: 'calls' };

  if (segments.length === 2) return { name: type };
  if (segments.length >= 3 && segments[2]) {
    return { name: `${type}-detail` as 'audio-detail' | 'video-detail', callId: segments[2] };
  }
  return { name: type };
};

const routeFromHash = (): CallsRoute | null => {
  try {
    return parseRoute(window.location.hash);
  } catch {
    return null;
  }
};

/** The call_type a route belongs to, or null for the Calls hub. */
export const routeCallType = (route: CallsRoute | null): 'audio' | 'video' | null => {
  if (!route) return null;
  if (route.name === 'audio' || route.name === 'audio-detail') return 'audio';
  if (route.name === 'video' || route.name === 'video-detail') return 'video';
  return null;
};

export const buildCallsHash = (route: CallsRoute): string => {
  switch (route.name) {
    case 'calls':
      return `#/${CALLS_ROUTE_PREFIX}`;
    case 'audio':
      return `#/${CALLS_ROUTE_PREFIX}/audio`;
    case 'video':
      return `#/${CALLS_ROUTE_PREFIX}/video`;
    case 'audio-detail':
      return `#/${CALLS_ROUTE_PREFIX}/audio/${encodeURIComponent(route.callId)}`;
    case 'video-detail':
      return `#/${CALLS_ROUTE_PREFIX}/video/${encodeURIComponent(route.callId)}`;
  }
};

interface CallsContextValue {
  route: CallsRoute | null;
  isOpen: boolean;
  /** Push a real history entry, e.g. navigate({ name: 'audio' }). */
  navigate: (route: CallsRoute) => void;
  /**
   * Programmatic back. Pops real history when we pushed the entry; otherwise
   * walks up the calls tree so a deep link still lands somewhere sensible.
   */
  back: () => void;
  /** Which history list is currently in view, or null on the hub. */
  activeCallType: 'audio' | 'video' | null;
}

const CallsContext = createContext<CallsContextValue | undefined>(undefined);

export const CallsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [route, setRoute] = useState<CallsRoute | null>(() => routeFromHash());

  const pushedByApp = useRef(0);
  const pendingPush = useRef(false);
  const routeRef = useRef(route);
  routeRef.current = route;

  useEffect(() => {
    const sync = () => {
      if (pendingPush.current) {
        pendingPush.current = false;
        pushedByApp.current += 1;
      } else if (pushedByApp.current > 0) {
        pushedByApp.current -= 1;
      }
      setRoute(routeFromHash());
    };
    window.addEventListener('hashchange', sync);
    window.addEventListener('popstate', sync);
    return () => {
      window.removeEventListener('hashchange', sync);
      window.removeEventListener('popstate', sync);
    };
  }, []);

  const navigate = useCallback((next: CallsRoute) => {
    const target = buildCallsHash(next);
    if (window.location.hash === target) return;
    pendingPush.current = true;
    window.location.hash = target;
  }, []);

  const back = useCallback(() => {
    const current = routeRef.current;

    if (pushedByApp.current > 0) {
      window.history.back();
      return;
    }

    // Deep link or first entry: walk up the calls tree without stacking history.
    switch (current?.name) {
      case 'audio':
      case 'video':
        navigate({ name: 'calls' });
        return;
      case 'audio-detail':
        navigate({ name: 'audio' });
        return;
      case 'video-detail':
        navigate({ name: 'video' });
        return;
      case 'calls':
      default:
        window.history.replaceState(null, '', window.location.pathname + window.location.search);
        setRoute(null);
    }
  }, [navigate]);

  // The Calls screens are full-page overlays; lock background scroll while open
  // so long histories do not scroll the page behind them.
  useEffect(() => {
    if (!route) return;
    const previous = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = previous;
    };
  }, [route]);

  const value = useMemo<CallsContextValue>(
    () => ({ route, isOpen: route !== null, navigate, back, activeCallType: routeCallType(route) }),
    [route, navigate, back],
  );

  return <CallsContext.Provider value={value}>{children}</CallsContext.Provider>;
};

export const useCalls = (): CallsContextValue => {
  const context = useContext(CallsContext);
  if (!context) {
    throw new Error('useCalls must be used within a CallsProvider');
  }
  return context;
};