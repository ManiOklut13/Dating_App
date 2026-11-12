import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';

/* ==========================================================================
   Settings router
   --------------------------------------------------------------------------
   The app has no router library; onboarding already uses a hash-based
   pseudo-routing pattern (window.location.hash + popstate). The settings
   screens follow the same approach so every navigation is a real history
   entry and the browser back / forward buttons work correctly.

   Routes (mirrored in the URL as #/...):
     settings                            -> Settings and Activity (hub)
     settings/privacy                    -> Privacy and Safety
     settings/privacy/blocked            -> Blocked Accounts
     settings/privacy/restricted         -> Restricted Accounts
     settings/privacy/hidden-words       -> Hidden Words
     settings/activity-status            -> Activity Status
     settings/messaging                  -> Who Can Message Me
     settings/notifications              -> Notifications
     settings/theme-language             -> Themes and Languages
     settings/security                   -> Security
     settings/security/login-activity    -> Login Activity (history)
     settings/security/devices           -> Where You're Logged In
     settings/security/account-management -> Account Management
     settings/help                       -> Help and Support
     settings/help/support-requests      -> Support Requests
     settings/help/faq                   -> Frequently Asked Questions
   ========================================================================== */

export const SETTINGS_ROUTES = [
  'settings',
  'settings/privacy',
  'settings/privacy/blocked',
  'settings/privacy/restricted',
  'settings/privacy/hidden-words',
  'settings/activity-status',
  'settings/messaging',
  'settings/notifications',
  'settings/theme-language',
  'settings/security',
  'settings/security/login-activity',
  'settings/security/devices',
  'settings/security/account-management',
  'settings/help',
  'settings/help/support-requests',
  'settings/help/faq',
] as const;

export type SettingsRoute = (typeof SETTINGS_ROUTES)[number];

const routeFromHash = (): SettingsRoute | null => {
  try {
    const hash = window.location.hash.replace(/^#\/?/, '');
    if (!hash) return null;
    if (hash === 'settings' || hash.startsWith('settings/')) {
      return (SETTINGS_ROUTES as readonly string[]).includes(hash)
        ? (hash as SettingsRoute)
        : 'settings';
    }
    return null;
  } catch {
    return null;
  }
};

interface SettingsContextType {
  /** Current settings route, or null when the settings screens are closed. */
  route: SettingsRoute | null;
  /** True while any settings screen is open. */
  isActive: boolean;
  /** Push a new history entry (e.g. navigate('settings/privacy')). */
  navigate: (route: SettingsRoute) => void;
  /** Programmatic back: pops real history when we have entries, otherwise walks up. */
  back: () => void;
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined);

export const SettingsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [route, setRoute] = useState<SettingsRoute | null>(() => routeFromHash());

  // History entries pushed by navigate() — lets back() decide between
  // history.back() (normal flow) and replaceState (deep link / fresh load).
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
        // A back / forward traversal brought us here.
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

  const navigate = useCallback((next: SettingsRoute) => {
    const target = `#/${next}`;
    if (window.location.hash === target) return;
    pendingPush.current = true;
    window.location.hash = target; // fires hashchange -> sync()
  }, []);

  const back = useCallback(() => {
    const current = routeRef.current;
    if (pushedByApp.current > 0) {
      window.history.back();
      return;
    }
    // Deep link / first entry: walk up the settings tree without stacking history.
    if (current && current !== 'settings') {
      const segments = current.split('/');
      segments.pop();
      const parent = segments.join('/') as SettingsRoute;
      window.history.replaceState(null, '', `#/${parent}`);
      setRoute(parent);
      return;
    }
    window.history.replaceState(null, '', window.location.pathname + window.location.search);
    setRoute(null);
  }, []);

  const value = useMemo<SettingsContextType>(
    () => ({ route, isActive: route !== null, navigate, back }),
    [route, navigate, back],
  );

  return <SettingsContext.Provider value={value}>{children}</SettingsContext.Provider>;
};

export const useSettings = (): SettingsContextType => {
  const context = useContext(SettingsContext);
  if (!context) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};
