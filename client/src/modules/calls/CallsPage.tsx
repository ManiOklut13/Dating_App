import React, { useMemo, useState } from 'react';
import { History, Phone, PhoneCall, Video } from 'lucide-react';
import { useCalls } from './CallsContext';
import { useCallHistory } from './useCallHistory';
import { CallType } from './types';
import {
  CallHistoryCard,
  CallsBackButton,
  CallsEmptyState,
  CallsError,
  CallsLoading,
  CallsShell,
} from './CallsUI';
import { INITIAL_CONVERSATIONS } from '../chat/mockData';
import { UserProfile } from '../chat/types';
import { useChat } from '../chat/ChatContext';

/* ==========================================================================
   Calls hub — reached from the calling icon in the Chat tab header.

   Three tabs, styled like the All Chats / Requests / Sent tabs on the Chats
   page: Audio contacts, Video contacts, and a combined Call History with
   All / Audio / Video / Missed filters.

   Frontend only: the Audio and Video tabs are display lists built from the
   contacts already used across the app, and the History tab reuses the
   existing call-history hook and card. No calling behaviour is added here.
   ========================================================================== */

type CallsTab = 'audio' | 'video' | 'history';
type HistoryFilter = 'all' | 'audio' | 'video' | 'missed';

const AUDIO_ACCENT = '#00e5ff';
const VIDEO_ACCENT = '#ff2d55';

/** Remember the last tab so returning from a call record reopens it. Defaults to Audio tab. */
let rememberedTab: CallsTab = 'audio';

/** Contacts already present in the app's frontend data, online ones first. */
const CALL_CONTACTS: UserProfile[] = [...INITIAL_CONVERSATIONS.map((conv) => conv.counterpart)].sort(
  (a, b) => {
    if (a.is_online !== b.is_online) return a.is_online ? -1 : 1;
    return a.nickname.localeCompare(b.nickname);
  },
);

const TABS = [
  { id: 'audio' as CallsTab, label: 'Audio', count: CALL_CONTACTS.length, Icon: PhoneCall },
  { id: 'video' as CallsTab, label: 'Video', count: CALL_CONTACTS.length, Icon: Video },
  { id: 'history' as CallsTab, label: 'History', count: null, Icon: History },
];

/** One contact row on the Audio / Video tabs. Clicking starts the demo call directly. */
const CallContactRow: React.FC<{ contact: UserProfile; kind: CallType }> = ({ contact, kind }) => {
  const accent = kind === 'video' ? VIDEO_ACCENT : AUDIO_ACCENT;
  const CallIcon = kind === 'video' ? Video : PhoneCall;
  const statusColor = contact.is_online ? '#00e676' : 'var(--text-muted)';
  const { setAudioCallTarget, setVideoCallTarget } = useChat();

  const handleCall = () => {
    const target = {
      id: `conv-${contact.id}`,
      counterpart: contact,
      is_pinned: false,
      is_muted: false,
      is_locked: false,
      unread_count: 0,
      last_message: {
        id: `call-${Date.now()}`,
        conv_id: `conv-${contact.id}`,
        sender_id: 'system',
        type: 'text' as const,
        body: '',
        status: 'sending' as const,
        created_at: new Date().toISOString(),
      },
    };

    if (kind === 'video') {
      setVideoCallTarget(target);
    } else {
      setAudioCallTarget(target);
    }
  };

  return (
    <div
      className="glass-panel"
      style={{
        borderRadius: 'var(--radius-md)',
        padding: '12px 14px',
        border: '1px solid var(--border-glass)',
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
      }}
    >
      <div style={{ position: 'relative', width: '50px', height: '50px', flexShrink: 0 }}>
        <img
          src={contact.avatar}
          alt={contact.nickname}
          loading="lazy"
          style={{
            width: '100%',
            height: '100%',
            borderRadius: '50%',
            objectFit: 'cover',
            border: `2px solid ${accent}66`,
          }}
        />
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', minWidth: 0 }}>
          <span
            style={{
              fontWeight: 700,
              fontSize: '14.5px',
              color: 'var(--text-primary)',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {contact.nickname}
          </span>
          {contact.is_verified && (
            <span className="badge-blue-tick" style={{ flexShrink: 0 }}>
              ✓
            </span>
          )}
        </div>

        <div
          style={{
            fontSize: '11px',
            color: statusColor,
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            marginTop: '2px',
          }}
        >
          {contact.is_online ? (
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
          ) : contact.last_seen ? (
            `Last seen ${contact.last_seen}`
          ) : (
            'Offline'
          )}
        </div>
      </div>

      <button
        type="button"
        onClick={handleCall}
        aria-label={`${kind === 'video' ? 'Video' : 'Audio'} call ${contact.nickname}`}
        title={kind === 'video' ? 'Start video call demo' : 'Start audio call demo'}
        style={{
          width: '40px',
          height: '40px',
          borderRadius: '50%',
          flexShrink: 0,
          background: `${accent}1f`,
          border: `1px solid ${accent}55`,
          color: accent,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          transition: 'transform var(--transition-fast), background var(--transition-fast)',
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.transform = 'scale(1.08)';
          e.currentTarget.style.background = `${accent}33`;
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.transform = 'scale(1)';
          e.currentTarget.style.background = `${accent}1f`;
        }}
      >
        <CallIcon size={16} />
      </button>
    </div>
  );
};

const ContactList: React.FC<{ kind: CallType; contacts: UserProfile[] }> = ({ kind, contacts }) => (
  <div>
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: '8px',
        padding: '4px 0 10px',
      }}
    >
      <span style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
        {contacts.length} {kind} call contacts
      </span>
    </div>

    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
      {contacts.map((contact) => (
        <CallContactRow key={contact.id} contact={contact} kind={kind} />
      ))}
    </div>
  </div>
);

const EMPTY_COPY: Record<HistoryFilter, { title: string; description: string }> = {
  all: {
    title: 'No calls yet',
    description: 'Your audio and video calls will appear here once you start calling.',
  },
  audio: {
    title: 'No audio calls',
    description: 'Audio calls you make or receive will show up here.',
  },
  video: {
    title: 'No video calls',
    description: 'Video calls you make or receive will show up here.',
  },
  missed: {
    title: 'No missed calls',
    description: 'You are all caught up — there are no missed calls in your history.',
  },
};

const HistoryPanel: React.FC = () => {
  const { navigate } = useCalls();
  const [filter, setFilter] = useState<HistoryFilter>('all');

  const audio = useCallHistory('audio', '');
  const video = useCallHistory('video', '');

  const records = useMemo(() => {
    const merged = [...audio.records, ...video.records];
    const filtered =
      filter === 'all'
        ? merged
        : filter === 'missed'
          ? merged.filter((record) => record.call_status === 'missed')
          : merged.filter((record) => record.call_type === filter);
    return filtered.sort(
      (a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime(),
    );
  }, [audio.records, video.records, filter]);

  const hasAnyRecord = audio.records.length > 0 || video.records.length > 0;
  const isLoading = (audio.isLoading || video.isLoading) && !hasAnyRecord;
  const bothFailed = !!audio.error && !!video.error;
  const showError = bothFailed && !hasAnyRecord && !isLoading;

  const retry = () => {
    audio.retry();
    video.retry();
  };

  return (
    <div>
      {/* Filters: All | Audio | Video | Missed */}
      <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '2px', marginBottom: '12px' }}>
        {(['all', 'audio', 'video', 'missed'] as const).map((f) => (
          <button
            key={f}
            type="button"
            onClick={() => setFilter(f)}
            style={{
              padding: '5px 14px',
              borderRadius: 'var(--radius-full)',
              border: filter === f ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
              background: filter === f ? 'rgba(255, 45, 85, 0.18)' : 'var(--surface-soft)',
              color: filter === f ? '#ff2d55' : 'var(--text-secondary)',
              fontSize: '11.5px',
              fontWeight: 600,
              cursor: 'pointer',
              whiteSpace: 'nowrap',
              textTransform: 'capitalize',
              transition: 'all var(--transition-fast)',
            }}
          >
            {f}
          </button>
        ))}
      </div>

      {isLoading && <CallsLoading />}

      {showError && (
        <CallsError message={audio.error || video.error || 'Unable to load call history.'} onRetry={retry} />
      )}

      {!isLoading && !showError && records.length === 0 && (
        <CallsEmptyState
          icon={<History size={26} />}
          title={EMPTY_COPY[filter].title}
          description={EMPTY_COPY[filter].description}
        />
      )}

      {!isLoading && !showError && records.length > 0 && (
        <>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {records.map((record) => (
              <CallHistoryCard
                key={record.call_id}
                record={record}
                onOpen={() =>
                  navigate(
                    record.call_type === 'video'
                      ? { name: 'video-detail', callId: record.call_id }
                      : { name: 'audio-detail', callId: record.call_id },
                  )
                }
              />
            ))}
          </div>
        </>
      )}
    </div>
  );
};

export const CallsPage: React.FC = () => {
  const { back } = useCalls();
  const [tab, setTab] = useState<CallsTab>('audio');

  React.useEffect(() => {
    setTab('audio');
  }, []);

  const selectTab = (next: CallsTab) => {
    rememberedTab = next;
    setTab(next);
  };

  return (
    <CallsShell>
      {/* Sticky header: title, subtitle and the three-tab navigation. */}
      <div
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 10,
          padding: '16px 0 12px',
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
          background: 'linear-gradient(to bottom, var(--bg-dark) 78%, transparent)',
          backdropFilter: 'blur(12px)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <CallsBackButton onClick={back} label="Back to chat" />
          <div style={{ minWidth: 0, flex: 1 }}>
            <h1
              style={{
                margin: 0,
                fontSize: '24px',
                fontWeight: 800,
                letterSpacing: '-0.5px',
                color: 'var(--text-primary)',
                fontFamily: 'var(--font-heading)',
              }}
            >
              Calls
            </h1>
            <p style={{ margin: '2px 0 0', fontSize: '12px', color: 'var(--text-secondary)' }}>
              Audio calls, video calls and call history
            </p>
          </div>
        </div>

        {/* Audio | Video | History */}
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
          {TABS.map(({ id, label, count, Icon }) => {
            const isActive = tab === id;
            return (
              <button
                key={id}
                type="button"
                onClick={() => selectTab(id)}
                aria-pressed={isActive}
                style={{
                  flex: 1,
                  minWidth: 0,
                  padding: '8px',
                  borderRadius: 'var(--radius-sm)',
                  border: 'none',
                  fontSize: '12.5px',
                  fontWeight: isActive ? 700 : 500,
                  color: isActive ? '#ffffff' : 'var(--text-secondary)',
                  background: isActive ? 'var(--gradient-flame)' : 'transparent',
                  cursor: 'pointer',
                  transition: 'all var(--transition-fast)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                  whiteSpace: 'nowrap',
                }}
              >
                <Icon size={14} aria-hidden="true" />
                <span>{label}</span>
                {count !== null && (
                  <span style={{ fontSize: '10px', opacity: 0.8 }}>({count})</span>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {tab === 'audio' && <ContactList kind="audio" contacts={CALL_CONTACTS} />}
      {tab === 'video' && <ContactList kind="video" contacts={CALL_CONTACTS} />}
      {tab === 'history' && <HistoryPanel />}
    </CallsShell>
  );
};
