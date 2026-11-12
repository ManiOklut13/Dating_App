import React from 'react';
import { X, Bell, Heart, Sparkles, Flame, Check } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const NotificationsModal: React.FC = () => {
  const {
    profile,
    isNotificationsOpen,
    setIsNotificationsOpen,
    markNotificationAsRead,
    showToast,
  } = useProfile();

  if (!isNotificationsOpen) return null;

  const notifications = profile.notifications;

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
      onClick={() => setIsNotificationsOpen(false)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '460px',
          maxHeight: '80vh',
          borderRadius: 'var(--radius-lg)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          border: '1px solid var(--border-glass)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          style={{
            padding: '16px 20px',
            background: 'var(--bg-surface)',
            borderBottom: '1px solid var(--border-glass)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Bell size={18} color="#ff2d55" />
            <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Activity Notifications</h3>
          </div>
          <button
            onClick={() => setIsNotificationsOpen(false)}
            style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Notifications List */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {notifications.map((n) => (
            <div
              key={n.id}
              onClick={() => markNotificationAsRead(n.id)}
              style={{
                padding: '12px 14px',
                borderRadius: 'var(--radius-md)',
                background: n.unread ? 'rgba(255, 45, 85, 0.08)' : 'var(--surface-faint)',
                border: n.unread ? '1px solid rgba(255, 45, 85, 0.25)' : '1px solid var(--border-glass)',
                cursor: 'pointer',
                transition: 'all var(--transition-fast)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '4px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  {n.type === 'match' && <Heart size={14} color="#ff2d55" fill="#ff2d55" />}
                  {n.type === 'like' && <Sparkles size={14} color="#00e5ff" />}
                  {n.type === 'reward' && <Flame size={14} color="#ffa502" />}
                  <strong style={{ fontSize: '13px', color: 'var(--text-primary)' }}>{n.title}</strong>
                </div>
                <span style={{ fontSize: '10px', color: 'var(--text-muted)' }}>{n.timestamp}</span>
              </div>
              <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.4 }}>
                {n.description}
              </p>
            </div>
          ))}
        </div>

        {/* Footer */}
        <div style={{ padding: '12px 20px', background: 'var(--bg-surface)', borderTop: '1px solid var(--border-glass)', textAlign: 'right' }}>
          <button
            onClick={() => {
              notifications.forEach((n) => markNotificationAsRead(n.id));
              showToast('All notifications marked as read', 'info');
              setIsNotificationsOpen(false);
            }}
            className="btn-ghost"
            style={{ padding: '6px 14px', fontSize: '12px', gap: '4px' }}
          >
            <Check size={13} />
            Mark All as Read
          </button>
        </div>
      </div>
    </div>
  );
};
