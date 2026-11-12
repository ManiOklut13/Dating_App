import React, { createContext, useContext, useState, useMemo, useCallback, useEffect } from 'react';
import {
  UserProfileData,
  ProfilePhoto,
  DatingPreferences,
  PrivacySettings,
  AccountSettingsData,
} from './types';
import { INITIAL_PROFILE } from './mockProfile';

interface ToastMessage {
  type: 'success' | 'info' | 'warning' | 'error';
  message: string;
}

export type SettingsInfoModalKey =
  | 'help'
  | 'contact'
  | 'report'
  | 'guidelines'
  | 'terms'
  | 'privacy';

interface ProfileContextType {
  profile: UserProfileData;
  calculatedAge: number;
  profileCompletion: number;
  completionChecklist: Array<{ id: string; title: string; completed: boolean; targetSection: string }>;
  isLoggedIn: boolean;

  // Actions
  updateProfile: (partial: Partial<UserProfileData>) => void;
  addPhoto: (url: string, caption?: string) => void;
  removePhoto: (id: string) => void;
  setPrimaryPhoto: (id: string) => void;
  toggleInterest: (interest: string) => void;
  addCustomInterest: (custom: string) => void;
  removeCustomInterest: (custom: string) => void;
  updatePreferences: (partial: Partial<DatingPreferences>) => void;
  updatePrivacy: (partial: Partial<PrivacySettings>) => void;
  unblockUser: (id: string) => void;
  unrestrictUser: (id: string) => void;
  completeVerificationDemo: (status?: 'verified' | 'not_verified' | 'requires_review') => void;
  updateAccountSettings: (partial: Partial<AccountSettingsData>) => void;
  deactivateAccount: (reason: string, duration: string) => void;
  reactivateAccount: () => void;
  deleteAccount: () => void;
  logout: () => void;
  login: () => void;
  toggleTheme: () => void;
  markNotificationAsRead: (id: string) => void;

  // Modals
  isEditProfileOpen: boolean;
  setIsEditProfileOpen: (open: boolean) => void;
  isPreviewProfileOpen: boolean;
  setIsPreviewProfileOpen: (open: boolean) => void;
  isVerificationModalOpen: boolean;
  setIsVerificationModalOpen: (open: boolean) => void;
  viewingPhoto: ProfilePhoto | null;
  setViewingPhoto: (photo: ProfilePhoto | null) => void;
  isNotificationsOpen: boolean;
  setIsNotificationsOpen: (open: boolean) => void;
  isSettingsOpen: boolean;
  setIsSettingsOpen: (open: boolean) => void;
  // 3-Dot settings menu placement ('top' = header trigger, 'bottom' = nav trigger)
  settingsMenuAnchor: 'top' | 'bottom';
  openSettingsMenu: (anchor?: 'top' | 'bottom') => void;
  closeSettingsMenu: () => void;
  // Settings menu sub-screens (frontend only)
  isNotificationSettingsOpen: boolean;
  setIsNotificationSettingsOpen: (open: boolean) => void;
  isSecurityOpen: boolean;
  setIsSecurityOpen: (open: boolean) => void;
  settingsInfoModal: SettingsInfoModalKey | null;
  setSettingsInfoModal: (key: SettingsInfoModalKey | null) => void;
  isEmailModalOpen: boolean;
  setIsEmailModalOpen: (open: boolean) => void;
  isPhoneModalOpen: boolean;
  setIsPhoneModalOpen: (open: boolean) => void;
  isPasswordModalOpen: boolean;
  setIsPasswordModalOpen: (open: boolean) => void;
  isDeactivateModalOpen: boolean;
  setIsDeactivateModalOpen: (open: boolean) => void;
  isDeleteModalOpen: boolean;
  setIsDeleteModalOpen: (open: boolean) => void;
  isLogoutConfirmOpen: boolean;
  setIsLogoutConfirmOpen: (open: boolean) => void;
  isBlockedUsersModalOpen: boolean;
  setIsBlockedUsersModalOpen: (open: boolean) => void;
  isRestrictedUsersModalOpen: boolean;
  setIsRestrictedUsersModalOpen: (open: boolean) => void;

  // Toast
  toast: ToastMessage | null;
  showToast: (message: string, type?: 'success' | 'info' | 'warning' | 'error') => void;
  clearToast: () => void;
}

const ProfileContext = createContext<ProfileContextType | undefined>(undefined);

const THEME_STORAGE_KEY = 'younme-app-theme';

// Demo-only preference persistence (no settings endpoint exists on the backend,
// so privacy / account preferences are kept in localStorage for this demo build).
const SETTINGS_STORAGE_KEY = 'younme-settings-prefs';

interface StoredSettings {
  privacy?: Partial<PrivacySettings>;
  settings?: Partial<AccountSettingsData>;
}

const readStoredTheme = (): 'dark' | 'light' => {
  try {
    return window.localStorage.getItem(THEME_STORAGE_KEY) === 'light' ? 'light' : 'dark';
  } catch {
    return 'dark';
  }
};

const readStoredSettings = (): StoredSettings => {
  try {
    const raw = window.localStorage.getItem(SETTINGS_STORAGE_KEY);
    return raw ? (JSON.parse(raw) as StoredSettings) : {};
  } catch {
    return {};
  }
};

const writeStoredSettings = (value: StoredSettings) => {
  try {
    window.localStorage.setItem(SETTINGS_STORAGE_KEY, JSON.stringify(value));
  } catch {
    /* storage unavailable — preferences still apply for this session */
  }
};

export const ProfileProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [profile, setProfile] = useState<UserProfileData>(() => {
    const stored = readStoredSettings();
    // Migrate the legacy messaging audience ('following' | 'followers') to the
    // current everyone / matches / nobody options so persisted prefs stay valid.
    const storedAudience = stored.privacy?.whoCanMessageMe as string | undefined;
    const whoCanMessageMe: PrivacySettings['whoCanMessageMe'] =
      storedAudience === 'everyone' || storedAudience === 'matches' || storedAudience === 'nobody'
        ? storedAudience
        : 'everyone';
    // Migrate the legacy message-request value ('decline') to the current options.
    const storedRequests = stored.privacy?.messageRequests as string | undefined;
    const messageRequests: PrivacySettings['messageRequests'] =
      storedRequests === 'deliver' || storedRequests === 'filter' || storedRequests === 'nobody'
        ? storedRequests
        : 'filter';
    return {
      ...INITIAL_PROFILE,
      privacy: { ...INITIAL_PROFILE.privacy, ...stored.privacy, whoCanMessageMe, messageRequests },
      settings: {
        ...INITIAL_PROFILE.settings,
        ...stored.settings,
        notifications: {
          ...INITIAL_PROFILE.settings.notifications,
          ...stored.settings?.notifications,
        },
        security: {
          ...INITIAL_PROFILE.settings.security,
          ...stored.settings?.security,
        },
        appTheme: readStoredTheme(),
      },
    };
  });
  const [isLoggedIn, setIsLoggedIn] = useState(true);

  // Modals state
  const [isEditProfileOpen, setIsEditProfileOpen] = useState(false);
  const [isPreviewProfileOpen, setIsPreviewProfileOpen] = useState(false);
  const [isVerificationModalOpen, setIsVerificationModalOpen] = useState(false);
  const [viewingPhoto, setViewingPhoto] = useState<ProfilePhoto | null>(null);
  const [isNotificationsOpen, setIsNotificationsOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [settingsMenuAnchor, setSettingsMenuAnchor] = useState<'top' | 'bottom'>('top');
  const [isNotificationSettingsOpen, setIsNotificationSettingsOpen] = useState(false);
  const [isSecurityOpen, setIsSecurityOpen] = useState(false);
  const [settingsInfoModal, setSettingsInfoModal] = useState<SettingsInfoModalKey | null>(null);
  const [isEmailModalOpen, setIsEmailModalOpen] = useState(false);
  const [isPhoneModalOpen, setIsPhoneModalOpen] = useState(false);
  const [isPasswordModalOpen, setIsPasswordModalOpen] = useState(false);
  const [isDeactivateModalOpen, setIsDeactivateModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [isLogoutConfirmOpen, setIsLogoutConfirmOpen] = useState(false);
  const [isBlockedUsersModalOpen, setIsBlockedUsersModalOpen] = useState(false);
  const [isRestrictedUsersModalOpen, setIsRestrictedUsersModalOpen] = useState(false);

  // Toast state
  const [toast, setToast] = useState<ToastMessage | null>(null);

  const showToast = useCallback((message: string, type: 'success' | 'info' | 'warning' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => {
      setToast((cur) => (cur?.message === message ? null : cur));
    }, 4000);
  }, []);

  const clearToast = useCallback(() => setToast(null), []);

  // Calculate age from date of birth
  const calculatedAge = useMemo(() => {
    try {
      const birth = new Date(profile.dateOfBirth);
      const diff = Date.now() - birth.getTime();
      const ageDt = new Date(diff);
      return Math.abs(ageDt.getUTCFullYear() - 1970);
    } catch {
      return 25;
    }
  }, [profile.dateOfBirth]);

  // Profile completion items
  const completionChecklist = useMemo(() => {
    return [
      {
        id: 'photos',
        title: 'Add at least 3 profile photos',
        completed: profile.photos.length >= 3,
        targetSection: 'photos',
      },
      {
        id: 'bio',
        title: 'Complete your personal bio',
        completed: profile.bio.trim().length > 20,
        targetSection: 'aboutme',
      },
      {
        id: 'interests',
        title: 'Select at least 4 interests or hobbies',
        completed: profile.interests.length + profile.customInterests.length >= 4,
        targetSection: 'interests',
      },
      {
        id: 'preferences',
        title: 'Set your dating & discovery preferences',
        completed: profile.preferences.activities.length > 0 && !!profile.preferences.lookingFor,
        targetSection: 'preferences',
      },
      {
        id: 'verification',
        title: 'Verify your profile with face & voice scan',
        completed: profile.verification.status === 'verified',
        targetSection: 'verification',
      },
    ];
  }, [profile]);

  // Calculated percentage
  const profileCompletion = useMemo(() => {
    const total = completionChecklist.length;
    const completed = completionChecklist.filter((c) => c.completed).length;
    return Math.round((completed / total) * 100);
  }, [completionChecklist]);

  // Sync theme changes with body class (+ remember the choice locally)
  useEffect(() => {
    if (profile.settings.appTheme === 'light') {
      document.body.classList.add('light-theme');
    } else {
      document.body.classList.remove('light-theme');
    }
    try {
      window.localStorage.setItem(THEME_STORAGE_KEY, profile.settings.appTheme);
    } catch {
      /* storage unavailable — theme still applies for this session */
    }
  }, [profile.settings.appTheme]);

  // Persist privacy + account preferences (demo persistence, see SETTINGS_STORAGE_KEY)
  useEffect(() => {
    writeStoredSettings({ privacy: profile.privacy, settings: profile.settings });
  }, [profile.privacy, profile.settings]);

  // 3-Dot settings menu helpers
  const openSettingsMenu = useCallback((anchor: 'top' | 'bottom' = 'top') => {
    setSettingsMenuAnchor(anchor);
    setIsSettingsOpen(true);
  }, []);

  const closeSettingsMenu = useCallback(() => setIsSettingsOpen(false), []);

  // Update Profile
  const updateProfile = useCallback((partial: Partial<UserProfileData>) => {
    setProfile((prev) => ({ ...prev, ...partial }));
    showToast('Profile updated successfully!', 'success');
  }, [showToast]);

  // Photos Actions
  const addPhoto = useCallback((url: string, caption?: string) => {
    setProfile((prev) => {
      const isFirst = prev.photos.length === 0;
      const newPhoto: ProfilePhoto = {
        id: `photo-${Date.now()}`,
        url,
        isPrimary: isFirst,
        caption: caption || 'New photo',
      };
      return {
        ...prev,
        photos: [...prev.photos, newPhoto],
      };
    });
    showToast('Photo added to gallery!', 'success');
  }, [showToast]);

  const removePhoto = useCallback((id: string) => {
    setProfile((prev) => {
      const photoToRemove = prev.photos.find((p) => p.id === id);
      const remaining = prev.photos.filter((p) => p.id !== id);
      if (photoToRemove?.isPrimary && remaining.length > 0) {
        remaining[0].isPrimary = true;
      }
      return {
        ...prev,
        photos: remaining,
      };
    });
    showToast('Photo removed', 'info');
  }, [showToast]);

  const setPrimaryPhoto = useCallback((id: string) => {
    setProfile((prev) => ({
      ...prev,
      photos: prev.photos.map((p) => ({
        ...p,
        isPrimary: p.id === id,
      })),
    }));
    showToast('Primary profile photo updated!', 'success');
  }, [showToast]);

  // Interests Actions
  const toggleInterest = useCallback((interest: string) => {
    setProfile((prev) => {
      const exists = prev.interests.includes(interest);
      const updated = exists
        ? prev.interests.filter((i) => i !== interest)
        : [...prev.interests, interest];
      return {
        ...prev,
        interests: updated,
      };
    });
  }, []);

  const addCustomInterest = useCallback((custom: string) => {
    const trimmed = custom.trim();
    if (!trimmed) return;
    setProfile((prev) => {
      if (prev.customInterests.includes(trimmed) || prev.interests.includes(trimmed)) return prev;
      return {
        ...prev,
        customInterests: [...prev.customInterests, trimmed],
      };
    });
    showToast(`Added custom interest: "${trimmed}"`, 'success');
  }, [showToast]);

  const removeCustomInterest = useCallback((custom: string) => {
    setProfile((prev) => ({
      ...prev,
      customInterests: prev.customInterests.filter((i) => i !== custom),
    }));
    showToast(`Removed custom interest: "${custom}"`, 'info');
  }, [showToast]);

  // Preferences Actions
  const updatePreferences = useCallback((partial: Partial<DatingPreferences>) => {
    setProfile((prev) => ({
      ...prev,
      preferences: { ...prev.preferences, ...partial },
    }));
    showToast('Dating preferences saved!', 'success');
  }, [showToast]);

  // Privacy Actions
  const updatePrivacy = useCallback((partial: Partial<PrivacySettings>) => {
    setProfile((prev) => ({
      ...prev,
      privacy: { ...prev.privacy, ...partial },
    }));
    showToast('Privacy settings updated!', 'success');
  }, [showToast]);

  const unblockUser = useCallback((id: string) => {
    setProfile((prev) => ({
      ...prev,
      privacy: {
        ...prev.privacy,
        blockedUsers: prev.privacy.blockedUsers.filter((u) => u.id !== id),
      },
    }));
    showToast('User has been unblocked.', 'success');
  }, [showToast]);

  const unrestrictUser = useCallback((id: string) => {
    setProfile((prev) => ({
      ...prev,
      privacy: {
        ...prev.privacy,
        restrictedUsers: prev.privacy.restrictedUsers.filter((u) => u.id !== id),
      },
    }));
    showToast('Restriction removed.', 'success');
  }, [showToast]);

  // Verification Demo
  const completeVerificationDemo = useCallback((status: 'verified' | 'not_verified' | 'requires_review' = 'verified') => {
    setProfile((prev) => ({
      ...prev,
      verification: {
        status,
        verifiedAt: status === 'verified' ? 'Just now' : undefined,
        faceVerified: status === 'verified',
        voiceVerified: status === 'verified',
        livenessScore: status === 'verified' ? 99 : undefined,
      },
    }));
    if (status === 'verified') {
      showToast('🎉 Verification complete! Blue Tick badge awarded to your profile.', 'success');
    } else {
      showToast('Verification status updated.', 'info');
    }
  }, [showToast]);

  // Account Settings Actions
  const updateAccountSettings = useCallback((partial: Partial<AccountSettingsData>) => {
    setProfile((prev) => ({
      ...prev,
      settings: { ...prev.settings, ...partial },
    }));
    showToast('Account settings saved!', 'success');
  }, [showToast]);

  // Theme Toggle
  const toggleTheme = useCallback(() => {
    setProfile((prev) => {
      const nextTheme = prev.settings.appTheme === 'dark' ? 'light' : 'dark';
      return {
        ...prev,
        settings: { ...prev.settings, appTheme: nextTheme },
      };
    });
    showToast('Theme switched!', 'info');
  }, [showToast]);

  // Account Deactivation & Deletion
  const deactivateAccount = useCallback((reason: string, duration: string) => {
    setProfile((prev) => ({ ...prev, isDeactivated: true }));
    showToast(`Account deactivated (${duration}). Reason: ${reason}`, 'warning');
  }, [showToast]);

  const reactivateAccount = useCallback(() => {
    setProfile((prev) => ({ ...prev, isDeactivated: false }));
    showToast('Welcome back! Your profile has been reactivated.', 'success');
  }, [showToast]);

  const deleteAccount = useCallback(() => {
    setProfile(INITIAL_PROFILE);
    setIsLoggedIn(false);
    showToast('Account permanently deleted.', 'error');
  }, [showToast]);

  const logout = useCallback(() => {
    setIsLoggedIn(false);
    showToast('Logged out successfully.', 'info');
  }, [showToast]);

  const login = useCallback(() => {
    setIsLoggedIn(true);
    showToast('Welcome back, Alex!', 'success');
  }, [showToast]);

  const markNotificationAsRead = useCallback((id: string) => {
    setProfile((prev) => ({
      ...prev,
      notifications: prev.notifications.map((n) => (n.id === id ? { ...n, unread: false } : n)),
    }));
  }, []);

  return (
    <ProfileContext.Provider
      value={{
        profile,
        calculatedAge,
        profileCompletion,
        completionChecklist,
        isLoggedIn,

        updateProfile,
        addPhoto,
        removePhoto,
        setPrimaryPhoto,
        toggleInterest,
        addCustomInterest,
        removeCustomInterest,
        updatePreferences,
        updatePrivacy,
        unblockUser,
        unrestrictUser,
        completeVerificationDemo,
        updateAccountSettings,
        deactivateAccount,
        reactivateAccount,
        deleteAccount,
        logout,
        login,
        toggleTheme,
        markNotificationAsRead,

        isEditProfileOpen,
        setIsEditProfileOpen,
        isPreviewProfileOpen,
        setIsPreviewProfileOpen,
        isVerificationModalOpen,
        setIsVerificationModalOpen,
        viewingPhoto,
        setViewingPhoto,
        isNotificationsOpen,
        setIsNotificationsOpen,
        isSettingsOpen,
        setIsSettingsOpen,
        settingsMenuAnchor,
        openSettingsMenu,
        closeSettingsMenu,
        isNotificationSettingsOpen,
        setIsNotificationSettingsOpen,
        isSecurityOpen,
        setIsSecurityOpen,
        settingsInfoModal,
        setSettingsInfoModal,
        isEmailModalOpen,
        setIsEmailModalOpen,
        isPhoneModalOpen,
        setIsPhoneModalOpen,
        isPasswordModalOpen,
        setIsPasswordModalOpen,
        isDeactivateModalOpen,
        setIsDeactivateModalOpen,
        isDeleteModalOpen,
        setIsDeleteModalOpen,
        isLogoutConfirmOpen,
        setIsLogoutConfirmOpen,
        isBlockedUsersModalOpen,
        setIsBlockedUsersModalOpen,
        isRestrictedUsersModalOpen,
        setIsRestrictedUsersModalOpen,

        toast,
        showToast,
        clearToast,
      }}
    >
      {children}
    </ProfileContext.Provider>
  );
};

export const useProfile = () => {
  const context = useContext(ProfileContext);
  if (!context) {
    throw new Error('useProfile must be used within a ProfileProvider');
  }
  return context;
};
