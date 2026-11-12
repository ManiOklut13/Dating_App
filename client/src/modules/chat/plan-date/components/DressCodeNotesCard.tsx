import React, { useState } from 'react';
import { Pencil } from 'lucide-react';
import { planDateTheme } from '../theme';

interface DressCodeNotesCardProps {
  proposalNote: string;
  partnerNote: string;
  onProposalNoteChange: (note: string) => void;
  onPartnerNoteChange: (note: string) => void;
  selectedDressCode: string;
  onDressCodeChange: (code: string) => void;
  maxLength?: number;
}

const DRESS_CODES = ['Casual', 'Smart casual', 'Formal', 'Cozy', 'Theme night'];

export const DressCodeNotesCard: React.FC<DressCodeNotesCardProps> = ({
  proposalNote,
  partnerNote,
  onProposalNoteChange,
  onPartnerNoteChange,
  selectedDressCode,
  onDressCodeChange,
  maxLength = 200,
}) => {
  const [editMode, setEditMode] = useState(false);

  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '12px',
        }}
      >
        <h3
          style={{
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          Dress Code & Notes
        </h3>
        <button
          onClick={() => setEditMode(!editMode)}
          aria-label={editMode ? 'Done editing' : 'Edit dress code and notes'}
          style={{
            height: '44px',
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            background: editMode ? planDateTheme.gradients.primary : planDateTheme.colors.raisedButton,
            border: editMode ? 'none' : `1px solid ${planDateTheme.colors.raisedButtonBorder}`,
            color: editMode ? '#FFFFFF' : planDateTheme.colors.accentPink4,
            fontSize: '14px',
            fontWeight: planDateTheme.typography.weights.semibold,
            fontFamily: planDateTheme.typography.fontFamily,
            padding: '0 16px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
          }}
        >
          {editMode ? (
            'Done'
          ) : (
            <>
              <Pencil size={16} />
              Edit
            </>
          )}
        </button>
      </div>

      <div style={{ marginBottom: '12px' }}>
        <div
          style={{
            fontSize: '12px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.muted,
            letterSpacing: '1px',
            marginBottom: '8px',
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          DRESS CODE
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
          {DRESS_CODES.map((code) => (
            <button
              key={code}
              onClick={() => editMode && onDressCodeChange(code)}
              disabled={!editMode}
              style={{
                height: '44px',
                borderRadius: `${planDateTheme.borderRadius.inner}px`,
                backgroundColor: !editMode
                  ? '#16101D'
                  : selectedDressCode === code
                  ? planDateTheme.colors.raisedButton
                  : planDateTheme.colors.idleChip,
                border: `1px solid ${
                  !editMode
                    ? '#221A2C'
                    : selectedDressCode === code
                    ? planDateTheme.colors.raisedButtonBorder
                    : planDateTheme.colors.idleChipBorder
                }`,
                color: !editMode ? '#8F83A3' : planDateTheme.colors.softText,
                fontSize: '14px',
                fontWeight: planDateTheme.typography.weights.semibold,
                fontFamily: planDateTheme.typography.fontFamily,
                padding: '0 16px',
                cursor: editMode ? 'pointer' : 'not-allowed',
                transition: 'all 0.2s ease',
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              {code}
            </button>
          ))}
        </div>
      </div>

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
              opacity: editMode ? 1 : 0.7,
            }}
          >
            <textarea
              value={proposalNote}
              onChange={(e) => editMode && onProposalNoteChange(e.target.value.slice(0, maxLength))}
              placeholder="Add notes..."
              readOnly={!editMode}
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
              opacity: 0.7,
            }}
          >
            <textarea
              value={partnerNote}
              readOnly
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
