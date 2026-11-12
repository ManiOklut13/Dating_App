import React, { useCallback, useMemo, useState } from 'react';
import { Phone, Video, PhoneCall, Info } from 'lucide-react';
import { useCalls } from './CallsContext';
import { useCallHistory } from './useCallHistory';
import { startCall } from './api';
import { useChat } from '../chat/ChatContext';
import { CallCounterpart, CallType, formatDuration } from './types';
import {
  CallHistoryCard,
  CallsEmptyState,
  CallsError,
  CallsHeader,
  CallsLoading,
  CallsSearchInput,
  CallsShell,
} from './CallsUI';

/* ==========================================================================
   Audio / Video call history page.

   One component serves both routes: the call_type comes from the route, and
   the API is always filtered by that type, so audio records can never appear
   on the video page (and vice versa).
   ========================================================================== */

const CONFIG: Record<CallType, {
  title: string;
  subtitle: string;
  accent: string;
  emptyTitle: string;
  emptyDescription: string;
  searchPlaceholder: string;
  startCta: string;
}> = {
  audio: {
    title: 'Audio Calls',
    subtitle: 'Voice calls over an encrypted LiveKit room',
    accent: '#00e5ff',
    emptyTitle: 'No audio call history yet',
    emptyDescription: 'Once you make or receive an audio call, it will show up here.',
    searchPlaceholder: 'Search audio calls by name',
    startCta: 'Start audio call',
  },
  video: {
    title: 'Video Calls',
    subtitle: 'Video calls over an encrypted LiveKit room',
    accent: '#ff2d55',
    emptyTitle: 'No video call history yet',
    emptyDescription: 'Once you make or receive a video call, it will show up here.',
    searchPlaceholder: 'Search video calls by name',
    startCta: 'Start video call',
  },
};

interface StartCallSheetProps {
  type: CallType;
  accent: string;
  contacts: CallCounterpart[];
  onClose: () => void;
}

const StartCallSheet: React.FC<StartCallSheetProps> = ({ type, accent, contacts, onClose }) => {
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [result, setResult] = useState<{ ok: boolean; message: string } | null>(null);
  const isVideo = type === 'video';
  const { setAudioCallTarget, setVideoCallTarget } = useChat();

  const placeCall = async (contact: CallCounterpart) => {
    setPendingId(contact.user_id);
    setResult(null);
    try {
      const session = await startCall(contact.user_id, type);
      setResult({
        ok: true,
        message: `Room ${session.livekit_room_sid} opened for ${contact.nickname}. Balance: ${session.caller_balance} coins.`,
      });
      const callTarget = {
        id: `conv-${contact.user_id}`,
        counterpart: {
          id: contact.user_id,
          nickname: contact.nickname,
          avatar: contact.avatar,
          age: 0,
          city: contact.city || '',
          occupation: '',
          bio: '',
          interests: [],
          is_verified: false,
          is_online: true,
          vibe_score: 0,
        },
        is_pinned: false,
        is_muted: false,
        is_locked: false,
        unread_count: 0,
        last_message: {
          id: `call-${session.call_id || contact.user_id}`,
          conv_id: `conv-${contact.user_id}`,
          sender_id: 'system',
          type: 'text' as const,
          body: '',
          status: 'sending' as const,
          created_at: new Date().toISOString(),
        },
      };

      if (isVideo) {
        setVideoCallTarget(callTarget);
      } else {
        setAudioCallTarget(callTarget);
      }
      onClose();
    } catch (error: any) {
      setResult({ ok: false, message: error?.message || 'The call could not be started.' });
    } finally {
      setPendingId(null);
    }
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={`Start a new ${type} call`}
      onClick={onClose}
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9600,
        background: 'rgba(5, 6, 12, 0.82)',
        backdropFilter: 'blur(16px)',
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'center',
        padding: '16px',
      }}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: 520,
          borderRadius: 'var(--radius-lg)',
          border: '1px solid var(--border-glass)',
          padding: '20px',
          maxHeight: '80vh',
          overflowY: 'auto',
        }}
      >
        <h3 style={{ margin: 0, fontSize: '17px', fontWeight: 800, color: 'var(--text-primary)' }}>
          {isVideo ? 'Start a video call' : 'Start an audio call'}
        </h3>
        <p style={{ margin: '4px 0 16px', fontSize: '12.5px', color: 'var(--text-secondary)' }}>
          Pick someone from your recent {type} call history.
        </p>

        {result && (
          <div
            role="status"
            style={{
              marginBottom: '14px',
              padding: '10px 12px',
              borderRadius: 'var(--radius-md)',
              fontSize: '12px',
              lineHeight: 1.45,
              background: result.ok ? 'rgba(0, 230, 118, 0.1)' : 'rgba(255, 71, 87, 0.1)',
              border: `1px solid ${result.ok ? 'rgba(0,230,118,0.35)' : 'rgba(255,71,87,0.35)'}`,
              color: result.ok ? '#00e676' : '#ff4757',
              display: 'flex',
              gap: '8px',
              alignItems: 'flex-start',
            }}
          >
            <Info size={14} aria-hidden="true" style={{ flexShrink: 0, marginTop: 1 }} />
            <span>{result.message}</span>
          </div>
        )}

        {contacts.length === 0 ? (
          <p style={{ fontSize: '13px', color: 'var(--text-secondary)', margin: 0 }}>
            No eligible contacts yet. Make a call first and they will appear here.
          </p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {contacts.map((contact) => (
              <div
                key={contact.user_id}
                className="glass-panel"
                style={{
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-glass)',
                  padding: '10px 12px',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                }}
              >
                <img
                  src={contact.avatar}
                  alt=""
                  loading="lazy"
                  style={{ width: '40px', height: '40px', borderRadius: '50%', objectFit: 'cover' }}
                />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div
                    style={{
                      fontWeight: 700,
                      fontSize: '14px',
                      color: 'var(--text-primary)',
                      whiteSpace: 'nowrap',
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                    }}
                  >
                    {contact.nickname}
                  </div>
                  {contact.city && (
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{contact.city}</div>
                  )}
                </div>
                <button
                  type="button"
                  onClick={() => placeCall(contact)}
                  disabled={pendingId !== null}
                  aria-label={`Call ${contact.nickname}`}
                  style={{
                    width: '38px',
                    height: '38px',
                    borderRadius: '50%',
                    flexShrink: 0,
                    background: `${accent}1f`,
                    border: `1px solid ${accent}55`,
                    color: accent,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: pendingId ? 'wait' : 'pointer',
                    opacity: pendingId === contact.user_id ? 0.5 : 1,
                  }}
                >
                  {isVideo ? <Video size={16} /> : <PhoneCall size={16} />}
                </button>
              </div>
            ))}
          </div>
        )}

        <button
          type="button"
          onClick={onClose}
          className="btn-ghost"
          style={{ marginTop: '18px', width: '100%', padding: '10px', fontSize: '13px' }}
        >
          Close
        </button>
      </div>
    </div>
  );
};

export const CallHistoryPage: React.FC<{ type: CallType }> = ({ type }) => {
  const { navigate, back } = useCalls();
  const [search, setSearch] = useState('');
  const [isPickerOpen, setIsPickerOpen] = useState(false);

  const { records, total, hasMore, isLoading, isLoadingMore, error, loadMore, retry } =
    useCallHistory(type, search);

  const config = CONFIG[type];
  const isVideo = type === 'video';
  const AccentIcon = isVideo ? Video : Phone;

  const openDetail = useCallback(
    (callId: string) => navigate(isVideo ? { name: 'video-detail', callId } : { name: 'audio-detail', callId }),
    [navigate, isVideo],
  );

  const { setAudioCallTarget, setVideoCallTarget } = useChat();

  const directCall = useCallback(
    async (contact: CallCounterpart) => {
      try {
        const session = await startCall(contact.user_id, type);
        const callTarget = {
          id: `conv-${contact.user_id}`,
          counterpart: {
            id: contact.user_id,
            nickname: contact.nickname,
            avatar: contact.avatar,
            age: 0,
            city: contact.city || '',
            occupation: '',
            bio: '',
            interests: [],
            is_verified: false,
            is_online: true,
            vibe_score: 0,
          },
          is_pinned: false,
          is_muted: false,
          is_locked: false,
          unread_count: 0,
          last_message: {
            id: `call-${session.call_id || contact.user_id}`,
            conv_id: `conv-${contact.user_id}`,
            sender_id: 'system',
            type: 'text' as const,
            body: '',
            status: 'sending' as const,
            created_at: new Date().toISOString(),
          },
        };

        if (isVideo) {
          setVideoCallTarget(callTarget);
        } else {
          setAudioCallTarget(callTarget);
        }
      } catch (err) {
        console.error('Call failed', err);
      }
    },
    [type, isVideo, setAudioCallTarget, setVideoCallTarget],
  );

  // Eligible contacts: everyone already in this call_type's history.
  const contacts = useMemo(() => {
    const seen = new Set<string>();
    const list: CallCounterpart[] = [];
    records.forEach((record) => {
      if (seen.has(record.counterpart.user_id)) return;
      seen.add(record.counterpart.user_id);
      list.push(record.counterpart);
    });
    return list;
  }, [records]);

  const showEmptyState = !isLoading && !error && records.length === 0;
  const showNoMatchState = showEmptyState && search.trim().length > 0;

  return (
    <CallsShell>
      <CallsHeader
        title={config.title}
        subtitle={config.subtitle}
        accent={config.accent}
        onBack={back}
        backLabel={`Back to Calls`}
        action={
          <button
            type="button"
            onClick={() => setIsPickerOpen(true)}
            aria-label={config.startCta}
            title={config.startCta}
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              padding: '9px 14px',
              borderRadius: 'var(--radius-full)',
              background: `${config.accent}1f`,
              border: `1px solid ${config.accent}55`,
              color: config.accent,
              fontSize: '12.5px',
              fontWeight: 700,
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            {isVideo ? <Video size={15} /> : <PhoneCall size={15} />}
            <span className="calls-start-label">New call</span>
          </button>
        }
      />

      <CallsSearchInput
        value={search}
        onChange={setSearch}
        placeholder={config.searchPlaceholder}
      />

      {!search.trim() && total > 0 && (
        <p style={{ margin: '-6px 0 12px', fontSize: '12px', color: 'var(--text-muted)' }}>
          {total} {type} call{total === 1 ? '' : 's'} · most recent first
        </p>
      )}

      {isLoading && <CallsLoading />}

      {error && !isLoading && <CallsError message={error} onRetry={retry} />}

      {showEmptyState && (
        <CallsEmptyState
          icon={<AccentIcon size={26} />}
          title={showNoMatchState ? 'No matching calls' : config.emptyTitle}
          description={
            showNoMatchState
              ? `No ${type} calls match "${search.trim()}". Try a different name.`
              : config.emptyDescription
          }
          action={
            <button
              type="button"
              onClick={() => setIsPickerOpen(true)}
              className="btn-primary"
              style={{ padding: '10px 20px', fontSize: '13px', gap: '6px' }}
            >
              {isVideo ? <Video size={15} /> : <PhoneCall size={15} />}
              {config.startCta}
            </button>
          }
        />
      )}

      {!isLoading && !error && records.length > 0 && (
        <>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {records.map((record) => (
              <CallHistoryCard
                key={record.call_id}
                record={record}
                onOpen={() => openDetail(record.call_id)}
                onStartCall={() => directCall(record.counterpart)}
              />
            ))}
          </div>

          {hasMore && (
            <button
              type="button"
              onClick={loadMore}
              disabled={isLoadingMore}
              className="btn-ghost"
              style={{ marginTop: '16px', width: '100%', padding: '11px', fontSize: '13px' }}
            >
              {isLoadingMore ? 'Loading…' : 'Load more'}
            </button>
          )}

          {!hasMore && records.length >= 20 && (
            <p style={{ textAlign: 'center', marginTop: '16px', fontSize: '11.5px', color: 'var(--text-muted)' }}>
              That's the end of your {type} call history · total duration{' '}
              {formatDuration(records.reduce((sum, r) => sum + r.duration_seconds, 0))} on this page
            </p>
          )}
        </>
      )}

      {isPickerOpen && (
        <StartCallSheet
          type={type}
          accent={config.accent}
          contacts={contacts}
          onClose={() => setIsPickerOpen(false)}
        />
      )}
    </CallsShell>
  );
};