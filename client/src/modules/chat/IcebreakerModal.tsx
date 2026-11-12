import React from 'react';
import { X, Sparkles, Send, Edit3 } from 'lucide-react';
import { useChat } from './ChatContext';
import { ICEBREAKER_PROMPTS } from './mockData';

interface IcebreakerModalProps {
  onInsertToInput: (prompt: string) => void;
}

export const IcebreakerModal: React.FC<IcebreakerModalProps> = ({ onInsertToInput }) => {
  const { icebreakerConv, setIcebreakerConv, sendMessage, showToast } = useChat();

  if (!icebreakerConv) return null;

  const handleSelectPrompt = (prompt: string, sendDirectly: boolean) => {
    if (sendDirectly) {
      const res = sendMessage(icebreakerConv.id, {
        type: 'icebreaker',
        body: prompt,
        icebreaker_prompt: {
          question: prompt,
        },
      });
      if (res.success) {
        showToast({
          type: 'success',
          text: `Icebreaker prompt sent to ${icebreakerConv.counterpart.nickname}!`,
        });
      }
    } else {
      onInsertToInput(prompt);
      showToast({
        type: 'info',
        text: 'Prompt inserted into message composer.',
      });
    }
    setIcebreakerConv(null);
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
      onClick={() => setIcebreakerConv(null)}
    >
      <div
        className="glass-panel"
        style={{
          width: '100%',
          maxWidth: '500px',
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
                background: 'rgba(0, 229, 255, 0.15)',
                color: '#00e5ff',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Sparkles size={18} />
            </div>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: 800 }}>Dating Icebreakers</h2>
              <p style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>
                Spark engaging conversations with {icebreakerConv.counterpart.nickname}
              </p>
            </div>
          </div>

          <button
            onClick={() => setIcebreakerConv(null)}
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

        {/* Prompt List */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {ICEBREAKER_PROMPTS.map((prompt, index) => (
            <div
              key={index}
              style={{
                padding: '14px 16px',
                borderRadius: 'var(--radius-md)',
                background: 'var(--surface-faint)',
                border: '1px solid var(--border-glass)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: '12px',
                transition: 'all var(--transition-fast)',
              }}
            >
              <div style={{ fontSize: '13.5px', fontWeight: 600, color: 'var(--text-primary)', flex: 1 }}>
                "{prompt}"
              </div>

              <div style={{ display: 'flex', gap: '6px' }}>
                <button
                  onClick={() => handleSelectPrompt(prompt, false)}
                  className="btn-ghost"
                  style={{ padding: '6px 10px', fontSize: '11px', gap: '4px' }}
                  title="Insert into text composer"
                >
                  <Edit3 size={13} />
                  Insert
                </button>
                <button
                  onClick={() => handleSelectPrompt(prompt, true)}
                  className="btn-primary"
                  style={{ padding: '6px 12px', fontSize: '11px', gap: '4px' }}
                  title="Send immediately"
                >
                  <Send size={13} />
                  Send
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
