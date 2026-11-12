import React from 'react';
import { Activity } from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  ToggleRow,
} from './SettingsUI';
import { useProfile } from '../profile/ProfileContext';

/* ==========================================================================
   B. Activity Status — immediate-apply toggles with plain-English explanations
   ========================================================================== */

export const ActivityStatusPage: React.FC = () => {
  const { profile, updatePrivacy } = useProfile();
  const privacy = profile.privacy;

  return (
    <SettingsPage title="Activity Status" subtitle="Choose when your activity is visible">
      <SettingsSection
        label="Your activity"
        note="Changes here apply the moment you flip the switch — there is nothing to save."
      >
        <ToggleRow
          icon={<Activity size={15} color="#00e676" />}
          label="Show Activity Status"
          description={
            privacy.showOnlineStatus
              ? 'People you follow and match with can see when you are active in the app.'
              : 'You will appear offline to everyone. You can still see other people’s activity status.'
          }
          checked={privacy.showOnlineStatus}
          onChange={(value) => updatePrivacy({ showOnlineStatus: value })}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

export default ActivityStatusPage;
