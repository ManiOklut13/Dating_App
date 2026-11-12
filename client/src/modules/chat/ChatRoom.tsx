import React, { useState, useRef, useEffect } from 'react';
import {
  ArrowLeft,
  Phone,
  Video,
  PhoneCall,
  MoreVertical,
  Send,
  Smile,
  Image as ImageIcon,
  Mic,
  MicOff,
  Sparkles,
  Calendar,
  CheckCheck,
  Check,
  Shield,
  ShieldAlert,
  Play,
  Pause,
  Plus,
  Flame,
  X,
  Sticker,
  Camera,
} from 'lucide-react';
import { useChat } from './ChatContext';
import { ChatConversation, ChatMessage } from './types';
import { ThreeDotMenu } from './ThreeDotMenu';
import { IcebreakerModal } from './IcebreakerModal';
import { WALLPAPER_THEMES } from './mockData';
import { WhatsAppPickerDrawer } from './WhatsAppPickerDrawer';
import { useCalls } from '../calls/CallsContext';
import { usePresence } from '../presence/PresenceContext';
import { PresenceDot, PresenceLabel } from '../presence/PresenceDot';

const POPULAR_EMOJIS = [
  '❤️', '🔥', '✨', '☕', '😍', '😂', '🥂', '🍕',
  '🌸', '🎶', '🙌', '💯', '😊', '🎉', '🌟', '👀',
  '😘', '🥰', '😎', '🤗', '😅', '😉', '🤩', '😭',
  '💖', '💫', '🌈', '🌻', '🍫', '🍷', '🎁', '💌',
];

const parseDuration = (value?: string): number => {
  if (!value) return 14;
  const parts = value.split(':').map((p) => Number(p));
  if (parts.length === 2) return parts[0] * 60 + (parts[1] || 0);
  if (parts.length === 3) return parts[0] * 3600 + parts[1] * 60 + (parts[2] || 0);
  return 14;
};

const formatAudioTime = (seconds: number): string => {
  const safe = Math.max(0, Math.round(seconds));
  const m = Math.floor(safe / 60);
  const s = safe % 60;
  return `${m}:${s < 10 ? '0' : ''}${s}`;
};

type PickerTab = 'none' | 'emoji' | 'bitmoji' | 'sticker' | 'gif';

interface ChatRoomProps {
  conversation: ChatConversation;
  onBack: () => void;
  onOpenDetails?: () => void;
}

export const ChatRoom: React.FC<ChatRoomProps> = ({ conversation, onBack, onOpenDetails }) => {
  const {
    activeMessages,
    sendMessage,
    setAudioCallTarget,
    setVideoCallTarget,
    setDatePlannerConv,
    setIcebreakerConv,
    setProfilePreviewUser,
    setIsScreenshotModalOpen,
    respondToDateInvite,
    showToast,
  } = useChat();

  // Single combined calling icon -> dedicated Calls page.
  const { navigate: navigateCalls } = useCalls();
  const { getStatus } = usePresence();

  const [inputText, setInputText] = useState('');
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isCallOptionsOpen, setIsCallOptionsOpen] = useState(false);
  const [isAttachMenuOpen, setIsAttachMenuOpen] = useState(false);
  const [activePickerTab, setActivePickerTab] = useState<PickerTab>('none');

  const MAX_PHOTOS = 5;
  const [pendingImages, setPendingImages] = useState<{ url: string; file: File }[]>([]);
  const [imageCaption, setImageCaption] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);
  const composerRef = useRef<HTMLFormElement>(null);
  const pickerRef = useRef<HTMLDivElement>(null);

  // Voice note simulated recording state
  const [isRecording, setIsRecording] = useState(false);
  const [recordingSeconds, setRecordingSeconds] = useState(0);

  // Audio player simulation state
  const [playingAudioId, setPlayingAudioId] = useState<string | null>(null);
  const [audioSpeed, setAudioSpeed] = useState<Record<string, string>>({});
  const [audioProgress, setAudioProgress] = useState<Record<string, number>>({});

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  // Focus the composer when a conversation opens so the keyboard pops up
  useEffect(() => {
    const timer = setTimeout(() => inputRef.current?.focus({ preventScroll: true }), 150);
    return () => clearTimeout(timer);
  }, [conversation.id]);

  // Scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [activeMessages]);

  // Keep the latest message visible when the picker opens/closes.
  useEffect(() => {
    const timer = window.setTimeout(() => {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, 220);
    return () => window.clearTimeout(timer);
  }, [activePickerTab]);

  // Voice recording timer
  useEffect(() => {
    let timer: any;
    if (isRecording) {
      timer = setInterval(() => {
        setRecordingSeconds((s) => s + 1);
      }, 1000);
    } else {
      setRecordingSeconds(0);
    }
    return () => clearInterval(timer);
  }, [isRecording]);

  const handleSendTextMessage = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    if (!inputText.trim()) return;

    const res = sendMessage(conversation.id, {
      type: 'text',
      body: inputText.trim(),
    });

    if (res.success) {
      setInputText('');
      setActivePickerTab('none');
    }
    // If not successful (e.g. link or profanity), inputText stays in composer so user can edit!
  };

  const handleInsertEmoji = (emoji: string) => {
    setInputText((prev) => prev + emoji);
  };

  const handleSendGif = (gifUrl: string) => {
    sendMessage(conversation.id, {
      type: 'gif',
      body: 'GIF animation',
      media_url: gifUrl,
    });
    setActivePickerTab('none');
  };

  const handleSendSticker = (sticker: { label: string; emoji: string }) => {
    sendMessage(conversation.id, {
      type: 'sticker',
      body: sticker.label,
      media_url: sticker.emoji,
    });
    setActivePickerTab('none');
  };

  const togglePicker = (tab: Exclude<PickerTab, 'none'>) => {
    setActivePickerTab((prev) => (prev === tab ? 'none' : tab));
    setIsAttachMenuOpen(false);
    if (activePickerTab !== tab) inputRef.current?.blur();
  };

  useEffect(() => {
    if (activePickerTab === 'none') return;

    const onPointerDown = (event: PointerEvent) => {
      const target = event.target as Node | null;
      if (!target) return;
      if (composerRef.current?.contains(target)) return;
      if (pickerRef.current?.contains(target)) return;
      setActivePickerTab('none');
    };

    document.addEventListener('pointerdown', onPointerDown);
    return () => document.removeEventListener('pointerdown', onPointerDown);
  }, [activePickerTab]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []).slice(0, MAX_PHOTOS);
    if (files.length > 0) {
      const picked = files.map((file) => ({ url: URL.createObjectURL(file), file }));
      setPendingImages(picked);
      setIsAttachMenuOpen(false);
    }
    // Reset so the same files can be picked again later
    e.target.value = '';
  };

  const handleRemovePendingImage = (index: number) => {
    setPendingImages((prev) => {
      const next = prev.filter((_, i) => i !== index);
      if (next.length === 0) setImageCaption('');
      return next;
    });
  };

  const handleConfirmImageUpload = () => {
    if (pendingImages.length === 0) return;
    const caption = imageCaption.trim() || 'Shared a photo';
    pendingImages.forEach((img) => {
      sendMessage(conversation.id, {
        type: 'image',
        body: caption,
        media_url: img.url,
      });
    });
    showToast({
      type: 'success',
      text: pendingImages.length === 1 ? 'Photo sent!' : `${pendingImages.length} photos sent!`,
    });
    setPendingImages([]);
    setImageCaption('');
  };

  const handleSendVoiceNote = () => {
    const duration = `0:${recordingSeconds < 10 ? '0' : ''}${recordingSeconds}`;
    sendMessage(conversation.id, {
      type: 'audio',
      body: `🎙️ Voice Note (${duration})`,
      audio_duration: duration,
    });
    setIsRecording(false);
    showToast({ type: 'success', text: 'Voice note sent!' });
  };

  const handleTogglePlayAudio = (msgId: string) => {
    if (playingAudioId === msgId) {
      setPlayingAudioId(null);
    } else {
      setPlayingAudioId(msgId);
      setAudioProgress((prev) => ({ ...prev, [msgId]: prev[msgId] ?? 0 }));
      setTimeout(() => {
        setPlayingAudioId(null);
        setAudioProgress((prev) => ({ ...prev, [msgId]: 1 }));
      }, 5000);
    }
  };

  useEffect(() => {
    if (!playingAudioId) return;
    const timer = window.setInterval(() => {
      setAudioProgress((prev) => {
        const current = prev[playingAudioId] ?? 0;
        if (current >= 1) {
          window.clearInterval(timer);
          setPlayingAudioId(null);
          return { ...prev, [playingAudioId]: 1 };
        }
        return { ...prev, [playingAudioId]: Math.min(1, current + 0.02) };
      });
    }, 100);
    return () => window.clearInterval(timer);
  }, [playingAudioId]);

  // Find active theme wallpaper
  const activeWallpaper =
    WALLPAPER_THEMES.find((w) => w.id === conversation.wallpaper) || WALLPAPER_THEMES[0];

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        minHeight: 0,
        background: '#0B0A10',
        position: 'relative',
        overflow: 'hidden',
        fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Hidden file input for attachment upload */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/*"
        multiple
        style={{ display: 'none' }}
      />

      {/* ================= HEADER ================= */}
      <div
        className="chat-room-header"
        style={{
          padding: '10px 14px',
          background: '#0B0A10',
          borderBottom: '1px solid #26212F',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '10px',
          flexShrink: 0,
          zIndex: 20,
          fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
        }}
      >
        {/* Left: Back button + User details */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0, flex: 1 }}>
          <button
            onClick={onBack}
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: '#1A1722',
              border: 'none',
              color: '#F5F2F7',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
            title="Back to Conversations"
            aria-label="Back"
          >
            <ArrowLeft size={20} />
          </button>

          {/* User Avatar */}
          <div
            onClick={onOpenDetails || (() => setProfilePreviewUser(conversation.counterpart))}
            style={{ position: 'relative', width: '44px', height: '44px', cursor: 'pointer', flexShrink: 0 }}
          >
            <img
              src={conversation.counterpart.avatar}
              alt={conversation.counterpart.nickname}
              style={{
                width: '100%',
                height: '100%',
                borderRadius: '50%',
                objectFit: 'cover',
              }}
            />
            <div style={{ position: 'absolute', bottom: '0px', right: '0px' }}>
              <PresenceDot userId={conversation.counterpart.id} size={10} />
            </div>
          </div>

          {/* User Name & Status */}
          <div
            onClick={onOpenDetails || (() => setProfilePreviewUser(conversation.counterpart))}
            style={{ cursor: 'pointer', minWidth: 0 }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', minWidth: 0 }}>
              <span
                style={{
                  fontWeight: 800,
                  fontSize: '16px',
                  color: '#F5F2F7',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {conversation.counterpart.nickname}
              </span>
              {conversation.counterpart.is_verified && <span className="badge-blue-tick" style={{ flexShrink: 0 }}>✓</span>}
            </div>
            <div style={{ fontSize: '12px', color: '#B3AEC0', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {getStatus(conversation.counterpart.id) === 'online' ? 'Online' : (conversation.counterpart.last_seen ? `Last seen ${conversation.counterpart.last_seen}` : 'Last seen recently')}
            </div>
          </div>
        </div>

        {/* Right: Call and Calendar buttons */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexShrink: 0 }}>
          <button
            onClick={() => navigateCalls({ name: 'calls' })}
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: '#1A1722',
              border: 'none',
              color: '#4ADE80',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
            title="Call"
            aria-label="Call"
          >
            <PhoneCall size={20} />
          </button>

          <button
            onClick={() => setDatePlannerConv(conversation)}
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: '#1A1722',
              border: 'none',
              color: '#FFC93C',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
            title="Plan a Date"
            aria-label="Plan a date"
          >
            <Calendar size={20} />
          </button>

          <button
            onClick={() => setIsMenuOpen(true)}
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: '#1A1722',
              border: 'none',
              color: '#F5F2F7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
            }}
            title="More"
            aria-label="More options"
          >
            <MoreVertical size={20} />
          </button>
        </div>
      </div>

      {/* ================= SECURITY GUARD RIBBON ================= */}
      <div style={{ padding: '8px 14px', flexShrink: 0 }}>
        <div
          style={{
            padding: '8px 12px',
            background: '#2A1220',
            borderRadius: '12px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '8px',
            fontSize: '11px',
            color: '#FFB3C7',
            fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', minWidth: 0 }}>
            <Shield size={16} color="#FF3D77" style={{ flexShrink: 0 }} />
            <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              Trust Guard: Stay safe while chatting
            </span>
          </div>

          <button
            onClick={() => setIsScreenshotModalOpen(true)}
            style={{
              background: 'rgba(255, 61, 119, 0.2)',
              border: '1px solid rgba(255, 61, 119, 0.4)',
              color: '#FFB3C7',
              padding: '4px 8px',
              borderRadius: '999px',
              fontSize: '10px',
              fontWeight: 700,
              cursor: 'pointer',
              flexShrink: 0,
              whiteSpace: 'nowrap',
            }}
            title="Screenshot Guard"
          >
            Screenshot Guard
          </button>
        </div>
      </div>

      {/* ================= MESSAGES STREAM ================= */}
      <div
        onClick={() => {
          if (activePickerTab !== 'none') {
            setActivePickerTab('none');
            return;
          }
          inputRef.current?.focus();
        }}
        style={{
          flex: 1,
          minHeight: 0,
          overflowY: 'auto',
          overflowX: 'hidden',
          padding: '16px',
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
          WebkitOverflowScrolling: 'touch',
        }}
      >
        {activeMessages.map((msg) => {
          const isMe = msg.sender_id === 'me';
          const isSystem = msg.sender_id === 'system';

          // System message banner (e.g. It's a match!)
          if (isSystem) {
            return (
              <div
                key={msg.id}
                style={{
                  alignSelf: 'center',
                  maxWidth: 'min(85%, 560px)',
                  padding: '10px 18px',
                  borderRadius: 'var(--radius-full)',
                  background: 'rgba(255, 45, 85, 0.12)',
                  border: '1px solid rgba(255, 45, 85, 0.35)',
                  color: 'var(--text-primary)',
                  fontSize: '12px',
                  fontWeight: 600,
                  textAlign: 'center',
                  margin: '8px 0',
                  boxShadow: 'var(--shadow-sm)',
                }}
              >
                {msg.body}
              </div>
            );
          }

          return (
            <div
              key={msg.id}
              style={{
                alignSelf: isMe ? 'flex-end' : 'flex-start',
                maxWidth: 'min(80%, 520px)',
                minWidth: 0,
                display: 'flex',
                flexDirection: 'column',
                alignItems: isMe ? 'flex-end' : 'flex-start',
              }}
            >
              {/* Message Bubble Container */}
              <div
                style={{
                  borderRadius: '18px',
                  borderTopRightRadius: isMe ? '6px' : '18px',
                  borderTopLeftRadius: !isMe ? '6px' : '18px',
                  background: isMe
                    ? 'linear-gradient(135deg, #FF3D77 0%, #B45CFF 100%)'
                    : '#1E1A28',
                  color: '#F5F2F7',
                  fontSize: '14px',
                  lineHeight: 1.4,
                  padding: msg.type === 'image' ? '4px' : '10px 14px',
                  overflow: 'hidden',
                  maxWidth: '75%',
                  minWidth: 0,
                  overflowWrap: 'anywhere',
                  wordBreak: 'break-word',
                }}
              >
                {/* 1. TEXT */}
                {msg.type === 'text' && <div>{msg.body}</div>}

                {/* 2. IMAGE */}
                {msg.type === 'image' && (
                  <div>
                    <img
                      src={msg.media_url}
                      alt="Shared media"
                      style={{
                        width: '100%',
                        maxHeight: '260px',
                        objectFit: 'cover',
                        borderRadius: '14px',
                        display: 'block',
                      }}
                    />
                    {msg.body && msg.body !== 'Shared a photo' && (
                      <div style={{ padding: '8px 10px', fontSize: '13px' }}>{msg.body}</div>
                    )}
                  </div>
                )}

                {/* 3. GIF */}
                {msg.type === 'gif' && (
                  <div style={{ position: 'relative' }}>
                    <img
                      src={msg.media_url}
                      alt="GIF"
                      style={{
                        width: '100%',
                        maxHeight: '220px',
                        objectFit: 'cover',
                        borderRadius: '14px',
                        display: 'block',
                      }}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        bottom: '6px',
                        left: '6px',
                        background: 'rgba(0,0,0,0.6)',
                        padding: '2px 6px',
                        borderRadius: '4px',
                        fontSize: '9px',
                        fontWeight: 700,
                      }}
                    >
                      GIF
                    </div>
                  </div>
                )}

                {/* 4. VOICE NOTE */}
                {msg.type === 'audio' && (
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '10px',
                      minWidth: 'min(260px, 72vw)',
                      padding: '4px 2px',
                    }}
                  >
                    {/* Avatar */}
                    <div
                      style={{
                        width: '34px',
                        height: '34px',
                        borderRadius: '50%',
                        flexShrink: 0,
                        overflow: 'hidden',
                        border: `2px solid ${isMe ? 'rgba(255,255,255,0.4)' : 'var(--border-glass)'}`,
                      }}
                    >
                      <img
                        src={isMe ? '/aditya.jpg' : conversation.counterpart.avatar}
                        alt=""
                        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                      />
                    </div>

                    {/* Play / Pause */}
                    <button
                      onClick={() => handleTogglePlayAudio(msg.id)}
                      style={{
                        width: '36px',
                        height: '36px',
                        borderRadius: '50%',
                        background: isMe ? '#ffffff' : 'var(--gradient-flame)',
                        color: isMe ? '#ff2d55' : '#ffffff',
                        border: 'none',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        cursor: 'pointer',
                        flexShrink: 0,
                        boxShadow: isMe ? '0 2px 6px rgba(0,0,0,0.25)' : 'var(--shadow-glow)',
                      }}
                    >
                      {playingAudioId === msg.id ? <Pause size={16} /> : <Play size={16} style={{ marginLeft: '2px' }} />}
                    </button>

                    {/* Waveform + duration */}
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '2px',
                          height: '24px',
                          cursor: 'pointer',
                        }}
                        onClick={(e) => {
                          const rect = e.currentTarget.getBoundingClientRect();
                          const ratio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
                          setAudioProgress((prev) => ({ ...prev, [msg.id]: ratio }));
                          if (playingAudioId !== msg.id) handleTogglePlayAudio(msg.id);
                        }}
                      >
                        {[8, 14, 18, 12, 16, 9, 14, 17, 10, 13, 8, 15, 11, 19, 7].map((h, i, arr) => {
                          const progress = audioProgress[msg.id] ?? 0;
                          const filled = i / arr.length <= progress;
                          return (
                            <span
                              key={i}
                              style={{
                                flex: 1,
                                height: `${playingAudioId === msg.id ? Math.max(6, h + (i % 3) * 3) : h}px`,
                                borderRadius: '2px',
                                background: filled
                                  ? isMe
                                    ? 'rgba(255,255,255,0.95)'
                                    : '#ffffff'
                                  : isMe
                                    ? 'rgba(255,255,255,0.35)'
                                    : 'rgba(255,255,255,0.3)',
                                transition: 'background 0.15s ease, height 0.15s ease',
                              }}
                            />
                          );
                        })}
                      </div>
                      <div style={{ fontSize: '10px', opacity: 0.85, marginTop: '3px', fontFamily: 'monospace' }}>
                        {playingAudioId === msg.id
                          ? `${formatAudioTime((audioProgress[msg.id] ?? 0) * parseDuration(msg.audio_duration))} / ${msg.audio_duration || '0:14'}`
                          : msg.audio_duration || '0:14'}
                      </div>
                    </div>

                    {/* Playback speed */}
                    <button
                      onClick={() =>
                        setAudioSpeed((prev) => {
                          const cur = prev[msg.id] || '1x';
                          const next = cur === '1x' ? '1.5x' : cur === '1.5x' ? '2x' : '1x';
                          return { ...prev, [msg.id]: next };
                        })
                      }
                      style={{
                        fontSize: '10px',
                        fontWeight: 800,
                        color: isMe ? '#ff2d55' : '#ffffff',
                        background: isMe ? 'rgba(255,255,255,0.85)' : 'rgba(255,255,255,0.15)',
                        border: 'none',
                        borderRadius: 'var(--radius-full)',
                        padding: '3px 6px',
                        cursor: 'pointer',
                        flexShrink: 0,
                      }}
                    >
                      {audioSpeed[msg.id] || '1x'}
                    </button>
                  </div>
                )}

                {/* 5. STICKER */}
                {msg.type === 'sticker' && (
                  <div style={{ padding: '4px 6px', textAlign: 'center' }}>
                    <div style={{ fontSize: '38px', marginBottom: '4px' }}>
                      {msg.media_url || '💖'}
                    </div>
                    <div style={{ fontSize: '12px', fontWeight: 700 }}>{msg.body}</div>
                  </div>
                )}

                {/* 6. ICEBREAKER CARD */}
                {msg.type === 'icebreaker' && (
                  <div style={{ padding: '4px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '10px', color: '#ffd700', fontWeight: 700, textTransform: 'uppercase', marginBottom: '4px' }}>
                      <Sparkles size={12} />
                      <span>Icebreaker Prompt</span>
                    </div>
                    <div style={{ fontSize: '13px', fontWeight: 700, marginBottom: '6px' }}>
                      "{msg.icebreaker_prompt?.question || msg.body}"
                    </div>
                    {msg.icebreaker_prompt?.answer && (
                      <div
                        style={{
                          fontSize: '12px',
                          color: 'rgba(255,255,255,0.9)',
                          background: 'rgba(0,0,0,0.2)',
                          padding: '6px 8px',
                          borderRadius: '8px',
                        }}
                      >
                        {msg.icebreaker_prompt.answer}
                      </div>
                    )}
                  </div>
                )}

                {/* 7. DATE INVITATION CARD */}
                {msg.type === 'date_invite' && msg.date_invite && (
                  <div style={{ minWidth: 'min(220px, 72vw)', padding: '6px 2px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: '#ffd700', fontWeight: 800, textTransform: 'uppercase', marginBottom: '6px' }}>
                      <Calendar size={13} />
                      <span>Official Date Invitation</span>
                    </div>

                    <div style={{ fontSize: '14px', fontWeight: 800, marginBottom: '4px' }}>
                      {msg.date_invite.activity}
                    </div>

                    <div style={{ fontSize: '12px', color: 'rgba(255,255,255,0.85)', marginBottom: '2px' }}>
                      📅 {msg.date_invite.date} • ⏰ {msg.date_invite.time}
                    </div>

                    {msg.date_invite.location && (
                      <div style={{ fontSize: '11px', color: 'var(--cyan-vibe)', marginBottom: '10px' }}>
                        📍 {msg.date_invite.location}
                      </div>
                    )}

                    {/* Status / Response Buttons */}
                    {msg.date_invite.status === 'accepted' ? (
                      <div
                        style={{
                          background: 'rgba(0, 230, 118, 0.2)',
                          border: '1px solid #00e676',
                          color: '#00e676',
                          padding: '6px 10px',
                          borderRadius: 'var(--radius-sm)',
                          fontSize: '11px',
                          fontWeight: 700,
                          textAlign: 'center',
                        }}
                      >
                        ✓ Date Confirmed & Accepted! 🎉
                      </div>
                    ) : msg.date_invite.status === 'declined' ? (
                      <div
                        style={{
                          background: 'rgba(255, 71, 87, 0.2)',
                          border: '1px solid #ff4757',
                          color: '#ff4757',
                          padding: '6px 10px',
                          borderRadius: 'var(--radius-sm)',
                          fontSize: '11px',
                          fontWeight: 700,
                          textAlign: 'center',
                        }}
                      >
                        Date Declined
                      </div>
                    ) : (
                      <div style={{ display: 'flex', gap: '6px', marginTop: '8px' }}>
                        <button
                          onClick={() => respondToDateInvite(conversation.id, msg.id, true)}
                          style={{
                            flex: 1,
                            background: '#00e676',
                            border: 'none',
                            color: '#000000',
                            padding: '6px',
                            borderRadius: 'var(--radius-sm)',
                            fontSize: '11px',
                            fontWeight: 700,
                            cursor: 'pointer',
                          }}
                        >
                          Accept Date 🎉
                        </button>
                        <button
                          onClick={() => respondToDateInvite(conversation.id, msg.id, false)}
                          style={{
                            background: 'var(--surface-hover)',
                            border: '1px solid var(--border-glass)',
                            color: 'var(--text-primary)',
                            padding: '6px 10px',
                            borderRadius: 'var(--radius-sm)',
                            fontSize: '11px',
                            cursor: 'pointer',
                          }}
                        >
                          Decline
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Timestamp & Read Receipts */}
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  marginTop: '4px',
                  fontSize: '10px',
                  color: 'var(--text-muted)',
                }}
              >
                <span>
                  {new Date(msg.created_at).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </span>
                {isMe && (
                  <span>
                    {msg.status === 'read' ? (
                      <CheckCheck size={12} color="#00e5ff" />
                    ) : (
                      <Check size={12} />
                    )}
                  </span>
                )}
                {msg.vanish_seconds && (
                  <span style={{ color: '#ff2d55', display: 'flex', alignItems: 'center', gap: '2px' }}>
                    <Flame size={10} /> vanish
                  </span>
                )}
              </div>
            </div>
          );
        })}
        <div ref={messagesEndRef} />
      </div>

      {/* ================= IMAGE PREVIEW MODAL BEFORE SEND ================= */}
      {pendingImages.length > 0 && (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'var(--bg-dark)',
            zIndex: 40,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            padding: '20px',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '15px', fontWeight: 700 }}>
              Preview Photos
              <span style={{ marginLeft: '8px', fontSize: '12px', color: 'var(--text-muted)' }}>
                {pendingImages.length}/{MAX_PHOTOS}
              </span>
            </span>
            <button
              onClick={() => {
                setPendingImages([]);
                setImageCaption('');
              }}
              style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', cursor: 'pointer' }}
            >
              <X size={20} />
            </button>
          </div>

          <div
            style={{
              flex: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '16px',
              minHeight: 0,
            }}
          >
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: pendingImages.length === 1 ? '1fr' : 'repeat(2, 1fr)',
                gap: '10px',
                width: '100%',
                maxWidth: '420px',
                maxHeight: '60vh',
                overflowY: 'auto',
              }}
            >
              {pendingImages.map((img, index) => (
                <div
                  key={img.url}
                  style={{ position: 'relative', borderRadius: 'var(--radius-md)', overflow: 'hidden', aspectRatio: '1 / 1' }}
                >
                  <img
                    src={img.url}
                    alt={`Preview ${index + 1}`}
                    style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}
                  />
                  <button
                    type="button"
                    onClick={() => handleRemovePendingImage(index)}
                    aria-label={`Remove photo ${index + 1}`}
                    style={{
                      position: 'absolute',
                      top: '6px',
                      right: '6px',
                      width: '24px',
                      height: '24px',
                      borderRadius: '50%',
                      background: 'rgba(0, 0, 0, 0.65)',
                      border: '1px solid rgba(255, 255, 255, 0.25)',
                      color: '#ffffff',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                      padding: 0,
                    }}
                  >
                    <X size={13} />
                  </button>
                </div>
              ))}
            </div>
          </div>

          <div style={{ display: 'flex', gap: '10px' }}>
            <input
              type="text"
              value={imageCaption}
              onChange={(e) => setImageCaption(e.target.value)}
              placeholder="Add a caption..."
              style={{
                flex: 1,
                padding: '12px 16px',
                borderRadius: 'var(--radius-full)',
                background: 'var(--surface-strong)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-primary)',
                outline: 'none',
                fontSize: '13px',
              }}
            />
            <button
              onClick={handleConfirmImageUpload}
              className="btn-primary"
              style={{ padding: '12px 20px', borderRadius: 'var(--radius-full)', whiteSpace: 'nowrap' }}
            >
              <Send size={16} />
              Send {pendingImages.length === 1 ? 'Photo' : `${pendingImages.length} Photos`}
            </button>
          </div>
        </div>
      )}

      {/* ================= VOICE RECORDING BAR SIMULATION ================= */}
      {isRecording && (
        <div
          style={{
            padding: '12px 16px',
            background: 'rgba(255, 45, 85, 0.15)',
            borderTop: '1px solid #ff2d55',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            zIndex: 30,
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div
              style={{
                width: '12px',
                height: '12px',
                borderRadius: '50%',
                background: '#ff2d55',
                animation: 'pulseGlow 1s infinite ease-in-out',
              }}
            />
            <span style={{ fontSize: '13px', fontWeight: 700, color: 'var(--text-primary)' }}>
              Recording Audio Note: 0:{recordingSeconds < 10 ? '0' : ''}{recordingSeconds}
            </span>
          </div>

          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => setIsRecording(false)}
              className="btn-ghost"
              style={{ padding: '6px 12px', fontSize: '12px' }}
            >
              Cancel
            </button>
            <button
              onClick={handleSendVoiceNote}
              className="btn-primary"
              style={{ padding: '6px 16px', fontSize: '12px', gap: '4px' }}
            >
              <Send size={13} />
              Send
            </button>
          </div>
        </div>
      )}

      {/* Attachment Menu */}
      {isAttachMenuOpen && (
        <>
          <div
            onClick={() => setIsAttachMenuOpen(false)}
            style={{
              position: 'absolute',
              inset: 0,
              background: 'rgba(0,0,0,0.5)',
              zIndex: 40,
            }}
          />
          <div
            style={{
              position: 'absolute',
              left: 0,
              right: 0,
              bottom: 0,
              background: '#12101A',
              borderTop: '1px solid #26212F',
              borderRadius: '20px 20px 0 0',
              padding: '16px',
              display: 'flex',
              flexDirection: 'column',
              gap: '10px',
              zIndex: 50,
              fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
            }}
          >
            <div style={{ width: '40px', height: '4px', borderRadius: '999px', background: '#3a3046', alignSelf: 'center', marginBottom: '4px' }} />
            <button
              onClick={() => {
                setIsAttachMenuOpen(false);
                sendMessage(conversation.id, {
                  type: 'image',
                  body: '📸 Camera photo',
                  media_url: '/ananya.jpg',
                });
                showToast({ type: 'success', text: 'Photo sent!' });
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                width: '100%',
                height: '56px',
                padding: '0 16px',
                borderRadius: '16px',
                background: '#2B1520',
                border: 'none',
                color: '#FF7A9C',
                fontSize: '14px',
                fontWeight: 700,
                cursor: 'pointer',
                textAlign: 'left',
              }}
            >
              <Camera size={20} />
              <span>Camera</span>
            </button>

            <button
              onClick={() => {
                setIsAttachMenuOpen(false);
                fileInputRef.current?.click();
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                width: '100%',
                height: '56px',
                padding: '0 16px',
                borderRadius: '16px',
                background: '#241A38',
                border: 'none',
                color: '#C58BFF',
                fontSize: '14px',
                fontWeight: 700,
                cursor: 'pointer',
                textAlign: 'left',
              }}
            >
              <ImageIcon size={20} />
              <span>Photos and videos</span>
            </button>

            <button
              onClick={() => {
                setIsAttachMenuOpen(false);
                setDatePlannerConv(conversation);
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                width: '100%',
                height: '56px',
                padding: '0 16px',
                borderRadius: '16px',
                background: '#2A2410',
                border: 'none',
                color: '#FFC93C',
                fontSize: '14px',
                fontWeight: 700,
                cursor: 'pointer',
                textAlign: 'left',
              }}
            >
              <Calendar size={20} />
              <span>Plan a date</span>
            </button>

            <button
              onClick={() => {
                setIsAttachMenuOpen(false);
                setIsRecording(true);
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                width: '100%',
                height: '56px',
                padding: '0 16px',
                borderRadius: '16px',
                background: '#10271D',
                border: 'none',
                color: '#4ADE80',
                fontSize: '14px',
                fontWeight: 700,
                cursor: 'pointer',
                textAlign: 'left',
              }}
            >
              <Mic size={20} />
              <span>Voice note</span>
            </button>
          </div>
        </>
      )}

      {/* ================= CALL OPTIONS SHEET ================= */}
      {isCallOptionsOpen && (
        <>
          {/* Backdrop */}
          <div
            onClick={() => setIsCallOptionsOpen(false)}
            style={{
              position: 'absolute',
              inset: 0,
              background: 'rgba(0, 0, 0, 0.55)',
              backdropFilter: 'blur(4px)',
              zIndex: 50,
            }}
            aria-hidden="true"
          />

          {/* Bottom Sheet */}
          <div
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              zIndex: 51,
              background: 'var(--bg-dark)',
              backdropFilter: 'blur(24px)',
              borderTop: '1px solid var(--surface-hover)',
              borderRadius: '20px 20px 0 0',
              padding: '0 20px 28px',
              boxShadow: '0 -8px 40px rgba(0,0,0,0.6)',
              animation: 'slideUpSheet 0.22s cubic-bezier(0.34,1.56,0.64,1)',
            }}
            role="dialog"
            aria-label="Call options"
          >
            {/* Drag handle */}
            <div
              style={{
                width: '36px',
                height: '4px',
                borderRadius: '2px',
                background: 'rgba(255,255,255,0.2)',
                margin: '12px auto 20px',
              }}
            />

            {/* Header row */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: '20px',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <img
                  src={conversation.counterpart.avatar}
                  alt={conversation.counterpart.nickname}
                  style={{
                    width: '38px',
                    height: '38px',
                    borderRadius: '50%',
                    objectFit: 'cover',
                    border: '2px solid #ff2d55',
                  }}
                />
                <div>
                  <div style={{ fontWeight: 800, fontSize: '15px', color: 'var(--text-primary)' }}>
                    {conversation.counterpart.nickname}
                  </div>
                  <div
                    style={{
                      fontSize: '11px',
                      color: conversation.counterpart.is_online ? '#00e676' : 'var(--text-muted)',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '4px',
                    }}
                  >
                    {conversation.counterpart.is_online && (
                      <span
                        style={{
                          width: '6px',
                          height: '6px',
                          borderRadius: '50%',
                          background: '#00e676',
                          display: 'inline-block',
                        }}
                      />
                    )}
                    {conversation.counterpart.is_online
                      ? 'Active now'
                      : `Last seen ${conversation.counterpart.last_seen || 'recently'}`}
                  </div>
                </div>
              </div>
              <button
                onClick={() => setIsCallOptionsOpen(false)}
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.08)',
                  border: '1px solid rgba(255,255,255,0.12)',
                  color: 'var(--text-secondary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
                aria-label="Close call options"
              >
                <X size={16} />
              </button>
            </div>

            {/* Call option cards */}
            <div style={{ display: 'flex', gap: '12px' }}>
              {/* Audio Call */}
              <button
                onClick={() => {
                  setIsCallOptionsOpen(false);
                  setAudioCallTarget(conversation);
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '20px 16px',
                  borderRadius: '16px',
                  background: 'rgba(0, 229, 255, 0.08)',
                  border: '1px solid rgba(0, 229, 255, 0.25)',
                  color: '#00e5ff',
                  cursor: 'pointer',
                  transition: 'all 0.18s ease',
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(0,229,255,0.16)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(0,229,255,0.5)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-2px)';
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(0,229,255,0.08)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(0,229,255,0.25)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)';
                }}
                title="Audio Call"
              >
                <div
                  style={{
                    width: '52px',
                    height: '52px',
                    borderRadius: '50%',
                    background: 'rgba(0, 229, 255, 0.15)',
                    border: '1.5px solid rgba(0, 229, 255, 0.4)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Phone size={22} color="#00e5ff" />
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--text-primary)' }}>Audio Call</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>Voice only</div>
                </div>
              </button>

              {/* Video Call */}
              <button
                onClick={() => {
                  setIsCallOptionsOpen(false);
                  setVideoCallTarget(conversation);
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '20px 16px',
                  borderRadius: '16px',
                  background: 'rgba(255, 45, 85, 0.08)',
                  border: '1px solid rgba(255, 45, 85, 0.25)',
                  color: '#ff2d55',
                  cursor: 'pointer',
                  transition: 'all 0.18s ease',
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255,45,85,0.16)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(255,45,85,0.5)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-2px)';
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255,45,85,0.08)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(255,45,85,0.25)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)';
                }}
                title="Video Call"
              >
                <div
                  style={{
                    width: '52px',
                    height: '52px',
                    borderRadius: '50%',
                    background: 'rgba(255, 45, 85, 0.15)',
                    border: '1.5px solid rgba(255, 45, 85, 0.4)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Video size={22} color="#ff2d55" />
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--text-primary)' }}>Video Call</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>Camera + voice</div>
                </div>
              </button>
            </div>

            {/* Cancel row */}
            <button
              onClick={() => setIsCallOptionsOpen(false)}
              style={{
                width: '100%',
                marginTop: '14px',
                padding: '12px',
                borderRadius: '12px',
                background: 'var(--surface-muted)',
                border: '1px solid var(--surface-hover)',
                color: 'var(--text-secondary)',
                fontSize: '14px',
                fontWeight: 600,
                cursor: 'pointer',
                transition: 'background 0.15s',
              }}
            >
              Cancel
            </button>
          </div>
        </>
      )}

      {/* ================= THREE-DOT MENU MODAL ================= */}
      <ThreeDotMenu
        conversation={conversation}
        isOpen={isMenuOpen}
        onClose={() => setIsMenuOpen(false)}
      />

      {/* Icebreaker Prompts Sheet */}
      <IcebreakerModal
        onInsertToInput={(prompt) => {
          setInputText(prompt);
        }}
      />
      {/* ================= COMPOSER BAR ================= */}
      <form
        ref={composerRef}
        onSubmit={handleSendTextMessage}
        className="chat-composer"
        style={{
          padding: '10px 14px',
          background: '#0B0A10',
          borderTop: '1px solid #26212F',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          flexShrink: 0,
          zIndex: 30,
          fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
        }}
      >
        {/* Attachment (+) Button */}
        <button
          type="button"
          onClick={() => {
            setIsAttachMenuOpen((value) => !value);
            setActivePickerTab('none');
          }}
          style={{
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            background: 'linear-gradient(135deg, #FF3D77 0%, #B45CFF 100%)',
            border: 'none',
            color: '#F5F2F7',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            flexShrink: 0,
          }}
          title="Add"
          aria-label="Add"
        >
          <Plus size={20} />
        </button>

        {/* Text Input */}
        <div
          style={{
            flex: 1,
            minWidth: 0,
            display: 'flex',
            alignItems: 'center',
            background: '#1A1722',
            borderRadius: '999px',
            height: '44px',
            padding: '0 14px',
          }}
        >
          <input
            type="text"
            ref={inputRef}
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onFocus={() => setActivePickerTab('none')}
            placeholder="Type a message"
            style={{
              flex: 1,
              minWidth: 0,
              background: 'transparent',
              border: 'none',
              color: '#F5F2F7',
              fontSize: '14px',
              outline: 'none',
              fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif",
            }}
          />
        </div>

        {/* Emoji Picker Button */}
        <button
          type="button"
          onClick={() => togglePicker('emoji')}
          style={{
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            background: '#1A1722',
            border: 'none',
            color: '#B3AEC0',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            flexShrink: 0,
          }}
          title="Emoji"
          aria-label="Emoji"
        >
          <Smile size={20} />
        </button>

        {/* Sticker Logo Button */}
        <button
          type="button"
          onClick={() => togglePicker('sticker')}
          style={{
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            background: '#1A1722',
            border: 'none',
            color: '#B3AEC0',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            flexShrink: 0,
          }}
          title="Sticker"
          aria-label="Sticker"
        >
          <Sticker size={20} />
        </button>

        {/* Voice Note Button or Send Button */}
        {inputText.trim() ? (
          <button
            type="submit"
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, #FF3D77 0%, #B45CFF 100%)',
              border: 'none',
              color: '#F5F2F7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              flexShrink: 0,
            }}
            title="Send"
            aria-label="Send"
          >
            <Send size={18} />
          </button>
        ) : (
          <button
            type="button"
            onClick={() => setIsRecording(true)}
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '50%',
              background: '#1A1722',
              border: 'none',
              color: '#F5F2F7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              flexShrink: 0,
            }}
            title="Voice note"
            aria-label="Voice note"
          >
            <Mic size={20} />
          </button>
        )}
      </form>

      {/* ================= CHAT PICKER DRAWER (EMOJI / STICKER / GIF) ================= */}
      <div
        ref={pickerRef}
        className={`chat-picker-drawer${activePickerTab !== 'none' ? ' open' : ''}`}
        style={{ zIndex: 30 }}
      >
        <WhatsAppPickerDrawer
          activeTab={activePickerTab === 'none' ? 'emoji' : activePickerTab}
          onTabChange={(tab) => setActivePickerTab(tab)}
          emojis={POPULAR_EMOJIS}
          onInsertEmoji={handleInsertEmoji}
          onSendSticker={handleSendSticker}
          onSendGif={handleSendGif}
        />
      </div>

      {/* ================= CALL OPTIONS SHEET ================= */}
      {isCallOptionsOpen && (
        <>
          {/* Backdrop */}
          <div
            onClick={() => setIsCallOptionsOpen(false)}
            style={{
              position: 'absolute',
              inset: 0,
              background: 'rgba(0, 0, 0, 0.55)',
              backdropFilter: 'blur(4px)',
              zIndex: 50,
            }}
            aria-hidden="true"
          />

          {/* Bottom Sheet */}
          <div
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0,
              zIndex: 51,
              background: 'var(--bg-dark)',
              backdropFilter: 'blur(24px)',
              borderTop: '1px solid var(--surface-hover)',
              borderRadius: '20px 20px 0 0',
              padding: '0 20px 28px',
              boxShadow: '0 -8px 40px rgba(0,0,0,0.6)',
              animation: 'slideUpSheet 0.22s cubic-bezier(0.34,1.56,0.64,1)',
            }}
            role="dialog"
            aria-label="Call options"
          >
            {/* Drag handle */}
            <div
              style={{
                width: '36px',
                height: '4px',
                borderRadius: '2px',
                background: 'rgba(255,255,255,0.2)',
                margin: '12px auto 20px',
              }}
            />

            {/* Header row */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: '20px',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <img
                  src={conversation.counterpart.avatar}
                  alt={conversation.counterpart.nickname}
                  style={{
                    width: '38px',
                    height: '38px',
                    borderRadius: '50%',
                    objectFit: 'cover',
                    border: '2px solid #ff2d55',
                  }}
                />
                <div>
                  <div style={{ fontWeight: 800, fontSize: '15px', color: 'var(--text-primary)' }}>
                    {conversation.counterpart.nickname}
                  </div>
                  <div
                    style={{
                      fontSize: '11px',
                      color: conversation.counterpart.is_online ? '#00e676' : 'var(--text-muted)',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '4px',
                    }}
                  >
                    {conversation.counterpart.is_online && (
                      <span
                        style={{
                          width: '6px',
                          height: '6px',
                          borderRadius: '50%',
                          background: '#00e676',
                          display: 'inline-block',
                        }}
                      />
                    )}
                    {conversation.counterpart.is_online
                      ? 'Active now'
                      : `Last seen ${conversation.counterpart.last_seen || 'recently'}`}
                  </div>
                </div>
              </div>
              <button
                onClick={() => setIsCallOptionsOpen(false)}
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.08)',
                  border: '1px solid rgba(255,255,255,0.12)',
                  color: 'var(--text-secondary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
                aria-label="Close call options"
              >
                <X size={16} />
              </button>
            </div>

            {/* Call option cards */}
            <div style={{ display: 'flex', gap: '12px' }}>
              {/* Audio Call */}
              <button
                onClick={() => {
                  setIsCallOptionsOpen(false);
                  setAudioCallTarget(conversation);
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '20px 16px',
                  borderRadius: '16px',
                  background: 'rgba(0, 229, 255, 0.08)',
                  border: '1px solid rgba(0, 229, 255, 0.25)',
                  color: '#00e5ff',
                  cursor: 'pointer',
                  transition: 'all 0.18s ease',
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(0,229,255,0.16)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(0,229,255,0.5)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-2px)';
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(0,229,255,0.08)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(0,229,255,0.25)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)';
                }}
                title="Audio Call"
              >
                <div
                  style={{
                    width: '52px',
                    height: '52px',
                    borderRadius: '50%',
                    background: 'rgba(0, 229, 255, 0.15)',
                    border: '1.5px solid rgba(0, 229, 255, 0.4)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Phone size={22} color="#00e5ff" />
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--text-primary)' }}>Audio Call</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>Voice only</div>
                </div>
              </button>

              {/* Video Call */}
              <button
                onClick={() => {
                  setIsCallOptionsOpen(false);
                  setVideoCallTarget(conversation);
                }}
                style={{
                  flex: 1,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '20px 16px',
                  borderRadius: '16px',
                  background: 'rgba(255, 45, 85, 0.08)',
                  border: '1px solid rgba(255, 45, 85, 0.25)',
                  color: '#ff2d55',
                  cursor: 'pointer',
                  transition: 'all 0.18s ease',
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255,45,85,0.16)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(255,45,85,0.5)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-2px)';
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255,45,85,0.08)';
                  (e.currentTarget as HTMLButtonElement).style.borderColor = 'rgba(255,45,85,0.25)';
                  (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)';
                }}
                title="Video Call"
              >
                <div
                  style={{
                    width: '52px',
                    height: '52px',
                    borderRadius: '50%',
                    background: 'rgba(255, 45, 85, 0.15)',
                    border: '1.5px solid rgba(255, 45, 85, 0.4)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Video size={22} color="#ff2d55" />
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--text-primary)' }}>Video Call</div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>Camera + voice</div>
                </div>
              </button>
            </div>

            {/* Cancel row */}
            <button
              onClick={() => setIsCallOptionsOpen(false)}
              style={{
                width: '100%',
                marginTop: '14px',
                padding: '12px',
                borderRadius: '12px',
                background: 'var(--surface-muted)',
                border: '1px solid var(--surface-hover)',
                color: 'var(--text-secondary)',
                fontSize: '14px',
                fontWeight: 600,
                cursor: 'pointer',
                transition: 'background 0.15s',
              }}
            >
              Cancel
            </button>
          </div>
        </>
      )}

      {/* ================= THREE-DOT MENU MODAL ================= */}
      <ThreeDotMenu
        conversation={conversation}
        isOpen={isMenuOpen}
        onClose={() => setIsMenuOpen(false)}
      />

      {/* Icebreaker Prompts Sheet */}
      <IcebreakerModal
        onInsertToInput={(prompt) => {
          setInputText(prompt);
        }}
      />
    </div>
  );
};
