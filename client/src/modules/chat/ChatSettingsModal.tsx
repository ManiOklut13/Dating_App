import React from 'react';
import { X, Shield, Bell, Eye, Moon, Sun, UserX, UserMinus } from 'lucide-react';
import { useChat } from './ChatContext';

export const ChatSettingsModal: React.FC = () => {
  const {
    isSettingsOpen,
    setIsSettingsOpen,
    settings,
    updateSettings,
    unblockUser,
    unrestrictUser,
  } = useChat();

  if (!isSettingsOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'rgba(5, 6, 12, 0.85)',
        backdropFilter: 'blur(20px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
      }}
      onClick={() => setIsSettingsOpen(false)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '560px',
          maxHeight: '90vh',
          borderRadius: 'var(--radius-lg)',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          border: '1px solid var(--border-glass)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          style={{
            padding: '18px 24px',
            background: 'var(--bg-dark)',
            borderBottom: '1px solid var(--border-glass)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                background: 'rgba(255, 45, 85, 0.15)',
                color: '#ff2d55',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Shield size={20} />
            </div>
            <div>
              <h2 style={{ fontSize: '19px', fontWeight: 800 }}>Chat & Privacy Settings</h2>
              <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                Preferences, Guard filters & blocked accounts
              </p>
            </div>
          </div>

          <button
            onClick={() => setIsSettingsOpen(false)}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'var(--text-secondary)',
              cursor: 'pointer',
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Content Body */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
          
          {/* Section 1: Who Can Message Me */}
          <div>
            <label style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', display: 'block', marginBottom: '8px' }}>
              Who Can Message Me
            </label>
            <div
              style={{
                display: 'flex',
                background: 'var(--surface-soft)',
                borderRadius: 'var(--radius-md)',
                padding: '4px',
                border: '1px solid var(--border-glass)',
                gap: '4px',
              }}
            >
              {(['everyone', 'matches', 'nobody'] as const).map((opt) => (
                <button
                  key={opt}
                  onClick={() => updateSettings({ who_can_message: opt })}
                  style={{
                    flex: 1,
                    padding: '8px 12px',
                    borderRadius: 'var(--radius-sm)',
                    border: 'none',
                    fontSize: '12px',
                    fontWeight: settings.who_can_message === opt ? 700 : 500,
                    color: settings.who_can_message === opt ? '#ffffff' : 'var(--text-secondary)',
                    background: settings.who_can_message === opt ? 'var(--gradient-flame)' : 'transparent',
                    cursor: 'pointer',
                    textTransform: 'capitalize',
                    transition: 'all var(--transition-fast)',
                  }}
                >
                  {opt === 'matches' ? 'Matches Only' : opt}
                </button>
              ))}
            </div>
          </div>

          {/* Section 2: Privacy Toggles */}
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Eye size={16} color="#00e5ff" />
              <span>Presence & Activity</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {/* Show Online Status */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-faint)', border: '1px solid var(--border-glass)' }}>
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 600 }}>Show Online Status</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Allow matches to see when you are active</div>
                </div>
                <input
                  type="checkbox"
                  checked={settings.show_online_status}
                  onChange={(e) => updateSettings({ show_online_status: e.target.checked })}
                  style={{ width: '20px', height: '20px', accentColor: '#ff2d55', cursor: 'pointer' }}
                />
              </div>

              {/* Read Receipts */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-faint)', border: '1px solid var(--border-glass)' }}>
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 600 }}>Read Receipts</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Show blue checkmarks when messages are read</div>
                </div>
                <input
                  type="checkbox"
                  checked={settings.read_receipts}
                  onChange={(e) => updateSettings({ read_receipts: e.target.checked })}
                  style={{ width: '20px', height: '20px', accentColor: '#ff2d55', cursor: 'pointer' }}
                />
              </div>
            </div>
          </div>

          {/* Section 3: Notification Preferences */}
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Bell size={16} color="#ffd700" />
              <span>Notifications & Alerts</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-faint)', border: '1px solid var(--border-glass)' }}>
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 600 }}>Direct Message Alerts</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Push notifications for new chat bubbles</div>
                </div>
                <input
                  type="checkbox"
                  checked={settings.dm_notifications}
                  onChange={(e) => updateSettings({ dm_notifications: e.target.checked })}
                  style={{ width: '20px', height: '20px', accentColor: '#ff2d55', cursor: 'pointer' }}
                />
              </div>

              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-faint)', border: '1px solid var(--border-glass)' }}>
                <div>
                  <div style={{ fontSize: '13px', fontWeight: 600 }}>Live Call Alerts</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Ringtone for incoming audio/video calls</div>
                </div>
                <input
                  type="checkbox"
                  checked={settings.call_alerts}
                  onChange={(e) => updateSettings({ call_alerts: e.target.checked })}
                  style={{ width: '20px', height: '20px', accentColor: '#ff2d55', cursor: 'pointer' }}
                />
              </div>
            </div>
          </div>

          {/* Section 4: Theme Preference */}
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              {settings.dark_mode ? <Moon size={16} color="#9b51e0" /> : <Sun size={16} color="#ffa502" />}
              <span>Theme Preference</span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--surface-faint)', border: '1px solid var(--border-glass)' }}>
              <div>
                <div style={{ fontSize: '13px', fontWeight: 600 }}>
                  {settings.dark_mode ? 'Cyber Luxe Dark Theme' : 'High Contrast Light Theme'}
                </div>
                <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                  Aesthetic visual mode across chat screens
                </div>
              </div>
              <button
                onClick={() => updateSettings({ dark_mode: !settings.dark_mode })}
                className="btn-ghost"
                style={{ padding: '6px 14px', fontSize: '12px', borderRadius: 'var(--radius-full)' }}
              >
                {settings.dark_mode ? 'Switch to Light' : 'Switch to Dark'}
              </button>
            </div>
          </div>

          {/* Section 5: Blocked Users */}
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <UserX size={16} color="#ff4757" />
              <span>Blocked Users ({settings.blocked_users.length})</span>
            </div>

            {settings.blocked_users.length === 0 ? (
              <div style={{ padding: '12px', background: 'rgba(255,255,255,0.02)', borderRadius: 'var(--radius-md)', fontSize: '12px', color: 'var(--text-muted)' }}>
                No blocked accounts currently.
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {settings.blocked_users.map((user) => (
                  <div
                    key={user.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '10px 14px',
                      borderRadius: 'var(--radius-md)',
                      background: 'rgba(255, 71, 87, 0.06)',
                      border: '1px solid rgba(255, 71, 87, 0.2)',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <img src={user.avatar} alt={user.name} style={{ width: '32px', height: '32px', borderRadius: '50%', objectFit: 'cover' }} />
                      <div>
                        <div style={{ fontSize: '13px', fontWeight: 700 }}>{user.name}</div>
                        <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>{user.date}</div>
                      </div>
                    </div>
                    <button
                      onClick={() => unblockUser(user.id)}
                      className="btn-ghost"
                      style={{ padding: '4px 10px', fontSize: '11px', color: '#00e676', borderColor: 'rgba(0, 230, 118, 0.3)' }}
                    >
                      Unblock
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Section 6: Restricted Users */}
          <div>
            <div style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <UserMinus size={16} color="#ffa502" />
              <span>Restricted Users ({settings.restricted_users.length})</span>
            </div>

            {settings.restricted_users.length === 0 ? (
              <div style={{ padding: '12px', background: 'rgba(255,255,255,0.02)', borderRadius: 'var(--radius-md)', fontSize: '12px', color: 'var(--text-muted)' }}>
                No restricted accounts.
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {settings.restricted_users.map((user) => (
                  <div
                    key={user.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '10px 14px',
                      borderRadius: 'var(--radius-md)',
                      background: 'rgba(255, 170, 0, 0.06)',
                      border: '1px solid rgba(255, 170, 0, 0.2)',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <img src={user.avatar} alt={user.name} style={{ width: '32px', height: '32px', borderRadius: '50%', objectFit: 'cover' }} />
                      <div>
                        <div style={{ fontSize: '13px', fontWeight: 700 }}>{user.name}</div>
                        <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>{user.date}</div>
                      </div>
                    </div>
                    <button
                      onClick={() => unrestrictUser(user.id)}
                      className="btn-ghost"
                      style={{ padding: '4px 10px', fontSize: '11px', color: '#ffd700', borderColor: 'rgba(255, 215, 0, 0.3)' }}
                    >
                      Unrestrict
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

        </div>

        {/* Footer */}
        <div style={{ padding: '14px 24px', background: 'var(--bg-dark)', borderTop: '1px solid var(--border-glass)', textAlign: 'right' }}>
          <button
            onClick={() => setIsSettingsOpen(false)}
            className="btn-primary"
            style={{ padding: '10px 24px', fontSize: '13px' }}
          >
            Save & Close
          </button>
        </div>

      </div>
    </div>
  );
};
