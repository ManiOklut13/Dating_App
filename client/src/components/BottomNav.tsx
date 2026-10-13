import React from 'react';
import { Flame, Heart, MessageSquare, User, Coins } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, setActiveTab }) => {
  const navItems = [
    { id: 'discovery', label: 'Home', icon: Flame },
    { id: 'connect', label: 'Connect', icon: Heart },
    { id: 'chat', label: 'Chat', icon: MessageSquare },
    { id: 'profile', label: 'Profile', icon: User },
    { id: 'ledger', label: 'Ledger', icon: Coins },
  ];

  return (
    <nav
      className="mobile-bottom-nav"
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        height: '62px',
        backgroundColor: 'rgba(8, 10, 16, 0.95)',
        backdropFilter: 'blur(20px)',
        WebkitBackdropFilter: 'blur(20px)',
        borderTop: '1px solid rgba(255, 255, 255, 0.08)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        zIndex: 50,
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
        boxShadow: '0 -4px 20px rgba(0, 0, 0, 0.5)',
      }}
    >
      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = activeTab === item.id;

        return (
          <button
            key={item.id}
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
              color: isActive ? '#ff2d55' : 'var(--text-secondary)',
              transition: 'all var(--transition-fast)',
              padding: '4px 0',
              position: 'relative',
              WebkitTapHighlightColor: 'transparent',
            }}
          >
            {/* Active Indicator Top Pill */}
            {isActive && (
              <span
                style={{
                  position: 'absolute',
                  top: 0,
                  width: '28px',
                  height: '3px',
                  borderRadius: '0 0 3px 3px',
                  background: 'var(--gradient-flame)',
                  boxShadow: '0 0 10px rgba(255, 45, 85, 0.6)',
                }}
              />
            )}

            <Icon
              size={20}
              color={isActive ? '#ff2d55' : 'currentColor'}
              style={{
                filter: isActive ? 'drop-shadow(0 0 6px rgba(255, 45, 85, 0.5))' : 'none',
                transition: 'transform var(--transition-fast)',
                transform: isActive ? 'scale(1.1)' : 'scale(1)',
              }}
            />
            <span
              style={{
                fontSize: '11px',
                fontWeight: isActive ? 700 : 500,
                letterSpacing: '-0.2px',
                color: isActive ? '#ffffff' : 'var(--text-secondary)',
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
