import React from 'react';
import { Heart, Calendar, Clock, Users, Coins, ArrowLeft, Image } from 'lucide-react';
import { planDateTheme } from '../theme';

interface DateProposedScreenProps {
  partnerName: string;
  mode: 'virtual' | 'offline';
  dateType: string;
  spotName?: string;
  date: string;
  time: string;
  duration: number;
  split: string;
  cost: number;
  onBackToChat: () => void;
  onViewAfterDate: () => void;
}

export const DateProposedScreen: React.FC<DateProposedScreenProps> = ({
  partnerName,
  mode,
  dateType,
  spotName,
  date,
  time,
  duration,
  split,
  cost,
  onBackToChat,
  onViewAfterDate,
}) => {
  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 10000,
        backgroundColor: planDateTheme.colors.background,
        backgroundImage: `${planDateTheme.gradients.backgroundRadialPink}, ${planDateTheme.gradients.backgroundRadialViolet}`,
        backgroundPosition: 'top right, top left',
        backgroundRepeat: 'no-repeat',
        display: 'flex',
        flexDirection: 'column',
        padding: `${planDateTheme.spacing.screenPadding}px`,
        fontFamily: planDateTheme.typography.fontFamily,
      }}
    >
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: '24px' }}>
        <div style={{ position: 'relative', width: '120px', height: '120px' }}>
          <div
            style={{
              position: 'absolute',
              width: '80px',
              height: '80px',
              borderRadius: '50%',
              background: 'rgba(232,34,111,0.2)',
              border: '2px dashed rgba(232,34,111,0.5)',
              top: '20px',
              left: '20px',
            }}
          />
          <Heart
            size={60}
            color="#FF5C9A"
            fill="#FF5C9A"
            style={{ position: 'absolute', top: '30px', left: '20px' }}
          />
          <Heart
            size={50}
            color="#8B5CF6"
            fill="#8B5CF6"
            style={{ position: 'absolute', top: '40px', left: '50px', opacity: 0.8 }}
          />
        </div>

        <div style={{ textAlign: 'center' }}>
          <h1
            style={{
              fontSize: '28px',
              fontWeight: planDateTheme.typography.weights.extrabold,
              color: planDateTheme.colors.text,
              margin: '0 0 8px 0',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            Date proposed!
          </h1>
          <p
            style={{
              fontSize: '14px',
              color: planDateTheme.colors.muted,
              margin: 0,
              fontFamily: planDateTheme.typography.fontFamily,
              maxWidth: '280px',
              lineHeight: '1.5',
            }}
          >
            {partnerName} will get your invite in chat. You'll be notified as soon as she responds.
          </p>
        </div>

        <div
          style={{
            width: '100%',
            maxWidth: '340px',
            background: planDateTheme.gradients.highlightCard,
            border: `1px solid ${planDateTheme.colors.highlightCardBorder}`,
            borderRadius: `${planDateTheme.borderRadius.card}px`,
            padding: '16px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
            <div
              style={{
                width: '44px',
                height: '44px',
                borderRadius: '12px',
                background: planDateTheme.gradients.primary,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF',
                flexShrink: 0,
              }}
            >
              <Calendar size={20} />
            </div>
            <div>
              <div
                style={{
                  fontSize: '15px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {dateType}
              </div>
              <div
                style={{
                  fontSize: '13px',
                  color: planDateTheme.colors.muted,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {mode === 'virtual' ? 'Virtual Date' : `Offline Date${spotName ? ` at ${spotName}` : ''}`} with {partnerName}
              </div>
            </div>
          </div>

          <div style={{ height: '1px', backgroundColor: planDateTheme.colors.cardBorder, marginBottom: '12px' }} />

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div>
              <div
                style={{
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.placeholder,
                  letterSpacing: '1px',
                  marginBottom: '4px',
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                WHEN
              </div>
              <div
                style={{
                  fontSize: '14px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {date} · {time}
              </div>
            </div>
            <div>
              <div
                style={{
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.placeholder,
                  letterSpacing: '1px',
                  marginBottom: '4px',
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                DURATION
              </div>
              <div
                style={{
                  fontSize: '14px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {duration} min
              </div>
            </div>
            <div>
              <div
                style={{
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.placeholder,
                  letterSpacing: '1px',
                  marginBottom: '4px',
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                SPLIT BILL
              </div>
              <div
                style={{
                  fontSize: '14px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {split}
              </div>
            </div>
            <div>
              <div
                style={{
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.placeholder,
                  letterSpacing: '1px',
                  marginBottom: '4px',
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                COST
              </div>
              <div
                style={{
                  fontSize: '14px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                }}
              >
                <Coins size={14} color={planDateTheme.colors.coin} />
                {cost} coins
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        <button
          onClick={onBackToChat}
          style={{
            width: '100%',
            height: '60px',
            borderRadius: '20px',
            background: planDateTheme.gradients.primary,
            border: 'none',
            color: '#FFFFFF',
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.extrabold,
            fontFamily: planDateTheme.typography.fontFamily,
            cursor: 'pointer',
            boxShadow: planDateTheme.colors.ctaShadow,
          }}
        >
          Back to chat
        </button>
        <button
          onClick={onViewAfterDate}
          style={{
            width: '100%',
            height: '60px',
            borderRadius: '20px',
            backgroundColor: planDateTheme.colors.card,
            border: `1px solid ${planDateTheme.colors.raisedButtonBorder}`,
            color: planDateTheme.colors.text,
            fontSize: '16px',
            fontWeight: planDateTheme.typography.weights.extrabold,
            fontFamily: planDateTheme.typography.fontFamily,
            cursor: 'pointer',
          }}
        >
          View After the Date
        </button>
      </div>
    </div>
  );
};
