import React, { useState, useRef, useMemo } from 'react';
import {
  ChevronLeft,
  ChevronRight,
  Calendar,
  CalendarDays,
  Clock,
  MapPin,
  Heart,
  Music,
  Sparkles,
  Phone,
  MessageCircle,
  Share2,
  CheckCircle2,
  Coffee,
  Camera,
  Upload,
  Check,
  Send,
  X,
  ListTodo,
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { ScheduledDate } from '../types';

interface DatePlanPageProps {
  datePlan: ScheduledDate;
  onBack: () => void;
  onStartCall?: (calleeId: string, name: string, avatar: string, mode?: 'audio' | 'video') => void;
  onOpenChat?: (convId?: string) => void;
}

export const DatePlanPage: React.FC<DatePlanPageProps> = ({
  datePlan,
  onBack,
  onStartCall,
  onOpenChat,
}) => {
  const formattedDate = new Date(datePlan.scheduled_at).toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  // Planned event date object
  const plannedEventDate = useMemo(() => {
    try {
      const d = new Date(datePlan.scheduled_at);
      return isNaN(d.getTime()) ? new Date() : d;
    } catch {
      return new Date();
    }
  }, [datePlan.scheduled_at]);

  // Current month displayed in the calendar
  const [viewMonth, setViewMonth] = useState<Date>(() => {
    return new Date(plannedEventDate.getFullYear(), plannedEventDate.getMonth(), 1);
  });

  // Selected date state
  const [selectedDate, setSelectedDate] = useState<Date>(() => plannedEventDate);

  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  const weekdayHeaders = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  // Navigate to previous month
  const handlePrevMonth = (e: React.MouseEvent) => {
    e.stopPropagation();
    setViewMonth(new Date(viewMonth.getFullYear(), viewMonth.getMonth() - 1, 1));
  };

  // Navigate to next month
  const handleNextMonth = (e: React.MouseEvent) => {
    e.stopPropagation();
    setViewMonth(new Date(viewMonth.getFullYear(), viewMonth.getMonth() + 1, 1));
  };

  // Calendar calculations
  const year = viewMonth.getFullYear();
  const month = viewMonth.getMonth();
  const firstDayIndex = new Date(year, month, 1).getDay();
  const daysInCurrentMonth = new Date(year, month + 1, 0).getDate();
  const daysInPrevMonth = new Date(year, month, 0).getDate();
  const today = new Date();

  // Weekly strip calculation around the planned date
  const weekDays = useMemo(() => {
    const list = [];
    const base = new Date(plannedEventDate);
    const dayOfWeek = base.getDay();
    const sunday = new Date(base);
    sunday.setDate(base.getDate() - dayOfWeek);
    for (let i = 0; i < 7; i++) {
      const d = new Date(sunday);
      d.setDate(sunday.getDate() + i);
      list.push(d);
    }
    return list;
  }, [plannedEventDate]);

  // Make Memories state
  const [isMemoryModalOpen, setIsMemoryModalOpen] = useState(false);
  const [uploadedMemoryPhoto, setUploadedMemoryPhoto] = useState<string | null>(null);
  const [isGeneratingSticker, setIsGeneratingSticker] = useState(false);
  const [createdSticker, setCreatedSticker] = useState<string | null>(null);
  const [stickerSentToast, setStickerSentToast] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const handlePhotoUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setUploadedMemoryPhoto(url);
      generateBitmojiSticker(url);
    }
  };

  const generateBitmojiSticker = (photoUrl: string) => {
    setIsGeneratingSticker(true);
    setTimeout(() => {
      setIsGeneratingSticker(false);
      setCreatedSticker(photoUrl);
      confetti({
        particleCount: 40,
        spread: 60,
        origin: { y: 0.6 },
        colors: ['#FE728B', '#FF2D55', '#FFD700', '#00E5FF'],
      });
    }, 1200);
  };

  const handleSendStickerToChat = () => {
    setStickerSentToast(true);
    setTimeout(() => {
      setStickerSentToast(false);
      setIsMemoryModalOpen(false);
      onOpenChat?.('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    }, 1000);
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: '#0B0D14',
        color: '#FFFFFF',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <input
        type="file"
        ref={fileInputRef}
        onChange={handlePhotoUpload}
        accept="image/*"
        style={{ display: 'none' }}
      />

      {/* Top Header */}
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '16px 20px',
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          background: 'rgba(11, 13, 20, 0.95)',
          backdropFilter: 'blur(10px)',
          position: 'sticky',
          top: 0,
          zIndex: 20,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button
            type="button"
            onClick={onBack}
            style={{
              background: 'rgba(255, 255, 255, 0.08)',
              border: 'none',
              borderRadius: '12px',
              width: '38px',
              height: '38px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              cursor: 'pointer',
            }}
          >
            <ChevronLeft size={20} />
          </button>
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: 800, margin: 0 }}>Date Plan Details</h1>
            <span style={{ fontSize: '11px', color: '#FE728B', fontWeight: 600 }}>Confirmed Itinerary</span>
          </div>
        </div>

        <button
          type="button"
          onClick={() => {
            if (navigator.share) {
              navigator.share({
                title: `Date with ${datePlan.nickname}`,
                text: `Meeting at ${datePlan.venue} on ${formattedDate}`,
              }).catch(() => { });
            }
          }}
          style={{
            background: 'rgba(255, 255, 255, 0.08)',
            border: 'none',
            borderRadius: '12px',
            width: '38px',
            height: '38px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#FFFFFF',
            cursor: 'pointer',
          }}
        >
          <Share2 size={16} />
        </button>
      </header>

      {/* Main Content (Transport/Parking & Budget sections completely removed) */}
      <div style={{ flex: 1, padding: '16px 18px 80px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {/* Hero Card: Date with Nickname */}
        <div
          style={{
            position: 'relative',
            borderRadius: '20px',
            background: 'linear-gradient(135deg, rgba(254, 114, 139, 0.18) 0%, rgba(255, 45, 85, 0.08) 100%)',
            border: '1.5px solid rgba(254, 114, 139, 0.35)',
            padding: '20px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            boxShadow: '0 8px 30px rgba(0, 0, 0, 0.4)',
          }}
        >
          <div style={{ position: 'relative' }}>
            <img
              src={datePlan.avatar || '/ananya.jpg'}
              alt={datePlan.nickname}
              style={{
                width: '68px',
                height: '68px',
                borderRadius: '50%',
                objectFit: 'cover',
                border: '2.5px solid #FE728B',
                boxShadow: '0 4px 16px rgba(254, 114, 139, 0.4)',
              }}
            />
            <div
              style={{
                position: 'absolute',
                bottom: '0',
                right: '0',
                background: '#4CD964',
                width: '18px',
                height: '18px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                border: '2px solid #0B0D14',
                color: '#FFFFFF',
              }}
            >
              <CheckCircle2 size={12} />
            </div>
          </div>

          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <h2 style={{ fontSize: '20px', fontWeight: 800, margin: 0 }}>Date with {datePlan.nickname}</h2>
            </div>
            <p style={{ fontSize: '13px', color: '#FE728B', margin: '4px 0 0', fontWeight: 600 }}>
              {datePlan.romantic_milestone || '98% Compatibility Vibe 🔥'}
            </p>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginTop: '10px' }}>
              <button
                type="button"
                onClick={() => onStartCall?.(datePlan.with_user_id, datePlan.nickname, datePlan.avatar)}
                style={{
                  padding: '6px 12px',
                  borderRadius: '10px',
                  background: 'rgba(0, 229, 255, 0.15)',
                  border: '1px solid rgba(0, 229, 255, 0.4)',
                  color: '#00E5FF',
                  fontSize: '11.5px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '5px',
                  cursor: 'pointer',
                }}
              >
                <Phone size={12} /> Call
              </button>
              <button
                type="button"
                onClick={() => onOpenChat?.('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')}
                style={{
                  padding: '6px 12px',
                  borderRadius: '10px',
                  background: 'rgba(254, 114, 139, 0.15)',
                  border: '1px solid rgba(254, 114, 139, 0.4)',
                  color: '#FE728B',
                  fontSize: '11.5px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '5px',
                  cursor: 'pointer',
                }}
              >
                <MessageCircle size={12} /> Chat
              </button>
            </div>
          </div>
        </div>

        {/* MAKE MEMORIES TILE: Convert date photos to bitmoji stickers for 1-1 chat */}
        <div
          style={{
            borderRadius: '18px',
            background: 'linear-gradient(135deg, rgba(255, 45, 85, 0.12) 0%, rgba(254, 114, 139, 0.18) 100%)',
            border: '1.5px solid rgba(254, 114, 139, 0.4)',
            padding: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            boxShadow: '0 4px 18px rgba(254, 114, 139, 0.2)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '12px',
                background: 'linear-gradient(135deg, #FE728B, #FF2D55)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF',
                boxShadow: '0 4px 12px rgba(254, 114, 139, 0.4)',
                flexShrink: 0,
              }}
            >
              <Sparkles size={20} />
            </div>
            <div>
              <h4 style={{ fontSize: '14px', fontWeight: 800, margin: 0, color: '#FFFFFF' }}>
                Make Memories ✨
              </h4>
              <p style={{ fontSize: '11px', color: '#E0D6DD', margin: '2px 0 0' }}>
                Upload date photos & convert to Bitmoji stickers for chat
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={() => setIsMemoryModalOpen(true)}
            style={{
              padding: '8px 14px',
              borderRadius: '999px',
              border: 'none',
              background: 'linear-gradient(135deg, #FE728B, #FF2D55)',
              color: '#FFFFFF',
              fontSize: '11.5px',
              fontWeight: 700,
              cursor: 'pointer',
              boxShadow: '0 4px 12px rgba(254, 114, 139, 0.35)',
              flexShrink: 0,
            }}
          >
            Create Sticker
          </button>
        </div>

        {/* FULL MONTHLY CALENDAR CARD */}
        <div
          style={{
            borderRadius: '20px',
            background:
              'linear-gradient(145deg, rgba(244, 63, 94, 0.12) 0%, rgba(251, 113, 133, 0.05) 45%, rgba(22, 26, 36, 0.95) 100%)',
            border: '1.5px solid rgba(244, 63, 94, 0.28)',
            boxShadow: '0 8px 24px rgba(0, 0, 0, 0.45), inset 0 0 24px rgba(244, 63, 94, 0.06)',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
          }}
        >
          {/* Header with Navigation */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '10px',
                  background: 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 2px 10px rgba(244, 63, 94, 0.4)',
                }}
              >
                <CalendarDays size={16} color="#ffffff" />
              </div>
              <div>
                <h3 style={{ fontSize: '14px', fontWeight: 800, margin: 0, color: '#f8fafc' }}>
                  Monthly Calendar
                </h3>
                <span style={{ fontSize: '10.5px', color: '#fb7185', fontWeight: 600 }}>
                  Date with {datePlan.nickname}
                </span>
              </div>
            </div>

            {/* Month & Year Navigation */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <button
                type="button"
                onClick={handlePrevMonth}
                title="Previous Month"
                aria-label="Previous month"
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.12)',
                  borderRadius: '8px',
                  width: '28px',
                  height: '28px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#f8fafc',
                  cursor: 'pointer',
                }}
              >
                <ChevronLeft size={15} />
              </button>

              <span
                style={{
                  fontSize: '12px',
                  fontWeight: 800,
                  color: '#f8fafc',
                  minWidth: '95px',
                  textAlign: 'center',
                }}
              >
                {monthNames[month].slice(0, 3)} {year}
              </span>

              <button
                type="button"
                onClick={handleNextMonth}
                title="Next Month"
                aria-label="Next month"
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.12)',
                  borderRadius: '8px',
                  width: '28px',
                  height: '28px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#f8fafc',
                  cursor: 'pointer',
                }}
              >
                <ChevronRight size={15} />
              </button>
            </div>
          </div>

          {/* Weekday Headings */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(7, 1fr)',
              textAlign: 'center',
            }}
          >
            {weekdayHeaders.map((day, idx) => (
              <div
                key={idx}
                style={{
                  fontSize: '10.5px',
                  fontWeight: 700,
                  color: idx === 0 || idx === 6 ? '#f43f5e' : '#94a3b8',
                  padding: '2px 0',
                }}
              >
                {day}
              </div>
            ))}
          </div>

          {/* Days Grid */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(7, 1fr)',
              gap: '4px',
              textAlign: 'center',
            }}
          >
            {Array.from({ length: firstDayIndex }).map((_, idx) => {
              const pDay = daysInPrevMonth - firstDayIndex + idx + 1;
              return (
                <div
                  key={`prev-${idx}`}
                  style={{
                    height: '30px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '11px',
                    color: 'rgba(255, 255, 255, 0.18)',
                    userSelect: 'none',
                  }}
                >
                  {pDay}
                </div>
              );
            })}

            {Array.from({ length: daysInCurrentMonth }).map((_, idx) => {
              const dayNum = idx + 1;
              const isToday =
                dayNum === today.getDate() &&
                month === today.getMonth() &&
                year === today.getFullYear();

              const isEventDate =
                dayNum === plannedEventDate.getDate() &&
                month === plannedEventDate.getMonth() &&
                year === plannedEventDate.getFullYear();

              const isSelected =
                selectedDate &&
                dayNum === selectedDate.getDate() &&
                month === selectedDate.getMonth() &&
                year === selectedDate.getFullYear();

              return (
                <div
                  key={`cur-${dayNum}`}
                  onClick={() => setSelectedDate(new Date(year, month, dayNum))}
                  style={{
                    height: '30px',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: '8px',
                    fontSize: '11.5px',
                    fontWeight: isEventDate || isToday || isSelected ? 800 : 500,
                    cursor: 'pointer',
                    position: 'relative',
                    transition: 'all 0.15s ease',
                    background: isEventDate
                      ? 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)'
                      : isSelected
                      ? 'rgba(244, 63, 94, 0.22)'
                      : isToday
                      ? 'rgba(56, 189, 248, 0.15)'
                      : 'transparent',
                    color: isEventDate
                      ? '#ffffff'
                      : isToday
                      ? '#38bdf8'
                      : isSelected
                      ? '#f43f5e'
                      : '#e2e8f0',
                    border: isEventDate
                      ? '1px solid #f43f5e'
                      : isSelected
                      ? '1px solid rgba(244, 63, 94, 0.5)'
                      : isToday
                      ? '1px solid rgba(56, 189, 248, 0.6)'
                      : '1px solid transparent',
                    boxShadow: isEventDate ? '0 0 12px rgba(244, 63, 94, 0.55)' : 'none',
                  }}
                >
                  <span>{dayNum}</span>
                  {isEventDate && (
                    <span
                      style={{
                        position: 'absolute',
                        bottom: '2px',
                        width: '4px',
                        height: '4px',
                        borderRadius: '50%',
                        background: '#ffffff',
                      }}
                    />
                  )}
                </div>
              );
            })}
          </div>

          {/* Calendar Legend */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '14px',
              paddingTop: '6px',
              borderTop: '1px solid rgba(255, 255, 255, 0.08)',
              fontSize: '10.5px',
              color: '#94a3b8',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <span
                style={{
                  width: '8px',
                  height: '8px',
                  borderRadius: '50%',
                  background: '#f43f5e',
                }}
              />
              <span>Date with {datePlan.nickname}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <span
                style={{
                  width: '8px',
                  height: '8px',
                  borderRadius: '50%',
                  background: '#38bdf8',
                }}
              />
              <span>Today</span>
            </div>
          </div>
        </div>

        {/* DETAILED WEEKLY PLANNING & ITINERARY */}
        <div
          style={{
            borderRadius: '20px',
            background: '#161824',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '14px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '10px',
                  background: 'rgba(254, 114, 139, 0.15)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#FE728B',
                }}
              >
                <ListTodo size={16} />
              </div>
              <div>
                <h3 style={{ fontSize: '14px', fontWeight: 800, margin: 0, color: '#FFFFFF' }}>
                  Weekly Planning & Timeline
                </h3>
                <span style={{ fontSize: '10.5px', color: '#8C8C9E' }}>
                  Week of {plannedEventDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                </span>
              </div>
            </div>
          </div>

          {/* Weekday Strip */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(7, 1fr)',
              gap: '4px',
              padding: '6px',
              borderRadius: '12px',
              background: 'rgba(255, 255, 255, 0.03)',
            }}
          >
            {weekDays.map((d, idx) => {
              const isEvent =
                d.getDate() === plannedEventDate.getDate() &&
                d.getMonth() === plannedEventDate.getMonth();
              const dayStr = d.toLocaleDateString('en-US', { weekday: 'narrow' });
              return (
                <div
                  key={idx}
                  style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    padding: '6px 2px',
                    borderRadius: '8px',
                    background: isEvent ? 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)' : 'transparent',
                    color: isEvent ? '#ffffff' : '#94a3b8',
                    border: isEvent ? '1px solid #f43f5e' : '1px solid transparent',
                    boxShadow: isEvent ? '0 2px 8px rgba(244, 63, 94, 0.4)' : 'none',
                  }}
                >
                  <span style={{ fontSize: '9px', fontWeight: 700, textTransform: 'uppercase' }}>{dayStr}</span>
                  <span style={{ fontSize: '12px', fontWeight: 800, marginTop: '2px' }}>{d.getDate()}</span>
                  {isEvent && (
                    <span style={{ fontSize: '8px', fontWeight: 800, color: '#ffffff', marginTop: '2px' }}>💕</span>
                  )}
                </div>
              );
            })}
          </div>

          {/* Planned Date Hour-by-Hour Timeline */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ fontSize: '11px', fontWeight: 700, color: '#FE728B', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Planned Date Itinerary
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {[
                { time: '07:00 PM', title: 'Arrival & Welcome Drinks', desc: 'Reserved corner booth at venue' },
                { time: '07:30 PM', title: 'Artisan Dinner & Appetizers', desc: `Candlelit table under "YoUnMe"` },
                { time: '08:30 PM', title: 'Specialty Coffee Tasting & Vinyls', desc: datePlan.activity_type || 'Specialty coffee & playlist browsing' },
                { time: '09:30 PM', title: 'Promenade Stroll & Goodnight Spark', desc: 'Take photos & create Bitmoji sticker' },
              ].map((step, sIdx) => (
                <div
                  key={sIdx}
                  style={{
                    display: 'flex',
                    alignItems: 'flex-start',
                    gap: '10px',
                    padding: '8px 10px',
                    borderRadius: '10px',
                    background: 'rgba(255, 255, 255, 0.04)',
                    border: '1px solid rgba(255, 255, 255, 0.06)',
                  }}
                >
                  <div
                    style={{
                      fontSize: '11px',
                      fontWeight: 800,
                      color: '#FE728B',
                      minWidth: '58px',
                      paddingTop: '1px',
                    }}
                  >
                    {step.time}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: '12px', fontWeight: 700, color: '#FFFFFF' }}>{step.title}</div>
                    <div style={{ fontSize: '10.5px', color: '#94a3b8', marginTop: '1px' }}>{step.desc}</div>
                  </div>
                  <CheckCircle2 size={14} color="#4CD964" style={{ marginTop: '2px', flexShrink: 0 }} />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Date & Time Tile */}
        <div
          style={{
            borderRadius: '16px',
            background: '#161824',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '16px',
            display: 'flex',
            alignItems: 'center',
            gap: '14px',
          }}
        >
          <div
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '12px',
              background: 'rgba(254, 114, 139, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FE728B',
              flexShrink: 0,
            }}
          >
            <Calendar size={22} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: '11px', color: '#8C8C9E', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>
              Date & Duration
            </div>
            <div style={{ fontSize: '15px', fontWeight: 800, color: '#FFFFFF', marginTop: '2px' }}>
              {formattedDate}
            </div>
            <div style={{ fontSize: '12px', color: '#00E5FF', marginTop: '2px', display: 'flex', alignItems: 'center', gap: '4px' }}>
              <Clock size={12} /> Reserved for {datePlan.duration_mins || 120} minutes
            </div>
          </div>
        </div>

        {/* Venue & Location */}
        <div
          style={{
            borderRadius: '16px',
            background: '#161824',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '16px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: '14px' }}>
            <div
              style={{
                width: '44px',
                height: '44px',
                borderRadius: '12px',
                background: 'rgba(255, 83, 118, 0.15)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FF5376',
                flexShrink: 0,
              }}
            >
              <MapPin size={22} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: '11px', color: '#8C8C9E', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>
                Confirmed Venue
              </div>
              <div style={{ fontSize: '16px', fontWeight: 800, color: '#FFFFFF', marginTop: '2px' }}>
                {datePlan.venue}
              </div>
              <div style={{ fontSize: '12px', color: '#B3B1C2', marginTop: '4px', lineHeight: 1.4 }}>
                {datePlan.address}
              </div>
              {datePlan.table_reservation && (
                <div
                  style={{
                    display: 'inline-block',
                    marginTop: '8px',
                    padding: '4px 10px',
                    borderRadius: '8px',
                    background: 'rgba(255, 215, 0, 0.12)',
                    border: '1px solid rgba(255, 215, 0, 0.3)',
                    color: '#FFD700',
                    fontSize: '11px',
                    fontWeight: 700,
                  }}
                >
                  {datePlan.table_reservation}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Romantic Vibe & Activity Details */}
        <div
          style={{
            borderRadius: '16px',
            background: '#161824',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
          }}
        >
          <div style={{ fontSize: '12px', color: '#8C8C9E', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>
            Vibe & Experience
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Coffee size={16} color="#FE728B" />
            <div style={{ fontSize: '13px', color: '#E0D6DD' }}>
              <strong style={{ color: '#FFFFFF' }}>Activity:</strong> {datePlan.activity_type}
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Sparkles size={16} color="#FFD700" />
            <div style={{ fontSize: '13px', color: '#E0D6DD' }}>
              <strong style={{ color: '#FFFFFF' }}>Dress Code:</strong> {datePlan.dress_code}
            </div>
          </div>

          {datePlan.shared_playlist && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Music size={16} color="#00E5FF" />
              <div style={{ fontSize: '13px', color: '#E0D6DD' }}>
                <strong style={{ color: '#FFFFFF' }}>Curated Soundtrack:</strong> {datePlan.shared_playlist}
              </div>
            </div>
          )}

          {datePlan.vibe_notes && (
            <div
              style={{
                marginTop: '4px',
                padding: '12px',
                borderRadius: '12px',
                background: 'rgba(255, 255, 255, 0.03)',
                border: '1px solid rgba(255, 255, 255, 0.06)',
                fontSize: '12.5px',
                color: '#C8C6D6',
                lineHeight: 1.5,
              }}
            >
              💡 <em>{datePlan.vibe_notes}</em>
            </div>
          )}
        </div>
      </div>

      {/* MAKE MEMORIES BITMOJI STICKER MODAL */}
      {isMemoryModalOpen && (
        <div
          onClick={() => setIsMemoryModalOpen(false)}
          style={{
            position: 'absolute',
            inset: 0,
            background: 'rgba(6, 8, 14, 0.85)',
            backdropFilter: 'blur(10px)',
            zIndex: 100,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '20px',
          }}
        >
          <div
            onClick={(e) => e.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: '320px',
              borderRadius: '24px',
              background: '#1A1C29',
              border: '1.5px solid rgba(254, 114, 139, 0.4)',
              padding: '20px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              boxShadow: '0 16px 40px rgba(0, 0, 0, 0.5)',
            }}
          >
            <div style={{ width: '100%', display: 'flex', justifyContent: 'flex-end' }}>
              <button
                type="button"
                onClick={() => setIsMemoryModalOpen(false)}
                style={{ background: 'transparent', border: 'none', color: '#8C8C9E', cursor: 'pointer' }}
              >
                <X size={18} />
              </button>
            </div>

            <div
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '50%',
                background: 'rgba(254, 114, 139, 0.15)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FE728B',
                marginBottom: '10px',
              }}
            >
              <Sparkles size={28} />
            </div>

            <h3 style={{ fontSize: '18px', fontWeight: 800, margin: '0 0 4px', color: '#FFFFFF' }}>
              Make Memories ✨
            </h3>
            <p style={{ fontSize: '12px', color: '#A89EAA', margin: '0 0 16px', lineHeight: 1.4 }}>
              Snap or upload a photo from your date with {datePlan.nickname} to generate animated Bitmoji stickers for chat!
            </p>

            {/* Sticker Preview Area */}
            <div
              style={{
                width: '120px',
                height: '120px',
                borderRadius: '24px',
                background: '#10121B',
                border: '2px dashed rgba(254, 114, 139, 0.4)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                overflow: 'hidden',
                position: 'relative',
                marginBottom: '16px',
              }}
            >
              {createdSticker ? (
                <>
                  <img
                    src={createdSticker}
                    alt="Bitmoji Sticker"
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  />
                  <div
                    style={{
                      position: 'absolute',
                      bottom: '4px',
                      background: 'rgba(0,0,0,0.7)',
                      padding: '2px 6px',
                      borderRadius: '999px',
                      fontSize: '9px',
                      color: '#FFD700',
                      fontWeight: 700,
                    }}
                  >
                    Bitmoji Ready ☕
                  </div>
                </>
              ) : isGeneratingSticker ? (
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px' }}>
                  <Sparkles size={24} color="#00E5FF" className="spin-animation" />
                  <span style={{ fontSize: '10px', color: '#00E5FF', fontWeight: 600 }}>Stickerizing...</span>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px', color: '#8C8C9E' }}>
                  <Camera size={26} />
                  <span style={{ fontSize: '10px' }}>Upload Snapshot</span>
                </div>
              )}
            </div>

            {/* Upload Action */}
            {!createdSticker ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', width: '100%' }}>
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: '12px',
                    border: 'none',
                    background: 'linear-gradient(135deg, #FE728B, #FF2D55)',
                    color: '#FFFFFF',
                    fontSize: '13px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '6px',
                  }}
                >
                  <Upload size={14} /> Upload Date Photo
                </button>
                <button
                  type="button"
                  onClick={() => generateBitmojiSticker('/ananya.jpg')}
                  style={{
                    width: '100%',
                    padding: '8px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.06)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    color: '#D4CAD6',
                    fontSize: '11.5px',
                    fontWeight: 600,
                    cursor: 'pointer',
                  }}
                >
                  Use Sample Subko Selfie
                </button>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', width: '100%' }}>
                <button
                  type="button"
                  onClick={handleSendStickerToChat}
                  style={{
                    width: '100%',
                    padding: '11px',
                    borderRadius: '12px',
                    border: 'none',
                    background: 'linear-gradient(135deg, #4CD964, #27AE60)',
                    color: '#FFFFFF',
                    fontSize: '13px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '6px',
                  }}
                >
                  {stickerSentToast ? (
                    <>
                      <Check size={15} /> Sent to 1-1 Chat!
                    </>
                  ) : (
                    <>
                      <Send size={14} /> Send Bitmoji in 1-1 Chat
                    </>
                  )}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setCreatedSticker(null);
                    setUploadedMemoryPhoto(null);
                  }}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: '#8C8C9E',
                    fontSize: '11.5px',
                    cursor: 'pointer',
                    padding: '4px',
                  }}
                >
                  Upload Another
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
