import React, { useState } from 'react';
import {
  Lock,
  UserX,
  UserMinus,
  Filter,
  Globe,
  Eye,
  Flag,
  Plus,
  X,
  ShieldOff,
  ShieldCheck,
} from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  SettingsNavRow,
  SettingsDivider,
  ToggleRow,
  RadioGroup,
  EmptyState,
} from './SettingsUI';
import { useSettings } from './SettingsContext';
import { useProfile } from '../profile/ProfileContext';
import { PrivacySettings } from '../profile/types';

/* ==========================================================================
   A. Privacy and Safety — main page
   ========================================================================== */

export const PrivacySafetyPage: React.FC = () => {
  const { navigate } = useSettings();
  const { profile, updatePrivacy, setSettingsInfoModal } = useProfile();
  const privacy = profile.privacy;
  const blockedCount = privacy.blockedUsers.length;
  const restrictedCount = privacy.restrictedUsers.length;

  return (
    <SettingsPage title="Privacy and safety" subtitle="Control who sees and reaches you">
      {/* Private account */}
      <SettingsSection
        label="Account privacy"
        note="A private account keeps your photos and posts visible only to people who follow you, once you approve them."
      >
        <ToggleRow
          icon={
            privacy.privateAccount ? (
              <Lock size={15} color="#ff2d55" />
            ) : (
              <Globe size={15} color="#00e676" />
            )
          }
          label="Private Account"
          description={
            privacy.privateAccount
              ? 'Your account is private — only approved followers can see your posts.'
              : 'Your account is public — anyone on YoUnMe can see your posts.'
          }
          checked={privacy.privateAccount}
          onChange={(value) => updatePrivacy({ privateAccount: value })}
        />
        <SettingsDivider />
        <RadioGroup
          label="Profile visibility"
          value={privacy.visibility}
          onChange={(value) => updatePrivacy({ visibility: value as PrivacySettings['visibility'] })}
          options={[
            { value: 'everyone', label: 'Everyone', description: 'Visible in discovery and search to all members' },
            { value: 'limited', label: 'Limited', description: 'Only people you have matched with can view your profile' },
            { value: 'hidden', label: 'Hidden', description: 'Incognito — your profile is hidden from all feeds' },
          ]}
        />
      </SettingsSection>

      {/* Who can find you */}
      <SettingsSection label="Connections you control">
        <SettingsNavRow
          icon={<UserX size={17} color="#ff4757" />}
          label="Blocked Accounts"
          hint={blockedCount === 0 ? 'No blocked accounts' : `${blockedCount} blocked account${blockedCount === 1 ? '' : 's'}`}
          onClick={() => navigate('settings/privacy/blocked')}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<UserMinus size={17} color="#ffa502" />}
          label="Restricted Accounts"
          hint={restrictedCount === 0 ? 'No restricted accounts' : `${restrictedCount} restricted account${restrictedCount === 1 ? '' : 's'}`}
          onClick={() => navigate('settings/privacy/restricted')}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<Filter size={17} color="#9b51e0" />}
          label="Hidden Words"
          hint={
            privacy.hiddenWords.words.length === 0
              ? 'No hidden words yet'
              : `${privacy.hiddenWords.words.length} custom word${privacy.hiddenWords.words.length === 1 ? '' : 's'}`
          }
          onClick={() => navigate('settings/privacy/hidden-words')}
        />
      </SettingsSection>

      {/* Visibility of profile details + messaging receipts */}
      <SettingsSection
        label="Messaging visibility"
        note="Read receipts let people who message you see when you have read their messages. Turning this off also hides other people's receipts from you."
      >
        <ToggleRow
          icon={<Eye size={15} color="#00e5ff" />}
          label="Read Receipts"
          description="Show others when you have read their messages"
          checked={privacy.readReceipts}
          onChange={(value) => updatePrivacy({ readReceipts: value })}
        />
      </SettingsSection>

      <SettingsSection label="Something looks wrong">
        <SettingsNavRow
          icon={<Flag size={17} color="#ff4757" />}
          label="Report a Problem"
          hint="Tell us about spam, bugs or anything that feels off"
          onClick={() => setSettingsInfoModal('report')}
        />
      </SettingsSection>
    </SettingsPage>
  );
};

/* ==========================================================================
   Blocked Accounts — list + empty state
   ========================================================================== */

export const BlockedAccountsPage: React.FC = () => {
  const { profile, unblockUser, showToast } = useProfile();
  const blocked = profile.privacy.blockedUsers;

  return (
    <SettingsPage title="Blocked Accounts" subtitle={`${blocked.length} account${blocked.length === 1 ? '' : 's'} blocked`}>
      <SettingsSection
        label="Blocked accounts"
        note="Blocked accounts cannot find your profile, message you, or see your comments. Unblocking restores full visibility both ways."
      >
        {blocked.length === 0 ? (
          <EmptyState
            icon={<ShieldOff size={26} />}
            title="No blocked accounts"
            description="Accounts you block will appear here. You can unblock them at any time."
          />
        ) : (
          blocked.map((user, index) => (
            <React.Fragment key={user.id}>
              {index > 0 && <div className="settings-row-divider" role="separator" />}
              <div className="settings-user-row">
                <img src={user.avatar} alt="" className="settings-user-avatar" />
                <div className="settings-row-text">
                  <span className="settings-row-label">{user.name}</span>
                  <span className="settings-row-hint">Blocked on {user.blockedAt}</span>
                </div>
                <button
                  type="button"
                  className="btn-ghost settings-user-action"
                  onClick={() => {
                    unblockUser(user.id);
                    showToast(`${user.name} has been unblocked.`, 'success');
                  }}
                >
                  Unblock
                </button>
              </div>
            </React.Fragment>
          ))
        )}
      </SettingsSection>
    </SettingsPage>
  );
};

/* ==========================================================================
   Restricted Accounts — list + empty state
   ========================================================================== */

export const RestrictedAccountsPage: React.FC = () => {
  const { profile, unrestrictUser, showToast } = useProfile();
  const restricted = profile.privacy.restrictedUsers;

  return (
    <SettingsPage title="Restricted Accounts" subtitle={`${restricted.length} account${restricted.length === 1 ? '' : 's'} restricted`}>
      <SettingsSection
        label="Restricted accounts"
        note="Restricted accounts can still send you messages, but those messages go to requests. They cannot see when you are active or that you have read their messages."
      >
        {restricted.length === 0 ? (
          <EmptyState
            icon={<ShieldCheck size={26} />}
            title="No restricted accounts"
            description="Accounts you restrict will appear here. Their messages will land in requests instead of your main chat."
          />
        ) : (
          restricted.map((user, index) => (
            <React.Fragment key={user.id}>
              {index > 0 && <div className="settings-row-divider" role="separator" />}
              <div className="settings-user-row">
                <img src={user.avatar} alt="" className="settings-user-avatar" />
                <div className="settings-row-text">
                  <span className="settings-row-label">{user.name}</span>
                  <span className="settings-row-hint">Restricted on {user.restrictedAt}</span>
                </div>
                <button
                  type="button"
                  className="btn-ghost settings-user-action"
                  onClick={() => {
                    unrestrictUser(user.id);
                    showToast(`Restriction on ${user.name} removed.`, 'success');
                  }}
                >
                  Unrestrict
                </button>
              </div>
            </React.Fragment>
          ))
        )}
      </SettingsSection>
    </SettingsPage>
  );
};

/* ==========================================================================
   Hidden Words — toggles + custom word management with validation
   ========================================================================== */

export const HiddenWordsPage: React.FC = () => {
  const { profile, updatePrivacy, showToast } = useProfile();
  const { hiddenWords } = profile.privacy;
  const [draft, setDraft] = useState('');

  const setPartial = (partial: Partial<typeof hiddenWords>) =>
    updatePrivacy({ hiddenWords: { ...hiddenWords, ...partial } });

  const addWord = (event: React.FormEvent) => {
    event.preventDefault();
    const word = draft.trim().replace(/\s+/g, ' ');
    if (!word) {
      showToast('Type a word or phrase first.', 'error');
      return;
    }
    if (word.length > 40) {
      showToast('Words must be 40 characters or fewer.', 'error');
      return;
    }
    if (hiddenWords.words.some((w) => w.toLowerCase() === word.toLowerCase())) {
      showToast('That word is already on your list.', 'error');
      return;
    }
    setPartial({ words: [...hiddenWords.words, word] });
    showToast(`"${word}" will now be hidden.`, 'success');
    setDraft('');
  };

  const removeWord = (word: string) => {
    setPartial({ words: hiddenWords.words.filter((w) => w !== word) });
    showToast(`"${word}" removed from your hidden words.`, 'info');
  };

  return (
    <SettingsPage title="Hidden Words" subtitle="Filter unwanted comments and messages">
      <SettingsSection
        label="Automatic filtering"
        note="Filtered words are hidden from your comments, captions and message requests. People will not be told their word was filtered."
      >
        <ToggleRow
          label="Hide offensive words in comments"
          description="Comments with offensive words on your posts are hidden by default"
          checked={hiddenWords.filterOffensive}
          onChange={(value) => setPartial({ filterOffensive: value })}
        />
        <SettingsDivider />
        <ToggleRow
          label="Filter words in message requests"
          description="Requests containing these words are sorted into a filtered folder"
          checked={hiddenWords.filterMessages}
          onChange={(value) => setPartial({ filterMessages: value })}
        />
      </SettingsSection>

      <SettingsSection
        label="Custom words and phrases"
        note="Add words, names or phrases you never want to see. They are stored only on this device."
      >
        <form className="settings-hidden-form" onSubmit={addWord}>
          <input
            type="text"
            className="settings-text-input"
            placeholder="Add a word or phrase…"
            value={draft}
            maxLength={40}
            aria-label="Word or phrase to hide"
            onChange={(event) => setDraft(event.target.value)}
          />
          <button type="submit" className="btn-primary settings-hidden-add" aria-label="Add word">
            <Plus size={16} />
            Add
          </button>
        </form>

        {hiddenWords.words.length === 0 ? (
          <EmptyState
            icon={<Filter size={26} />}
            title="No hidden words yet"
            description="Add a word or phrase above and it will be hidden from your comments and requests."
          />
        ) : (
          <div className="settings-chip-list">
            {hiddenWords.words.map((word) => (
              <span key={word} className="settings-chip">
                {word}
                <button
                  type="button"
                  className="settings-chip-x"
                  aria-label={`Remove ${word}`}
                  onClick={() => removeWord(word)}
                >
                  <X size={12} />
                </button>
              </span>
            ))}
          </div>
        )}
      </SettingsSection>
    </SettingsPage>
  );
};
