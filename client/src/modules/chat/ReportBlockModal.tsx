import React, { useState } from 'react';
import { ShieldAlert, UserX, X } from 'lucide-react';
import { useChat } from './ChatContext';

const REPORT_REASONS = [
  'Fake profile or impersonation',
  'Inappropriate or sexually explicit content',
  'Harassment, hate speech, or abuse',
  'Commercial advertising, crypto, or spam',
  'Off-platform solicitation or contact asking',
  'Other safety concern',
];

export const ReportBlockModal: React.FC = () => {
  const {
    reportTarget,
    setReportTarget,
    blockTarget,
    setBlockTarget,
    reportUser,
    blockUser,
  } = useChat();

  const [selectedReason, setSelectedReason] = useState(REPORT_REASONS[0]);
  const [details, setDetails] = useState('');

  // Handle Report Submission
  const handleReportSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!reportTarget) return;
    reportUser(reportTarget.user, selectedReason, reportTarget.requestId);
  };

  // Handle Block Confirmation
  const handleBlockConfirm = () => {
    if (!blockTarget) return;
    blockUser(blockTarget.user, blockTarget.requestId);
  };

  return (
    <>
      {/* Report Modal */}
      {reportTarget && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'rgba(5, 6, 12, 0.85)',
            backdropFilter: 'blur(20px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '16px',
          }}
          onClick={() => setReportTarget(null)}
        >
          <div
            className="glass-panel"
            style={{
              width: '100%',
              maxWidth: '480px',
              borderRadius: 'var(--radius-lg)',
              overflow: 'hidden',
              border: '1px solid rgba(255, 71, 87, 0.4)',
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
                <ShieldAlert size={20} color="#ff4757" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>
                  Report {reportTarget.user.nickname}
                </h3>
              </div>
              <button
                onClick={() => setReportTarget(null)}
                style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}
              >
                <X size={18} />
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleReportSubmit} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Help us keep the YoUnMe community safe. Select the reason for reporting this account:
              </p>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {REPORT_REASONS.map((reason) => (
                  <label
                    key={reason}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '10px',
                      padding: '10px 14px',
                      borderRadius: 'var(--radius-md)',
                      background: selectedReason === reason ? 'rgba(255, 71, 87, 0.12)' : 'var(--surface-faint)',
                      border: selectedReason === reason ? '1px solid #ff4757' : '1px solid var(--border-glass)',
                      cursor: 'pointer',
                      fontSize: '13px',
                    }}
                  >
                    <input
                      type="radio"
                      name="reportReason"
                      value={reason}
                      checked={selectedReason === reason}
                      onChange={() => setSelectedReason(reason)}
                      style={{ accentColor: '#ff4757' }}
                    />
                    <span>{reason}</span>
                  </label>
                ))}
              </div>

              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>
                  Additional details (optional):
                </label>
                <textarea
                  value={details}
                  onChange={(e) => setDetails(e.target.value)}
                  placeholder="Provide context for our trust and safety moderators..."
                  rows={3}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: 'var(--radius-md)',
                    background: 'var(--surface-soft)',
                    border: '1px solid var(--border-glass)',
                    color: 'var(--text-primary)',
                    fontSize: '13px',
                    outline: 'none',
                    resize: 'none',
                  }}
                />
              </div>

              <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
                <button
                  type="button"
                  onClick={() => setReportTarget(null)}
                  className="btn-ghost"
                  style={{ flex: 1, padding: '12px', fontSize: '13px' }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="btn-primary"
                  style={{ flex: 1, padding: '12px', fontSize: '13px', background: '#ff4757' }}
                >
                  Submit Report
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Block Confirmation Modal */}
      {blockTarget && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 99999,
            background: 'rgba(5, 6, 12, 0.85)',
            backdropFilter: 'blur(20px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '16px',
          }}
          onClick={() => setBlockTarget(null)}
        >
          <div
            className="glass-panel"
            style={{
              width: '100%',
              maxWidth: '420px',
              borderRadius: 'var(--radius-lg)',
              padding: '28px 24px',
              textAlign: 'center',
              border: '1px solid rgba(255, 71, 87, 0.4)',
              boxShadow: '0 0 40px rgba(255, 71, 87, 0.25)',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              style={{
                width: '64px',
                height: '64px',
                borderRadius: '50%',
                background: 'rgba(255, 71, 87, 0.15)',
                border: '2px solid #ff4757',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 16px',
              }}
            >
              <UserX size={32} color="#ff4757" />
            </div>

            <h3 style={{ fontSize: '20px', fontWeight: 800, marginBottom: '8px' }}>
              Block {blockTarget.user.nickname}?
            </h3>

            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5, marginBottom: '22px' }}>
              They will not be notified. Their conversation will be permanently removed, and you will no longer encounter each other in Discovery or Connect.
            </p>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => setBlockTarget(null)}
                className="btn-ghost"
                style={{ flex: 1, padding: '12px', fontSize: '13px' }}
              >
                Cancel
              </button>
              <button
                onClick={handleBlockConfirm}
                className="btn-primary"
                style={{ flex: 1, padding: '12px', fontSize: '13px', background: '#ff4757' }}
              >
                Block & Unmatch
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
