import React from 'react';
import { ChevronUp, ChevronDown, Minus, Plus } from 'lucide-react';
import { planDateTheme } from '../theme';

interface CombinedDateTimeDurationCardProps {
  selectedDate: Date;
  onDateChange: (date: Date) => void;
  hour: number;
  minute: number;
  period: 'AM' | 'PM';
  onHourChange: (hour: number) => void;
  onMinuteChange: (minute: number) => void;
  onPeriodChange: (period: 'AM' | 'PM') => void;
  duration: number;
  onDurationChange: (duration: number) => void;
}

const WEEKDAYS = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

export const CombinedDateTimeDurationCard: React.FC<CombinedDateTimeDurationCardProps> = ({
  selectedDate,
  onDateChange,
  hour,
  minute,
  period,
  onHourChange,
  onMinuteChange,
  onPeriodChange,
  duration,
  onDurationChange,
}) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const year = selectedDate.getFullYear();
  const month = selectedDate.getMonth();
  
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  
  const adjustHour = (delta: number) => {
    let newHour = hour + delta;
    if (newHour > 12) newHour = 1;
    if (newHour < 1) newHour = 12;
    onHourChange(newHour);
  };

  const adjustMinute = (delta: number) => {
    let newMinute = minute + delta;
    if (newMinute > 59) newMinute = 0;
    if (newMinute < 0) newMinute = 59;
    onMinuteChange(newMinute);
  };

  const togglePeriod = () => {
    onPeriodChange(period === 'AM' ? 'PM' : 'AM');
  };

  const handleToday = () => {
    onDateChange(new Date());
  };

  const formatSelectedDate = () => {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const dayName = days[selectedDate.getDay()];
    const day = selectedDate.getDate();
    const monthName = MONTHS[selectedDate.getMonth()].substring(0, 3);
    const year = selectedDate.getFullYear();
    return `Selected: ${dayName}, ${day} ${monthName} ${year}`;
  };

  const decreaseDuration = () => {
    if (duration > 15) onDurationChange(duration - 15);
  };

  const increaseDuration = () => {
    if (duration < 240) onDurationChange(duration + 15);
  };

  const quickChips = [30, 60, 90, 120];

  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: '18px',
        padding: '16px',
        display: 'grid',
        gridTemplateColumns: '140px 1fr',
        gap: '12px',
      }}
    >
      {/* LEFT COLUMN */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        <div>
          <div
            style={{
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              marginBottom: '6px',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            TIME
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            <div style={{ display: 'flex', gap: '4px' }}>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <button
                  onClick={() => adjustHour(1)}
                  aria-label="Increase hour"
                  style={{
                    width: '100%',
                    height: '24px',
                    backgroundColor: 'transparent',
                    border: 'none',
                    color: planDateTheme.colors.accentText,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: 0,
                  }}
                >
                  <ChevronUp size={16} />
                </button>
                <div
                  style={{
                    width: '100%',
                    height: '32px',
                    borderRadius: '8px',
                    backgroundColor: planDateTheme.colors.raisedButton,
                    border: '1px solid #f06aa8',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '16px',
                    fontWeight: planDateTheme.typography.weights.bold,
                    color: planDateTheme.colors.text,
                    fontFamily: planDateTheme.typography.fontFamily,
                  }}
                >
                  {hour.toString().padStart(2, '0')}
                </div>
                <button
                  onClick={() => adjustHour(-1)}
                  aria-label="Decrease hour"
                  style={{
                    width: '100%',
                    height: '24px',
                    backgroundColor: 'transparent',
                    border: 'none',
                    color: planDateTheme.colors.accentText,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: 0,
                  }}
                >
                  <ChevronDown size={16} />
                </button>
              </div>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <button
                  onClick={() => adjustMinute(1)}
                  aria-label="Increase minute"
                  style={{
                    width: '100%',
                    height: '24px',
                    backgroundColor: 'transparent',
                    border: 'none',
                    color: planDateTheme.colors.accentText,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: 0,
                  }}
                >
                  <ChevronUp size={16} />
                </button>
                <div
                  style={{
                    width: '100%',
                    height: '32px',
                    borderRadius: '8px',
                    backgroundColor: planDateTheme.colors.raisedButton,
                    border: '1px solid #f06aa8',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '16px',
                    fontWeight: planDateTheme.typography.weights.bold,
                    color: planDateTheme.colors.text,
                    fontFamily: planDateTheme.typography.fontFamily,
                  }}
                >
                  {minute.toString().padStart(2, '0')}
                </div>
                <button
                  onClick={() => adjustMinute(-1)}
                  aria-label="Decrease minute"
                  style={{
                    width: '100%',
                    height: '24px',
                    backgroundColor: 'transparent',
                    border: 'none',
                    color: planDateTheme.colors.accentText,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: 0,
                  }}
                >
                  <ChevronDown size={16} />
                </button>
              </div>
            </div>
            <button
              onClick={togglePeriod}
              style={{
                width: '100%',
                height: '28px',
                borderRadius: '8px',
                backgroundColor: planDateTheme.colors.idleChip,
                border: '1px solid #f06aa8',
                color: planDateTheme.colors.text,
                fontSize: '12px',
                fontWeight: planDateTheme.typography.weights.bold,
                fontFamily: planDateTheme.typography.fontFamily,
                cursor: 'pointer',
              }}
            >
              {period}
            </button>
          </div>
        </div>

        <div style={{ height: '1px', backgroundColor: planDateTheme.colors.cardBorder }} />

        <div>
          <div
            style={{
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              marginBottom: '6px',
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            DURATION
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '8px' }}>
            <button
              onClick={decreaseDuration}
              aria-label="Decrease duration"
              style={{
                width: '28px',
                height: '28px',
                borderRadius: '8px',
                backgroundColor: planDateTheme.colors.raisedButton,
                border: '1px solid #2a2234',
                color: planDateTheme.colors.text,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                padding: 0,
              }}
            >
              <Minus size={14} />
            </button>
            <div style={{ flex: 1, textAlign: 'center' }}>
              <div
                style={{
                  fontSize: '18px',
                  fontWeight: planDateTheme.typography.weights.bold,
                  color: planDateTheme.colors.text,
                  fontFamily: planDateTheme.typography.fontFamily,
                  lineHeight: '1',
                }}
              >
                {duration}
              </div>
              <div
                style={{
                  fontSize: '10px',
                  color: planDateTheme.colors.muted,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                minutes
              </div>
            </div>
            <button
              onClick={increaseDuration}
              aria-label="Increase duration"
              style={{
                width: '28px',
                height: '28px',
                borderRadius: '8px',
                background: 'linear-gradient(135deg, #e91e8c 0%, #a21caf 100%)',
                border: 'none',
                color: '#FFFFFF',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                padding: 0,
              }}
            >
              <Plus size={14} />
            </button>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px' }}>
            {quickChips.map((chip) => (
              <button
                key={chip}
                onClick={() => onDurationChange(chip)}
                style={{
                  height: '24px',
                  borderRadius: '6px',
                  backgroundColor: duration === chip ? planDateTheme.colors.raisedButton : planDateTheme.colors.idleChip,
                  border: `1px solid ${duration === chip ? '#f06aa8' : '#2a2234'}`,
                  color: planDateTheme.colors.text,
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.semibold,
                  fontFamily: planDateTheme.typography.fontFamily,
                  cursor: 'pointer',
                }}
              >
                {chip}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* RIGHT COLUMN */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
          <div
            style={{
              fontSize: '13px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            {MONTHS[month]} {year}
          </div>
          <button
            onClick={handleToday}
            style={{
              fontSize: '11px',
              color: planDateTheme.colors.accentText,
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontFamily: planDateTheme.typography.fontFamily,
              fontWeight: planDateTheme.typography.weights.semibold,
            }}
          >
            Today
          </button>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '2px', marginBottom: '4px' }}>
          {WEEKDAYS.map((day, idx) => (
            <div
              key={idx}
              style={{
                textAlign: 'center',
                fontSize: '10px',
                color: planDateTheme.colors.muted,
                fontFamily: planDateTheme.typography.fontFamily,
                padding: '2px 0',
              }}
            >
              {day}
            </div>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '2px', marginBottom: '6px' }}>
          {Array.from({ length: firstDay }).map((_, i) => (
            <div key={`empty-${i}`} />
          ))}
          {Array.from({ length: daysInMonth }).map((_, i) => {
            const day = i + 1;
            const date = new Date(year, month, day);
            const isSelected = date.toDateString() === selectedDate.toDateString();
            const isPast = date < today;
            const isToday = date.toDateString() === new Date().toDateString();
            
            return (
              <button
                key={day}
                onClick={() => !isPast && onDateChange(date)}
                disabled={isPast}
                style={{
                  aspectRatio: '1',
                  borderRadius: '6px',
                  background: isSelected ? 'linear-gradient(135deg, #e91e8c 0%, #a21caf 100%)' : 'transparent',
                  border: 'none',
                  color: isPast ? '#6b5b7a' : isSelected ? '#FFFFFF' : isToday ? planDateTheme.colors.accentText : planDateTheme.colors.text,
                  fontSize: '11px',
                  fontWeight: isSelected || isToday ? planDateTheme.typography.weights.bold : planDateTheme.typography.weights.semibold,
                  fontFamily: planDateTheme.typography.fontFamily,
                  cursor: isPast ? 'not-allowed' : 'pointer',
                  padding: 0,
                }}
              >
                {day}
              </button>
            );
          })}
        </div>

        <div
          style={{
            fontSize: '11px',
            color: planDateTheme.colors.muted,
            fontFamily: planDateTheme.typography.fontFamily,
            textAlign: 'center',
          }}
        >
          {formatSelectedDate()}
        </div>
      </div>
    </div>
  );
};
