import React, { useState } from 'react';
import { ChevronLeft, Flame, Heart, Mic, Gem, Calendar, CheckCheck, Bell, Sparkles } from 'lucide-react';

export interface AppNotification {
  id: string;
  kind: 'streak' | 'like' | 'prompt' | 'rubies' | 'date';
  title: string;
  desc: string;
  time: string;
  unread?: boolean;
}

interface NotificationsPageProps {
  onBack: () => void;
  onOpenStore?: () => void;
  onOpenChat?: (convId: string) => void;
}

const INITIAL_NOTIFICATIONS: AppNotification[] = [
  {
    id: 'n1',
    kind: 'streak',
    title: '🔥 Daily Connection Streak Active',
    desc: 'You are on a 4-day streak with 1.4x Ruby multiplier! Check in tomorrow to keep the flame burning.',
    time: '10m ago',
    unread: true,
  },
  {
    id: 'n2',
    kind: 'like',
    title: '❤️ Secret Admirer',
    desc: 'Someone with 96% Vibe Match liked your profile in Connect. Unlock the stack to reveal them.',
    time: '25m ago',
    unread: true,
  },
  {
    id: 'n3',
    kind: 'date',
    title: '☕ Upcoming Specialty Coffee Date',
    desc: 'Your date with Ananya at Subko Coffee Roasters is confirmed for this Saturday at 5:00 PM.',
    time: '1h ago',
    unread: false,
  },
  {
    id: 'n4',
    kind: 'prompt',
    title: '🎙️ New Audio Prompt',
    desc: 'Ananya uploaded a new voice prompt in Bandra: "My favorite late-night vinyl record".',
    time: '3h ago',
    unread: false,
  },
  {
    id: 'n5',
    kind: 'rubies',
    title: '💎 500 Rubies Credited',
    desc: 'Your Ruby bundle was credited successfully. Use them for Instant Video Calls and Mega Crushes.',
    time: 'Yesterday',
    unread: false,
  },
];

export const NotificationsPage: React.FC<NotificationsPageProps> = ({ onBack, onOpenStore }) => {
  const [notifications, setNotifications] = useState<AppNotification[]>(INITIAL_NOTIFICATIONS);
  const [activeFilter, setActiveFilter] = useState<'all' | 'unread'>('all');

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, unread: false })));
  };

  const filtered = notifications.filter((n) => (activeFilter === 'unread' ? n.unread : true));

  const getIcon = (kind: AppNotification['kind']) => {
    switch (kind) {
      case 'streak':
        return <Flame size={18} color="#FF5277" />;
      case 'like':
        return <Heart size={18} color="#FE728B" fill="#FE728B" />;
      case 'prompt':
        return <Mic size={18} color="#00E5FF" />;
      case 'rubies':
        return <Gem size={18} color="#FFD700" />;
      case 'date':
        return <Calendar size={18} color="#FF2D55" />;
      default:
        return <Bell size={18} color="#FFFFFF" />;
    }
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: '#0B0D14',
        color: '#FFFFFF',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* Single Clean Top Header without duplicate icons or streak/ruby badges */}
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '16px 20px',
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          background: 'rgba(11, 13, 20, 0.95)',
          backdropFilter: 'blur(10px)',
          position: 'sticky',
          top: 0,
          zIndex: 20,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button
            type="button"
            onClick={onBack}
            style={{
              background: 'rgba(255, 255, 255, 0.08)',
              border: 'none',
              borderRadius: '12px',
              width: '38px',
              height: '38px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              cursor: 'pointer',
            }}
          >
            <ChevronLeft size={20} />
          </button>
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: 800, margin: 0 }}>Notifications</h1>
            <span style={{ fontSize: '11px', color: '#8C8C9E' }}>Activity & updates</span>
          </div>
        </div>

        <button
          type="button"
          onClick={markAllAsRead}
          style={{
            background: 'transparent',
            border: 'none',
            color: '#FE728B',
            fontSize: '12px',
            fontWeight: 700,
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            cursor: 'pointer',
          }}
        >
          <CheckCheck size={14} />
          <span>Mark all read</span>
        </button>
      </header>

      {/* Filter Tabs */}
      <div style={{ display: 'flex', gap: '8px', padding: '14px 20px 8px' }}>
        <button
          type="button"
          onClick={() => setActiveFilter('all')}
          style={{
            padding: '6px 14px',
            borderRadius: '999px',
            border: 'none',
            background: activeFilter === 'all' ? 'linear-gradient(135deg, #FE728B, #FF2D55)' : '#181A24',
            color: '#FFFFFF',
            fontSize: '12px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
        >
          All
        </button>
        <button
          type="button"
          onClick={() => setActiveFilter('unread')}
          style={{
            padding: '6px 14px',
            borderRadius: '999px',
            border: 'none',
            background: activeFilter === 'unread' ? 'linear-gradient(135deg, #FE728B, #FF2D55)' : '#181A24',
            color: '#FFFFFF',
            fontSize: '12px',
            fontWeight: 700,
            cursor: 'pointer',
          }}
        >
          Unread ({notifications.filter((n) => n.unread).length})
        </button>
      </div>

      {/* Notifications List */}
      <div style={{ flex: 1, padding: '10px 16px 80px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '48px 20px', color: '#8C8C9E' }}>
            <Sparkles size={28} color="#FE728B" style={{ marginBottom: '8px' }} />
            <p style={{ fontSize: '14px', fontWeight: 600 }}>All caught up!</p>
            <p style={{ fontSize: '12px', margin: 0 }}>No new notifications at this time.</p>
          </div>
        ) : (
          filtered.map((item) => (
            <div
              key={item.id}
              onClick={() => {
                if (item.kind === 'rubies' && onOpenStore) onOpenStore();
                setNotifications((prev) =>
                  prev.map((n) => (n.id === item.id ? { ...n, unread: false } : n))
                );
              }}
              style={{
                display: 'flex',
                gap: '12px',
                padding: '14px',
                borderRadius: '16px',
                background: item.unread ? 'rgba(254, 114, 139, 0.08)' : '#151722',
                border: item.unread ? '1px solid rgba(254, 114, 139, 0.3)' : '1px solid rgba(255, 255, 255, 0.06)',
                cursor: 'pointer',
                transition: 'transform 0.1s ease',
              }}
            >
              <div
                style={{
                  width: '38px',
                  height: '38px',
                  borderRadius: '12px',
                  background: '#1F2232',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                {getIcon(item.kind)}
              </div>

              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '6px' }}>
                  <h4 style={{ fontSize: '13.5px', fontWeight: 700, margin: 0, color: '#FFFFFF' }}>{item.title}</h4>
                  <span style={{ fontSize: '11px', color: '#8C8C9E', flexShrink: 0 }}>{item.time}</span>
                </div>
                <p style={{ fontSize: '12px', color: '#B3B1C2', margin: '4px 0 0', lineHeight: 1.45 }}>
                  {item.desc}
                </p>
              </div>

              {item.unread && (
                <div
                  style={{
                    width: '7px',
                    height: '7px',
                    borderRadius: '50%',
                    background: '#FE728B',
                    alignSelf: 'center',
                    flexShrink: 0,
                  }}
                />
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
};

