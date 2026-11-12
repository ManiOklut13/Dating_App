import React, { useState } from 'react';
import {
  Search,
  Phone,
  Video,
  PhoneCall,
  Settings,
  X,
  Check,
  CheckCheck,
  Pin,
  Flame,
  UserCheck,
  ShieldAlert,
  UserX,
  Sparkles,
  Heart,
  Send,
  MessageSquare,
  Clock,
} from 'lucide-react';
import { useChat } from './ChatContext';
import { ChatConversation, MessageRequest, SentRequest } from './types';
import { PresenceDot } from '../presence/PresenceDot';

interface ChatsPageProps {
  onSelectConversation: (id: string) => void;
  onOpenCalls?: () => void;
}

export const ChatsPage: React.FC<ChatsPageProps> = ({ onSelectConversation, onOpenCalls }) => {
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
    cancelSentRequest,
    setCallHistoryType,
    setIsSettingsOpen,
    setReportTarget,
    setBlockTarget,
    setProfilePreviewUser,
  } = useChat();

  const [isSearchExpanded, setIsSearchExpanded] = useState(false);
  const [isCallHistoryMenuOpen, setIsCallHistoryMenuOpen] = useState(false);

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        background: 'var(--bg-dark)',
      }}
    >
      {/* ================= HEADER ================= */}
      <div
        style={{
          padding: '16px 20px 12px',
          background: 'var(--bg-dark)',
          borderBottom: '1px solid var(--border-glass)',
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
        }}
      >
        {/* Top Header Bar */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <h1
              style={{
                fontSize: '24px',
                fontWeight: 800,
                letterSpacing: '-0.5px',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
              }}
            >
              Chats
              {receivedRequests.length > 0 && (
                <span
                  style={{
                    background: 'var(--gradient-flame)',
                    color: 'var(--text-primary)',
                    fontSize: '11px',
                    fontWeight: 700,
                    padding: '2px 8px',
                    borderRadius: 'var(--radius-full)',
                    boxShadow: 'var(--shadow-glow)',
                  }}
                >
                  {receivedRequests.length} new
                </span>
              )}
            </h1>
            <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
              Real-time messaging, connections & dates
            </p>
          </div>

          {/* Action Icons: Call History, Video History, Settings */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            {/* Search Toggle */}
            <button
              onClick={() => setIsSearchExpanded(!isSearchExpanded)}
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: isSearchExpanded ? 'rgba(255, 45, 85, 0.2)' : 'var(--surface-muted)',
                border: isSearchExpanded ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                color: isSearchExpanded ? '#ff2d55' : 'var(--text-secondary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              title="Search Conversations"
            >
              <Search size={16} />
            </button>

            {/* Combined Call History Button */}
            <div style={{ position: 'relative' }}>
            <button
              onClick={() => {
                setIsCallHistoryMenuOpen(false);
                onOpenCalls?.();
                window.location.hash = '#/calls';
              }}
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: 'rgba(255, 255, 255, 0.05)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-secondary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                transition: 'all var(--transition-fast)',
              }}
              title="Calls"
              aria-label="Calls"
            >
              <PhoneCall size={16} />
            </button>
            {/* Settings */}
            <button
              onClick={() => setIsSettingsOpen(true)}
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                background: 'var(--surface-muted)',
                border: '1px solid var(--border-glass)',
                color: 'var(--text-secondary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
              title="Chat Settings"
            >
              <Settings size={16} />
            </button>
          </div>
        </div>

        {/* Search Field (Always visible or expanded) */}
        {(isSearchExpanded || searchQuery) && (
          <div
            style={{
              position: 'relative',
              display: 'flex',
              alignItems: 'center',
              background: 'var(--surface-strong)',
              borderRadius: 'var(--radius-full)',
              border: '1px solid var(--border-glass)',
              padding: '6px 14px',
            }}
          >
            <Search size={15} color="var(--text-muted)" style={{ marginRight: '8px' }} />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by nickname, bio, or message content..."
              style={{
                flex: 1,
                background: 'transparent',
                border: 'none',
                color: 'var(--text-primary)',
                fontSize: '13px',
                outline: 'none',
              }}
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                style={{ background: 'transparent', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
              >
                <X size={14} />
              </button>
            )}
          </div>
        )}

        {/* 3 Main Tabs: All Chats | Message Requests | Sent Requests */}
        <div
          style={{
            display: 'flex',
            background: 'var(--surface-soft)',
            borderRadius: 'var(--radius-md)',
            padding: '4px',
            border: '1px solid var(--border-glass)',
            gap: '4px',
          }}
        >
          <button
            onClick={() => setActiveTab('all')}
            style={{
              flex: 1,
              padding: '8px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              fontSize: '12.5px',
              fontWeight: activeTab === 'all' ? 700 : 500,
              color: activeTab === 'all' ? '#ffffff' : 'var(--text-secondary)',
              background: activeTab === 'all' ? 'var(--gradient-flame)' : 'transparent',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <span>All Chats</span>
            <span style={{ fontSize: '10px', opacity: 0.8 }}>({filteredConversations.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('requests')}
            style={{
              flex: 1,
              padding: '8px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              fontSize: '12.5px',
              fontWeight: activeTab === 'requests' ? 700 : 500,
              color: activeTab === 'requests' ? '#ffffff' : 'var(--text-secondary)',
              background: activeTab === 'requests' ? 'var(--gradient-flame)' : 'transparent',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <span>Requests</span>
            {receivedRequests.length > 0 && (
              <span
                style={{
                  background: activeTab === 'requests' ? '#ffffff' : '#ff2d55',
                  color: activeTab === 'requests' ? '#ff2d55' : '#ffffff',
                  fontSize: '10px',
                  fontWeight: 800,
                  padding: '1px 6px',
                  borderRadius: 'var(--radius-full)',
                }}
              >
                {receivedRequests.length}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveTab('sent')}
            style={{
              flex: 1,
              padding: '8px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              fontSize: '12.5px',
              fontWeight: activeTab === 'sent' ? 700 : 500,
              color: activeTab === 'sent' ? '#ffffff' : 'var(--text-secondary)',
              background: activeTab === 'sent' ? 'var(--gradient-flame)' : 'transparent',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
            }}
          >
            <span>Sent</span>
            <span style={{ fontSize: '10px', opacity: 0.8 }}>({sentRequests.length})</span>
          </button>
        </div>

        {/* Filter Pills (Shown under All Chats) */}
        {activeTab === 'all' && (
          <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '2px' }}>
            {(['all', 'unread', 'online', 'verified'] as const).map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                style={{
                  padding: '5px 12px',
                  borderRadius: 'var(--radius-full)',
                  border: filter === f ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                  background: filter === f ? 'rgba(255, 45, 85, 0.18)' : 'var(--surface-soft)',
                  color: filter === f ? '#ff2d55' : 'var(--text-secondary)',
                  fontSize: '11px',
                  fontWeight: 600,
                  cursor: 'pointer',
                  textTransform: 'capitalize',
                  whiteSpace: 'nowrap',
                  transition: 'all var(--transition-fast)',
                }}
              >
                {f === 'all' ? 'All Chats' : f}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* ================= BODY CONTENT ================= */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px' }}>
        
        {/* TAB 1: ALL CHATS CONVERSATION LIST */}
        {activeTab === 'all' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {filteredConversations.length === 0 ? (
              <div
                style={{
                  textAlign: 'center',
                  padding: '60px 20px',
                  color: 'var(--text-muted)',
                }}
              >
                <div style={{ fontSize: '36px', marginBottom: '12px' }}>ðŸ’¬</div>
                <h3 style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '4px' }}>
                  No Conversations Found
                </h3>
                <p style={{ fontSize: '12px' }}>
                  Try switching filters or matching with more profiles in Discovery!
                </p>
              </div>
            ) : (
              filteredConversations.map((conv) => {
                const counterpart = conv.counterpart;
                const lastMsg = conv.last_message;
                const isUnread = conv.unread_count > 0;

                return (
                  <div
                    key={conv.id}
                    onClick={() => onSelectConversation(conv.id)}
                    className="glass-panel"
                    style={{
                      padding: '12px 14px',
                      borderRadius: 'var(--radius-md)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      cursor: 'pointer',
                      border: isUnread ? '1px solid rgba(255, 45, 85, 0.3)' : '1px solid var(--border-glass)',
                      background: isUnread ? 'rgba(255, 45, 85, 0.05)' : 'var(--bg-card)',
                      transition: 'transform var(--transition-fast), background var(--transition-fast)',
                    }}
                  >
                    {/* Left: Avatar + Details */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flex: 1, minWidth: 0 }}>
                      {/* Avatar with Online/Offline Dot */}
                      <div style={{ position: 'relative', width: '50px', height: '50px', flexShrink: 0 }}>
                        <img
                          src={counterpart.avatar}
                          alt={counterpart.nickname}
                          style={{
                            width: '100%',
                            height: '100%',
                            borderRadius: '50%',
                            objectFit: 'cover',
                            border: '2px solid rgba(255, 45, 85, 0.4)',
                          }}
                        />
                        <PresenceDot userId={counterpart.id} size={12} style={{ bottom: 1, right: 1 }} />
                      </div>

                      {/* Name & Last Message */}
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '2px' }}>
                          <span style={{ fontWeight: 700, fontSize: '14.5px', color: 'var(--text-primary)' }}>
                            {counterpart.nickname}
                          </span>
                          {counterpart.is_verified && <span className="badge-blue-tick">âœ“</span>}
                          {conv.is_pinned && <Pin size={12} color="#ffd700" style={{ transform: 'rotate(45deg)' }} />}
                        </div>

                        {/* Online / last-seen status */}
                        <div
                          style={{
                            fontSize: '11px',
                            color: counterpart.is_online ? '#00e676' : 'var(--text-muted)',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '4px',
                            marginBottom: '2px',
                          }}
                        >
                          {counterpart.is_online ? (
                            <>
                              <span
                                style={{
                                  width: '6px',
                                  height: '6px',
                                  borderRadius: '50%',
                                  background: '#00e676',
                                  display: 'inline-block',
                                  boxShadow: '0 0 4px #00e676',
                                  animation: 'pulseGlow 2s infinite ease-in-out',
                                  flexShrink: 0,
                                }}
                              />
                              Active now
                            </>
                          ) : counterpart.last_seen ? (
                            `Last seen ${counterpart.last_seen}`
                          ) : (
                            'Offline'
                          )}
                        </div>

                        {/* Last message preview */}
                        <div
                          style={{
                            fontSize: '12.5px',
                            color: isUnread ? '#ffffff' : 'var(--text-secondary)',
                            fontWeight: isUnread ? 600 : 400,
                            whiteSpace: 'nowrap',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                          }}
                        >
                          {lastMsg ? (
                            <span>
                              {lastMsg.sender_id === 'me' && 'You: '}
                              {lastMsg.body}
                            </span>
                          ) : (
                            'Say hi! Start a conversation...'
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Right: Timestamp & Unread Badge & Read ticks */}
                    <div
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'flex-end',
                        gap: '6px',
                        marginLeft: '12px',
                        flexShrink: 0,
                      }}
                    >
                      <span style={{ fontSize: '11px', color: isUnread ? '#ff2d55' : 'var(--text-muted)', fontWeight: isUnread ? 700 : 400 }}>
                        {lastMsg ? new Date(lastMsg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                      </span>

                      {conv.unread_count > 0 ? (
                        <div
                          style={{
                            background: 'var(--gradient-flame)',
                            color: 'var(--text-primary)',
                            borderRadius: 'var(--radius-full)',
                            fontSize: '10px',
                            fontWeight: 800,
                            minWidth: '18px',
                            height: '18px',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            padding: '0 5px',
                            boxShadow: 'var(--shadow-glow)',
                          }}
                        >
                          {conv.unread_count}
                        </div>
                      ) : lastMsg?.sender_id === 'me' ? (
                        lastMsg.status === 'read' ? (
                          <CheckCheck size={14} color="#00e5ff" />
                        ) : (
                          <Check size={14} color="var(--text-muted)" />
                        )
                      ) : null}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        )}

        {/* TAB 2: RECEIVED MESSAGE REQUESTS */}
        {activeTab === 'requests' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 0' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Incoming message requests ({receivedRequests.length})
              </span>
              <span style={{ fontSize: '11px', color: 'var(--cyan-vibe)', fontWeight: 600 }}>
                Respond without revealing phone/links
              </span>
            </div>

            {receivedRequests.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
                <Sparkles size={36} color="#ffd700" style={{ margin: '0 auto 12px' }} />
                <h3 style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '4px' }}>
                  No Pending Requests
                </h3>
                <p style={{ fontSize: '12px' }}>All incoming requests have been reviewed!</p>
              </div>
            ) : (
              receivedRequests.map((req) => (
                <div
                  key={req.id}
                  className="glass-panel"
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid rgba(255, 45, 85, 0.25)',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '12px',
                  }}
                >
                  {/* Top user info */}
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div
                      onClick={() => setProfilePreviewUser(req as any)}
                      style={{ display: 'flex', alignItems: 'center', gap: '12px', cursor: 'pointer' }}
                    >
                      <div style={{ position: 'relative', width: '48px', height: '48px' }}>
                        <img
                          src={req.avatar}
                          alt={req.nickname}
                          style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
                        />
                        {req.is_verified && <div className="badge-blue-tick" style={{ position: 'absolute', bottom: 0, right: 0 }}>âœ“</div>}
                      </div>

                      <div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <span style={{ fontWeight: 800, fontSize: '15px' }}>{req.nickname}, {req.age}</span>
                        </div>
                        <div style={{ fontSize: '11px', color: 'var(--cyan-vibe)' }}>
                          {req.city} â€¢ {req.vibe_score}% Vibe Match
                        </div>
                      </div>
                    </div>

                    <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{req.created_at}</span>
                  </div>

                  {/* Initial Message Body */}
                  <div
                    style={{
                      padding: '10px 14px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'var(--surface-soft)',
                      border: '1px solid var(--border-glass)',
                      fontSize: '13px',
                      color: 'var(--text-primary)',
                      lineHeight: 1.45,
                    }}
                  >
                    ðŸ’¬ "{req.message}"
                  </div>

                  {/* Actions: Accept, Decline, Report, Block */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                    <button
                      onClick={() => acceptRequest(req.id)}
                      className="btn-primary"
                      style={{ flex: 2, padding: '8px 14px', fontSize: '12.5px' }}
                    >
                      <MessageSquare size={14} />
                      Accept & Chat
                    </button>

                    <button
                      onClick={() => declineRequest(req.id)}
                      className="btn-ghost"
                      style={{ flex: 1, padding: '8px 12px', fontSize: '12px' }}
                    >
                      Decline
                    </button>

                    <button
                      onClick={() => setReportTarget({ user: req as any, requestId: req.id })}
                      className="btn-ghost"
                      style={{ padding: '8px 10px', fontSize: '11px', color: '#ff4757', borderColor: 'rgba(255, 71, 87, 0.3)' }}
                      title="Report Request"
                    >
                      <ShieldAlert size={14} />
                    </button>

                    <button
                      onClick={() => setBlockTarget({ user: req as any, requestId: req.id })}
                      className="btn-ghost"
                      style={{ padding: '8px 10px', fontSize: '11px', color: '#ff4757', borderColor: 'rgba(255, 71, 87, 0.3)' }}
                      title="Block User"
                    >
                      <UserX size={14} />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {/* TAB 3: SENT REQUESTS */}
        {activeTab === 'sent' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 0' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Outgoing requests ({sentRequests.length})
              </span>
              <span style={{ fontSize: '11px', color: '#ffd700' }}>Pending receiver response</span>
            </div>

            {sentRequests.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
                <Send size={36} color="#00e5ff" style={{ margin: '0 auto 12px' }} />
                <h3 style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '4px' }}>
                  No Outgoing Requests
                </h3>
                <p style={{ fontSize: '12px' }}>You haven't sent any pending connection requests.</p>
              </div>
            ) : (
              sentRequests.map((sent) => (
                <div
                  key={sent.id}
                  className="glass-panel"
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--border-glass)',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '12px',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <img
                        src={sent.avatar}
                        alt={sent.nickname}
                        style={{ width: '46px', height: '46px', borderRadius: '50%', objectFit: 'cover' }}
                      />
                      <div>
                        <div style={{ fontWeight: 800, fontSize: '15px' }}>{sent.nickname}, {sent.age}</div>
                        <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                          {sent.city} â€¢ <span style={{ color: '#ffd700' }}>{sent.created_at}</span>
                        </div>
                      </div>
                    </div>

                    <span
                      style={{
                        padding: '3px 8px',
                        borderRadius: 'var(--radius-full)',
                        background: 'rgba(255, 215, 0, 0.1)',
                        border: '1px solid rgba(255, 215, 0, 0.3)',
                        color: '#ffd700',
                        fontSize: '10px',
                        fontWeight: 700,
                        textTransform: 'uppercase',
                      }}
                    >
                      {sent.status}
                    </span>
                  </div>

                  <div
                    style={{
                      padding: '10px 14px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'var(--surface-faint)',
                      fontSize: '13px',
                      color: 'var(--text-secondary)',
                      lineHeight: 1.4,
                    }}
                  >
                    ðŸ’¬ "{sent.message}"
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                    <button
                      onClick={() => cancelSentRequest(sent.id)}
                      className="btn-ghost"
                      style={{ padding: '6px 14px', fontSize: '11.5px', color: '#ff4757', borderColor: 'rgba(255, 71, 87, 0.3)' }}
                    >
                      Cancel Request
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

      </div>
    </div>
  );
};
