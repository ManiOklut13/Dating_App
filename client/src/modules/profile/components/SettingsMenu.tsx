import React, { useEffect, useRef } from 'react';
import {
  X,
  Shield,
  UserCog,
  Bell,
  Lock,
  LifeBuoy,
  FileText,
  Palette,
  ChevronRight,
  UserX,
  UserMinus,
  Mail,
  Phone,
  PauseCircle,
  Trash2,
  LogOut,
  Sun,
  Moon,
  Languages,
  MessageSquare,
  AlertTriangle,
  BookOpen,
  FileCheck,
  Eye,
} from 'lucide-react';
import { useProfile, SettingsInfoModalKey } from '../ProfileContext';
import { PrivacySettings } from '../types';
import { LANGUAGES } from '../mockProfile';

/* ==========================================================================
   Reusable building blocks for the global 3-Dot settings menu
   ========================================================================== */

const SectionTitle: React.FC<{ icon: React.ReactNode; color: string; children: React.ReactNode }> = ({
  icon,
  color,
  children,
}) => (
  <div className="settings-section-title">
    <span className="settings-section-icon" style={{ color, background: `${color}1f` }}>
      {icon}
    </span>
    <span>{children}</span>
  </div>
);

const Field: React.FC<{ label: string; hint?: string; children: React.ReactNode }> = ({
  label,
  hint,
  children,
}) => (
  <div className="settings-field">
    <div className="settings-field-label">{label}</div>
    {children}
    {hint && <div className="settings-field-hint">{hint}</div>}
  </div>
);

interface SegOption<T extends string> {
  value: T;
  label: string;
  icon?: React.ReactNode;
}

function Segmented<T extends string>({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: T;
  options: SegOption<T>[];
  onChange: (value: T) => void;
}) {
  return (
    <div className="segmented" role="radiogroup" aria-label={label}>
      {options.map((opt) => (
        <button
          key={opt.value}
          type="button"
          role="radio"
          aria-checked={value === opt.value}
          className={`segmented-item${value === opt.value ? ' active' : ''}`}
          onClick={() => onChange(opt.value)}
        >
          {opt.icon}
          <span>{opt.label}</span>
        </button>
      ))}
    </div>
  );
}

const Switch: React.FC<{ checked: boolean; onToggle: (value: boolean) => void; label: string }> = ({
  checked,
  onToggle,
  label,
}) => (
  <button
    type="button"
    role="switch"
    aria-checked={checked}
    aria-label={label}
    className={`switch${checked ? ' on' : ''}`}
    onClick={() => onToggle(!checked)}
  >
    <span className="switch-knob" />
  </button>
);

interface RadioOption {
  value: string;
  label: string;
  description?: string;
}

const RadioList: React.FC<{
  label: string;
  value: string;
  options: RadioOption[];
  onChange: (value: string) => void;
}> = ({ label, value, options, onChange }) => (
  <div role="radiogroup" aria-label={label} style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
    {options.map((opt) => {
      const isActive = value === opt.value;
      return (
        <button
          key={opt.value}
          type="button"
          role="radio"
          aria-checked={isActive}
          className={`radio-option${isActive ? ' active' : ''}`}
          onClick={() => onChange(opt.value)}
        >
          <span className="radio-dot" aria-hidden="true" />
          <span className="radio-text">
            <span>{opt.label}</span>
            {opt.description && <span className="radio-desc">{opt.description}</span>}
          </span>
        </button>
      );
    })}
  </div>
);

const Row: React.FC<{
  icon: React.ReactNode;
  label: string;
  hint?: string;
  onClick: () => void;
  danger?: boolean;
  trailing?: React.ReactNode;
  showChevron?: boolean;
}> = ({ icon, label, hint, onClick, danger, trailing, showChevron = true }) => (
  <button type="button" className="settings-row" onClick={onClick}>
    <span className="settings-row-icon" style={danger ? { color: '#ff4757' } : undefined} aria-hidden="true">
      {icon}
    </span>
    <span className="settings-row-text">
      <span className="settings-row-label" style={danger ? { color: '#ff4757' } : undefined}>
        {label}
      </span>
      {hint && <span className="settings-row-hint">{hint}</span>}
    </span>
    {trailing ?? (showChevron && <ChevronRight size={15} className="settings-row-chevron" aria-hidden="true" />)}
  </button>
);

const Divider: React.FC = () => <div className="settings-divider" role="separator" />;

/* ==========================================================================
   Global 3-Dot Settings Menu
   ========================================================================== */

export const SettingsMenu: React.FC = () => {
  const {
    profile,
    isSettingsOpen,
    settingsMenuAnchor,
    closeSettingsMenu,
    updatePrivacy,
    updateAccountSettings,
    showToast,

    setIsBlockedUsersModalOpen,
    setIsRestrictedUsersModalOpen,
    setIsEmailModalOpen,
    setIsPhoneModalOpen,
    setIsDeactivateModalOpen,
    setIsDeleteModalOpen,
    setIsLogoutConfirmOpen,
    setIsNotificationSettingsOpen,
    setIsSecurityOpen,
    setSettingsInfoModal,
  } = useProfile();

  const panelRef = useRef<HTMLDivElement>(null);

  // Keyboard support: focus the panel on open and close with Escape
  useEffect(() => {
    if (!isSettingsOpen) return;
    panelRef.current?.focus();
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') closeSettingsMenu();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [isSettingsOpen, closeSettingsMenu]);

  if (!isSettingsOpen) return null;

  const privacy = profile.privacy;
  const settings = profile.settings;

  // Closing the dropdown while opening a screen/modal (per spec)
  const go = (action: () => void) => {
    closeSettingsMenu();
    action();
  };

  const setInfo = (key: SettingsInfoModalKey) => go(() => setSettingsInfoModal(key));

  return (
    <>
      {/* Click-outside layer */}
      <div className="settings-dropdown-backdrop" onClick={closeSettingsMenu} aria-hidden="true" />

      <div
        ref={panelRef}
        tabIndex={-1}
        role="dialog"
        aria-label="Settings menu"
        className={`settings-dropdown anchor-${settingsMenuAnchor}`}
      >
        {/* Header */}
        <div className="settings-dropdown-header">
          <div>
            <div className="settings-dropdown-title">Settings</div>
            <div className="settings-dropdown-subtitle">Privacy, account &amp; app preferences</div>
          </div>
          <button
            type="button"
            className="settings-icon-btn"
            onClick={closeSettingsMenu}
            aria-label="Close settings menu"
          >
            <X size={17} />
          </button>
        </div>

        <div style={{ padding: '2px 4px 14px' }}>
          {/* ================= A. PRIVACY & SAFETY ================= */}
          <SectionTitle icon={<Shield size={13} />} color="#ff2d55">
            Privacy &amp; Safety
          </SectionTitle>

          <Field
            label="Profile Visibility"
            hint="Control who can find your profile in discovery and search."
          >
            <RadioList
              label="Profile visibility"
              value={privacy.visibility}
              onChange={(value) => updatePrivacy({ visibility: value as PrivacySettings['visibility'] })}
              options={[
                { value: 'everyone', label: 'Everyone', description: 'Visible to every YoUnMe member' },
                { value: 'limited', label: 'Limited Visibility', description: 'Only people you have matched with' },
                { value: 'hidden', label: 'Hidden', description: 'Incognito — hidden from all feeds' },
              ]}
            />
          </Field>

          <Field label="Activity Status">
            <div className="settings-inline">
              <div>
                <div className="settings-inline-label">
                  <Eye size={14} color={privacy.showOnlineStatus ? '#00e676' : 'var(--text-muted)'} />
                  Show Online Status
                </div>
                <div className="settings-inline-hint">
                  {privacy.showOnlineStatus
                    ? 'On — others can see when you are active in the app.'
                    : 'Hide Online Status — you appear offline to everyone.'}
                </div>
              </div>
              <Switch
                checked={privacy.showOnlineStatus}
                onToggle={(value) => updatePrivacy({ showOnlineStatus: value })}
                label="Show online status"
              />
            </div>
          </Field>

          <Field label="Who Can Message Me" hint="Filter incoming chats before they reach your inbox.">
            <Segmented
              label="Who can message me"
              value={privacy.whoCanMessageMe}
              onChange={(value) => updatePrivacy({ whoCanMessageMe: value })}
              options={[
                { value: 'everyone', label: 'Everyone' },
                { value: 'matches', label: 'Matches' },
                { value: 'nobody', label: 'Nobody' },
              ]}
            />
          </Field>

          <Row
            icon={<UserX size={16} color="#ff4757" />}
            label="View Blocked Users"
            hint={`${privacy.blockedUsers.length} blocked account${privacy.blockedUsers.length === 1 ? '' : 's'}`}
            onClick={() => go(() => setIsBlockedUsersModalOpen(true))}
          />
          <Row
            icon={<UserMinus size={16} color="#ffa502" />}
            label="View Restricted Users"
            hint={`${privacy.restrictedUsers.length} restricted account${privacy.restrictedUsers.length === 1 ? '' : 's'}`}
            onClick={() => go(() => setIsRestrictedUsersModalOpen(true))}
          />

          <div className="settings-note">
            🔒 <strong>Trust Guard:</strong> phone numbers and emails stay masked until you exchange 20 messages
            over 3 active days.
          </div>

          <Divider />

          {/* ================= B. NOTIFICATIONS ================= */}
          <SectionTitle icon={<Bell size={13} />} color="#ffa502">
            Notifications
          </SectionTitle>

          <Row
            icon={<Bell size={16} color="#ffa502" />}
            label="Notification Preferences"
            hint="Push, email and message alerts"
            onClick={() => go(() => setIsNotificationSettingsOpen(true))}
          />

          <Divider />

          {/* ================= C. SECURITY ================= */}
          <SectionTitle icon={<Lock size={13} />} color="#00e676">
            Security
          </SectionTitle>

          <Row
            icon={<Lock size={16} color="#00e676" />}
            label="Security & Login"
            hint="Password, active sessions and login security"
            onClick={() => go(() => setIsSecurityOpen(true))}
          />

          <Divider />

          {/* ================= D. HELP & SUPPORT ================= */}
          <SectionTitle icon={<LifeBuoy size={13} />} color="#00e5ff">
            Help &amp; Support
          </SectionTitle>

          <Row
            icon={<LifeBuoy size={16} color="#00e5ff" />}
            label="Help Center"
            hint="FAQs and guides"
            onClick={() => setInfo('help')}
          />
          <Row
            icon={<MessageSquare size={16} color="#00e676" />}
            label="Contact Support"
            hint="Reach the YoUnMe team"
            onClick={() => setInfo('contact')}
          />
          <Row
            icon={<AlertTriangle size={16} color="#ff4757" />}
            label="Report a Problem"
            hint="Tell us about a bug or concern"
            onClick={() => setInfo('report')}
          />

          <Divider />

          {/* ================= E. COMMUNITY & LEGAL ================= */}
          <SectionTitle icon={<FileText size={13} />} color="#ffd700">
            Community &amp; Legal
          </SectionTitle>

          <Row
            icon={<BookOpen size={16} color="#ffd700" />}
            label="Community Guidelines"
            onClick={() => setInfo('guidelines')}
          />
          <Row
            icon={<FileCheck size={16} color="#9b51e0" />}
            label="Terms of Service"
            onClick={() => setInfo('terms')}
          />
          <Row icon={<Eye size={16} color="#00e5ff" />} label="Privacy Policy" onClick={() => setInfo('privacy')} />

          <Divider />

          {/* ================= F. APP THEME ================= */}
          <SectionTitle icon={<Palette size={13} />} color="#9b51e0">
            App Theme
          </SectionTitle>

          <Field
            label="Appearance"
            hint={
              settings.appTheme === 'dark'
                ? 'Cyber Luxe dark theme is active.'
                : 'Clean light mode is active.'
            }
          >
            <Segmented<'dark' | 'light'>
              label="App theme"
              value={settings.appTheme}
              onChange={(value) => {
                if (value !== settings.appTheme) {
                  updateAccountSettings({ appTheme: value });
                  showToast(`Switched to ${value === 'dark' ? 'Dark' : 'Light'} theme`, 'info');
                }
              }}
              options={[
                { value: 'light', label: 'Light', icon: <Sun size={13} /> },
                { value: 'dark', label: 'Dark', icon: <Moon size={13} /> },
              ]}
            />
          </Field>

          <Divider />

          {/* ================= G. ACCOUNT (last section) ================= */}
          <SectionTitle icon={<UserCog size={13} />} color="#00e5ff">
            Account
          </SectionTitle>

          <Row
            icon={<Mail size={16} color="#00e5ff" />}
            label="Change Email"
            hint={settings.email}
            onClick={() => go(() => setIsEmailModalOpen(true))}
          />
          <Row
            icon={<Phone size={16} color="#00e676" />}
            label="Change Phone Number"
            hint={settings.phone}
            onClick={() => go(() => setIsPhoneModalOpen(true))}
          />

          <div className="settings-field" style={{ paddingTop: '2px' }}>
            <div className="settings-inline">
              <div>
                <div className="settings-inline-label">
                  <Languages size={15} color="#ffd700" />
                  Language
                </div>
                <div className="settings-inline-hint">App interface language</div>
              </div>
              <select
                className="settings-select"
                aria-label="App language"
                value={settings.language}
                onChange={(e) => updateAccountSettings({ language: e.target.value })}
              >
                {LANGUAGES.map((lang) => (
                  <option key={lang} value={lang}>
                    {lang}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <Row
            icon={<PauseCircle size={16} color="#ffa502" />}
            label="Deactivate Account"
            hint="Temporarily hide your profile and take a break"
            onClick={() => go(() => setIsDeactivateModalOpen(true))}
          />
          <Row
            icon={<Trash2 size={16} color="#ff4757" />}
            label="Delete Account"
            hint="Permanently erase your profile and data"
            danger
            onClick={() => go(() => setIsDeleteModalOpen(true))}
          />
          <Row
            icon={<LogOut size={16} color="#ff4757" />}
            label="Log Out"
            hint="End the session on this device"
            danger
            showChevron={false}
            onClick={() => go(() => setIsLogoutConfirmOpen(true))}
          />
        </div>
      </div>
    </>
  );
};

export default SettingsMenu;
