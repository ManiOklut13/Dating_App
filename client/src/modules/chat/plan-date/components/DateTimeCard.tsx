import React from 'react';
import { ChevronUp, ChevronDown } from 'lucide-react';
import { planDateTheme } from '../theme';

interface DateTimeCardProps {
  selectedDate: Date;
  onDateChange: (date: Date) => void;
  hour: number;
  minute: number;
  period: 'AM' | 'PM';
  onHourChange: (hour: number) => void;
  onMinuteChange: (minute: number) => void;
  onPeriodChange: (period: 'AM' | 'PM') => void;
  duration: number;
}

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export const DateTimeCard: React.FC<DateTimeCardProps> = ({
  selectedDate,
  onDateChange,
  hour,
  minute,
  period,
  onHourChange,
  onMinuteChange,
  onPeriodChange,
  duration,
}) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  // Get week days starting from today or current week
  const getWeekDays = () => {
    const days = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      days.push(date);
    }
    return days;
  };

  const weekDays = getWeekDays();
  const monthLabel = MONTHS[selectedDate.getMonth()] + ' ' + selectedDate.getFullYear();

  const formatSummary = () => {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const dayName = days[selectedDate.getDay()];
    const month = MONTHS[selectedDate.getMonth()];
    const day = selectedDate.getDate();
    const hour12 = hour;
    const minStr = minute.toString().padStart(2, '0');
    return `${dayName}, ${month} ${day} · ${hour12}:${minStr} ${period} · ${duration} min`;
  };

  const adjustHour = (delta: number) => {
    let newHour = hour + delta;
    if (newHour > 12) newHour = 1;
    if (newHour < 1) newHour = 12;
    onHourChange(newHour);
  };

  const adjustMinute = (delta: number) => {
    let newMinute = minute + delta * 15;
    if (newMinute >= 60) newMinute = 0;
    if (newMinute < 0) newMinute = 45;
    onMinuteChange(newMinute);
  };

  const togglePeriod = () => {
    onPeriodChange(period === 'AM' ? 'PM' : 'AM');
  };

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
          Date & Time
        </h3>
        <span
          style={{
            fontSize: '13px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.accentText,
            fontFamily: planDateTheme.typography.fontFamily,
          }}
        >
          {monthLabel}
        </span>
      </div>

      {/* Week strip */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(7, 1fr)',
          gap: '6px',
          marginBottom: '16px',
        }}
      >
        {weekDays.map((date, idx) => {
          const isSelected = date.toDateString() === selectedDate.toDateString();
          const isPast = date < today;
          const weekday = WEEKDAYS[date.getDay()];
          const dayNum = date.getDate();

          return (
            <button
              key={idx}
              onClick={() => !isPast && onDateChange(date)}
              disabled={isPast}
              aria-label={`${weekday} ${dayNum}`}
              style={{
                height: '64px',
                borderRadius: `${planDateTheme.borderRadius.inner}px`,
                background: isSelected
                  ? planDateTheme.gradients.primary
                  : planDateTheme.colors.idleChip,
                border: 'none',
                color: isPast ? planDateTheme.colors.disabledText : '#FFFFFF',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '2px',
                cursor: isPast ? 'not-allowed' : 'pointer',
                opacity: isPast ? 0.5 : 1,
                transition: 'all 0.2s ease',
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
                padding: 0,
              }}
            >
              <span
                style={{
                  fontSize: '11px',
                  fontWeight: planDateTheme.typography.weights.semibold,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {weekday}
              </span>
              <span
                style={{
                  fontSize: '17px',
                  fontWeight: planDateTheme.typography.weights.extrabold,
                  fontFamily: planDateTheme.typography.fontFamily,
                }}
              >
                {dayNum}
              </span>
            </button>
          );
        })}
      </div>

      {/* Time picker */}
      <div
        style={{
          backgroundColor: planDateTheme.colors.innerField,
          borderRadius: `${planDateTheme.borderRadius.large}px`,
          padding: '12px 14px',
          marginBottom: '12px',
        }}
      >
        <div
          style={{
            fontSize: '11px',
            fontWeight: planDateTheme.typography.weights.bold,
            color: planDateTheme.colors.text,
            letterSpacing: '1px',
            marginBottom: '10px',
            textAlign: 'center',
          }}
        >
          TIME
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '8px',
          }}
        >
          {/* Hour */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
            <button
              onClick={() => adjustHour(1)}
              aria-label="Increase hour"
              style={{
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronUp size={20} />
            </button>
            <div
              style={{
                width: `${planDateTheme.sizes.timeColumn}px`,
                height: `${planDateTheme.sizes.timeBoxHeight}px`,
                borderRadius: `${planDateTheme.borderRadius.medium}px`,
                backgroundColor: planDateTheme.colors.raisedButton,
                border: `1px solid #FF3D81`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '24px',
                fontWeight: planDateTheme.typography.weights.extrabold,
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
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronDown size={20} />
            </button>
          </div>

          {/* Minute */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
            <button
              onClick={() => adjustMinute(1)}
              aria-label="Increase minute"
              style={{
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronUp size={20} />
            </button>
            <div
              style={{
                width: `${planDateTheme.sizes.timeColumn}px`,
                height: `${planDateTheme.sizes.timeBoxHeight}px`,
                borderRadius: `${planDateTheme.borderRadius.medium}px`,
                backgroundColor: planDateTheme.colors.raisedButton,
                border: `1px solid #FF3D81`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '24px',
                fontWeight: planDateTheme.typography.weights.extrabold,
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
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronDown size={20} />
            </button>
          </div>

          {/* AM/PM */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px' }}>
            <button
              onClick={togglePeriod}
              aria-label="Toggle AM PM"
              style={{
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronUp size={20} />
            </button>
            <button
              onClick={togglePeriod}
              style={{
                width: `${planDateTheme.sizes.timeColumn}px`,
                height: `${planDateTheme.sizes.timeBoxHeight}px`,
                borderRadius: `${planDateTheme.borderRadius.medium}px`,
                backgroundColor: planDateTheme.colors.idleChip,
                border: `1px solid ${planDateTheme.colors.raisedButtonBorder}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '24px',
                fontWeight: planDateTheme.typography.weights.extrabold,
                color: planDateTheme.colors.text,
                fontFamily: planDateTheme.typography.fontFamily,
                cursor: 'pointer',
                padding: 0,
              }}
            >
              {period}
            </button>
            <button
              onClick={togglePeriod}
              aria-label="Toggle AM PM down"
              style={{
                width: '44px',
                height: '36px',
                backgroundColor: 'transparent',
                border: 'none',
                color: planDateTheme.colors.accentText,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                padding: 0,
                minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
              }}
            >
              <ChevronDown size={20} />
            </button>
          </div>
        </div>
      </div>

      <div
        style={{
          textAlign: 'center',
          fontSize: '13px',
          fontWeight: planDateTheme.typography.weights.semibold,
          color: planDateTheme.colors.softText,
          fontFamily: planDateTheme.typography.fontFamily,
        }}
      >
        {formatSummary()}
      </div>
    </div>
  );
};
