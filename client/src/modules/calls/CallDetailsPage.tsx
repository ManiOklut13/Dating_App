import React, { useState } from 'react';
import { Phone, Video, PhoneCall, Info, ArrowDownLeft, ArrowUpRight, Clock } from 'lucide-react';
import { useCalls } from './CallsContext';
import { useCallDetail } from './useCallHistory';
import {
  formatCallDateTime,
  formatDuration,
} from './types';
import {
  CallsEmptyState,
  CallsError,
  CallsHeader,
  CallsLoading,
  CallsShell,
} from './CallsUI';

export const CallDetailsPage: React.FC<{ type: 'audio' | 'video' }> = ({ type }) => {
  const { route, navigate } = useCalls();
  const callId = route && 'callId' in route ? route.callId : null;

  const { record, isLoading, error, retry } = useCallDetail(callId);

  const isVideo = type === 'video';
  const AccentIcon = isVideo ? Video : Phone;
  const accent = isVideo ? '#ff2d55' : '#00e5ff';

  const typeMismatch = record !== null && record.call_type !== type;

  return (
    <CallsShell>
      <CallsHeader
        title="Call Details"
        subtitle={`${isVideo ? 'Video' : 'Audio'} call record`}
        accent={accent}
        onBack={() => navigate({ name: type })}
        backLabel={`Back to ${isVideo ? 'Video' : 'Audio'} Calls`}
      />

      {isLoading && <CallsLoading label="Loading call details…" />}

      {error && !isLoading && <CallsError message={error} onRetry={retry} />}

      {typeMismatch && !isLoading && (
        <CallsEmptyState
          icon={<Info size={26} />}
          title="Call not found in this history"
          description={`This record is an ${record!.call_type} call. Open it from the ${record!.call_type} call history instead.`}
          action={
            <button
              type="button"
              onClick={() => navigate({ name: record!.call_type })}
              className="btn-primary"
              style={{ padding: '10px 20px', fontSize: '13px' }}
            >
              Go to {record!.call_type === 'audio' ? 'Audio' : 'Video'} Calls
            </button>
          }
        />
      )}

      {record && !isLoading && !error && !typeMismatch && (
        <div
          className="glass-panel"
          style={{
            borderRadius: 'var(--radius-lg)',
            border: '1px solid var(--border-glass)',
            padding: '24px 20px',
            textAlign: 'center',
            marginBottom: '16px',
          }}
        >
          <div
            style={{
              width: '80px',
              height: '80px',
              margin: '0 auto 12px',
              borderRadius: '50%',
              overflow: 'hidden',
              border: `3px solid ${accent}`,
            }}
          >
            <img
              src={record.counterpart.avatar}
              alt={record.counterpart.nickname}
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
            />
          </div>

          <h2 style={{ margin: 0, fontSize: '20px', fontWeight: 800, color: 'var(--text-primary)' }}>
            {record.counterpart.nickname}
          </h2>

          <div style={{ marginTop: '18px', display: 'flex', flexDirection: 'column', gap: '12px', textAlign: 'left' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '14px', color: 'var(--text-primary)', fontWeight: 600 }}>
              {isVideo ? <Video size={18} color={accent} /> : <Phone size={18} color={accent} />}
              <span>{isVideo ? 'Video Call' : 'Audio Call'}</span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '14px', color: 'var(--text-primary)', fontWeight: 600 }}>
              {record.call_direction === 'incoming' ? (
                <ArrowDownLeft size={18} color="#00e676" />
              ) : (
                <ArrowUpRight size={18} color="#00e5ff" />
              )}
              <span>
                {record.call_direction === 'incoming' ? 'Incoming Call' : 'Outgoing Call'}
                {' • '}
                {formatCallDateTime(record.started_at)}
              </span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '14px', color: 'var(--text-primary)', fontWeight: 600 }}>
              <Clock size={18} color="var(--text-secondary)" />
              <span>
                Duration:{' '}
                {record.duration_seconds > 0 ? formatDuration(record.duration_seconds) : 'No connection'}
              </span>
            </div>
          </div>
        </div>
      )}

      {!isLoading && !error && !record && (
        <CallsEmptyState
          icon={<Info size={26} />}
          title="Call record not found"
          description="This call record could not be loaded. It may have been removed."
          action={
            <button
              type="button"
              onClick={() => navigate({ name: type })}
              className="btn-primary"
              style={{ padding: '10px 20px', fontSize: '13px' }}
            >
              Back to {isVideo ? 'Video' : 'Audio'} Calls
            </button>
          }
        />
      )}
    </CallsShell>
  );
};
