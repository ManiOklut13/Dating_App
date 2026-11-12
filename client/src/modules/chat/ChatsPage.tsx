import React, { useState } from 'react';
import {
  Search,
  Phone,
  Calendar,
  Settings,
  Check,
  CheckCheck,
  Pin,
  MessageSquare,
  X,
} from 'lucide-react';
import { useChat } from './ChatContext';
import { ChatConversation } from './types';

interface ChatsPageProps {
  onSelectConversation: (id: string) => void;
  onOpenCalls?: () => void;
}

function formatRelativeTime(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  if (diffMins < 1) return 'now';
  if (diffMins < 60) return `${diffMins}m`;
  if (diffHours < 24) return `${diffHours}h`;
  if (diffDays === 1) return 'Yesterday';
  return `${diffDays}d`;
}

export const ChatsPage: React.FC<ChatsPageProps> = ({ onSelectConversation, onOpenCalls }) => {
  const [isDateChatPickerOpen, setIsDateChatPickerOpen] = useState(false);
  const {
    filteredConversations,
    searchQuery,
    setSearchQuery,
    activeTab,
    setActiveTab,
    filter,
    setFilter,
    receivedRequests,
    sentRequests,
    acceptRequest,
    declineRequest,
    setCallHistoryType,
    setIsSettingsOpen,
    setDatePlannerConv,
  } = useChat();

  const [notifCount] = useState(2);
  const coinBalance = 250;
  const streakDays = 4;
  
  const unreadCount = filteredConversations.reduce((sum, c) => sum + (c.unread_count || 0), 0);
  const totalConversations = filteredConversations.length;
  const onlineUsers = filteredConversations.filter(c => c.counterpart.is_online).slice(0, 6);

  const getPreviewText = (conv: ChatConversation) => {
    const lastMsg = conv.last_message;
    if (!lastMsg) return 'Say hi!';
    if (lastMsg.sender_id === 'me') {
      return `You: ${lastMsg.body}`;
    }
    return lastMsg.body;
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        background: 'radial-gradient(ellipse 80% 40% at 90% 0%, rgba(255,77,126,0.15) 0%, transparent 60%), radial-gradient(ellipse 60% 30% at 10% 10%, rgba(168,85,247,0.12) 0%, transparent 60%), #0c080e',
      }}
    >
      {/* Header Row 2 */}
      <div style={{ padding: '8px 16px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '8px' }}>
          <div>
            <h1
              style={{
                fontSize: '28px',
                fontWeight: 800,
                color: '#fff',
                margin: 0,
                fontFamily: "'Plus Jakarta Sans', sans-serif",
              }}
            >
              Chats
            </h1>
            <p style={{ fontSize: '13px', color: '#9ca3af', margin: '4px 0 0 0' }}>
              {activeTab === 'all'
                ? `${unreadCount} unread · ${totalConversations} conversations`
                : `${receivedRequests.length} people want to connect with you`}
            </p>
          </div>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              onClick={() => { setCallHistoryType('audio'); onOpenCalls?.(); }}
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              aria-label="Calls"
            >
              <Phone size={16} />
            </button>
            <button
              onClick={() => setIsDateChatPickerOpen(true)}
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              aria-label="Calendar"
            >
              <Calendar size={16} />
            </button>
            <button
              onClick={() => setIsSettingsOpen(true)}
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                background: '#1a141f',
                border: '1px solid #2a2030',
                color: '#fff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              aria-label="Settings"
            >
              <Settings size={16} />
            </button>
          </div>
        </div>

        {/* Segmented Control */}
        <div
          style={{
            display: 'flex',
            background: '#14101a',
            borderRadius: '12px',
            padding: '4px',
            border: '1px solid #2a2030',
          }}
        >
          <button
            onClick={() => setActiveTab('all')}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: '10px',
              border: 'none',
              background: activeTab === 'all' ? 'linear-gradient(135deg, #ff4d7e 0%, #e0264f 100%)' : 'transparent',
              color: '#fff',
              fontSize: '14px',
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
              boxShadow: activeTab === 'all' ? '0 4px 16px rgba(255,77,126,0.4)' : 'none',
            }}
          >
            Messages
            <span
              style={{
                padding: '2px 8px',
                borderRadius: '10px',
                background: activeTab === 'all' ? 'rgba(255,255,255,0.2)' : '#ff4d7e',
                fontSize: '12px',
                fontWeight: 700,
              }}
            >
              {totalConversations}
            </span>
          </button>
          <button
            onClick={() => setActiveTab('requests')}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: '10px',
              border: 'none',
              background: activeTab === 'requests' ? 'linear-gradient(135deg, #ff4d7e 0%, #e0264f 100%)' : 'transparent',
              color: '#fff',
              fontSize: '14px',
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
              boxShadow: activeTab === 'requests' ? '0 4px 16px rgba(255,77,126,0.4)' : 'none',
            }}
          >
            Requests
            <span
              style={{
                padding: '2px 8px',
                borderRadius: '10px',
                background: activeTab === 'requests' ? 'rgba(255,255,255,0.2)' : '#ff4d7e',
                fontSize: '12px',
                fontWeight: 700,
              }}
            >
              {receivedRequests.length}
            </span>
          </button>
        </div>
      </div>

      {/* Search */}
      {activeTab === 'all' && (
        <div style={{ padding: '0 16px 12px' }}>
          <div
            style={{
              position: 'relative',
              display: 'flex',
              alignItems: 'center',
              background: '#14101a',
              borderRadius: '14px',
              border: '1px solid #2a2030',
              padding: '10px 16px',
            }}
          >
            <Search size={18} color="#6b7280" style={{ marginRight: '10px' }} />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search chats by name"
              style={{
                flex: 1,
                background: 'transparent',
                border: 'none',
                color: '#fff',
                fontSize: '14px',
                outline: 'none',
              }}
            />
          </div>
        </div>
      )}

      {/* Content */}
      <div style={{ flex: 1, overflowY: 'auto', paddingBottom: '80px' }}>
        {activeTab === 'all' ? (
          <>
            {/* Active now */}
            {onlineUsers.length > 0 && (
              <div style={{ padding: '0 16px 16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
                  <h3 style={{ fontSize: '16px', fontWeight: 700, color: '#fff', margin: 0 }}>Active now</h3>
                  <button style={{ background: 'transparent', border: 'none', color: '#ff4d7e', fontSize: '13px', fontWeight: 600, cursor: 'pointer' }}>
                    See all
                  </button>
                </div>
                <div style={{ display: 'flex', gap: '12px', overflowX: 'auto' }}>
                  {onlineUsers.map((conv) => (
                    <button
                      key={conv.id}
                      onClick={() => onSelectConversation(conv.id)}
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: '6px',
                        background: 'transparent',
                        border: 'none',
                        cursor: 'pointer',
                        minWidth: '60px',
                      }}
                    >
                      <div
                        style={{
                          width: '54px',
                          height: '54px',
                          borderRadius: '50%',
                          background: 'linear-gradient(135deg, #ff4d7e 0%, #a855f7 100%)',
                          padding: '2px',
                        }}
                      >
                        <img
                          src={conv.counterpart.avatar}
                          alt={conv.counterpart.nickname}
                          style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
                        />
                      </div>
                      <span style={{ fontSize: '11px', color: '#fff', textAlign: 'center', maxWidth: '60px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        {conv.counterpart.nickname.split(' ')[0]}
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Filter chips */}
            <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', padding: '0 16px 12px' }}>
              {[
                { key: 'all', label: 'All' },
                { key: 'unread', label: `Unread · ${unreadCount}` },
                { key: 'online', label: 'Online' },
                { key: 'verified', label: 'Verified' },
              ].map((chip) => (
                <button
                  key={chip.key}
                  onClick={() => setFilter(chip.key as any)}
                  style={{
                    padding: '8px 16px',
                    borderRadius: '20px',
                    border: filter === chip.key ? '1px solid #ff4d7e' : '1px solid #2a2030',
                    background: filter === chip.key ? 'rgba(255,77,126,0.1)' : '#14101a',
                    color: filter === chip.key ? '#ff4d7e' : '#9ca3af',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    whiteSpace: 'nowrap',
                    flexShrink: 0,
                  }}
                >
                  {chip.label}
                </button>
              ))}
            </div>

            {/* Chat list */}
            <div style={{ padding: '0 16px' }}>
              {filteredConversations.map((conv) => {
                const isUnread = conv.unread_count > 0;
                const lastMsg = conv.last_message;
                return (
                  <div
                    key={conv.id}
                    onClick={() => onSelectConversation(conv.id)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      padding: '12px 0',
                      borderBottom: '1px solid #1f1825',
                      cursor: 'pointer',
                      background: conv.is_pinned ? 'linear-gradient(90deg, rgba(255,77,126,0.08) 0%, transparent 100%)' : 'transparent',
                    }}
                  >
                    <div style={{ position: 'relative', flexShrink: 0 }}>
                      <div
                        style={{
                          width: '56px',
                          height: '56px',
                          borderRadius: '50%',
                          background: conv.is_pinned ? 'linear-gradient(135deg, #ff4d7e 0%, #a855f7 100%)' : 'transparent',
                          padding: conv.is_pinned ? '2px' : '0',
                        }}
                      >
                        <img
                          src={conv.counterpart.avatar}
                          alt={conv.counterpart.nickname}
                          style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }}
                        />
                      </div>
                      {conv.counterpart.is_online && (
                        <span
                          style={{
                            position: 'absolute',
                            bottom: '2px',
                            right: '2px',
                            width: '12px',
                            height: '12px',
                            borderRadius: '50%',
                            background: '#2ed47a',
                            border: '2px solid #0c080e',
                          }}
                        />
                      )}
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '4px' }}>
                        <span style={{ fontSize: '15px', fontWeight: 700, color: '#fff', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {conv.counterpart.nickname}
                        </span>
                        {conv.counterpart.is_verified && (
                          <Check size={14} color="#1d9bf0" fill="#1d9bf0" />
                        )}
                        {conv.is_pinned && <Pin size={12} color="#ff4d7e" style={{ transform: 'rotate(45deg)' }} />}
                      </div>
                      <div
                        style={{
                          fontSize: '13px',
                          color: isUnread ? '#fff' : '#9ca3af',
                          fontWeight: isUnread ? 600 : 400,
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '4px',
                        }}
                      >
                        {getPreviewText(conv)}
                        {lastMsg?.sender_id === 'me' && (
                          <span style={{ marginLeft: '4px' }}>
                            {lastMsg.status === 'read' ? <CheckCheck size={12} color="#1d9bf0" /> : <Check size={12} color="#9ca3af" />}
                          </span>
                        )}
                      </div>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '6px' }}>
                      <span style={{ fontSize: '11px', color: isUnread ? '#ff4d7e' : '#6b7280' }}>
                        {lastMsg ? formatRelativeTime(lastMsg.created_at) : ''}
                      </span>
                      {isUnread && conv.unread_count > 0 && (
                        <span
                          style={{
                            width: '20px',
                            height: '20px',
                            borderRadius: '50%',
                            background: 'linear-gradient(135deg, #ff4d7e 0%, #e0264f 100%)',
                            color: '#fff',
                            fontSize: '11px',
                            fontWeight: 700,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          {conv.unread_count}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </>
        ) : (
          <div style={{ padding: '16px' }}>
            <div style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
              {[
                { key: 'received', label: `Received · ${receivedRequests.length}` },
                { key: 'sent', label: `Sent · ${sentRequests.length}` },
                { key: 'date', label: 'Date invites · 0' },
              ].map((chip) => (
                <button
                  key={chip.key}
                  style={{
                    padding: '8px 16px',
                    borderRadius: '20px',
                    border: '1px solid #2a2030',
                    background: '#14101a',
                    color: '#9ca3af',
                    fontSize: '13px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {chip.label}
                </button>
              ))}
            </div>
            {receivedRequests.map((req) => (
              <div
                key={req.id}
                style={{
                  background: '#14101a',
                  border: '1px solid #2a2030',
                  borderRadius: '20px',
                  padding: '16px',
                  marginBottom: '12px',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
                  <img
                    src={req.avatar}
                    alt={req.nickname}
                    style={{ width: '52px', height: '52px', borderRadius: '50%', objectFit: 'cover' }}
                  />
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '2px' }}>
                      <span style={{ fontSize: '16px', fontWeight: 700, color: '#fff' }}>{req.nickname}</span>
                      {req.is_verified && <Check size={14} color="#1d9bf0" fill="#1d9bf0" />}
                      <span
                        style={{
                          padding: '2px 8px',
                          borderRadius: '10px',
                          background: 'rgba(168,85,247,0.2)',
                          color: '#c39bff',
                          fontSize: '11px',
                          fontWeight: 600,
                        }}
                      >
                        {req.vibe_score || 95}% match
                      </span>
                      <span style={{ fontSize: '12px', color: '#9ca3af' }}>· {req.city || '2 km away'}</span>
                    </div>
                    <span style={{ fontSize: '12px', color: '#6b7280' }}>{req.created_at}</span>
                  </div>
                </div>
                <div
                  style={{
                    background: '#0c080e',
                    borderRadius: '12px',
                    padding: '12px',
                    marginBottom: '12px',
                    color: '#d1d5db',
                    fontSize: '14px',
                  }}
                >
                  "{req.message}"
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    onClick={() => declineRequest(req.id)}
                    style={{
                      flex: 1,
                      padding: '12px',
                      borderRadius: '12px',
                      background: '#14101a',
                      border: '1px solid #2a2030',
                      color: '#fff',
                      fontSize: '14px',
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                  >
                    ✕ Decline
                  </button>
                  <button
                    onClick={() => acceptRequest(req.id)}
                    style={{
                      flex: 1,
                      padding: '12px',
                      borderRadius: '12px',
                      background: 'linear-gradient(135deg, #ff4d7e 0%, #e0264f 100%)',
                      border: 'none',
                      color: '#fff',
                      fontSize: '14px',
                      fontWeight: 600,
                      cursor: 'pointer',
                      boxShadow: '0 4px 16px rgba(255,77,126,0.4)',
                    }}
                  >
                    ♥ Accept
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Plan a Date picker */}
      {isDateChatPickerOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 9999,
            background: 'rgba(0,0,0,0.88)',
            backdropFilter: 'blur(18px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '12px',
          }}
          onClick={() => setIsDateChatPickerOpen(false)}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '480px',
              maxHeight: '80vh',
              background: '#121212',
              borderRadius: '24px',
              display: 'flex',
              flexDirection: 'column',
              overflow: 'hidden',
              border: '1px solid rgba(255,45,85,0.2)',
            }}
          >
            <div style={{ padding: '18px 20px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <h2 style={{ margin: 0, fontSize: '19px', fontWeight: 800, color: '#fff' }}>
                Plan a <span style={{ color: '#ff2d55' }}>Date</span>
              </h2>
              <button
                onClick={() => setIsDateChatPickerOpen(false)}
                style={{ background: 'transparent', border: 'none', color: '#fff', cursor: 'pointer' }}
              >
                <X size={20} />
              </button>
            </div>
            <p style={{ padding: '0 20px', margin: 0, fontSize: '13px', color: '#9ca3af' }}>Pick a chat to plan a date with:</p>
            <div style={{ flex: 1, overflowY: 'auto', padding: '12px' }}>
              {filteredConversations.map((conv) => (
                <button
                  key={conv.id}
                  onClick={() => {
                    setIsDateChatPickerOpen(false);
                    setDatePlannerConv(conv);
                  }}
                  style={{
                    width: '100%',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '10px 12px',
                    background: 'transparent',
                    border: 'none',
                    color: '#fff',
                    cursor: 'pointer',
                    textAlign: 'left',
                  }}
                >
                  <img
                    src={conv.counterpart.avatar}
                    alt={conv.counterpart.nickname}
                    style={{ width: '44px', height: '44px', borderRadius: '50%' }}
                  />
                  <span style={{ flex: 1 }}>{conv.counterpart.nickname}</span>
                  <Calendar size={16} color="#ffd700" />
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
