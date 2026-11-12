import React from 'react';
import { Flame, Heart, MessageSquare, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  unreadCount?: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({
  activeTab,
  setActiveTab,
  unreadCount = 4,
}) => {
  const navItems = [
    { id: 'discovery', label: 'Home', icon: Flame },
    { id: 'connect', label: 'Connect', icon: Heart },
    { id: 'chat', label: 'Chat', icon: MessageSquare, badge: unreadCount },
    { id: 'profile', label: 'Profile', icon: User },
  ];

  return (
    <nav
      id="bottom-navigation-bar"
      className="bottom-nav"
      aria-label="Bottom Navigation"
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 50,
        background: 'var(--bg-nav)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        borderTop: '1px solid var(--surface-strong)',
        boxShadow: '0 -4px 20px rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        padding: '8px 16px max(8px, env(safe-area-inset-bottom))',
        maxWidth: '800px',
        margin: '0 auto',
      }}
    >
      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = activeTab === item.id;
        const hasBadge = !!item.badge && item.badge > 0;

        return (
          <button
            key={item.id}
            id={`nav-btn-${item.id}`}
            onClick={() => setActiveTab(item.id)}
            style={{
              position: 'relative',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              background: 'transparent',
              border: 'none',
              padding: '6px 16px',
              borderRadius: 'var(--radius-md)',
              cursor: 'pointer',
              color: isActive ? '#ffffff' : 'var(--text-secondary)',
              transition: 'all var(--transition-fast)',
              outline: 'none',
            }}
          >
            <div
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: isActive ? 'var(--gradient-flame)' : 'transparent',
                boxShadow: isActive ? 'var(--shadow-glow)' : 'none',
                transition: 'all var(--transition-fast)',
              }}
            >
              <Icon
                size={isActive ? 18 : 20}
                color={isActive ? '#ffffff' : 'var(--text-secondary)'}
                strokeWidth={isActive ? 2.5 : 2}
              />

              {/* Unread Message Badge */}
              {hasBadge && (
                <span
                  id="chats-unread-badge"
                  style={{
                    position: 'absolute',
                    top: '-3px',
                    right: '-6px',
                    background: '#ff2d55',
                    color: 'var(--text-primary)',
                    fontSize: '10px',
                    fontWeight: 800,
                    minWidth: '16px',
                    height: '16px',
                    borderRadius: 'var(--radius-full)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: '0 4px',
                    border: '2px solid var(--bg-dark)',
                    boxShadow: '0 0 10px rgba(255, 45, 85, 0.8)',
                  }}
                >
                  {item.badge}
                </span>
              )}
            </div>

            <span
              style={{
                fontSize: '11px',
                fontWeight: isActive ? 700 : 500,
                marginTop: '3px',
                color: isActive ? '#ffffff' : 'var(--text-muted)',
                letterSpacing: '-0.2px',
              }}
            >
              {item.label}
            </span>
          </button>
        );
      })}
    </nav>
  );
};
