import React, { useState } from 'react';
import { X, Phone, Video, PhoneIncoming, PhoneOutgoing, PhoneMissed, PhoneCall } from 'lucide-react';
import { useChat } from './ChatContext';

export const CallHistoryModal: React.FC = () => {
  const {
    callHistoryType,
    setCallHistoryType,
    callHistory,
    conversations,
    setAudioCallTarget,
    setVideoCallTarget,
  } = useChat();

  const [activeFilter, setActiveFilter] = useState<'all' | 'audio' | 'video' | 'missed'>('all');

  if (!callHistoryType) return null;

  const filteredHistory = callHistory.filter((call) => {
    if (callHistoryType === 'audio' && call.type !== 'audio') return false;
    if (callHistoryType === 'video' && call.type !== 'video') return false;

    if (activeFilter === 'audio') return call.type === 'audio';
    if (activeFilter === 'video') return call.type === 'video';
    if (activeFilter === 'missed') return call.direction === 'missed';
    return true;
  });

  const handleStartCall = (userId: string, type: 'audio' | 'video') => {
    setCallHistoryType(null);
    const targetConv = conversations.find(
      (c) => c.counterpart.id === userId || c.counterpart.nickname.includes(userId)
    ) || conversations[0];

    if (type === 'audio') {
      setAudioCallTarget(targetConv);
    } else {
      setVideoCallTarget(targetConv);
    }
  };

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
      onClick={() => setCallHistoryType(null)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '520px',
          maxHeight: '85vh',
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
            padding: '16px 20px',
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
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: callHistoryType === 'audio' ? 'rgba(0, 229, 255, 0.15)' : 'rgba(255, 45, 85, 0.15)',
                color: callHistoryType === 'audio' ? '#00e5ff' : '#ff2d55',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {callHistoryType === 'audio' ? <Phone size={18} /> : <Video size={18} />}
            </div>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: 800 }}>
                {callHistoryType === 'audio' ? 'Audio Call History' : 'Video Call History'}
              </h2>
              <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                Recent LiveKit WebRTC sessions
              </p>
            </div>
          </div>

          <button
            onClick={() => setCallHistoryType(null)}
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

        {/* Filter Chips */}
        <div
          style={{
            display: 'flex',
            gap: '8px',
            padding: '12px 20px',
            borderBottom: '1px solid var(--surface-muted)',
            background: 'var(--surface-faint)',
          }}
        >
          {(['all', 'audio', 'video', 'missed'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setActiveFilter(f)}
              style={{
                padding: '6px 12px',
                borderRadius: 'var(--radius-full)',
                border: activeFilter === f ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                background: activeFilter === f ? 'rgba(255, 45, 85, 0.15)' : 'var(--surface-soft)',
                color: activeFilter === f ? '#ff2d55' : 'var(--text-secondary)',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
                textTransform: 'capitalize',
              }}
            >
              {f === 'all' ? 'All Calls' : `${f} calls`}
            </button>
          ))}
        </div>

        {/* Call Log List */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '12px 20px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {filteredHistory.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: 'var(--text-muted)' }}>
              No call logs match this filter.
            </div>
          ) : (
            filteredHistory.map((call) => (
              <div
                key={call.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  borderRadius: 'var(--radius-md)',
                  background: 'var(--surface-faint)',
                  border: '1px solid var(--border-glass)',
                  transition: 'background var(--transition-fast)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <img
                    src={call.caller_avatar}
                    alt={call.caller_name}
                    style={{ width: '42px', height: '42px', borderRadius: '50%', objectFit: 'cover' }}
                  />
                  <div>
                    <div style={{ fontWeight: 700, fontSize: '14px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span>{call.caller_name}</span>
                      {call.direction === 'missed' && (
                        <span style={{ fontSize: '10px', color: '#ff4757', background: 'rgba(255,71,87,0.15)', padding: '2px 6px', borderRadius: '4px' }}>
                          Missed
                        </span>
                      )}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '11px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                      {call.direction === 'incoming' && <PhoneIncoming size={12} color="#00e676" />}
                      {call.direction === 'outgoing' && <PhoneOutgoing size={12} color="#00e5ff" />}
                      {call.direction === 'missed' && <PhoneMissed size={12} color="#ff4757" />}
                      <span>{call.timestamp}</span>
                      <span>•</span>
                      <span>{call.duration}</span>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    onClick={() => handleStartCall(call.user_id, 'audio')}
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '50%',
                      background: 'var(--surface-strong)',
                      border: '1px solid var(--border-glass)',
                      color: '#00e5ff',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                    title="Audio Call"
                  >
                    <PhoneCall size={15} />
                  </button>
                  <button
                    onClick={() => handleStartCall(call.user_id, 'video')}
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '50%',
                      background: 'rgba(255, 45, 85, 0.15)',
                      border: '1px solid rgba(255, 45, 85, 0.3)',
                      color: '#ff2d55',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                    title="Video Call"
                  >
                    <Video size={15} />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
