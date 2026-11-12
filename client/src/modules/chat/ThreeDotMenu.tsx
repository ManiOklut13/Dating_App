import React, { useState } from 'react';
import {
  User,
  BellOff,
  Bell,
  Pin,
  PinOff,
  Palette,
  Flame,
  Trash2,
  Lock,
  ShieldAlert,
  UserX,
  Shield,
  X,
  Check,
} from 'lucide-react';
import { useChat } from './ChatContext';
import { ChatConversation } from './types';
import { WALLPAPER_THEMES } from './mockData';

interface ThreeDotMenuProps {
  conversation: ChatConversation;
  isOpen: boolean;
  onClose: () => void;
}

export const ThreeDotMenu: React.FC<ThreeDotMenuProps> = ({
  conversation,
  isOpen,
  onClose,
}) => {
  const {
    togglePinChat,
    toggleMuteChat,
    setChatWallpaper,
    setDisappearingMode,
    clearChatHistory,
    setProfilePreviewUser,
    setReportTarget,
    setBlockTarget,
    setIsScreenshotModalOpen,
    showToast,
  } = useChat();

  const [activeSubView, setActiveSubView] = useState<
    'menu' | 'theme' | 'wallpaper' | 'disappearing' | 'clearConfirm' | 'lockChat'
  >('menu');

  const [pinCode, setPinCode] = useState('');

  if (!isOpen) return null;

  const handleCloseAll = () => {
    setActiveSubView('menu');
    onClose();
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        background: 'rgba(5, 6, 12, 0.65)',
        backdropFilter: 'blur(12px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
      }}
      onClick={handleCloseAll}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '380px',
          borderRadius: 'var(--radius-lg)',
          overflow: 'hidden',
          border: '1px solid var(--border-glass)',
          boxShadow: 'var(--shadow-lg)',
          background: 'rgba(15, 18, 29, 0.98)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* ================= MAIN MENU ================= */}
        {activeSubView === 'menu' && (
          <div>
            {/* Header */}
            <div
              style={{
                padding: '16px 20px',
                borderBottom: '1px solid var(--border-glass)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ fontWeight: 800, fontSize: '16px' }}>Chat Options</span>
                <span style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                  • {conversation.counterpart.nickname}
                </span>
              </div>
              <button
                onClick={handleCloseAll}
                style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
              >
                <X size={18} />
              </button>
            </div>

            {/* Menu Items */}
            <div style={{ padding: '8px', display: 'flex', flexDirection: 'column', gap: '2px' }}>
              
              {/* View Profile */}
              <button
                onClick={() => {
                  setProfilePreviewUser(conversation.counterpart);
                  handleCloseAll();
                }}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <User size={16} color="#00e5ff" />
                <span>View Full Profile</span>
              </button>

              {/* Pin / Unpin */}
              <button
                onClick={() => {
                  togglePinChat(conversation.id);
                  handleCloseAll();
                }}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                {conversation.is_pinned ? <PinOff size={16} color="#ffd700" /> : <Pin size={16} color="#ffd700" />}
                <span>{conversation.is_pinned ? 'Unpin Conversation' : 'Pin Chat to Top'}</span>
              </button>

              {/* Mute / Unmute */}
              <button
                onClick={() => {
                  toggleMuteChat(conversation.id);
                  handleCloseAll();
                }}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                {conversation.is_muted ? <Bell size={16} color="#00e676" /> : <BellOff size={16} color="#ff4757" />}
                <span>{conversation.is_muted ? 'Unmute Notifications' : 'Mute Notifications'}</span>
              </button>

              {/* Chat Theme */}
              <button
                onClick={() => setActiveSubView('theme')}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <Palette size={16} color="#9b51e0" />
                <span>Chat Theme</span>
              </button>

              {/* Wallpaper */}
              <button
                onClick={() => setActiveSubView('wallpaper')}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <Palette size={16} color="#00e5ff" />
                <span>Wallpaper</span>
              </button>

              {/* Disappearing Messages */}
              <button
                onClick={() => setActiveSubView('disappearing')}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <Flame size={16} color="#ff2d55" />
                <span>Disappearing Messages ({conversation.disappearing_mode || 'off'})</span>
              </button>

              {/* Hide / Lock Chat */}
              <button
                onClick={() => setActiveSubView('lockChat')}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <Lock size={16} color="#00e5ff" />
                <span>{conversation.is_locked ? 'Unlock Chat' : 'Lock Chat (PIN)'}</span>
              </button>

              {/* Clear Chat History */}
              <button
                onClick={() => setActiveSubView('clearConfirm')}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                }}
              >
                <Trash2 size={16} color="#ff4757" />
                <span>Clear Chat History</span>
              </button>

              <div style={{ height: '1px', background: 'var(--border-glass)', margin: '4px 0' }} />

              {/* Report */}
              <button
                onClick={() => {
                  setReportTarget({ user: conversation.counterpart });
                  handleCloseAll();
                }}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                  color: '#ff4757',
                }}
              >
                <ShieldAlert size={16} />
                <span>Report User</span>
              </button>

              {/* Block */}
              <button
                onClick={() => {
                  setBlockTarget({ user: conversation.counterpart });
                  handleCloseAll();
                }}
                className="btn-ghost"
                style={{
                  width: '100%',
                  padding: '12px 14px',
                  justifyContent: 'flex-start',
                  border: 'none',
                  fontSize: '13.5px',
                  borderRadius: 'var(--radius-sm)',
                  gap: '12px',
                  color: '#ff4757',
                }}
              >
                <UserX size={16} />
                <span>Block User</span>
              </button>

            </div>
          </div>
        )}

        {/* ================= CHAT THEME SUB-VIEW ================= */}
        {activeSubView === 'theme' && (
          <div style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 800, marginBottom: '14px' }}>
              Chat Theme
            </h3>

            <div style={{ marginBottom: '16px' }}>
              <div style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-secondary)', marginBottom: '8px' }}>
                Appearance
              </div>
              <div style={{ display: 'flex', gap: '8px' }}>
                {(['light', 'dark'] as const).map((mode) => (
                  <button
                    key={mode}
                    onClick={() => {
                      showToast({ type: 'info', text: `Switched to ${mode} chat theme` });
                      handleCloseAll();
                    }}
                    className="btn-ghost"
                    style={{
                      flex: 1,
                      padding: '10px',
                      fontSize: '13px',
                      fontWeight: 600,
                      borderRadius: 'var(--radius-md)',
                      textTransform: 'capitalize',
                    }}
                  >
                    {mode}
                  </button>
                ))}
              </div>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <div style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-secondary)', marginBottom: '8px' }}>
                Accent Color
              </div>
              <div style={{ display: 'flex', gap: '10px' }}>
                {['#ff2d55', '#00e5ff', '#00e676', '#9b51e0', '#ffd700'].map((color) => (
                  <button
                    key={color}
                    onClick={() => {
                      showToast({ type: 'info', text: 'Accent color updated' });
                      handleCloseAll();
                    }}
                    style={{
                      width: '32px',
                      height: '32px',
                      borderRadius: '50%',
                      background: color,
                      border: '2px solid var(--border-glass)',
                      cursor: 'pointer',
                    }}
                    aria-label={`Select ${color} accent`}
                  />
                ))}
              </div>
            </div>

            <div>
              <div style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-secondary)', marginBottom: '8px' }}>
                Message Bubble Style
              </div>
              <div style={{ display: 'flex', gap: '8px' }}>
                {['Rounded', 'Squared', 'Minimal'].map((style) => (
                  <button
                    key={style}
                    onClick={() => {
                      showToast({ type: 'info', text: `${style} bubble style applied` });
                      handleCloseAll();
                    }}
                    className="btn-ghost"
                    style={{ flex: 1, padding: '8px', fontSize: '12px', borderRadius: 'var(--radius-md)' }}
                  >
                    {style}
                  </button>
                ))}
              </div>
            </div>

            <button
              onClick={() => setActiveSubView('menu')}
              className="btn-ghost"
              style={{ marginTop: '18px', width: '100%', padding: '10px', fontSize: '13px' }}
            >
              Back
            </button>
          </div>
        )}

        {/* ================= WALLPAPER SUB-VIEW ================= */}
        {activeSubView === 'wallpaper' && (
          <div style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 800, marginBottom: '14px' }}>
              Choose Chat Wallpaper Theme
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {WALLPAPER_THEMES.map((theme) => {
                const isSelected = (conversation.wallpaper || 'cyber-dark') === theme.id;
                return (
                  <div
                    key={theme.id}
                    onClick={() => {
                      setChatWallpaper(conversation.id, theme.id);
                      handleCloseAll();
                    }}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '12px 14px',
                      borderRadius: 'var(--radius-md)',
                      background: theme.bg,
                      border: isSelected ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                      cursor: 'pointer',
                    }}
                  >
                    <span style={{ fontSize: '13.5px', fontWeight: 700 }}>{theme.label}</span>
                    {isSelected && <Check size={16} color="#ff2d55" />}
                  </div>
                );
              })}
            </div>
            <button
              onClick={() => setActiveSubView('menu')}
              className="btn-ghost"
              style={{ width: '100%', marginTop: '16px', padding: '10px' }}
            >
              Back
            </button>
          </div>
        )}

        {/* ================= DISAPPEARING SUB-VIEW ================= */}
        {activeSubView === 'disappearing' && (
          <div style={{ padding: '20px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: 800, marginBottom: '14px' }}>
              Disappearing Messages Timer
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {[
                { id: 'off', label: 'Off' },
                { id: '60s', label: 'Vanish Mode (60 seconds)' },
                { id: '24h', label: '24 Hours' },
                { id: '7d', label: '7 Days' },
              ].map((opt) => {
                const isSelected = (conversation.disappearing_mode || 'off') === opt.id;
                return (
                  <div
                    key={opt.id}
                    onClick={() => {
                      setDisappearingMode(conversation.id, opt.id as any);
                      handleCloseAll();
                    }}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '12px 14px',
                      borderRadius: 'var(--radius-md)',
                      background: 'var(--surface-faint)',
                      border: isSelected ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                      cursor: 'pointer',
                    }}
                  >
                    <span style={{ fontSize: '13.5px', fontWeight: 600 }}>{opt.label}</span>
                    {isSelected && <Check size={16} color="#ff2d55" />}
                  </div>
                );
              })}
            </div>
            <button
              onClick={() => setActiveSubView('menu')}
              className="btn-ghost"
              style={{ width: '100%', marginTop: '16px', padding: '10px' }}
            >
              Back
            </button>
          </div>
        )}

        {/* ================= CLEAR HISTORY SUB-VIEW ================= */}
        {activeSubView === 'clearConfirm' && (
          <div style={{ padding: '24px 20px', textAlign: 'center' }}>
            <Trash2 size={36} color="#ff4757" style={{ margin: '0 auto 12px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>
              Clear Chat History?
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              This will erase all sent and received message bubbles for this session with {conversation.counterpart.nickname}.
            </p>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setActiveSubView('menu')}
                className="btn-ghost"
                style={{ flex: 1, padding: '10px' }}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  clearChatHistory(conversation.id);
                  handleCloseAll();
                }}
                className="btn-primary"
                style={{ flex: 1, padding: '10px', background: '#ff4757' }}
              >
                Clear All
              </button>
            </div>
          </div>
        )}

        {/* ================= LOCK CHAT SUB-VIEW ================= */}
        {activeSubView === 'lockChat' && (
          <div style={{ padding: '24px 20px', textAlign: 'center' }}>
            <Lock size={36} color="#00e5ff" style={{ margin: '0 auto 12px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>
              Set 4-Digit Chat PIN
            </h3>
            <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              Locked chats require passcode or biometric confirmation to open.
            </p>
            <input
              type="password"
              maxLength={4}
              value={pinCode}
              onChange={(e) => setPinCode(e.target.value)}
              placeholder="••••"
              style={{
                width: '140px',
                padding: '10px',
                textAlign: 'center',
                letterSpacing: '8px',
                fontSize: '22px',
                borderRadius: 'var(--radius-md)',
                background: 'var(--surface-strong)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-primary)',
                marginBottom: '20px',
                outline: 'none',
              }}
            />
            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setActiveSubView('menu')}
                className="btn-ghost"
                style={{ flex: 1, padding: '10px' }}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  showToast({ type: 'success', text: `Chat with ${conversation.counterpart.nickname} locked with PIN.` });
                  handleCloseAll();
                }}
                className="btn-primary"
                style={{ flex: 1, padding: '10px' }}
              >
                Lock Chat
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};
