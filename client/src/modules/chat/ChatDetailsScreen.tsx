import React, { useState } from 'react';
import {
  ArrowLeft,
  User,
  Search,
  Bell,
  MoreVertical,
  Palette,
  Timer,
  Lock,
  Users,
  UserRound,
  CheckCircle2,
  ImageIcon,
  X,
  Check,
} from 'lucide-react';
import { ChatConversation, ChatMessage } from './types';
import { useChat } from './ChatContext';
import { WALLPAPER_THEMES } from './mockData';

interface ChatDetailsScreenProps {
  conversation: ChatConversation;
  messages: ChatMessage[];
  onBack: () => void;
}

// ── Gradient icon wrapper for Customise ──────────────────────────────────────
const GradientIconWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div
    style={{
      width: 44,
      height: 44,
      borderRadius: '50%',
      background: 'linear-gradient(135deg, #9b51e0 0%, #3b82f6 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0,
    }}
  >
    {children}
  </div>
);

// ── Plain dark icon wrapper ───────────────────────────────────────────────────
const DarkIconWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div
    style={{
      width: 44,
      height: 44,
      borderRadius: '50%',
      background: 'rgba(255,255,255,0.10)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0,
    }}
  >
    {children}
  </div>
);

// ── Settings row (no trailing arrow) ────────────────────────────────────────
interface SettingsRowProps {
  icon: React.ReactNode;
  label: string;
  subtitle?: string;
  onClick: () => void;
  id?: string;
}

const SettingsRow: React.FC<SettingsRowProps> = ({ icon, label, subtitle, onClick, id }) => (
  <button
    id={id}
    onClick={onClick}
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: 16,
      padding: '14px 0',
      background: 'transparent',
      border: 'none',
      cursor: 'pointer',
      width: '100%',
      textAlign: 'left',
    }}
  >
    {icon}
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 16, fontWeight: 500, color: '#ffffff', lineHeight: 1.3 }}>
        {label}
      </div>
      {subtitle && (
        <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.45)', marginTop: 2 }}>
          {subtitle}
        </div>
      )}
    </div>
    {/* NO trailing arrow — by design */}
  </button>
);

// ── Mute options ──────────────────────────────────────────────────────────────
const MUTE_OPTIONS = [
  { label: '1 hour', value: '1h' },
  { label: '8 hours', value: '8h' },
  { label: '1 week', value: '7d' },
  { label: 'Until I turn it back on', value: 'forever' },
];

// ── Nickname modal ───────────────────────────────────────────────────────────
interface NicknameModalProps {
  currentName: string;
  nickname: string;
  onSave: (nick: string) => void;
  onClose: () => void;
}

const NicknameModal: React.FC<NicknameModalProps> = ({ currentName, nickname, onSave, onClose }) => {
  const [value, setValue] = useState(nickname);
  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 10002,
        background: 'rgba(0,0,0,0.75)',
        backdropFilter: 'blur(10px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
      }}
      onClick={onClose}
    >
      <div
        style={{
          background: '#1a1d2e',
          borderRadius: 16,
          padding: '24px 24px 20px',
          width: '100%',
          maxWidth: 380,
          border: '1px solid rgba(255,255,255,0.12)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
          <span style={{ fontSize: 17, fontWeight: 700, color: '#fff' }}>Nickname</span>
          <button onClick={onClose} style={{ background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.5)', cursor: 'pointer' }}>
            <X size={20} />
          </button>
        </div>
        <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.5)', marginBottom: 16 }}>
          Set a nickname for <strong style={{ color: '#fff' }}>{currentName}</strong>. This will not change their account name.
        </p>
        <input
          type="text"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          placeholder={`Nickname for ${currentName}...`}
          autoFocus
          style={{
            width: '100%',
            padding: '12px 14px',
            borderRadius: 10,
            background: 'rgba(255,255,255,0.07)',
            border: '1px solid rgba(255,255,255,0.15)',
            color: '#fff',
            fontSize: 15,
            outline: 'none',
            boxSizing: 'border-box',
          }}
        />
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <button
            onClick={onClose}
            style={{
              flex: 1,
              padding: '11px',
              borderRadius: 10,
              background: 'rgba(255,255,255,0.06)',
              border: '1px solid rgba(255,255,255,0.12)',
              color: 'rgba(255,255,255,0.7)',
              fontSize: 14,
              cursor: 'pointer',
            }}
          >
            Cancel
          </button>
          <button
            onClick={() => { onSave(value.trim()); onClose(); }}
            style={{
              flex: 1,
              padding: '11px',
              borderRadius: 10,
              background: 'linear-gradient(135deg, #9b51e0 0%, #3b82f6 100%)',
              border: 'none',
              color: '#fff',
              fontSize: 14,
              fontWeight: 700,
              cursor: 'pointer',
            }}
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
};

// ── Sheet overlay helper ─────────────────────────────────────────────────────
interface SheetProps {
  title: string;
  onClose: () => void;
  children: React.ReactNode;
}

const Sheet: React.FC<SheetProps> = ({ title, onClose, children }) => (
  <div
    style={{
      position: 'fixed',
      inset: 0,
      zIndex: 10002,
      background: 'rgba(0,0,0,0.65)',
      backdropFilter: 'blur(8px)',
      display: 'flex',
      alignItems: 'flex-end',
    }}
    onClick={onClose}
  >
    <div
      style={{
        width: '100%',
        background: '#141620',
        borderRadius: '20px 20px 0 0',
        border: '1px solid rgba(255,255,255,0.1)',
        padding: '0 0 32px',
        animation: 'slideUpSheet 0.22s cubic-bezier(0.34,1.56,0.64,1)',
      }}
      onClick={(e) => e.stopPropagation()}
    >
      <div style={{ width: 36, height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.2)', margin: '12px auto 16px' }} />
      <div style={{ padding: '0 20px 16px', borderBottom: '1px solid rgba(255,255,255,0.08)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 17, fontWeight: 700, color: '#fff' }}>{title}</span>
        <button onClick={onClose} style={{ background: 'transparent', border: 'none', color: 'rgba(255,255,255,0.5)', cursor: 'pointer' }}>
          <X size={20} />
        </button>
      </div>
      <div style={{ padding: '8px 20px 0' }}>{children}</div>
    </div>
  </div>
);

// ── Thin divider ─────────────────────────────────────────────────────────────
const Divider: React.FC = () => (
  <div style={{ height: 1, background: 'rgba(255,255,255,0.07)' }} />
);

// ── Shared inline styles ─────────────────────────────────────────────────────
const actionBtnStyle: React.CSSProperties = {
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  gap: 8,
  background: 'transparent',
  border: 'none',
  cursor: 'pointer',
  padding: '6px 8px',
  minWidth: 68,
};

const actionIconBg: React.CSSProperties = {
  width: 52,
  height: 52,
  borderRadius: '50%',
  background: 'rgba(255,255,255,0.12)',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
};

const actionLabelStyle: React.CSSProperties = {
  fontSize: 12,
  color: '#ffffff',
  fontWeight: 500,
};

const sheetItemStyle: React.CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  width: '100%',
  padding: '15px 0',
  background: 'transparent',
  border: 'none',
  borderBottom: '1px solid rgba(255,255,255,0.06)',
  cursor: 'pointer',
  fontSize: 16,
  color: '#ffffff',
  textAlign: 'left',
};

// ── Main Component ────────────────────────────────────────────────────────────
export const ChatDetailsScreen: React.FC<ChatDetailsScreenProps> = ({
  conversation,
  messages,
  onBack,
}) => {
  const {
    toggleMuteChat,
    setChatWallpaper,
    setDisappearingMode,
    setProfilePreviewUser,
    showToast,
  } = useChat();

  const user = conversation.counterpart;

  const [activeSheet, setActiveSheet] = useState<
    null | 'mute' | 'disappearing' | 'privacy' | 'customise' | 'search' | 'options'
  >(null);
  const [showNicknameModal, setShowNicknameModal] = useState(false);
  const [nickname, setNickname] = useState('');
  const [disappearingMode, setLocalDisappearingMode] = useState<'off' | '60s' | '24h' | '7d'>(
    conversation.disappearing_mode || 'off'
  );
  const [isMuted, setIsMuted] = useState(conversation.is_muted);

  // Pull image messages for Shared media
  const sharedImages = messages.filter(
    (m) => (m.type === 'image' || m.type === 'gif') && m.media_url
  );

  const handleMute = (value: string) => {
    toggleMuteChat(conversation.id);
    setIsMuted(true);
    setActiveSheet(null);
    showToast({ type: 'success', text: `Notifications muted${value !== 'forever' ? ` for ${value}` : ' indefinitely'}` });
  };

  const handleDisappearing = (mode: 'off' | '60s' | '24h' | '7d') => {
    setDisappearingMode(conversation.id, mode);
    setLocalDisappearingMode(mode);
    setActiveSheet(null);
    showToast({
      type: 'info',
      text: mode === 'off' ? 'Disappearing messages turned off' : `Disappearing messages: ${mode}`,
    });
  };

  const disappearingLabel =
    disappearingMode === 'off' ? 'Off' :
    disappearingMode === '60s' ? '60 seconds' :
    disappearingMode === '24h' ? '24 hours' : '7 days';

  const DISAPPEARING_OPTIONS: { label: string; value: 'off' | '60s' | '24h' | '7d' }[] = [
    { label: 'Off', value: 'off' },
    { label: '60 seconds', value: '60s' },
    { label: '24 hours', value: '24h' },
    { label: '7 days', value: '7d' },
  ];

  return (
    <div
      id="chat-details-screen"
      style={{
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        minHeight: 0,
        background: '#0a0b10',
        overflowY: 'auto',
        overflowX: 'hidden',
      }}
    >
      {/* ── BACK ARROW ─────────────────────────────────────────────────── */}
      <button
        id="chat-details-back-btn"
        onClick={onBack}
        aria-label="Back to conversation"
        style={{
          position: 'sticky',
          top: 0,
          left: 0,
          zIndex: 10,
          alignSelf: 'flex-start',
          margin: '16px 0 0 16px',
          width: 38,
          height: 38,
          borderRadius: '50%',
          background: 'rgba(255,255,255,0.08)',
          border: 'none',
          color: '#ffffff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          flexShrink: 0,
        }}
      >
        <ArrowLeft size={20} />
      </button>

      {/* ── PROFILE HEADER ─────────────────────────────────────────────── */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          paddingTop: 24,
          paddingBottom: 28,
          paddingInline: 20,
          background: '#0a0b10',
        }}
      >
        {/* Profile Photo */}
        <div
          style={{
            width: 96,
            height: 96,
            borderRadius: '50%',
            overflow: 'hidden',
            border: '3px solid rgba(255,255,255,0.18)',
            flexShrink: 0,
            marginBottom: 14,
          }}
        >
          <img
            src={user.avatar}
            alt={user.nickname}
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        </div>

        {/* Name + verification badge — NO online indicator or last-seen text */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span
            style={{
              fontSize: 22,
              fontWeight: 700,
              color: '#ffffff',
              letterSpacing: '-0.3px',
            }}
          >
            {nickname || user.nickname}
          </span>
          {user.is_verified && (
            <CheckCircle2
              size={20}
              color="#3b82f6"
              fill="#3b82f6"
              strokeWidth={0}
              aria-label="Verified"
            />
          )}
        </div>
        {/* Intentionally no online text or green dot here */}
      </div>

      {/* ── FOUR ACTION BUTTONS ─────────────────────────────────────────── */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-evenly',
          paddingInline: 12,
          paddingBottom: 28,
          background: '#0a0b10',
        }}
      >
        {/* Profile */}
        <button
          id="chat-details-profile-btn"
          onClick={() => setProfilePreviewUser(user)}
          style={actionBtnStyle}
          aria-label="View profile"
        >
          <div style={actionIconBg}>
            <User size={22} color="#ffffff" />
          </div>
          <span style={actionLabelStyle}>Profile</span>
        </button>

        {/* Search */}
        <button
          id="chat-details-search-btn"
          onClick={() => setActiveSheet('search')}
          style={actionBtnStyle}
          aria-label="Search messages"
        >
          <div style={actionIconBg}>
            <Search size={22} color="#ffffff" />
          </div>
          <span style={actionLabelStyle}>Search</span>
        </button>

        {/* Mute */}
        <button
          id="chat-details-mute-btn"
          onClick={() => setActiveSheet('mute')}
          style={actionBtnStyle}
          aria-label="Mute notifications"
        >
          <div
            style={{
              ...actionIconBg,
              background: isMuted ? 'rgba(255,45,85,0.25)' : 'rgba(255,255,255,0.12)',
            }}
          >
            <Bell size={22} color={isMuted ? '#ff4757' : '#ffffff'} />
          </div>
          <span style={actionLabelStyle}>Mute</span>
        </button>

        {/* Options */}
        <button
          id="chat-details-options-btn"
          onClick={() => setActiveSheet('options')}
          style={actionBtnStyle}
          aria-label="More options"
        >
          <div style={actionIconBg}>
            <MoreVertical size={22} color="#ffffff" />
          </div>
          <span style={actionLabelStyle}>Options</span>
        </button>
      </div>

      {/* ── SETTINGS LIST ─────────────────────────────────────────────────── */}
      <div
        style={{
          background: '#111318',
          paddingInline: 20,
          paddingTop: 4,
          paddingBottom: 4,
        }}
      >
        {/* Customise */}
        <SettingsRow
          id="chat-details-customise"
          icon={
            <GradientIconWrapper>
              <Palette size={22} color="#ffffff" />
            </GradientIconWrapper>
          }
          label="Customise"
          subtitle="Theme and font"
          onClick={() => setActiveSheet('customise')}
        />
        <Divider />

        {/* Disappearing messages */}
        <SettingsRow
          id="chat-details-disappearing"
          icon={
            <DarkIconWrapper>
              <Timer size={22} color="#ffffff" />
            </DarkIconWrapper>
          }
          label="Disappearing messages"
          subtitle={disappearingLabel}
          onClick={() => setActiveSheet('disappearing')}
        />
        <Divider />

        {/* Privacy and safety */}
        <SettingsRow
          id="chat-details-privacy"
          icon={
            <DarkIconWrapper>
              <Lock size={22} color="#ffffff" />
            </DarkIconWrapper>
          }
          label="Privacy and safety"
          onClick={() => setActiveSheet('privacy')}
        />
        <Divider />

        {/* Nicknames */}
        <SettingsRow
          id="chat-details-nicknames"
          icon={
            <DarkIconWrapper>
              <UserRound size={22} color="#ffffff" />
            </DarkIconWrapper>
          }
          label="Nicknames"
          onClick={() => setShowNicknameModal(true)}
        />
        <Divider />

        {/* Create a group chat */}
        <SettingsRow
          id="chat-details-group"
          icon={
            <DarkIconWrapper>
              <Users size={22} color="#ffffff" />
            </DarkIconWrapper>
          }
          label="Create a group chat"
          onClick={() =>
            showToast({ type: 'info', text: 'Group chat creation coming soon!' })
          }
        />
      </div>

      {/* ── SHARED MEDIA ───────────────────────────────────────────────────── */}
      <div
        style={{
          borderTop: '1px solid rgba(255,255,255,0.08)',
          paddingInline: 20,
          paddingTop: 22,
          paddingBottom: 40,
          background: '#0a0b10',
          flex: 1,
        }}
      >
        <h3
          style={{
            fontSize: 17,
            fontWeight: 700,
            color: '#ffffff',
            marginBottom: 16,
            margin: '0 0 16px 0',
          }}
        >
          Shared media
        </h3>

        {sharedImages.length > 0 ? (
          <div
            style={{
              display: 'flex',
              gap: 10,
              overflowX: 'auto',
              paddingBottom: 6,
              WebkitOverflowScrolling: 'touch',
            }}
          >
            {sharedImages.map((msg) => (
              <div
                key={msg.id}
                style={{
                  minWidth: 90,
                  height: 90,
                  borderRadius: 12,
                  overflow: 'hidden',
                  flexShrink: 0,
                  background: 'rgba(255,255,255,0.06)',
                  border: '1px solid rgba(255,255,255,0.1)',
                }}
              >
                <img
                  src={msg.media_url}
                  alt="Shared media"
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
              </div>
            ))}
          </div>
        ) : (
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 10,
              padding: '28px 0',
            }}
          >
            <ImageIcon size={40} color="rgba(255,255,255,0.18)" />
            <span style={{ fontSize: 14, color: 'rgba(255,255,255,0.35)' }}>
              No shared photos or videos yet
            </span>
          </div>
        )}
      </div>

      {/* ── BOTTOM SHEETS & MODALS ─────────────────────────────────────────── */}

      {/* Mute sheet */}
      {activeSheet === 'mute' && (
        <Sheet title="Mute notifications" onClose={() => setActiveSheet(null)}>
          {MUTE_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => handleMute(opt.value)}
              style={sheetItemStyle}
            >
              {opt.label}
            </button>
          ))}
        </Sheet>
      )}

      {/* Disappearing messages sheet */}
      {activeSheet === 'disappearing' && (
        <Sheet title="Disappearing messages" onClose={() => setActiveSheet(null)}>
          <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.45)', marginBottom: 14, lineHeight: 1.5 }}>
            New messages sent in this conversation will disappear after the selected time once seen.
          </p>
          {DISAPPEARING_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => handleDisappearing(opt.value)}
              style={{
                ...sheetItemStyle,
                color: disappearingMode === opt.value ? '#9b51e0' : '#fff',
                fontWeight: disappearingMode === opt.value ? 700 : 400,
              }}
            >
              <span style={{ flex: 1, textAlign: 'left' }}>{opt.label}</span>
              {disappearingMode === opt.value && <Check size={18} color="#9b51e0" />}
            </button>
          ))}
        </Sheet>
      )}

      {/* Privacy and safety sheet */}
      {activeSheet === 'privacy' && (
        <Sheet title="Privacy and safety" onClose={() => setActiveSheet(null)}>
          {[
            { label: `Block ${user.nickname}`, color: '#ff4757' },
            { label: `Report ${user.nickname}`, color: '#ffd700' },
            { label: `Restrict ${user.nickname}`, color: 'rgba(255,255,255,0.8)' },
          ].map((item) => (
            <button
              key={item.label}
              onClick={() => {
                setActiveSheet(null);
                showToast({ type: 'info', text: item.label });
              }}
              style={{ ...sheetItemStyle, color: item.color }}
            >
              {item.label}
            </button>
          ))}
        </Sheet>
      )}

      {/* Customise (Theme / Wallpaper) sheet */}
      {activeSheet === 'customise' && (
        <Sheet title="Customise chat" onClose={() => setActiveSheet(null)}>
          <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.45)', marginBottom: 14 }}>
            Choose a wallpaper theme for this conversation.
          </p>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10, paddingBottom: 8 }}>
            {WALLPAPER_THEMES.map((wp) => (
              <button
                key={wp.id}
                onClick={() => {
                  setChatWallpaper(conversation.id, wp.id);
                  setActiveSheet(null);
                  showToast({ type: 'success', text: `Theme set to ${wp.label}` });
                }}
                style={{
                  padding: '10px 18px',
                  borderRadius: 30,
                  background: wp.bg || 'rgba(255,255,255,0.08)',
                  backgroundImage: wp.gradient,
                  border: conversation.wallpaper === wp.id
                    ? '2px solid #9b51e0'
                    : '1px solid rgba(255,255,255,0.15)',
                  color: '#fff',
                  fontSize: 13,
                  fontWeight: 600,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 6,
                }}
              >
                {conversation.wallpaper === wp.id && <Check size={14} />}
                {wp.label}
              </button>
            ))}
          </div>
        </Sheet>
      )}

      {/* Search sheet */}
      {activeSheet === 'search' && (
        <Sheet title="Search messages" onClose={() => setActiveSheet(null)}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 0 16px' }}>
            <input
              type="text"
              autoFocus
              placeholder={`Search in conversation with ${user.nickname}...`}
              style={{
                flex: 1,
                background: 'rgba(255,255,255,0.07)',
                border: '1px solid rgba(255,255,255,0.15)',
                borderRadius: 10,
                padding: '10px 14px',
                color: '#fff',
                fontSize: 14,
                outline: 'none',
                width: '100%',
                boxSizing: 'border-box',
              }}
            />
          </div>
          <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.35)', textAlign: 'center' }}>
            Full-text search coming soon
          </p>
        </Sheet>
      )}

      {/* Options sheet */}
      {activeSheet === 'options' && (
        <Sheet title="Conversation options" onClose={() => setActiveSheet(null)}>
          {[
            {
              label: isMuted ? 'Unmute notifications' : 'Mute notifications',
              onClick: () => {
                toggleMuteChat(conversation.id);
                setIsMuted((prev) => !prev);
                setActiveSheet(null);
              },
              danger: false,
            },
            {
              label: 'Clear chat history',
              onClick: () => {
                setActiveSheet(null);
                showToast({ type: 'info', text: 'Use Options in the chat header to clear history' });
              },
              danger: false,
            },
            {
              label: `Block ${user.nickname}`,
              onClick: () => {
                setActiveSheet(null);
                showToast({ type: 'warning', text: 'Use Privacy & safety to block' });
              },
              danger: true,
            },
          ].map((item) => (
            <button
              key={item.label}
              onClick={item.onClick}
              style={{
                ...sheetItemStyle,
                color: item.danger ? '#ff4757' : '#fff',
              }}
            >
              {item.label}
            </button>
          ))}
        </Sheet>
      )}

      {/* Nickname Modal */}
      {showNicknameModal && (
        <NicknameModal
          currentName={user.nickname}
          nickname={nickname}
          onSave={(nick) => {
            setNickname(nick);
            showToast({
              type: 'success',
              text: nick ? `Nickname set to "${nick}"` : 'Nickname removed',
            });
          }}
          onClose={() => setShowNicknameModal(false)}
        />
      )}
    </div>
  );
};
