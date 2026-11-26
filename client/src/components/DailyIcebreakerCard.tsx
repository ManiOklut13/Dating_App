import React, { useState } from 'react';
import { MessageSquare, Sparkles, Check, CheckCircle2 } from 'lucide-react';

export interface IcebreakerOption {
  id: string;
  text: string;
  votesPercent: number;
}

export interface DailyIcebreakerCardProps {
  prompt?: string;
  category?: string;
  options?: IcebreakerOption[];
  onSelectOption?: (optionId: string) => void;
}

export const DailyIcebreakerCard: React.FC<DailyIcebreakerCardProps> = ({
  prompt = 'Subko Coffee or Blue Tokai: Which one wins your vote for a first date in Mumbai?',
  category = 'Lifestyle & Cafe Culture',
  options = [
    { id: 'opt_1', text: 'Subko Bandra (Artisanal cold brew & sourdough)', votesPercent: 48 },
    { id: 'opt_2', text: 'Blue Tokai (Relaxed ambience & classic pour-overs)', votesPercent: 36 },
    { id: 'opt_3', text: 'Marine Drive sunset cutting chai instead 🌅', votesPercent: 16 },
  ],
  onSelectOption,
}) => {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [hasVoted, setHasVoted] = useState(false);

  const handleSelect = (optionId: string) => {
    setSelectedId(optionId);
    setHasVoted(true);
    if (onSelectOption) {
      onSelectOption(optionId);
    }
  };

  return (
    <div
      className="glass-panel"
      style={{
        borderRadius: 'var(--radius-lg)',
        padding: '20px',
        border: '1px solid rgba(255, 45, 85, 0.2)',
        background: 'radial-gradient(circle at 10% 10%, rgba(255, 45, 85, 0.08) 0%, rgba(20, 24, 38, 0.8) 100%)',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      {/* Category Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <div
            style={{
              width: '24px',
              height: '24px',
              borderRadius: '6px',
              background: 'rgba(255, 45, 85, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Sparkles size={14} color="#ff2d55" />
          </div>
          <span style={{ fontSize: '11px', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 700, color: '#ff6b8b' }}>
            Daily Vibe Prompt • {category}
          </span>
        </div>
        <span
          className="glass-pill"
          style={{ fontSize: '11px', padding: '3px 8px', color: 'var(--text-muted)' }}
        >
          Community Poll
        </span>
      </div>

      {/* Main Prompt Question */}
      <h3 style={{ fontSize: '16px', fontWeight: 700, lineHeight: 1.4, marginBottom: '14px', color: '#ffffff' }}>
        "{prompt}"
      </h3>

      {/* Response Options */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {options.map((opt) => {
          const isSelected = selectedId === opt.id;
          return (
            <button
              key={opt.id}
              onClick={() => handleSelect(opt.id)}
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '12px 14px',
                borderRadius: 'var(--radius-md)',
                border: isSelected
                  ? '1.5px solid #ff2d55'
                  : '1px solid rgba(255, 255, 255, 0.08)',
                background: isSelected
                  ? 'rgba(255, 45, 85, 0.12)'
                  : 'rgba(255, 255, 255, 0.03)',
                color: isSelected ? '#ffffff' : 'var(--text-secondary)',
                fontSize: '13px',
                fontWeight: isSelected ? 600 : 500,
                textAlign: 'left',
                cursor: 'pointer',
                overflow: 'hidden',
                transition: 'all var(--transition-fast)',
              }}
            >
              {/* Progress background bar when voted */}
              {hasVoted && (
                <div
                  style={{
                    position: 'absolute',
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: `${opt.votesPercent}%`,
                    background: isSelected
                      ? 'linear-gradient(90deg, rgba(255, 45, 85, 0.25), rgba(255, 45, 85, 0.1))'
                      : 'rgba(255, 255, 255, 0.05)',
                    transition: 'width 0.6s ease-out',
                    pointerEvents: 'none',
                  }}
                />
              )}

              <span style={{ position: 'relative', zIndex: 2, display: 'flex', alignItems: 'center', gap: '8px' }}>
                {isSelected ? (
                  <CheckCircle2 size={16} color="#ff2d55" />
                ) : (
                  <div
                    style={{
                      width: '14px',
                      height: '14px',
                      borderRadius: '50%',
                      border: '1.5px solid rgba(255, 255, 255, 0.25)',
                    }}
                  />
                )}
                <span>{opt.text}</span>
              </span>

              {hasVoted && (
                <span
                  style={{
                    position: 'relative',
                    zIndex: 2,
                    fontSize: '12px',
                    fontWeight: 700,
                    color: isSelected ? '#ff2d55' : 'var(--text-muted)',
                  }}
                >
                  {opt.votesPercent}%
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Visual Feedback Bar */}
      {hasVoted && (
        <div
          style={{
            marginTop: '12px',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '12px',
            color: 'var(--cyan-vibe)',
          }}
        >
          <Check size={14} />
          <span>Your answer was saved and matched with fellow coffee enthusiasts nearby!</span>
        </div>
      )}
    </div>
  );
};
