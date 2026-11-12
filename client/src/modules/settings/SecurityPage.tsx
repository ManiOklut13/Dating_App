import React, { useState } from 'react';
import {
  KeyRound,
  History,
  MonitorSmartphone,
  BookmarkCheck,
  BellRing,
  LogOut,
  UserCog,
  Clock,
  MapPin,
} from 'lucide-react';
import {
  SettingsPage,
  SettingsSection,
  SettingsNavRow,
  SettingsDivider,
  ToggleRow,
  EmptyState,
  ConfirmDialog,
} from './SettingsUI';
import { useSettings } from './SettingsContext';
import { useProfile } from '../profile/ProfileContext';

/* ==========================================================================
   E. Security — password form, sessions, sign-out confirmations and toggles.
   Sensitive actions go through a confirmation dialog; demo-only controls are
   tagged so they are never mistaken for production security features.
   ========================================================================== */

export const SecurityPage: React.FC = () => {
  const { navigate } = useSettings();
  const { profile, updateAccountSettings, setIsPasswordModalOpen, showToast } = useProfile();
  const security = profile.settings.security;

  const [confirmSignOutAll, setConfirmSignOutAll] = useState(false);

  const otherSessions = security.activeSessions.filter((s) => !s.isCurrent);

  const signOutEverywhereElse = () => {
    updateAccountSettings({
      security: { ...security, activeSessions: security.activeSessions.filter((s) => s.isCurrent) },
    });
    setConfirmSignOutAll(false);
    showToast('Signed out of all other sessions.', 'success');
  };

  return (
    <SettingsPage title="Security" subtitle="Protect your account and review access">
      <SettingsSection label="Sign-in">
        <SettingsNavRow
          icon={<KeyRound size={17} color="#ffd700" />}
          label="Change Password"
          hint="Update the password you sign in with"
          onClick={() => setIsPasswordModalOpen(true)}
        />
      </SettingsSection>

      <SettingsSection
        label="Account management"
        note="Update your mobile number or email, or close the account entirely."
      >
        <SettingsNavRow
          icon={<UserCog size={17} color="#00e5ff" />}
          label="Account Management"
          hint="Change mobile number, change email, delete or deactivate"
          onClick={() => navigate('settings/security/account-management')}
        />
      </SettingsSection>

      <SettingsSection
        label="Where your account is being used"
        note="Review every device signed in to your account and end anything you do not recognise."
      >
        <SettingsNavRow
          icon={<History size={17} color="#00e5ff" />}
          label="Login Activity"
          hint="Recent sign-ins with time and location"
          onClick={() => navigate('settings/security/login-activity')}
        />
        <SettingsDivider />
        <SettingsNavRow
          icon={<MonitorSmartphone size={17} color="#00e676" />}
          label="Where You’re Logged In"
          hint={`${security.activeSessions.length} active session${security.activeSessions.length === 1 ? '' : 's'}`}
          onClick={() => navigate('settings/security/devices')}
        />
        {otherSessions.length > 0 && (
          <>
            <SettingsDivider />
            <SettingsNavRow
              icon={<LogOut size={17} color="#ff4757" />}
              label="Sign Out of All Other Sessions"
              hint={`Ends ${otherSessions.length} session${otherSessions.length === 1 ? '' : 's'} on other devices`}
              danger
              onClick={() => setConfirmSignOutAll(true)}
            />
          </>
        )}
      </SettingsSection>

      <SettingsSection label="Login protection">
        <ToggleRow
          icon={<BookmarkCheck size={15} color="#00e5ff" />}
          label="Saved Login Information"
          description="Remember this device so you skip password entry next time"
          checked={security.savedLoginInfo}
          onChange={(value) =>
            updateAccountSettings({ security: { ...security, savedLoginInfo: value } })
          }
        />
        <SettingsDivider />
        <ToggleRow
          icon={<BellRing size={15} color="#ffa502" />}
          label="Security Alerts"
          description="Get notified when your account is used on an unrecognised device"
          checked={security.securityAlerts}
          onChange={(value) =>
            updateAccountSettings({ security: { ...security, securityAlerts: value } })
          }
        />
      </SettingsSection>

      {/* Sign out everywhere confirmation */}
      <ConfirmDialog
        open={confirmSignOutAll}
        icon={<LogOut size={26} color="#ff4757" />}
        title="Sign out everywhere else?"
        message={`This will end ${otherSessions.length} session${
          otherSessions.length === 1 ? '' : 's'
        } on other devices. You will stay signed in on this device.`}
        confirmLabel="Sign out"
        danger
        onConfirm={signOutEverywhereElse}
        onCancel={() => setConfirmSignOutAll(false)}
      />
    </SettingsPage>
  );
};

/* ==========================================================================
   Login Activity — recent sign-in history with a clearable list (empty state)
   ========================================================================== */

interface LoginEvent {
  id: string;
  device: string;
  location: string;
  time: string;
  method: string;
  current: boolean;
}

const INITIAL_LOGINS: LoginEvent[] = [
  {
    id: 'log-1',
    device: 'iPhone 15 Pro · YoUnMe iOS App',
    location: 'Hyderabad, India',
    time: 'Today, 09:14',
    method: 'Password',
    current: true,
  },
  {
    id: 'log-2',
    device: 'MacBook Pro 16" · Chrome 129',
    location: 'Hyderabad, India',
    time: 'Yesterday, 21:48',
    method: 'Saved login',
    current: false,
  },
  {
    id: 'log-3',
    device: 'Pixel 8 · YoUnMe Android App',
    location: 'Bengaluru, India',
    time: '05 Oct, 18:02',
    method: 'Password',
    current: false,
  },
];

export const LoginActivityPage: React.FC = () => {
  const { showToast } = useProfile();
  const [logins, setLogins] = useState<LoginEvent[]>(INITIAL_LOGINS);
  const [confirmClear, setConfirmClear] = useState(false);

  return (
    <SettingsPage title="Login Activity" subtitle="Every recent sign-in to your account">
      <SettingsSection
        label="Recent sign-ins"
        note="If you see a sign-in you do not recognise, change your password right away."
      >
        {logins.length === 0 ? (
          <EmptyState
            icon={<Clock size={26} />}
            title="No login activity"
            description="Sign-ins to your account will be listed here with the device, location and time."
            action={
              <button type="button" className="btn-ghost" onClick={() => setLogins(INITIAL_LOGINS)}>
                Reload activity
              </button>
            }
          />
        ) : (
          logins.map((login, index) => (
            <React.Fragment key={login.id}>
              {index > 0 && <SettingsDivider />}
              <div className="settings-login-row">
                <div className="settings-login-icon" aria-hidden="true">
                  <Clock size={16} />
                </div>
                <div className="settings-row-text">
                  <span className="settings-row-label">
                    {login.device}{' '}
                    {login.current && <span className="settings-current-tag">This device</span>}
                  </span>
                  <span className="settings-row-hint">
                    <MapPin size={11} style={{ verticalAlign: '-1px', marginRight: 3 }} />
                    {login.location} · {login.time} · {login.method}
                  </span>
                </div>
              </div>
            </React.Fragment>
          ))
        )}
      </SettingsSection>

      {logins.length > 0 && (
        <SettingsSection label="Manage">
          <SettingsNavRow
            icon={<LogOut size={17} color="#ff4757" />}
            label="Clear login history"
            hint="Remove this history from the current device"
            danger
            showChevron={false}
            onClick={() => setConfirmClear(true)}
          />
        </SettingsSection>
      )}

      <ConfirmDialog
        open={confirmClear}
        title="Clear login history?"
        message="This removes the sign-in history shown here. It does not sign you out of any device."
        confirmLabel="Clear"
        danger
        onConfirm={() => {
          setLogins([]);
          setConfirmClear(false);
          showToast('Login history cleared.', 'info');
        }}
        onCancel={() => setConfirmClear(false)}
      />
    </SettingsPage>
  );
};

/* ==========================================================================
   Where You're Logged In — active sessions with per-session sign out
   ========================================================================== */

export const DevicesPage: React.FC = () => {
  const { profile, updateAccountSettings, showToast } = useProfile();
  const security = profile.settings.security;
  const sessions = security.activeSessions;
  const [pendingSignOut, setPendingSignOut] = useState<{ id: string; device: string } | null>(null);

  const signOut = (id: string) => {
    updateAccountSettings({
      security: { ...security, activeSessions: sessions.filter((s) => s.id !== id) },
    });
    showToast('Session signed out.', 'success');
    setPendingSignOut(null);
  };

  return (
    <SettingsPage title="Where You’re Logged In" subtitle="Active sessions on your account">
      <SettingsSection
        label="Active sessions"
        note="Sign out of anything you do not recognise. The device you are using now cannot be signed out from here."
      >
        {sessions.length === 0 ? (
          <EmptyState
            icon={<MonitorSmartphone size={26} />}
            title="No active sessions"
            description="Devices signed in to your account will appear here so you can review or end them."
          />
        ) : (
          sessions.map((session, index) => (
            <React.Fragment key={session.id}>
              {index > 0 && <SettingsDivider />}
              <div className="settings-user-row">
                <div className="settings-login-icon" aria-hidden="true">
                  <MonitorSmartphone size={16} />
                </div>
                <div className="settings-row-text">
                  <span className="settings-row-label">
                    {session.device}{' '}
                    {session.isCurrent && <span className="settings-current-tag">This device</span>}
                  </span>
                  <span className="settings-row-hint">
                    {session.location} ·{' '}
                    <span style={{ color: session.isCurrent ? '#00e676' : undefined }}>
                      {session.lastActive}
                    </span>
                  </span>
                </div>
                {!session.isCurrent && (
                  <button
                    type="button"
                    className="btn-ghost settings-user-action"
                    onClick={() => setPendingSignOut({ id: session.id, device: session.device })}
                  >
                    Sign out
                  </button>
                )}
              </div>
            </React.Fragment>
          ))
        )}
      </SettingsSection>

      <ConfirmDialog
        open={pendingSignOut !== null}
        icon={<LogOut size={26} color="#ff4757" />}
        title="Sign out this device?"
        message={
          pendingSignOut
            ? `"${pendingSignOut.device}" will need the password again to sign in.`
            : ''
        }
        confirmLabel="Sign out"
        danger
        onConfirm={() => pendingSignOut && signOut(pendingSignOut.id)}
        onCancel={() => setPendingSignOut(null)}
      />
    </SettingsPage>
  );
};
