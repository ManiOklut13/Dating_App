import React, { useState } from 'react';
import { useChat } from './ChatContext';
import { Shield } from 'lucide-react';
import {
  planDateTheme,
  Header,
  PartnerCard,
  DateModeCard,
  DateTypeCard,
  VIRTUAL_DATE_TYPES,
  OFFLINE_DATE_TYPES,
  TodosCard,
  NotesCard,
  SplitBillCard,
  AboutPlanDateCard,
  CTAButton,
  MeetupSpotCard,
  DressCodeNotesCard,
  DateProposedScreen,
  AfterTheDateScreen,
  CombinedDateTimeDurationCard,
  DateMode,
  Partner,
  TodoItem,
} from './plan-date';

export const DatePlannerModal: React.FC = () => {
  const { datePlannerConv, setDatePlannerConv, sendMessage, showToast } = useChat();

  // View state
  const [view, setView] = useState<'planning' | 'proposed' | 'after'>('planning');

  // Form state
  const [mode, setMode] = useState<DateMode>('virtual');
  const [partnerSearch, setPartnerSearch] = useState('');
  const [selectedType, setSelectedType] = useState(VIRTUAL_DATE_TYPES[0].id);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [timeHour, setTimeHour] = useState(19);
  const [timeMinute, setTimeMinute] = useState(30);
  const [timePeriod, setTimePeriod] = useState<'AM' | 'PM'>('PM');
  const [duration, setDuration] = useState(60);
  const [todos, setTodos] = useState<TodoItem[]>([
    { id: 1, text: 'Pick a movie', done: true },
    { id: 2, text: 'Order popcorn', done: false },
    { id: 3, text: 'Set up online game', done: false },
  ]);
  const [proposalNote, setProposalNote] = useState('');
  const [partnerNote, setPartnerNote] = useState('');
  const [yourShare, setYourShare] = useState(50);
  const [selectedSpot, setSelectedSpot] = useState<any>(null);
  const [selectedDressCode, setSelectedDressCode] = useState('Smart casual');

  if (!datePlannerConv) return null;

  const partner: Partner = {
    id: datePlannerConv.counterpart.id,
    name: datePlannerConv.counterpart.nickname,
    avatar: datePlannerConv.counterpart.avatar,
    isOnline: true,
  };

  const partnerNameFirst = datePlannerConv.counterpart.nickname.split(' ')[0];

  const handleModeChange = (newMode: DateMode) => {
    setMode(newMode);
    // Only change toggle and hint text as per requirements - don't reset other values
    // Optional: suggest different to-dos for offline
    if (newMode === 'offline' && todos.some(t => t.text === 'Set up online game')) {
      setTodos([
        { id: 1, text: 'Book a table', done: false },
        { id: 2, text: 'Choose a place', done: false },
        ...todos.filter(t => t.text !== 'Set up online game')
      ]);
    }
  };

  const handleSend = () => {
    if (!partner || !selectedType || !selectedDate) {
      return;
    }

    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    const dateStr = `${monthNames[selectedDate.getMonth()]} ${selectedDate.getDate()}, ${selectedDate.getFullYear()}`;
    const timeStr = `${timeHour}:${timeMinute.toString().padStart(2, '0')} ${timePeriod}`;
    
    const types = mode === 'virtual' ? VIRTUAL_DATE_TYPES : OFFLINE_DATE_TYPES;
    const selectedTypeObj = types.find(t => t.id === selectedType);
    
    const res = sendMessage(datePlannerConv.id, {
      type: 'date_invite',
      body: `Date Invitation: ${selectedTypeObj?.label || selectedType} on ${dateStr} at ${timeStr}`,
      date_invite: {
        id: `date-${Date.now()}`,
        activity: selectedTypeObj?.label || selectedType,
        date: dateStr,
        time: timeStr,
        location: mode === 'virtual' ? 'Virtual' : (selectedSpot?.name || 'To be decided'),
        status: 'pending',
      },
    });
    
    if (res.success) {
      setView('proposed');
    }
  };

  const handleBackToChat = () => {
    showToast({ type: 'success', text: `Date plan sent to ${datePlannerConv.counterpart.nickname}!` });
    setDatePlannerConv(null);
    setView('planning');
  };

  const handleViewAfterDate = () => {
    setView('after');
  };

  const handleBackFromAfter = () => {
    setView('proposed');
  };

  const isDisabled = !partner || !selectedType || !selectedDate;

  if (view === 'proposed') {
    const types = mode === 'virtual' ? VIRTUAL_DATE_TYPES : OFFLINE_DATE_TYPES;
    const selectedTypeObj = types.find(t => t.id === selectedType);
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    const dateStr = `${monthNames[selectedDate.getMonth()]} ${selectedDate.getDate()}, ${selectedDate.getFullYear()}`;
    const timeStr = `${timeHour}:${timeMinute.toString().padStart(2, '0')} ${timePeriod}`;
    
    return (
      <DateProposedScreen
        partnerName={partnerNameFirst}
        mode={mode}
        dateType={selectedTypeObj?.label || selectedType}
        spotName={selectedSpot?.name}
        date={dateStr}
        time={timeStr}
        duration={duration}
        split={mode === 'virtual' ? `${yourShare}% / ${100-yourShare}%` : `${yourShare}% / ${100-yourShare}%`}
        cost={150}
        onBackToChat={handleBackToChat}
        onViewAfterDate={handleViewAfterDate}
      />
    );
  }

  if (view === 'after') {
    const types = mode === 'virtual' ? VIRTUAL_DATE_TYPES : OFFLINE_DATE_TYPES;
    const selectedTypeObj = types.find(t => t.id === selectedType);
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    const dateInfo = `${monthNames[selectedDate.getMonth()]} ${selectedDate.getDate()} · ${timeHour}:${timeMinute.toString().padStart(2, '0')} ${timePeriod} · ${duration} min`;
    
    return (
      <AfterTheDateScreen
        mode={mode}
        dateType={selectedTypeObj?.label || selectedType}
        spotName={selectedSpot?.name}
        dateInfo={dateInfo}
        onBack={handleBackFromAfter}
        partnerName={partnerNameFirst}
      />
    );
  }

  const currentTypes = mode === 'virtual' ? VIRTUAL_DATE_TYPES : OFFLINE_DATE_TYPES;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 9999,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        backdropFilter: 'blur(10px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '10px',
        fontFamily: planDateTheme.typography.fontFamily,
      }}
      onClick={() => setDatePlannerConv(null)}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          width: '100%',
          maxWidth: '390px',
          maxHeight: '95vh',
          backgroundColor: '#0e0a14',
          backgroundImage: `radial-gradient(ellipse 60% 40% at 90% 0%, rgba(233,30,140,0.15) 0%, transparent 60%)`,
          backgroundPosition: 'top right',
          backgroundRepeat: 'no-repeat',
          borderRadius: '18px',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          border: `1px solid #2a2234`,
        }}
      >
        <div style={{ padding: `${planDateTheme.spacing.screenPadding}px ${planDateTheme.spacing.screenPadding}px 0` }}>
          <Header onClose={() => setDatePlannerConv(null)} />
        </div>

        <div
          style={{
            flex: 1,
            overflowY: 'auto',
            overflowX: 'hidden',
            padding: `0 16px`,
            display: 'flex',
            flexDirection: 'column',
            gap: '14px',
          }}
        >
          <PartnerCard
            partner={partner}
            searchValue={partnerSearch}
            onSearchChange={setPartnerSearch}
          />

          <DateModeCard mode={mode} onModeChange={handleModeChange} />

          <DateTypeCard
            types={currentTypes}
            selectedType={selectedType}
            onTypeSelect={setSelectedType}
          />

          {mode === 'offline' && (
            <MeetupSpotCard
              selectedSpot={selectedSpot}
              onSpotSelect={setSelectedSpot}
            />
          )}

          <CombinedDateTimeDurationCard
            selectedDate={selectedDate}
            onDateChange={setSelectedDate}
            hour={timeHour}
            minute={timeMinute}
            period={timePeriod}
            onHourChange={setTimeHour}
            onMinuteChange={setTimeMinute}
            onPeriodChange={setTimePeriod}
            duration={duration}
            onDurationChange={setDuration}
          />

          {mode === 'offline' ? (
            <DressCodeNotesCard
              proposalNote={proposalNote}
              partnerNote={partnerNote}
              onProposalNoteChange={setProposalNote}
              onPartnerNoteChange={setPartnerNote}
              selectedDressCode={selectedDressCode}
              onDressCodeChange={setSelectedDressCode}
            />
          ) : (
            <TodosCard todos={todos} onTodosChange={setTodos} />
          )}

          {mode === 'virtual' && (
            <NotesCard
              proposalNote={proposalNote}
              partnerNote={partnerNote}
              onProposalNoteChange={setProposalNote}
              onPartnerNoteChange={setPartnerNote}
            />
          )}

          {mode === 'offline' && (
            <TodosCard todos={todos} onTodosChange={setTodos} />
          )}

          <SplitBillCard
            yourShare={yourShare}
            onYourShareChange={setYourShare}
            partnerName={partnerNameFirst}
          />
        </div>

        <div style={{ padding: '12px 16px 16px', borderTop: `1px solid #2a2234` }}>
          <CTAButton
            onClick={handleSend}
            cost={150}
            disabled={isDisabled}
            partnerName={partnerNameFirst}
          />
        </div>
      </div>
    </div>
  );
};
