import React from 'react';
import { Flame, Coins, Sparkles, Compass, Heart, MessageSquare, PhoneCall, UserCheck } from 'lucide-react';

interface TopNavProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  coinBalance: number;
  streakDays: number;
  onOpenStore: () => void;
  onOpenWheel: () => void;
}

export const TopNav: React.FC<TopNavProps> = ({
  activeTab,
  setActiveTab,
  coinBalance,
  streakDays,
  onOpenStore,
  onOpenWheel,
}) => {
  const tabs = [
    { id: 'discovery', label: 'Discovery', icon: Compass },
    { id: 'connect', label: 'Connect', icon: Heart },
    { id: 'chat', label: 'Chat', icon: MessageSquare },
    { id: 'calls', label: 'LiveKit Calls', icon: PhoneCall },
    { id: 'profile', label: 'Profile & Ledger', icon: UserCheck },
  ];

  return (
    <header className="sticky top-0 z-40 w-full" style={{ background: 'rgba(8, 10, 16, 0.85)', backdropFilter: 'blur(20px)', borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
      <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '12px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
        
        {/* Brand Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }} onClick={() => setActiveTab('discovery')}>
          <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'var(--gradient-flame)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-glow)' }}>
            <Flame size={24} color="#ffffff" />
          </div>
          <div>
            <div style={{ fontFamily: 'var(--font-heading)', fontSize: '22px', fontWeight: '800', background: 'var(--gradient-flame)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', letterSpacing: '-0.5px' }}>
              YoUnMe
            </div>
            <div style={{ fontSize: '10px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 600 }}>
              v3.2 Cloud Run
            </div>
          </div>
        </div>

        {/* 5-Tab Navigation Pill */}
        <nav style={{ display: 'flex', alignItems: 'center', background: 'rgba(255, 255, 255, 0.04)', padding: '4px', borderRadius: 'var(--radius-full)', border: '1px solid var(--border-glass)' }}>
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  padding: '8px 16px',
                  borderRadius: 'var(--radius-full)',
                  border: 'none',
                  fontSize: '13px',
                  fontWeight: isActive ? '700' : '500',
                  color: isActive ? '#ffffff' : 'var(--text-secondary)',
                  background: isActive ? 'var(--gradient-flame)' : 'transparent',
                  boxShadow: isActive ? 'var(--shadow-glow)' : 'none',
                  cursor: 'pointer',
                  transition: 'all var(--transition-fast)',
                }}
              >
                <Icon size={16} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </nav>

        {/* Action Widgets (Coins & Daily Streak & Avatar) */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          {/* Daily Streak Pill */}
          <button
            onClick={onOpenWheel}
            className="glass-pill"
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 14px',
              color: '#ffa502',
              fontWeight: '700',
              fontSize: '13px',
              cursor: 'pointer',
              border: '1px solid rgba(255, 165, 2, 0.3)',
            }}
          >
            <Sparkles size={16} />
            <span>🔥 Day {streakDays} (1.4x)</span>
          </button>

          {/* Coin Balance Pill */}
          <button
            onClick={onOpenStore}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 14px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(255, 215, 0, 0.1)',
              border: '1px solid rgba(255, 215, 0, 0.35)',
              color: '#ffd700',
              fontWeight: '700',
              fontSize: '13px',
              cursor: 'pointer',
              boxShadow: 'var(--shadow-gold)',
            }}
          >
            <Coins size={16} />
            <span>{coinBalance} Coins</span>
            <span style={{ background: '#ffd700', color: '#000', borderRadius: '50%', width: '16px', height: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', fontWeight: 'bold' }}>+</span>
          </button>

          {/* User Avatar with Blue Tick */}
          <div
            onClick={() => setActiveTab('profile')}
            style={{ position: 'relative', width: '38px', height: '38px', cursor: 'pointer' }}
          >
            <img
              src="/aditya.jpg"
              alt="Arjun"
              style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(255, 45, 85, 0.5)' }}
            />
            <div
              className="badge-blue-tick"
              style={{ position: 'absolute', bottom: '-2px', right: '-2px', width: '16px', height: '16px', fontSize: '10px' }}
            >
              ✓
            </div>
          </div>
        </div>

      </div>
    </header>
  );
};
