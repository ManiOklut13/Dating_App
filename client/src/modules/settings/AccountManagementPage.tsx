import React from 'react';
import { Phone, Mail, Trash2, PauseCircle } from 'lucide-react';
import { SettingsPage, SettingsSection, SettingsNavRow, SettingsDivider } from './SettingsUI';
import { useProfile } from '../profile/ProfileContext';

/* ==========================================================================
   Account Management — a single place for the account-level actions that
   used to live only inside the 3-dot menu: change phone, change email,
   delete account and deactivate account, in that order.

   The rows reuse the existing account modals (rendered globally by
   <AccountModals /> in App.tsx), so the flows and validation stay identical.
   ========================================================================== */

export const AccountManagementPage: React.FC = () => {
  const {
    profile,
    setIsPhoneModalOpen,
    setIsEmailModalOpen,
    setIsDeleteModalOpen,
    setIsDeactivateModalOpen,
  } = useProfile();

  const { email, phone } = profile.settings;

  return (
    <SettingsPage title="Account Management" subtitle="Your contact details and account status">
      <SettingsSection
        label="Contact details"
        note="We only ever use these to secure your account and send important notices."
      >
        <SettingsNavRow
          icon={<Phone size={17} color="#00e676" />}
          label="Change Mobile Number"
          hint={phone}
          onClick={() => setIsPhoneModalOpen(true)}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<Mail size={17} color="#00e5ff" />}
          label="Change Email"
          hint={email}
          onClick={() => setIsEmailModalOpen(true)}
        />
      </SettingsSection>

      <SettingsSection
        label="Account status"
        note="Neither action can be undone from this screen — read the confirmation carefully."
      >
        <SettingsNavRow
          icon={<Trash2 size={17} color="#ff4757" />}
          label="Delete Account"
          hint="Permanently erase your profile and data"
          danger
          onClick={() => setIsDeleteModalOpen(true)}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<PauseCircle size={17} color="#ffa502" />}
          label="Deactivate Account"
          hint="Temporarily hide your profile and take a break"
          onClick={() => setIsDeactivateModalOpen(true)}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

export default AccountManagementPage;
