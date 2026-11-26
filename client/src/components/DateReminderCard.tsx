import React, { useMemo } from 'react';
import { Heart, Clock, MapPin, PhoneCall } from 'lucide-react';
import { ScheduledDate } from '../types';

interface DateReminderCardProps {
  scheduledDate: ScheduledDate;
  onOpenDatePlan: () => void;
  onStartCall?: (calleeId: string, name: string, avatar: string) => void;
  onOpenMemoryMaker?: () => void;
}

// Strictly rounds date/time to clean 30-minute or 1-hour intervals (e.g., 6:30 PM, 5:00 PM)
const roundToNearest30Minutes = (date: Date): Date => {
  const rounded = new Date(date);
  const minutes = rounded.getMinutes();
  if (minutes < 15) {
    rounded.setMinutes(0);
  } else if (minutes < 45) {
    rounded.setMinutes(30);
  } else {
    rounded.setHours(rounded.getHours() + 1);
    rounded.setMinutes(0);
  }
  rounded.setSeconds(0);
  rounded.setMilliseconds(0);
  return rounded;
};

export const DateReminderCard: React.FC<DateReminderCardProps> = ({
  scheduledDate,
  onOpenDatePlan,
  onStartCall,
}) => {
  // Conditional is_date logic: Displays Date Reminder ONLY when is_date === true
  if (!scheduledDate || scheduledDate.is_date !== true) {
    return null;
  }

  const partnerName = scheduledDate.nickname || 'Ananya';
  const venueLocation = scheduledDate.venue || 'Roastery Coffee House, Banjara Hills';
  const venueAddress = scheduledDate.address || 'Road 45, Jubilee Hills';

  // Planned event date object
  const plannedEventDate = useMemo(() => {
    try {
      const d = new Date(scheduledDate.scheduled_at);
      return isNaN(d.getTime()) ? new Date() : d;
    } catch {
      return new Date();
    }
  }, [scheduledDate.scheduled_at]);

  // Highlighted active date parts (e.g., "29 OCT")
  const activeDateParts = useMemo(() => {
    try {
      const monthStr = plannedEventDate.toLocaleDateString('en-US', { month: 'short' }).toUpperCase();
      const dayNum = plannedEventDate.getDate();
      return { month: monthStr, day: dayNum };
    } catch {
      return { month: 'OCT', day: 29 };
    }
  }, [plannedEventDate]);

  // Formatted date string rounded strictly to clean 30-minute or hourly figures (e.g., "6:30 PM", "5:00 PM")
  const formattedEventTime = useMemo(() => {
    try {
      const rounded = roundToNearest30Minutes(plannedEventDate);
      const day = rounded.toLocaleDateString('en-US', { weekday: 'short' });
      const time = rounded.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
      return `${day}, ${time}`;
    } catch {
      return 'Sat, 6:30 PM';
    }
  }, [plannedEventDate]);

  const handleCallClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (onStartCall) {
      onStartCall(
        scheduledDate.with_user_id || '22222222-2222-2222-2222-222222222222',
        partnerName,
        scheduledDate.avatar || '/ananya.jpg'
      );
    }
  };

  return (
    <div
      onClick={onOpenDatePlan}
      title="Tap to open full Monthly Calendar & Weekly Date Planner"
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          onOpenDatePlan();
        }
      }}
      style={{
        margin: '2px 14px 4px',
        borderRadius: '14px',
        background:
          'linear-gradient(135deg, rgba(244, 63, 94, 0.14) 0%, rgba(251, 113, 133, 0.06) 45%, rgba(18, 21, 30, 0.95) 100%)',
        border: '1px solid rgba(244, 63, 94, 0.35)',
        boxShadow: '0 4px 14px rgba(0, 0, 0, 0.32)',
        backdropFilter: 'blur(14px)',
        WebkitBackdropFilter: 'blur(14px)',
        padding: '6px 10px',
        boxSizing: 'border-box',
        flexShrink: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: '10px',
        cursor: 'pointer',
        transition: 'all 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
        userSelect: 'none',
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.borderColor = 'rgba(244, 63, 94, 0.65)';
        e.currentTarget.style.transform = 'translateY(-1px)';
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.borderColor = 'rgba(244, 63, 94, 0.35)';
        e.currentTarget.style.transform = 'translateY(0)';
      }}
    >
      {/* =================================================================== */}
      {/* 1. LEFT COLUMN: Dedicated Calendar Date Badge (Calendar Icon)       */}
      {/* =================================================================== */}
      <div
        style={{
          width: '38px',
          height: '40px',
          borderRadius: '10px',
          background: 'linear-gradient(180deg, #1f2433 0%, #151824 100%)',
          border: '1px solid rgba(244, 63, 94, 0.55)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          overflow: 'hidden',
          boxShadow: '0 2px 8px rgba(244, 63, 94, 0.25)',
          flexShrink: 0,
          position: 'relative',
        }}
      >
        {/* Month Banner (e.g., "OCT") */}
        <div
          style={{
            width: '100%',
            height: '13px',
            background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '8px',
            fontWeight: 900,
            color: '#ffffff',
            letterSpacing: '0.6px',
            textTransform: 'uppercase',
          }}
        >
          {activeDateParts.month}
        </div>
        {/* Highlighted Day Number (e.g., "29") */}
        <div
          style={{
            flex: 1,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '14px',
            fontWeight: 900,
            color: '#ffffff',
            lineHeight: 1,
            background: 'rgba(244, 63, 94, 0.1)',
            width: '100%',
          }}
        >
          {activeDateParts.day}
        </div>
      </div>

      {/* =================================================================== */}
      {/* 2. MIDDLE COLUMN: Date Reminder Title & Rounded Time                */}
      {/* =================================================================== */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '2px',
          minWidth: 0,
          flex: 1,
        }}
      >
        {/* Date Reminder Title + Time */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span style={{ fontSize: '12.5px', fontWeight: 800, color: '#f8fafc', letterSpacing: '-0.2px' }}>
            Date Reminder
          </span>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '3px',
              fontSize: '10px',
              fontWeight: 700,
              color: '#fb7185',
              background: 'rgba(244, 63, 94, 0.16)',
              padding: '1px 6px',
              borderRadius: '999px',
            }}
          >
            <Clock size={9} color="#fb7185" />
            <span>{formattedEventTime}</span>
          </div>
        </div>

        {/* Minimal Upcoming Plan Details */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            fontSize: '10.5px',
            color: '#cbd5e1',
            fontWeight: 600,
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
          title={`${venueLocation} with ${partnerName}`}
        >
          <MapPin size={10} color="#f43f5e" style={{ flexShrink: 0 }} />
          <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {venueLocation} • {partnerName}
          </span>
        </div>
      </div>

      {/* =================================================================== */}
      {/* 3. RIGHT COLUMN: Subtle Romantic Call Action Icon                   */}
      {/* =================================================================== */}
      <button
        type="button"
        onClick={handleCallClick}
        title={`Direct Call with ${partnerName}`}
        aria-label={`Call ${partnerName}`}
        style={{
          width: '34px',
          height: '34px',
          borderRadius: '10px',
          background: 'linear-gradient(135deg, rgba(244, 63, 94, 0.85) 0%, rgba(225, 29, 72, 0.95) 100%)',
          border: '1px solid rgba(255, 255, 255, 0.15)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#ffffff',
          flexShrink: 0,
          cursor: 'pointer',
          boxShadow: '0 2px 8px rgba(244, 63, 94, 0.3)',
          transition: 'all 0.18s ease',
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.transform = 'scale(1.06)';
          e.currentTarget.style.boxShadow = '0 4px 12px rgba(244, 63, 94, 0.45)';
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.transform = 'scale(1)';
          e.currentTarget.style.boxShadow = '0 2px 8px rgba(244, 63, 94, 0.3)';
        }}
        onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.92)')}
        onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1.06)')}
      >
        <PhoneCall size={15} color="#ffffff" />
      </button>
    </div>
  );
};
