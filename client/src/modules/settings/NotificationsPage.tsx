import React from 'react';
import {
  PauseCircle,
  Heart,
  MessageSquare,
  Mail,
  Phone,
  AtSign,
  Radio,
  Smartphone,
  Sparkles,
} from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  ToggleRow,
  SettingsDivider,
} from './SettingsUI';
import { useProfile } from '../profile/ProfileContext';
import { NotificationPrefs } from '../profile/types';

/* ==========================================================================
   D. Notifications — pause-all master switch + per-category toggles.
   Every change is applied immediately and persisted through ProfileContext.
   ========================================================================== */

export const NotificationsPage: React.FC = () => {
  const { profile, updateAccountSettings, showToast } = useProfile();
  const prefs = profile.settings.notifications;

  const setPref = (key: keyof NotificationPrefs, value: boolean) => {
    updateAccountSettings({ notifications: { ...prefs, [key]: value } });
  };

  const togglePauseAll = (value: boolean) => {
    updateAccountSettings({ notifications: { ...prefs, pauseAll: value } });
    showToast(
      value ? 'All notifications paused.' : 'Notifications resumed.',
      value ? 'info' : 'success',
    );
  };

  const categories: Array<{
    key: keyof Omit<NotificationPrefs, 'pauseAll'>;
    icon: React.ReactNode;
    label: string;
    description: string;
  }> = [
      {
        key: 'likes',
        icon: <Heart size={15} color="#ff2d55" />,
        label: 'Likes and Reactions',
        description: 'When someone likes or reacts to your posts',
      },
      {
        key: 'comments',
        icon: <MessageSquare size={15} color="#00e5ff" />,
        label: 'Comments',
        description: 'Replies and reactions to your comments',
      },
      {
        key: 'matches',
        icon: <Heart size={15} color="#00e676" />,
        label: 'New Matches',
        description: 'When you match with someone new',
      },
      {
        key: 'messages',
        icon: <Mail size={15} color="#9b51e0" />,
        label: 'Messages and Message Requests',
        description: 'New direct messages and incoming requests',
      },
      {
        key: 'calls',
        icon: <Phone size={15} color="#ffa502" />,
        label: 'Calls',
        description: 'Incoming audio and video calls',
      },
      {
        key: 'mentions',
        icon: <AtSign size={15} color="#00e5ff" />,
        label: 'Mentions and Tags',
        description: 'When someone mentions or tags you',
      },
      {
        key: 'live',
        icon: <Radio size={15} color="#ff2d55" />,
        label: 'Live and Other Notifications',
        description: 'Live rooms, reminders and product news',
      },
      {
        key: 'email',
        icon: <Mail size={15} color="#9b51e0" />,
        label: 'Email Notifications',
        description: 'Summaries and account activity by email',
      },
      {
        key: 'sms',
        icon: <Smartphone size={15} color="#00e676" />,
        label: 'SMS Notifications',
        description: 'Important alerts by text message',
      },
      {
        key: 'promotions',
        icon: <Sparkles size={15} color="#ffd700" />,
        label: 'Promotions and Rewards',
        description: 'Coin offers, streaks and spin-wheel drops',
      },
    ];

  return (
    <SettingsPage title="Notifications" subtitle="Choose what reaches you and when">
      <SettingsSection
        label="Pause"
        note="While paused, nothing buzzes — your individual choices below are kept and resume as soon as you unpause."
      >
        <ToggleRow
          icon={<PauseCircle size={15} color="#ffa502" />}
          label="Mute All Notifications"
          description={prefs.pauseAll ? 'Paused — no notifications are being delivered.' : 'Everything is currently active.'}
          checked={prefs.pauseAll}
          onChange={togglePauseAll}
        />
      </SettingsSection>

      <SettingsSection
        label="What you get notified about"
        note={
          prefs.pauseAll
            ? 'These choices are saved, but nothing is delivered while “Pause All” is on.'
            : 'Each switch applies instantly.'
        }
      >
        {categories.map((category, index) => (
          <React.Fragment key={category.key}>
            {index > 0 && <SettingsDivider />}
            <ToggleRow
              icon={category.icon}
              label={category.label}
              description={category.description}
              checked={prefs[category.key] && !prefs.pauseAll}
              disabled={prefs.pauseAll}
              onChange={(value) => setPref(category.key, value)}
            />
          </React.Fragment>
        ))}
      </SettingsSection>
    </SettingsPage>
  );
};

export default NotificationsPage;
