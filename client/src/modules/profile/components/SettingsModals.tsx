import React, { useState } from 'react';
import {
  X,
  Bell,
  Smartphone,
  Mail,
  MessageSquare,
  Heart,
  Sparkles,
  Lock,
  KeyRound,
  AlertTriangle,
  LifeBuoy,
  BookOpen,
  FileCheck,
  Eye,
  Send,
} from 'lucide-react';
import { useProfile, SettingsInfoModalKey } from '../ProfileContext';
import {
  modalBackdropStyle,
  modalBoxStyle,
  modalHeaderStyle,
  inputStyle,
  iconBtnStyle,
} from './AccountModals';

/* ==========================================================================
   Shared modal shell — reuses the styling of the existing account modals
   ========================================================================== */

const ModalShell: React.FC<{
  icon: React.ReactNode;
  title: string;
  onClose: () => void;
  children: React.ReactNode;
  maxWidth?: number;
}> = ({ icon, title, onClose, children, maxWidth = 480 }) => (
  <div style={modalBackdropStyle} onClick={onClose}>
    <div
      className="glass-panel"
      role="dialog"
      aria-modal="true"
      aria-label={title}
      style={{ ...modalBoxStyle, maxWidth, maxHeight: '85vh' }}
      onClick={(e) => e.stopPropagation()}
    >
      <div style={modalHeaderStyle}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {icon}
          <h3 style={{ fontSize: '17px', fontWeight: 800 }}>{title}</h3>
        </div>
        <button type="button" onClick={onClose} style={iconBtnStyle} aria-label={`Close ${title}`}>
          <X size={18} />
        </button>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 20px' }}>{children}</div>
    </div>
  </div>
);

/* ==========================================================================
   C. Notifications — preference screen
   ========================================================================== */

const NotificationSettingsModal: React.FC<{ onClose: () => void }> = ({ onClose }) => {
  const { profile, updateAccountSettings } = useProfile();
  const notifications = profile.settings.notifications;

  const setPreference = (partial: Partial<typeof notifications>) =>
    updateAccountSettings({ notifications: { ...notifications, ...partial } });

  const items: Array<{
    key: keyof typeof notifications;
    icon: React.ReactNode;
    label: string;
    hint: string;
  }> = [
    { key: 'push', icon: <Smartphone size={16} color="#00e5ff" />, label: 'Push Notifications', hint: 'Real-time alerts on this device' },
    { key: 'email', icon: <Mail size={16} color="#9b51e0" />, label: 'Email Notifications', hint: 'Summaries and important account activity' },
    { key: 'messages', icon: <MessageSquare size={16} color="#00e676" />, label: 'Message Notifications', hint: 'New direct messages from your matches' },
    { key: 'matches', icon: <Heart size={16} color="#ff2d55" />, label: 'Match Alerts', hint: 'When someone you liked likes you back' },
    { key: 'promotions', icon: <Sparkles size={16} color="#ffa502" />, label: 'Rewards & Promotions', hint: 'Coin offers, streaks and spin wheel drops' },
  ];

  return (
    <ModalShell icon={<Bell size={18} color="#ff2d55" />} title="Notification Preferences" onClose={onClose}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {items.map((item) => (
          <div key={item.key} className="settings-inline">
            <div>
              <div className="settings-inline-label">
                {item.icon}
                {item.label}
              </div>
              <div className="settings-inline-hint">{item.hint}</div>
            </div>
            <button
              type="button"
              role="switch"
              aria-checked={notifications[item.key]}
              aria-label={item.label}
              className={`switch${notifications[item.key] ? ' on' : ''}`}
              onClick={() => setPreference({ [item.key]: !notifications[item.key] } as Partial<typeof notifications>)}
            >
              <span className="switch-knob" />
            </button>
          </div>
        ))}
      </div>
    </ModalShell>
  );
};

/* ==========================================================================
   D. Security — password, sessions, login security
   ========================================================================== */

const SecurityModal: React.FC<{ onClose: () => void }> = ({ onClose }) => {
  const { profile, updateAccountSettings, setIsPasswordModalOpen, showToast } = useProfile();
  const security = profile.settings.security;
  const [loginAlerts, setLoginAlerts] = useState(true);

  const revokeSession = (id: string) => {
    updateAccountSettings({
      security: { ...security, activeSessions: security.activeSessions.filter((s) => s.id !== id) },
    });
    showToast('Session signed out.', 'info');
  };

  return (
    <ModalShell icon={<Lock size={18} color="#00e676" />} title="Security & Login" onClose={onClose}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {/* Change password */}
        <button
          type="button"
          className="settings-row"
          style={{ border: '1px solid var(--border-glass)', background: 'var(--bg-glass)' }}
          onClick={() => {
            onClose();
            setIsPasswordModalOpen(true);
          }}
        >
          <span className="settings-row-icon">
            <KeyRound size={16} color="#ffd700" />
          </span>
          <span className="settings-row-text">
            <span className="settings-row-label">Change Password</span>
            <span className="settings-row-hint">Last updated 2 months ago</span>
          </span>
          <span style={{ fontSize: '11.5px', fontWeight: 700, color: '#ff2d55' }}>Update</span>
        </button>

        {/* Login security toggles */}
        <div className="settings-inline">
          <div>
            <div className="settings-inline-label">
              <AlertTriangle size={16} color="#ffa502" />
              Login Alerts
            </div>
            <div className="settings-inline-hint">Notify me when my account is used on a new device</div>
          </div>
          <button
            type="button"
            role="switch"
            aria-checked={loginAlerts}
            aria-label="Login alerts"
            className={`switch${loginAlerts ? ' on' : ''}`}
            onClick={() => setLoginAlerts((v) => !v)}
          >
            <span className="switch-knob" />
          </button>
        </div>

        {/* Active sessions */}
        <div>
          <div className="settings-field-label" style={{ margin: '4px 0 8px' }}>
            Active Sessions
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {security.activeSessions.length === 0 ? (
              <div style={{ fontSize: '12px', color: 'var(--text-muted)', padding: '8px 0' }}>
                No other active sessions.
              </div>
            ) : (
              security.activeSessions.map((session) => (
                <div
                  key={session.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    gap: '10px',
                    padding: '11px 12px',
                    borderRadius: 'var(--radius-md)',
                    background: 'var(--bg-glass)',
                    border: '1px solid var(--border-glass)',
                  }}
                >
                  <div style={{ minWidth: 0 }}>
                    <div style={{ fontSize: '12.5px', fontWeight: 700, color: 'var(--text-primary)' }}>
                      {session.device}
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>
                      {session.location} •{' '}
                      <span style={{ color: session.isCurrent ? '#00e676' : 'var(--text-muted)' }}>
                        {session.isCurrent ? 'This device' : session.lastActive}
                      </span>
                    </div>
                  </div>
                  {!session.isCurrent && (
                    <button
                      type="button"
                      className="btn-ghost"
                      style={{ padding: '5px 11px', fontSize: '11px', color: '#ff4757', borderColor: 'rgba(255, 71, 87, 0.3)', flexShrink: 0 }}
                      onClick={() => revokeSession(session.id)}
                    >
                      Sign out
                    </button>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </ModalShell>
  );
};

/* ==========================================================================
   E + F. Help, Support and Legal content screens
   ========================================================================== */

const INFO_META: Record<
  SettingsInfoModalKey,
  { title: string; icon: React.ReactNode }
> = {
  help: { title: 'Help Center', icon: <LifeBuoy size={18} color="#00e5ff" /> },
  contact: { title: 'Contact Support', icon: <MessageSquare size={18} color="#00e676" /> },
  report: { title: 'Report a Problem', icon: <AlertTriangle size={18} color="#ff4757" /> },
  guidelines: { title: 'Community Guidelines', icon: <BookOpen size={18} color="#ffd700" /> },
  terms: { title: 'Terms of Service', icon: <FileCheck size={18} color="#9b51e0" /> },
  privacy: { title: 'Privacy Policy', icon: <Eye size={18} color="#00e5ff" /> },
};

const bodyTextStyle: React.CSSProperties = {
  fontSize: '13px',
  lineHeight: 1.65,
  color: 'var(--text-secondary)',
};

const headingStyle: React.CSSProperties = {
  fontSize: '13px',
  fontWeight: 800,
  color: 'var(--text-primary)',
  margin: '14px 0 5px',
};

const InfoModal: React.FC<{ infoKey: SettingsInfoModalKey; onClose: () => void }> = ({
  infoKey,
  onClose,
}) => {
  const { showToast } = useProfile();
  const [category, setCategory] = useState('Bug or crash');
  const [reportText, setReportText] = useState('');
  const meta = INFO_META[infoKey];

  const submitReport = (e: React.FormEvent) => {
    e.preventDefault();
    if (!reportText.trim()) {
      showToast('Please describe the problem first', 'error');
      return;
    }
    showToast('Thanks! Your report was saved locally (nothing was sent).', 'success');
    setReportText('');
    onClose();
  };

  return (
    <ModalShell icon={meta.icon} title={meta.title} onClose={onClose} maxWidth={540}>
      {infoKey === 'help' && (
        <div>
          <p style={bodyTextStyle}>
            Quick answers to the most common YoUnMe questions.
          </p>
          {[
            {
              q: 'How do matches work?',
              a: 'You and another member must like each other before a chat unlocks. Head to Discovery to start swiping.',
            },
            {
              q: 'What are YoUnMe Coins?',
              a: 'Coins power boosts, the daily Spin Wheel and profile highlights. They live in your wallet ledger.',
            },
            {
              q: 'How do I verify my profile?',
              a: 'Open Profile → Verification Center and complete the face and voice scan to earn the blue tick.',
            },
            {
              q: 'Why is contact sharing locked?',
              a: 'Trust Guard masks numbers and emails until you exchange 20 messages across 3 active days.',
            },
          ].map((item) => (
            <div key={item.q} style={{ marginTop: '12px' }}>
              <div style={headingStyle}>{item.q}</div>
              <p style={bodyTextStyle}>{item.a}</p>
            </div>
          ))}
          <button
            type="button"
            className="btn-ghost"
            style={{ width: '100%', marginTop: '18px', padding: '10px', fontSize: '12.5px' }}
            onClick={() => showToast('Full FAQ library is coming soon.', 'info')}
          >
            Browse all articles
          </button>
        </div>
      )}

      {infoKey === 'contact' && (
        <div>
          <p style={bodyTextStyle}>
            Our support squad reads every message. Reach us through any of these channels:
          </p>
          {[
            { label: 'Email', value: 'support@younme.app' },
            { label: 'Live chat', value: 'Daily, 9:00 – 21:00 IST' },
            { label: 'Safety line', value: 'safety@younme.app · 24/7' },
          ].map((item) => (
            <div
              key={item.label}
              className="settings-inline"
              style={{ marginTop: '8px', padding: '10px 12px' }}
            >
              <div className="settings-inline-label" style={{ fontSize: '12.5px' }}>
                {item.label}
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-secondary)', textAlign: 'right' }}>
                {item.value}
              </div>
            </div>
          ))}
          <button
            type="button"
            className="btn-primary"
            style={{ width: '100%', marginTop: '16px', padding: '11px', fontSize: '13px' }}
            onClick={() => {
              showToast('Support chat is coming soon.', 'info');
              onClose();
            }}
          >
            <Send size={15} />
            Start Secure Support Chat
          </button>
        </div>
      )}

      {infoKey === 'report' && (
        <form onSubmit={submitReport}>
          <p style={{ ...bodyTextStyle, marginBottom: '12px' }}>
            Spot something off? Tell us what happened.
          </p>
          <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>
            Category
          </label>
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            style={{ ...inputStyle, width: '100%', marginBottom: '12px' }}
          >
            {['Bug or crash', 'Safety concern', 'Payment & coins', 'Profile & photos', 'Other'].map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>

          <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>
            What went wrong?
          </label>
          <textarea
            rows={4}
            value={reportText}
            onChange={(e) => setReportText(e.target.value)}
            placeholder="Describe the issue..."
            style={{ ...inputStyle, resize: 'vertical', lineHeight: 1.5 }}
          />

          <div style={{ display: 'flex', gap: '8px', marginTop: '16px' }}>
            <button type="button" className="btn-ghost" style={{ flex: 1, padding: '10px' }} onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn-primary" style={{ flex: 1, padding: '10px' }}>
              Submit Report
            </button>
          </div>
        </form>
      )}

      {infoKey === 'guidelines' && (
        <div>
          <p style={bodyTextStyle}>
            YoUnMe is built on respect. Members who break these guidelines can be restricted or removed.
          </p>
          {[
            'Be yourself — real photos, real age, real intentions.',
            'Respect boundaries: no unsolicited explicit content, ever.',
            'Keep conversations on YoUnMe until you genuinely know each other.',
            'No harassment, hate speech, scam links or fake profiles.',
            'Use block, report and restriction tools whenever something feels off.',
          ].map((rule) => (
            <div
              key={rule}
              style={{ display: 'flex', gap: '9px', alignItems: 'flex-start', marginTop: '11px' }}
            >
              <span style={{ color: '#00e676', fontSize: '13px', lineHeight: 1.5 }}>✓</span>
              <span style={bodyTextStyle}>{rule}</span>
            </div>
          ))}
          <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '18px' }}>
            Last updated 01 Oct 2026.
          </p>
        </div>
      )}

      {infoKey === 'terms' && (
        <div>
          <p style={bodyTextStyle}>
            Welcome to YoUnMe. By using the app you agree to the terms below.
          </p>
          {[
            {
              h: '1. Eligibility',
              t: 'You must be 18 years or older and legally able to enter a binding agreement in your region.',
            },
            {
              h: '2. Your account',
              t: 'You are responsible for the activity on your account and for keeping your login credentials secure.',
            },
            {
              h: '3. Your content',
              t: 'You keep ownership of your photos and messages, and grant YoUnMe a licence to display them inside the service.',
            },
            {
              h: '4. Virtual coins',
              t: 'Coins are digital credits with no cash value, are non-refundable and may only be spent inside the app.',
            },
            {
              h: '5. Suspension',
              t: 'We may restrict or remove accounts that breach these terms or the Community Guidelines.',
            },
          ].map((clause) => (
            <div key={clause.h}>
              <div style={headingStyle}>{clause.h}</div>
              <p style={bodyTextStyle}>{clause.t}</p>
            </div>
          ))}
        </div>
      )}

      {infoKey === 'privacy' && (
        <div>
          <p style={bodyTextStyle}>
            This policy explains what YoUnMe collects and how you stay in control.
          </p>
          {[
            {
              h: 'Data we collect',
              t: 'Profile details you add, photos, approximate location for discovery, and device information needed to keep the app running.',
            },
            {
              h: 'How we use it',
              t: 'To rank nearby recommendations, power matches and chats, prevent fraud and improve the product.',
            },
            {
              h: 'Location & discovery',
              t: 'Precise coordinates are never shared with other members — only an approximate distance is shown.',
            },
            {
              h: 'Sharing',
              t: 'Contact details stay masked by Trust Guard and are never sold to advertisers.',
            },
            {
              h: 'Your rights',
              t: 'You can download or delete your data at any time from Account → Delete Account.',
            },
          ].map((clause) => (
            <div key={clause.h}>
              <div style={headingStyle}>{clause.h}</div>
              <p style={bodyTextStyle}>{clause.t}</p>
            </div>
          ))}
        </div>
      )}
    </ModalShell>
  );
};

/* ==========================================================================
   Settings screens mounted globally (next to the 3-Dot menu)
   ========================================================================== */

export const SettingsModals: React.FC = () => {
  const {
    isNotificationSettingsOpen,
    setIsNotificationSettingsOpen,
    isSecurityOpen,
    setIsSecurityOpen,
    settingsInfoModal,
    setSettingsInfoModal,
  } = useProfile();

  return (
    <>
      {isNotificationSettingsOpen && (
        <NotificationSettingsModal onClose={() => setIsNotificationSettingsOpen(false)} />
      )}
      {isSecurityOpen && <SecurityModal onClose={() => setIsSecurityOpen(false)} />}
      {settingsInfoModal && <InfoModal infoKey={settingsInfoModal} onClose={() => setSettingsInfoModal(null)} />}
    </>
  );
};

export default SettingsModals;
