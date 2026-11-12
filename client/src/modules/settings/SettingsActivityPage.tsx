import React from 'react';
import {
  Eye,
  Share2,
  Shield,
  Activity,
  MessageSquare,
  UserX,
  UserCog,
  Bell,
  Palette,
  Lock,
  LifeBuoy,
  LogOut,
} from 'lucide-react';
import { useSettings } from './SettingsContext';
import { SettingsPage, SettingsSection, SettingsNavRow } from './SettingsUI';
import { useProfile } from '../profile/ProfileContext';

/* ==========================================================================
   Settings and Activity — the unified hub page opened from the Profile Settings icon.
   Consolidates all privacy, account management, discovery, and app preference items
   without duplicate options or redundant menu levels.
   ========================================================================== */

export const SettingsActivityPage: React.FC = () => {
  const { navigate } = useSettings();
  const {
    setIsPreviewProfileOpen,
    setIsLogoutConfirmOpen,
    showToast,
  } = useProfile();

  const handleShareProfile = () => {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(window.location.origin);
    }
    showToast('Profile link copied to clipboard!', 'info');
  };

  return (
    <SettingsPage
      title="Settings and activity"
      subtitle="Manage your profile, privacy, account and app preferences"
    >
      {/* 1. Profile & Discovery */}
      <SettingsSection label="Profile and discovery">
        <SettingsNavRow
          icon={<Eye size={18} color="#00e5ff" />}
          label="Preview Public Profile"
          hint="View your card exactly as other daters see it"
          onClick={() => setIsPreviewProfileOpen(true)}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<Share2 size={18} color="#ffa502" />}
          label="Share Profile"
          hint="Copy your profile link to share with others"
          onClick={handleShareProfile}
        />
      </SettingsSection>

      {/* 2. Privacy & Safety */}
      <SettingsSection label="How others find and contact you">
        <SettingsNavRow
          icon={<Shield size={18} color="#ff2d55" />}
          label="Privacy and Safety"
          hint="Profile visibility, masked contacts & safety tools"
          onClick={() => navigate('settings/privacy')}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<Activity size={18} color="#00e676" />}
          label="Activity Status"
          hint="Control whether others can see when you are active"
          onClick={() => navigate('settings/activity-status')}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<MessageSquare size={18} color="#00e5ff" />}
          label="Who Can Message Me"
          hint="Filter message requests, connections and audience"
          onClick={() => navigate('settings/messaging')}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<UserX size={18} color="#ff4757" />}
          label="Blocked & Restricted Accounts"
          hint="Review and manage blocked or restricted members"
          onClick={() => navigate('settings/privacy/blocked')}
        />
      </SettingsSection>

      {/* 3. Account & Security */}
      <SettingsSection label="Account and security">
        <SettingsNavRow
          icon={<UserCog size={18} color="#00e5ff" />}
          label="Account Management"
          hint="Change mobile number, email, deactivate or delete account"
          onClick={() => navigate('settings/security/account-management')}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<Lock size={18} color="#00e676" />}
          label="Security & Login"
          hint="Password, active sessions and trusted devices"
          onClick={() => navigate('settings/security')}
        />
      </SettingsSection>

      {/* 4. App Preferences */}
      <SettingsSection label="App preferences">
        <SettingsNavRow
          icon={<Bell size={18} color="#ffa502" />}
          label="Notifications"
          hint="Push alerts, matches, messages and call sounds"
          onClick={() => navigate('settings/notifications')}
        />
        <div className="settings-row-divider" role="separator" />
        <SettingsNavRow
          icon={<Palette size={18} color="#9b51e0" />}
          label="Themes and Languages"
          hint="Switch between Dark and Light mode and select language"
          onClick={() => navigate('settings/theme-language')}
        />
      </SettingsSection>

      {/* 5. Guidance & Policies */}
      <SettingsSection label="Guidance and policies">
        <SettingsNavRow
          icon={<LifeBuoy size={18} color="#00e5ff" />}
          label="Help, Policies & Support"
          hint="Help center, support requests, guidelines and terms"
          onClick={() => navigate('settings/help')}
        />
      </SettingsSection>

      {/* 6. Sign Out */}
      <SettingsSection>
        <SettingsNavRow
          icon={<LogOut size={18} color="#ff4757" />}
          label="Log Out"
          hint="End the session on this device"
          danger
          showChevron={false}
          onClick={() => setIsLogoutConfirmOpen(true)}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

export default SettingsActivityPage;
