import React, { useState, useEffect } from 'react';
import { ShieldCheck, Coins, ArrowUpRight, ArrowDownLeft, Mic, UserCheck, Sparkles, MapPin } from 'lucide-react';
import { TransactionItem } from '../types';

interface ProfileWalletTabProps {
  coinBalance: number;
  onOpenStore: () => void;
  onOpenWheel: () => void;
}

export const ProfileWalletTab: React.FC<ProfileWalletTabProps> = ({
  coinBalance,
  onOpenStore,
  onOpenWheel,
}) => {
  const [ledger, setLedger] = useState<TransactionItem[]>([]);
  const [profileProgress, setProfileProgress] = useState(92);
  const [isVerified, setIsVerified] = useState(true);

  useEffect(() => {
    const fetchWalletData = async () => {
      try {
        const res = await fetch('/v1/wallet?user_id=11111111-1111-1111-1111-111111111111');
        const data = await res.json();
        if (data.success) {
          setLedger(data.ledger);
          setIsVerified(data.is_verified_creator);
        }
      } catch (err) {
        console.error(err);
      }
    };
    fetchWalletData();
  }, [coinBalance]);

  const onboardingSteps = [
    { title: 'Phone Verification (Twilio WhatsApp OTP)', completed: true },
    { title: 'Basic Identity & Bio', completed: true },
    { title: 'Discovery Preferences', completed: true },
    { title: '6 Photos Uploaded', completed: true },
    { title: 'Voice PIN Recording Sample', completed: true },
    { title: 'Blink SDK Oval Face Liveness Test', completed: true },
    { title: 'Anonymous Call Avatar Configured', completed: true },
    { title: 'PostGIS GPS Geolocation Anchored', completed: true },
    { title: 'Trust Guard Baseline Enabled', completed: true },
  ];

  return (
    <div style={{ maxWidth: '840px', margin: '20px auto', padding: '0 16px' }}>
      
      {/* Profile Card Header */}
      <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '28px', marginBottom: '24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div style={{ position: 'relative', width: '90px', height: '90px' }}>
            <img
              src="/aditya.jpg"
              alt="Arjun Mehta"
              style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: '3px solid #ff2d55', boxShadow: 'var(--shadow-glow)' }}
            />
            {isVerified && (
              <div className="badge-blue-tick" style={{ position: 'absolute', bottom: '2px', right: '2px', width: '22px', height: '22px', fontSize: '13px' }}>
                ✓
              </div>
            )}
          </div>

          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <h1 style={{ fontSize: '24px', fontWeight: 800 }}>Arjun Mehta, 26</h1>
              <span style={{ fontSize: '12px', background: 'rgba(29, 161, 242, 0.2)', color: '#1da1f2', padding: '2px 8px', borderRadius: 'var(--radius-full)', fontWeight: 700, border: '1px solid rgba(29, 161, 242, 0.4)' }}>
                Blue Tick Verified
              </span>
            </div>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Building next-gen AI tech • Subko coffee addict • Mumbai (Bandra West)
            </p>
            <div style={{ display: 'flex', gap: '14px', marginTop: '10px', fontSize: '12px', color: 'var(--cyan-vibe)' }}>
              <span>📍 19.0596° N, 72.8295° E</span>
              <span>🎙️ Voice PIN Active</span>
              <span>🎭 Cyber Lotus Avatar</span>
            </div>
          </div>
        </div>

        {/* 9-Step Completion Meter */}
        <div style={{ background: 'rgba(255, 255, 255, 0.04)', borderRadius: 'var(--radius-md)', padding: '16px 20px', textAlign: 'center', border: '1px solid var(--border-glass)' }}>
          <div style={{ fontSize: '11px', color: 'var(--text-secondary)', textTransform: 'uppercase', letterSpacing: '1px' }}>Onboarding Progress</div>
          <div style={{ fontSize: '28px', fontWeight: 800, color: '#00e676', margin: '4px 0' }}>{profileProgress}%</div>
          <div style={{ fontSize: '11px', color: '#1da1f2' }}>Auto-awarded Blue Tick (&gt;=70%)</div>
        </div>
      </div>

      {/* Wallet Balance Hero Section */}
      <div className="glass-panel" style={{ borderRadius: 'var(--radius-lg)', padding: '28px', marginBottom: '24px', background: 'radial-gradient(circle at 10% 20%, rgba(255, 215, 0, 0.12) 0%, rgba(15, 18, 29, 0.95) 100%)', border: '1px solid rgba(255, 215, 0, 0.3)' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#ffd700', fontSize: '13px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '1px' }}>
              <Coins size={18} />
              Double-Entry Wallet Ledger
            </div>
            <div style={{ fontSize: '42px', fontWeight: 800, color: '#ffffff', margin: '6px 0' }}>
              {coinBalance} <span style={{ fontSize: '18px', color: '#ffd700', fontWeight: 600 }}>YoUnMe Coins</span>
            </div>
            <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
              Server-authoritative balance • Zero double-spending guarantee
            </div>
          </div>

          <div style={{ display: 'flex', gap: '12px' }}>
            <button onClick={onOpenStore} className="btn-gold" style={{ padding: '12px 22px', fontSize: '14px' }}>
              + Buy Coin Bundles
            </button>
            <button onClick={onOpenWheel} className="btn-ghost" style={{ padding: '12px 18px', fontSize: '14px', display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Sparkles size={16} color="#ffa502" />
              Spin Wheel
            </button>
          </div>
        </div>
      </div>

      {/* 9-Step Verification Checklist & Ledger Audit */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: '20px' }}>
        
        {/* Onboarding Verification Checklist */}
        <div className="glass-panel" style={{ borderRadius: 'var(--radius-md)', padding: '20px' }}>
          <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldCheck size={18} color="#00e676" />
            9-Step Verification Status
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {onboardingSteps.map((step, idx) => (
              <div key={idx} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '13px', padding: '6px 0', borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                <span style={{ color: 'var(--text-secondary)' }}>{idx + 1}. {step.title}</span>
                <span style={{ color: '#00e676', fontWeight: 700 }}>✓ Done</span>
              </div>
            ))}
          </div>
        </div>

        {/* Append-Only Double-Entry Audit Ledger */}
        <div className="glass-panel" style={{ borderRadius: 'var(--radius-md)', padding: '20px' }}>
          <h3 style={{ fontSize: '16px', fontWeight: 700, marginBottom: '14px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Coins size={18} color="#ffd700" />
            Append-Only Audit Ledger
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '340px', overflowY: 'auto' }}>
            {ledger.length === 0 ? (
              <div style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>Loading transactions...</div>
            ) : (
              ledger.map((tx) => {
                const isCredit = tx.coins > 0;
                return (
                  <div
                    key={tx.idempotency_key || tx.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '10px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'rgba(255, 255, 255, 0.02)',
                      border: '1px solid rgba(255, 255, 255, 0.05)',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <div style={{ width: '28px', height: '28px', borderRadius: '50%', background: isCredit ? 'rgba(0, 230, 118, 0.15)' : 'rgba(255, 45, 85, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        {isCredit ? <ArrowDownLeft size={16} color="#00e676" /> : <ArrowUpRight size={16} color="#ff2d55" />}
                      </div>
                      <div>
                        <div style={{ fontSize: '13px', fontWeight: 600, textTransform: 'capitalize' }}>
                          {tx.type} • {tx.reference_id?.slice(0, 20)}
                        </div>
                        <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                          {new Date(tx.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </div>
                      </div>
                    </div>

                    <div style={{ fontSize: '14px', fontWeight: 700, color: isCredit ? '#00e676' : '#ff4757' }}>
                      {isCredit ? `+${tx.coins}` : tx.coins}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

      </div>

    </div>
  );
};
