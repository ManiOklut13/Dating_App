import React, { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';
import {
  OnboardingState,
  Route,
  KNOWN_ROUTES,
  ONBOARDING_STEPS,
  ThemeChoice,
} from './types';
import { DEFAULT_NOTIFICATION_PREFS } from './mockData';
import { validateDob } from './validation';

export interface ToastState {
  type: 'success' | 'error' | 'warn' | 'info';
  message: string;
}

interface OnboardingContextType {
  route: Route;
  go: (next: Route) => void;
  back: () => void;
  stepIndex: number;
  stepProgress: number;
  nextStep: () => void;
  prevStep: () => void;
  state: OnboardingState;
  patch: (partial: Partial<OnboardingState>) => void;
  completion: number;
  age: number | null;
  toast: ToastState | null;
  showToast: (message: string, type?: ToastState['type']) => void;
  clearToast: () => void;
}

const OnboardingContext = createContext<OnboardingContextType | undefined>(undefined);

const readTheme = (): ThemeChoice => {
  try {
    return window.localStorage.getItem('younme-app-theme') === 'light' ? 'light' : 'dark';
  } catch {
    return 'dark';
  }
};

const initialState: OnboardingState = {
  method: 'email',
  email: '',
  countryCode: '+91',
  phone: '',
  password: '',
  confirmPassword: '',
  acceptedTerms: false,
  destinationType: 'email',
  destination: '',

  firstName: '',
  dob: '',
  gender: '',
  genderSelf: '',
  orientation: '',
  orientationSelf: '',

  photos: [],
  avatar: null,

  lookingFor: [],
  interestedIn: '',
  ageMin: 21,
  ageMax: 32,
  distanceKm: 25,
  languages: ['English'],

  interests: [],
  customInterests: [],

  bio: '',
  profession: '',
  education: '',
  city: '',

  permissions: {
    notifications: 'not_requested',
    contacts: 'not_requested',
    microphone: 'not_requested',
    camera: 'not_requested',
  },

  visibility: 'everyone',
  showOnlineStatus: true,
  whoCanMessage: 'matches',

  notifications: { ...DEFAULT_NOTIFICATION_PREFS },
  theme: readTheme(),

  completed: false,
};

const routeFromHash = (): Route => {
  try {
    const hash = window.location.hash.replace(/^#/, '');
    if (hash && KNOWN_ROUTES.includes(hash)) return hash as Route;
  } catch {
    /* no window */
  }
  return 'welcome';
};

export const OnboardingProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [route, setRoute] = useState<Route>(() => routeFromHash());
  const [state, setState] = useState<OnboardingState>(initialState);
  const [toast, setToast] = useState<ToastState | null>(null);
  const stack = useRef<Route[]>([]);

  /* Reflect the current step in the URL (frontend-only pseudo-routing). */
  useEffect(() => {
    const target = `#${route}`;
    if (window.location.hash !== target) {
      window.history.replaceState(null, '', target);
    }
  }, [route]);

  useEffect(() => {
    const onPop = () => setRoute(routeFromHash());
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, []);

  /* Apply the selected theme immediately (shared body class with the main app). */
  useEffect(() => {
    const prefersLight =
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-color-scheme: light)').matches;
    const resolved = state.theme === 'system' ? (prefersLight ? 'light' : 'dark') : state.theme;
    document.body.classList.toggle('light-theme', resolved === 'light');
    try {
      window.localStorage.setItem('younme-app-theme', resolved);
    } catch {
      /* storage unavailable */
    }
  }, [state.theme]);

  const showToast = (message: string, type: ToastState['type'] = 'info') => {
    setToast({ message, type });
    window.setTimeout(() => {
      setToast((current) => (current?.message === message ? null : current));
    }, 3600);
  };

  const clearToast = () => setToast(null);

  const go = (next: Route) => {
    if (next === route) return;
    stack.current.push(route);
    setRoute(next);
  };

  const stepIndex = useMemo(
    () => ONBOARDING_STEPS.findIndex((step) => step.route === route),
    [route],
  );

  const back = () => {
    const previous = stack.current.pop();
    if (previous) {
      setRoute(previous);
      return;
    }
    if (stepIndex > 0) {
      setRoute(ONBOARDING_STEPS[stepIndex - 1].route as Route);
      return;
    }
    setRoute('welcome');
  };

  const nextStep = () => {
    if (stepIndex >= 0 && stepIndex < ONBOARDING_STEPS.length - 1) {
      go(ONBOARDING_STEPS[stepIndex + 1].route as Route);
    }
  };

  const prevStep = () => back();

  const patch = (partial: Partial<OnboardingState>) => setState((current) => ({ ...current, ...partial }));

  const stepProgress = useMemo(() => {
    if (stepIndex < 0) return 0;
    return Math.round(((stepIndex + 1) / ONBOARDING_STEPS.length) * 100);
  }, [stepIndex]);

  const age = useMemo(() => validateDob(state.dob).age, [state.dob]);

  const completion = useMemo(() => {
    let score = 0;
    if (state.firstName.trim()) score += 6.25;
    if (validateDob(state.dob).age !== null) score += 6.25;
    if (state.gender) score += 6.25;
    if (state.orientation) score += 6.25;
    if (state.photos.length > 0 || state.avatar) score += 20;
    if (state.lookingFor.length > 0 && state.interestedIn) score += 20;
    if (state.interests.length + state.customInterests.length >= 3) score += 15;
    if (state.bio.trim().length >= 20) score += 10;
    if (state.city && state.languages.length > 0) score += 10;
    return Math.min(100, Math.round(score));
  }, [state]);

  const value: OnboardingContextType = {
    route,
    go,
    back,
    stepIndex,
    stepProgress,
    nextStep,
    prevStep,
    state,
    patch,
    completion,
    age,
    toast,
    showToast,
    clearToast,
  };

  return <OnboardingContext.Provider value={value}>{children}</OnboardingContext.Provider>;
};

export const useOnboarding = (): OnboardingContextType => {
  const context = useContext(OnboardingContext);
  if (!context) throw new Error('useOnboarding must be used within an OnboardingProvider');
  return context;
};
