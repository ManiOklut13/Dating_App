import React from 'react';
import { planDateTheme } from '../theme';

interface NotesCardProps {
  proposalNote: string;
  partnerNote: string;
  onProposalNoteChange: (note: string) => void;
  onPartnerNoteChange: (note: string) => void;
  maxLength?: number;
}

export const NotesCard: React.FC<NotesCardProps> = ({
  proposalNote,
  partnerNote,
  onProposalNoteChange,
  onPartnerNoteChange,
  maxLength = 200,
}) => {
  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <div style={{ display: 'flex', gap: '10px' }}>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '6px' }}>
          <div
            style={{
              fontSize: '14px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.accentText,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            Proposal Notes
          </div>
          <div
            style={{
              backgroundColor: planDateTheme.colors.innerField,
              borderRadius: `${planDateTheme.borderRadius.medium}px`,
              padding: '10px',
              height: `${planDateTheme.sizes.notesHeight}px`,
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <textarea
              value={proposalNote}
              onChange={(e) => onProposalNoteChange(e.target.value.slice(0, maxLength))}
              placeholder="Add notes..."
              style={{
                flex: 1,
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.text,
                fontSize: '13px',
                fontFamily: planDateTheme.typography.fontFamily,
                resize: 'none',
                outline: 'none',
              }}
            />
            <div
              style={{
                fontSize: '11px',
                color: planDateTheme.colors.placeholder,
                textAlign: 'right',
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {proposalNote.length}/{maxLength}
            </div>
          </div>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '6px' }}>
          <div
            style={{
              fontSize: '14px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.violetText,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            Partner Notes
          </div>
          <div
            style={{
              backgroundColor: planDateTheme.colors.innerField,
              borderRadius: `${planDateTheme.borderRadius.medium}px`,
              padding: '10px',
              height: `${planDateTheme.sizes.notesHeight}px`,
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <textarea
              value={partnerNote}
              onChange={(e) => onPartnerNoteChange(e.target.value.slice(0, maxLength))}
              placeholder="Partner's notes..."
              style={{
                flex: 1,
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.text,
                fontSize: '13px',
                fontFamily: planDateTheme.typography.fontFamily,
                resize: 'none',
                outline: 'none',
              }}
            />
            <div
              style={{
                fontSize: '11px',
                color: planDateTheme.colors.placeholder,
                textAlign: 'right',
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {partnerNote.length}/{maxLength}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
