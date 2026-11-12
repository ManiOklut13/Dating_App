import React from 'react';
import { Calendar, MessageCircle, Video, Image } from 'lucide-react';
import { planDateTheme } from '../theme';

interface AboutPlanDateCardProps {
  step3Text?: string;
}

export const AboutPlanDateCard: React.FC<AboutPlanDateCardProps> = ({
  step3Text = 'Virtual: join the video date from chat.',
}) => {
  const steps = [
    {
      number: 1,
      text: 'Propose (type, time, to-dos, send with 150 coins)',
      icon: <Calendar size={16} />,
    },
    {
      number: 2,
      text: 'Partner replies (accept or suggest a new time in chat)',
      icon: <MessageCircle size={16} />,
    },
    {
      number: 3,
      text: step3Text,
      icon: <Video size={16} />,
    },
    {
      number: 4,
      text: 'After the date (add photos and a rating to shared memories)',
      icon: <Image size={16} />,
    },
  ];

  return (
    <div
      style={{
        background: planDateTheme.gradients.highlightCard,
        border: `1px solid ${planDateTheme.colors.highlightCardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
        <div
          style={{
            width: `${planDateTheme.sizes.iconSquare}px`,
            height: `${planDateTheme.sizes.iconSquare}px`,
            borderRadius: '10px',
            backgroundColor: 'rgba(255,61,129,.14)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: planDateTheme.colors.accentText,
            flexShrink: 0,
          }}
        >
          <Calendar size={18} />
        </div>
        <h3
          style={{
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            margin: 0,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          About Plan a Date
        </h3>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {steps.map((step) => (
          <div key={step.number} style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
            <div
              style={{
                width: `${planDateTheme.sizes.stepCircle}px`,
                height: `${planDateTheme.sizes.stepCircle}px`,
                borderRadius: '50%',
                background: planDateTheme.gradients.primary,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF',
                fontSize: '13px',
                fontWeight: planDateTheme.typography.weights.bold,
                flexShrink: 0,
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {step.number}
            </div>
            <div
              style={{
                flex: 1,
                fontSize: '14px',
                color: '#D9CFE6',
                fontFamily: planDateTheme.typography.fontFamily,
                lineHeight: '1.5',
                paddingTop: '4px',
              }}
            >
              {step.text.includes('150 coins') ? (
                <>
                  Propose (type, time, to-dos, send with{' '}
                  <span style={{ color: planDateTheme.colors.text, fontWeight: planDateTheme.typography.weights.bold }}>
                    150 coins
                  </span>
                  )
                </>
              ) : step.number === 2 ? (
                <>
                  Partner replies (accept or suggest a new time in{' '}
                  <span style={{ color: planDateTheme.colors.text, fontWeight: planDateTheme.typography.weights.bold }}>
                    chat
                  </span>
                  )
                </>
              ) : step.number === 4 ? (
                <>
                  After the date (add photos and a rating to{' '}
                  <span style={{ color: planDateTheme.colors.text, fontWeight: planDateTheme.typography.weights.bold }}>
                    shared memories
                  </span>
                  )
                </>
              ) : (
                <span style={{ color: planDateTheme.colors.text, fontWeight: planDateTheme.typography.weights.bold }}>
                  {step.text}
                </span>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
