import React, { useState } from 'react';
import { X, Sparkles, Trophy } from 'lucide-react';
import confetti from 'canvas-confetti';

interface SpinWheelModalProps {
  isOpen: boolean;
  onClose: () => void;
  streakDays: number;
  onCoinsAwarded: (newBalance: number) => void;
}

export const SpinWheelModal: React.FC<SpinWheelModalProps> = ({
  isOpen,
  onClose,
  streakDays,
  onCoinsAwarded,
}) => {
  const [spinning, setSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [resultMessage, setResultMessage] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleSpin = async () => {
    if (spinning) return;
    setSpinning(true);
    setResultMessage(null);

    // Dynamic rotation animation (5 full turns + random angle)
    const extraTurns = 1800;
    const randomAngle = Math.floor(Math.random() * 360);
    const newRotation = rotation + extraTurns + randomAngle;
    setRotation(newRotation);

    try {
      const res = await fetch('/v1/home/spin-wheel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: '11111111-1111-1111-1111-111111111111' }),
      });
      const data = await res.json();

      setTimeout(() => {
        setSpinning(false);
        if (data.success) {
          onCoinsAwarded(data.new_balance);
          setResultMessage(data.message);
          confetti({
            particleCount: 100,
            spread: 80,
            origin: { y: 0.6 },
          });
        } else {
          setResultMessage(data.message || data.error);
        }
      }, 3000);
    } catch (err) {
      setTimeout(() => {
        setSpinning(false);
        setResultMessage('Daily reward already claimed today!');
      }, 3000);
    }
  };

  return (
    <div style={{ position: 'fixed', inset: 0, zIndex: 50, display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(0, 0, 0, 0.8)', backdropFilter: 'blur(10px)', padding: '16px' }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '440px', borderRadius: 'var(--radius-lg)', padding: '24px', textAlign: 'center', position: 'relative' }}>
        
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '16px', right: '16px', background: 'rgba(255, 255, 255, 0.1)', border: 'none', borderRadius: '50%', width: '32px', height: '32px', color: '#ffffff', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginBottom: '8px' }}>
          <Sparkles color="#ffd700" size={24} />
          <h2 style={{ fontSize: '22px', fontWeight: 800 }}>Daily Streak Multiplier</h2>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '24px' }}>
          Active Streak: <strong style={{ color: '#ff9900' }}>Day {streakDays} 🔥</strong> (Current Bonus: <strong>1.4x</strong>)
        </p>

        {/* Wheel Graphic */}
        <div style={{ position: 'relative', width: '220px', height: '220px', margin: '0 auto 24px' }}>
          {/* Pointer */}
          <div style={{ position: 'absolute', top: '-10px', left: '50%', transform: 'translateX(-50%)', width: '0', height: '0', borderLeft: '10px solid transparent', borderRight: '10px solid transparent', borderTop: '16px solid #ffd700', zIndex: 10 }} />
          
          <div
            style={{
              width: '100%',
              height: '100%',
              borderRadius: '50%',
              border: '4px solid #ffd700',
              boxShadow: 'var(--shadow-gold)',
              background: 'conic-gradient(#ff2d55 0deg 72deg, #ff9900 72deg 144deg, #9b51e0 144deg 216deg, #00e5ff 216deg 288deg, #00e676 288deg 360deg)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              transition: spinning ? 'transform 3s cubic-bezier(0.15, 0.9, 0.2, 1)' : 'none',
              transform: `rotate(${rotation}deg)`,
            }}
          >
            <div style={{ width: '70px', height: '70px', borderRadius: '50%', background: '#0a0c16', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '3px solid rgba(255, 255, 255, 0.2)' }}>
              <Trophy size={28} color="#ffd700" />
            </div>
          </div>
        </div>

        {resultMessage ? (
          <div style={{ padding: '14px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 215, 0, 0.1)', border: '1px solid rgba(255, 215, 0, 0.3)', marginBottom: '16px', color: '#ffd700', fontWeight: 700, fontSize: '14px' }}>
            {resultMessage}
          </div>
        ) : (
          <button
            onClick={handleSpin}
            disabled={spinning}
            className="btn-gold"
            style={{ width: '100%', padding: '14px', fontSize: '15px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
          >
            <Sparkles size={18} />
            {spinning ? 'Spinning Wheel...' : 'Spin for Free Coins!'}
          </button>
        )}

      </div>
    </div>
  );
};
