import React, { useState } from 'react';
import { CheckCircle2, ArrowRight, Zap, ChevronDown } from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const ProfileCompletionCard: React.FC = () => {
  const {
    profileCompletion,
    completionChecklist,
    setIsVerificationModalOpen,
  } = useProfile();

  const [detailsOpen, setDetailsOpen] = useState(false);

  const handleItemClick = (targetSection: string) => {
    if (targetSection === 'verification') {
      setIsVerificationModalOpen(true);
    } else {
      const elem = document.getElementById(`section-${targetSection}`);
      if (elem) {
        elem.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }
  };

  const handleCardClick = (e: React.MouseEvent) => {
    const target = e.target as HTMLElement;
    if (target.closest('button[data-step-item="true"]')) {
      return;
    }
    e.preventDefault();
    setDetailsOpen((prev) => !prev);
  };

  return (
    <div
      role="button"
      tabIndex={0}
      aria-expanded={detailsOpen}
      style={{
        borderRadius: '22px',
        padding: '16px',
        border: '1px solid rgba(34, 211, 238, 0.4)',
        background: 'linear-gradient(90deg, rgba(34, 211, 238, 0.18) 0%, rgba(20, 16, 26, 0.98) 100%)',
        cursor: 'pointer',
        userSelect: 'none',
        boxShadow: '0 10px 40px rgba(0, 0, 0, 0.4)',
      }}
      onClick={handleCardClick}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          setDetailsOpen((prev) => !prev);
        }
      }}
    >
      {/* Top Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '10px',
              background: 'rgba(34, 211, 238, 0.2)',
              color: '#22d3ee',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: '1px solid rgba(34, 211, 238, 0.5)',
              flexShrink: 0,
            }}
          >
            <Zap size={18} />
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ffffff', margin: 0 }}>
              Profile Progress
            </h3>
            <p style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.65)', margin: '2px 0 0 0' }}>
              Complete your profile to improve connection matches & visibility
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ fontSize: '22px', fontWeight: 900, color: '#22d3ee', letterSpacing: '-0.5px' }}>
            {profileCompletion}%
          </div>
          <button
            onClick={(e) => {
              e.stopPropagation();
              setDetailsOpen((prev) => !prev);
            }}
            aria-label="Toggle completion details"
            style={{
              background: '#1a141f',
              border: '1px solid #2a2030',
              borderRadius: '50%',
              color: '#ffffff',
              cursor: 'pointer',
              width: '36px',
              height: '36px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              transform: detailsOpen ? 'rotate(180deg)' : 'rotate(0deg)',
              transition: 'transform var(--transition-fast)',
            }}
          >
            <ChevronDown size={18} />
          </button>
        </div>
      </div>

      {/* Progress Bar & Step Indicators */}
      <div style={{ marginBottom: detailsOpen ? '16px' : '0px' }}>
        <div
          style={{
            width: '100%',
            height: '8px',
            borderRadius: '999px',
            background: 'rgba(255, 255, 255, 0.12)',
            overflow: 'hidden',
            marginBottom: '10px',
          }}
        >
          <div
            style={{
              width: `${profileCompletion}%`,
              height: '100%',
              background: 'linear-gradient(90deg, #2ed47a 0%, #22d3ee 100%)',
              borderRadius: '999px',
              transition: 'width 0.5s cubic-bezier(0.4, 0, 0.2, 1)',
              boxShadow: '0 0 12px rgba(34, 211, 238, 0.4)',
            }}
          />
        </div>

        {/* 5-step visual track line */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '0 2px' }}>
          {completionChecklist.map((item, idx) => {
            const isCompleted = item.completed;
            const nextNotCompleted = completionChecklist.findIndex((c) => !c.completed) === idx;
            return (
              <div
                key={`bar-step-${item.id}`}
                style={{
                  flex: 1,
                  height: '6px',
                  borderRadius: '999px',
                  background: isCompleted
                    ? 'linear-gradient(90deg, #2ed47a 0%, #22d3ee 100%)'
                    : nextNotCompleted
                    ? 'rgba(34, 211, 238, 0.5)'
                    : 'rgba(255, 255, 255, 0.18)',
                  boxShadow: isCompleted ? '0 0 8px rgba(46, 212, 122, 0.4)' : undefined,
                  transition: 'background 0.3s ease',
                }}
                title={`Step ${idx + 1}: ${item.title}`}
              />
            );
          })}
        </div>
      </div>

      {/* Checklist */}
      {detailsOpen && (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: '10px',
            marginTop: '16px',
            paddingTop: '14px',
            borderTop: '1px solid rgba(255, 255, 255, 0.12)',
          }}
        >
          {completionChecklist.map((item, index) => (
            <button
              key={item.id}
              data-step-item="true"
              onClick={(e) => {
                e.stopPropagation();
                handleItemClick(item.targetSection);
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '11px 13px',
                borderRadius: '14px',
                background: item.completed
                  ? 'rgba(46, 212, 122, 0.12)'
                  : '#14101a',
                border: item.completed
                  ? '1px solid rgba(46, 212, 122, 0.5)'
                  : '1px solid #2a2030',
                cursor: 'pointer',
                textAlign: 'left',
                transition: 'all var(--transition-fast)',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <div
                  style={{
                    width: '24px',
                    height: '24px',
                    borderRadius: '50%',
                    background: item.completed ? '#2ed47a' : 'rgba(255, 255, 255, 0.12)',
                    color: item.completed ? '#000000' : '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '11.5px',
                    fontWeight: 800,
                    flexShrink: 0,
                  }}
                >
                  {item.completed ? <CheckCircle2 size={16} color="#000000" /> : index + 1}
                </div>

                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <span
                    style={{
                      fontSize: '12.5px',
                      fontWeight: 700,
                      color: '#ffffff',
                    }}
                  >
                    {item.title}
                  </span>
                  <span
                    style={{
                      fontSize: '10.5px',
                      fontWeight: 600,
                      color: item.completed ? '#2ed47a' : 'rgba(255, 255, 255, 0.65)',
                      marginTop: '2px',
                    }}
                  >
                    {item.completed ? 'Completed' : 'Pending step'}
                  </span>
                </div>
              </div>

              {!item.completed && (
                <ArrowRight size={15} color="#22d3ee" style={{ flexShrink: 0, marginLeft: '6px' }} />
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
};
