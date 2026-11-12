import React from 'react';
import { Flame, Heart, MessageSquare, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, setActiveTab }) => {
  // STRICTLY 4 TABS: Home, Connect, Chat, Profile
  const navItems = [
    { id: 'discovery', label: 'Home', icon: Flame },
    { id: 'connect', label: 'Connect', icon: Heart },
    { id: 'chat', label: 'Chat', icon: MessageSquare },
    { id: 'profile', label: 'Profile', icon: User },
  ];

  return (
    <nav
      style={{
        height: '60px',
        backgroundColor: '#111318',
        borderTop: '1px solid rgba(255, 255, 255, 0.08)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        zIndex: 50,
        position: 'relative',
        boxSizing: 'border-box',
      }}
    >
      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = activeTab === item.id;

        return (
          <button
            key={item.id}
            type="button"
            onClick={() => setActiveTab(item.id)}
            style={{
              flex: 1,
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '3px',
              background: 'transparent',
              border: 'none',
              cursor: 'pointer',
              color: isActive ? '#f8fafc' : '#94a3b8',
              position: 'relative',
              padding: '6px 0',
              transition: 'all 0.15s ease',
            }}
          >
            {/* Top Indicator Line */}
            {isActive && (
              <span
                style={{
                  position: 'absolute',
                  top: 0,
                  width: '24px',
                  height: '2.5px',
                  borderRadius: '0 0 2px 2px',
                  background: '#f43f5e',
                }}
              />
            )}

            <Icon
              size={19}
              color={isActive ? '#f43f5e' : '#94a3b8'}
              strokeWidth={isActive ? 2.3 : 1.8}
            />
            <span
              style={{
                fontSize: '11px',
                fontWeight: isActive ? 700 : 500,
                color: isActive ? '#f8fafc' : '#94a3b8',
                letterSpacing: '-0.1px',
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
