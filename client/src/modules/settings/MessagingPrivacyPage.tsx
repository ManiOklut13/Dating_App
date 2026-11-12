import React from 'react';
import { UserX, Inbox } from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  SettingsNavRow,
  SettingsDivider,
  RadioGroup,
} from './SettingsUI';
import { useSettings } from './SettingsContext';
import { useProfile } from '../profile/ProfileContext';
import { PrivacySettings } from '../profile/types';

/* ==========================================================================
   C. Who Can Message Me — messaging privacy with radios + dropdown
   ========================================================================== */

export const MessagingPrivacyPage: React.FC = () => {
  const { navigate } = useSettings();
  const { profile, updatePrivacy } = useProfile();
  const privacy = profile.privacy;
  const blockedCount = privacy.blockedUsers.length;

  const setPartial = (partial: Partial<PrivacySettings>) => updatePrivacy(partial);

  return (
    <SettingsPage title="Messages and requests" subtitle="Decide who can reach your inbox">
      <SettingsSection
        label="Who can message you"
        note="People outside this audience can still send you a message request — it will land in the requests folder instead of your main chat."
      >
        <RadioGroup
          label="Who can message you"
          value={privacy.whoCanMessageMe}
          onChange={(value) => setPartial({ whoCanMessageMe: value as PrivacySettings['whoCanMessageMe'] })}
          options={[
            {
              value: 'everyone',
              label: 'Everyone',
              description: 'Allow messages from all eligible members on YoUnMe',
            },
            {
              value: 'matches',
              label: 'Matches',
              description: 'Only people you have matched with can start a chat',
            },
            {
              value: 'nobody',
              label: 'Nobody',
              description: 'No one can start a new chat with you',
            },
          ]}
        />
      </SettingsSection>

      <SettingsSection
        label="Message requests"
        note="Requests never show a read receipt or your activity status until you accept them."
      >
        <RadioGroup
          label="How message requests are handled"
          value={privacy.messageRequests}
          onChange={(value) => setPartial({ messageRequests: value as PrivacySettings['messageRequests'] })}
          options={[
            { value: 'deliver', label: 'Deliver all requests', description: 'Every request lands in your main message list' },
            { value: 'filter', label: 'Filter requests', description: 'Requests from people outside your audience go to a filtered folder' },
            { value: 'nobody', label: 'Nobody', description: 'Message requests are turned off — nobody outside your audience can reach you' },
          ]}
        />
      </SettingsSection>

      <SettingsSection
        label="Group message permissions"
        note="Controls who can pull you into a group conversation. Existing groups are not affected."
      >
        <RadioGroup
          label="Who can add you to groups"
          value={privacy.groupMessages}
          onChange={(value) => setPartial({ groupMessages: value as PrivacySettings['groupMessages'] })}
          options={[
            { value: 'everyone', label: 'Everyone', description: 'Anyone can add you to a group chat' },
            { value: 'following', label: 'People You Follow', description: 'Only accounts you follow can add you' },
            { value: 'followers', label: 'Matches', description: 'Only accounts that follow you can add you' },
            { value: 'nobody', label: 'No One', description: 'You can only be added after you approve a request' },
          ]}
        />
      </SettingsSection>

      <SettingsSection label="Blocked">
        <SettingsNavRow
          icon={<UserX size={17} color="#ff4757" />}
          label="Blocked Users"
          hint={blockedCount === 0 ? 'No blocked accounts' : `${blockedCount} blocked account${blockedCount === 1 ? '' : 's'}`}
          onClick={() => navigate('settings/privacy/blocked')}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<Inbox size={17} color="#9b51e0" />}
          label="Restricted Accounts"
          hint="Send quiet accounts to requests instead"
          onClick={() => navigate('settings/privacy/restricted')}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

export default MessagingPrivacyPage;
