import React, { useMemo } from 'react';
import { Calendar } from 'lucide-react';

interface MinimalDateStripProps {
  streakDays?: number;
  hasPlannedDate?: boolean;
  onDateClick?: (date: Date) => void;
}

export const MinimalDateStrip: React.FC<MinimalDateStripProps> = ({
  streakDays = 4,
  hasPlannedDate = true,
  onDateClick,
}) => {
  const today = useMemo(() => new Date(), []);

  // Compute 7-day strip (3 days before today, today, 3 days after)
  const days = useMemo(() => {
    const list: { date: Date; dayName: string; dayNum: number; isToday: boolean; status: 'streak' | 'date' | 'normal' }[] = [];
    for (let i = -3; i <= 3; i++) {
      const d = new Date();
      d.setDate(today.getDate() + i);
      const isToday = i === 0;
      
      // Activity/streak status indicator:
      // Past days up to streakDays count -> streak active (green)
      // Planned date (e.g. Saturday or 2 days ahead) -> date active (rose)
      let status: 'streak' | 'date' | 'normal' = 'normal';
      if (i <= 0 && i >= -streakDays) {
        status = 'streak';
      } else if (i === 2 && hasPlannedDate) {
        status = 'date';
      }

      list.push({
        date: d,
        dayName: d.toLocaleDateString('en-US', { weekday: 'short' }),
        dayNum: d.getDate(),
        isToday,
        status,
      });
    }
    return list;
  }, [today, streakDays, hasPlannedDate]);

  return (
    <div
      style={{
        margin: '6px 14px 2px',
        padding: '6px 10px',
        borderRadius: '16px',
        background: 'rgba(25, 28, 36, 0.75)',
        backdropFilter: 'blur(12px)',
        WebkitBackdropFilter: 'blur(12px)',
        border: '1px solid rgba(255, 255, 255, 0.08)',
        boxShadow: '0 4px 16px rgba(0, 0, 0, 0.35)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: '6px',
        userSelect: 'none',
      }}
    >
      {days.map((item, idx) => (
        <div
          key={idx}
          onClick={() => onDateClick?.(item.date)}
          style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '4px 2px',
            borderRadius: '10px',
            cursor: 'pointer',
            background: item.isToday
              ? 'linear-gradient(135deg, rgba(244, 63, 94, 0.3) 0%, rgba(225, 29, 72, 0.2) 100%)'
              : 'transparent',
            border: item.isToday ? '1px solid rgba(244, 63, 94, 0.55)' : '1px solid transparent',
            transition: 'all 0.15s ease',
          }}
        >
          {/* Day of Week */}
          <span
            style={{
              fontSize: '9.5px',
              fontWeight: item.isToday ? 800 : 600,
              color: item.isToday ? '#ffffff' : '#94a3b8',
              lineHeight: 1,
            }}
          >
            {item.dayName}
          </span>

          {/* Day Number */}
          <span
            style={{
              fontSize: '12.5px',
              fontWeight: 800,
              color: item.isToday ? '#ffffff' : '#f8fafc',
              marginTop: '3px',
              lineHeight: 1,
            }}
          >
            {item.dayNum}
          </span>

          {/* Minimal Activity/Streak Status Dot Indicator */}
          <span
            style={{
              width: '4px',
              height: '4px',
              borderRadius: '50%',
              marginTop: '4px',
              background:
                item.status === 'date'
                  ? '#f43f5e'
                  : item.status === 'streak'
                  ? '#22c55e'
                  : 'rgba(255, 255, 255, 0.15)',
              boxShadow:
                item.status === 'date'
                  ? '0 0 6px #f43f5e'
                  : item.status === 'streak'
                  ? '0 0 6px #22c55e'
                  : 'none',
            }}
          />
        </div>
      ))}
    </div>
  );
};

