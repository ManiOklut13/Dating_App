import React, { useEffect } from 'react';
import { useSettings, SettingsRoute } from './SettingsContext';
import { SettingsActivityPage } from './SettingsActivityPage';
import { PrivacySafetyPage, BlockedAccountsPage, RestrictedAccountsPage, HiddenWordsPage } from './PrivacySafetyPage';
import { ActivityStatusPage } from './ActivityStatusPage';
import { MessagingPrivacyPage } from './MessagingPrivacyPage';
import { NotificationsPage } from './NotificationsPage';
import { ThemeLanguagePage } from './ThemeLanguagePage';
import { SecurityPage, LoginActivityPage, DevicesPage } from './SecurityPage';
import { AccountManagementPage } from './AccountManagementPage';
import { HelpSupportPage, SupportRequestsPage, FaqPage } from './HelpSupportPage';

/* ==========================================================================
   Maps the current settings route (see SettingsContext) to its page.
   Returns null when the settings screens are closed, so it can be mounted
   permanently inside the app shell.
   ========================================================================== */

const PAGES: Record<SettingsRoute, React.FC> = {
  settings: SettingsActivityPage,
  'settings/privacy': PrivacySafetyPage,
  'settings/privacy/blocked': BlockedAccountsPage,
  'settings/privacy/restricted': RestrictedAccountsPage,
  'settings/privacy/hidden-words': HiddenWordsPage,
  'settings/activity-status': ActivityStatusPage,
  'settings/messaging': MessagingPrivacyPage,
  'settings/notifications': NotificationsPage,
  'settings/theme-language': ThemeLanguagePage,
  'settings/security': SecurityPage,
  'settings/security/login-activity': LoginActivityPage,
  'settings/security/devices': DevicesPage,
  'settings/security/account-management': AccountManagementPage,
  'settings/help': HelpSupportPage,
  'settings/help/support-requests': SupportRequestsPage,
  'settings/help/faq': FaqPage,
};

export const SettingsRouter: React.FC = () => {
  const { route, isActive } = useSettings();

  // Lock body scroll while a settings page is open (they scroll internally).
  useEffect(() => {
    if (!isActive) return;
    const previous = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = previous;
    };
  }, [isActive]);

  if (!route) return null;
  const Page = PAGES[route] ?? SettingsActivityPage;
  return <Page />;
};

export default SettingsRouter;
