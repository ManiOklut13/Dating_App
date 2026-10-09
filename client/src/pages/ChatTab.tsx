import React, { useState, useEffect, useRef } from 'react';
import { Send, ShieldAlert, ShieldCheck, Flame, Mic, Lock, PhoneCall, CheckCheck } from 'lucide-react';
import { MessageItem } from '../types';

interface ChatTabProps {
  selectedConvId?: string;
  onStartCall: (calleeId: string, name: string, avatar: string) => void;
}

export const ChatTab: React.FC<ChatTabProps> = ({ selectedConvId, onStartCall }) => {
  const convId = selectedConvId || 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const [messages, setMessages] = useState<MessageItem[]>([]);
  const [inputText, setInputText] = useState('');
  const [isVanishMode, setIsVanishMode] = useState(false);
  const [guardAlert, setGuardAlert] = useState<{ reason: string; strikes: number } | null>(null);
  const [contactUnlocked, setContactUnlocked] = useState(false);
  const [activeDays, setActiveDays] = useState(1);
  const [pairCount, setPairCount] = useState(6);
  const [isRecording, setIsRecording] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const fetchMessages = async () => {
    try {
      const res = await fetch(`/v1/messages/${convId}`);
      const data = await res.json();
      if (data.success) {
        setMessages(data.messages);
        setContactUnlocked(data.contact_sharing_unlocked);
        setActiveDays(data.active_days);
        setPairCount(data.message_pair_count);
      }
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchMessages();
  }, [convId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim()) return;

    setGuardAlert(null);

    try {
      const res = await fetch('/v1/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          conv_id: convId,
          sender_id: '11111111-1111-1111-1111-111111111111',
          type: 'text',
          body: inputText,
          vanish_seconds: isVanishMode ? 60 : null,
        }),
      });

      const data = await res.json();

      if (res.status === 422) {
        // Contact Guard Intercepted!
        setGuardAlert({
          reason: data.reason,
          strikes: data.strike_count,
        });
        return;
      }

      if (data.success) {
        setMessages((prev) => [...prev, data.message]);
        setPairCount(data.message_pair_count);
        setInputText('');

        // Simulate realistic smart reply from Ananya after 2 seconds
        if (messages.length % 2 === 0) {
          setTimeout(() => {
            const replies = [
              "Totally agree! Have you listened to the new Peter Cat Recording Co. vinyl?",
              "Subko's cinnamon toast is iconic! We definitely need to grab coffee there soon ☕",
              "Haha that dry wit is dangerous! Are you always this witty on first conversations? 😊",
            ];
            const botReply: MessageItem = {
              id: Date.now(),
              conv_id: convId,
              sender_id: '22222222-2222-2222-2222-222222222222',
              type: 'text',
              body: replies[Math.floor(Math.random() * replies.length)],
              is_flagged: false,
              created_at: new Date().toISOString(),
            };
            setMessages((prev) => [...prev, botReply]);
          }, 1800);
        }
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSendAudioNote = () => {
    setIsRecording(true);
    setTimeout(async () => {
      setIsRecording(false);
      try {
        const res = await fetch('/v1/messages', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            conv_id: convId,
            sender_id: '11111111-1111-1111-1111-111111111111',
            type: 'audio',
            body: '🎙️ Voice Note (0:14) — "Hey Ananya, Subko Bandra tomorrow?"',
            media_url: 'voice_note_subko.mp3',
          }),
        });
        const data = await res.json();
        if (data.success) {
          setMessages((prev) => [...prev, data.message]);
        }
      } catch (err) {
        console.error(err);
      }
    }, 1500);
  };

  return (
    <div style={{ maxWidth: '680px', margin: '20px auto', padding: '0 16px' }}>
      
      {/* Chat Container */}
      <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', height: '620px', display: 'flex', flexDirection: 'column', overflow: 'hidden', border: '1px solid var(--border-glass)' }}>
        
        {/* Chat Header */}
        <div style={{ padding: '14px 20px', background: 'rgba(8, 10, 16, 0.9)', borderBottom: '1px solid var(--border-glass)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ position: 'relative', width: '42px', height: '42px' }}>
              <img
                src="/ananya.jpg"
                alt="Ananya Sharma"
                style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '2px solid #ff2d55' }}
              />
              <div style={{ position: 'absolute', bottom: 0, right: 0, width: '10px', height: '10px', borderRadius: '50%', background: '#00e676', border: '2px solid #080a10' }} />
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ fontWeight: 700, fontSize: '15px' }}>Ananya Sharma</span>
                <span className="badge-blue-tick">✓</span>
              </div>
              <div style={{ fontSize: '11px', color: '#00e676' }}>Active Now • Bandra Pali Hill</div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            {/* Vanish Mode Switch */}
            <button
              onClick={() => setIsVanishMode(!isVanishMode)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                padding: '6px 10px',
                borderRadius: 'var(--radius-full)',
                border: isVanishMode ? '1px solid #ff2d55' : '1px solid var(--border-glass)',
                background: isVanishMode ? 'rgba(255, 45, 85, 0.2)' : 'rgba(255, 255, 255, 0.05)',
                color: isVanishMode ? '#ff2d55' : 'var(--text-secondary)',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
              }}
              title="Vanish Mode: Disappearing Ephemeral Messages"
            >
              <Flame size={14} />
              <span>{isVanishMode ? 'Vanish ON' : 'Vanish'}</span>
            </button>

            {/* LiveKit Call Button */}
            <button
              onClick={() => onStartCall('22222222-2222-2222-2222-222222222222', 'Ananya', '/ananya.jpg')}
              className="btn-primary"
              style={{ padding: '8px 14px', fontSize: '12px', gap: '6px' }}
            >
              <PhoneCall size={14} />
              <span>Call</span>
            </button>
          </div>
        </div>

        {/* Contact Guard Status Ribbon */}
        <div style={{ padding: '8px 16px', background: contactUnlocked ? 'rgba(0, 230, 118, 0.1)' : 'rgba(255, 170, 0, 0.08)', borderBottom: '1px solid rgba(255, 255, 255, 0.05)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '11px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: contactUnlocked ? '#00e676' : '#ffd700' }}>
            {contactUnlocked ? <ShieldCheck size={14} /> : <Lock size={14} />}
            <span>
              {contactUnlocked
                ? 'Trust Phase Complete: Direct contact sharing is unlocked.'
                : `🛡️ Trust Guard Active: Phone numbers & external links locked (Day ${activeDays}/3 • ${pairCount}/20 messages)`}
            </span>
          </div>
          <span style={{ color: 'var(--text-muted)' }}>Auto-Unlocks at 20 msgs</span>
        </div>

        {/* Warning Toast if Contact Guard Triggers */}
        {guardAlert && (
          <div style={{ margin: '12px 16px', padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 71, 87, 0.15)', border: '1px solid #ff4757', display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
            <ShieldAlert size={18} color="#ff4757" style={{ flexShrink: 0, marginTop: '2px' }} />
            <div>
              <div style={{ fontSize: '13px', fontWeight: 700, color: '#ff4757' }}>Interception: Contact Guard Triggered</div>
              <div style={{ fontSize: '12px', color: '#ffffff', marginTop: '2px' }}>{guardAlert.reason}</div>
              <div style={{ fontSize: '11px', color: 'rgba(255, 255, 255, 0.7)', marginTop: '4px' }}>
                Strike count logged: {guardAlert.strikes}. Please keep interactions within YoUnMe during early acquaintance.
              </div>
            </div>
          </div>
        )}

        {/* Messages Stream */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {messages.map((msg) => {
            const isMe = msg.sender_id === '11111111-1111-1111-1111-111111111111';
            return (
              <div
                key={msg.id}
                style={{
                  alignSelf: isMe ? 'flex-end' : 'flex-start',
                  maxWidth: '75%',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: isMe ? 'flex-end' : 'flex-start',
                }}
              >
                <div
                  style={{
                    padding: '10px 14px',
                    borderRadius: '16px',
                    borderTopRightRadius: isMe ? '4px' : '16px',
                    borderTopLeftRadius: !isMe ? '4px' : '16px',
                    background: isMe ? 'var(--gradient-flame)' : 'rgba(255, 255, 255, 0.08)',
                    color: '#ffffff',
                    fontSize: '13.5px',
                    lineHeight: 1.4,
                    boxShadow: isMe ? 'var(--shadow-glow)' : 'none',
                    border: !isMe ? '1px solid var(--border-glass)' : 'none',
                  }}
                >
                  {msg.body}
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '4px', fontSize: '10px', color: 'var(--text-muted)' }}>
                  <span>{new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                  {isMe && <CheckCheck size={12} color="#00e5ff" />}
                  {msg.expires_at && <span style={{ color: '#ff2d55' }}>🔥 vanish</span>}
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        {/* Chat Input Bar */}
        <form onSubmit={handleSendMessage} style={{ padding: '12px 16px', background: 'rgba(8, 10, 16, 0.95)', borderTop: '1px solid var(--border-glass)', display: 'flex', alignItems: 'center', gap: '10px' }}>
          
          {/* Audio Note Recorder */}
          <button
            type="button"
            onClick={handleSendAudioNote}
            style={{
              background: isRecording ? '#ff2d55' : 'rgba(255, 255, 255, 0.06)',
              border: 'none',
              borderRadius: '50%',
              width: '38px',
              height: '38px',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)',
            }}
            title="Record 2-minute Audio Note"
          >
            <Mic size={18} />
          </button>

          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            placeholder={isRecording ? 'Recording audio note...' : 'Type a message... (Try phone or IG to test guard)'}
            style={{
              flex: 1,
              padding: '10px 14px',
              borderRadius: 'var(--radius-full)',
              background: 'rgba(255, 255, 255, 0.06)',
              border: '1px solid var(--border-glass)',
              color: '#ffffff',
              fontSize: '13px',
              outline: 'none',
            }}
          />

          <button
            type="submit"
            className="btn-primary"
            style={{ width: '38px', height: '38px', borderRadius: '50%', padding: 0 }}
          >
            <Send size={16} />
          </button>
        </form>

      </div>
    </div>
  );
};
