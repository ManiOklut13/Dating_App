import React, { useState } from 'react';
import { ChevronLeft, Gem, Sparkles, Flame, Video, ShieldCheck, CheckCircle2, Gift, ChevronDown, ChevronUp } from 'lucide-react';
import confetti from 'canvas-confetti';

interface RubiesPageProps {
  rubyBalance: number;
  onUpdateBalance: (newBalance: number) => void;
  onBack: () => void;
}

interface RubyPackage {
  id: string;
  name: string;
  rubies: number;
  bonus: number;
  priceInr: string;
  tag?: string;
  popular?: boolean;
}

export const RubiesPage: React.FC<RubiesPageProps> = ({
  rubyBalance,
  onUpdateBalance,
  onBack,
}) => {
  const [purchasingId, setPurchasingId] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [isHowRubiesWorkOpen, setIsHowRubiesWorkOpen] = useState(false);

  const packages: RubyPackage[] = [
    {
      id: 'pack_100',
      name: 'Starter Spark',
      rubies: 100,
      bonus: 0,
      priceInr: '₹99',
      tag: 'Quick Refill',
    },
    {
      id: 'pack_500',
      name: 'Popular Flame',
      rubies: 500,
      bonus: 50,
      priceInr: '₹399',
      tag: 'Most Popular',
      popular: true,
    },
    {
      id: 'pack_1200',
      name: 'VIP Inferno',
      rubies: 1200,
      bonus: 200,
      priceInr: '₹799',
      tag: 'Best Value',
    },
  ];

  const handlePurchase = (pkg: RubyPackage) => {
    setPurchasingId(pkg.id);
    setTimeout(() => {
      const added = pkg.rubies + pkg.bonus;
      const newBal = rubyBalance + added;
      onUpdateBalance(newBal);
      setPurchasingId(null);
      setSuccessMessage(`Added ${added} Rubies to your balance!`);
      try {
        confetti({
          particleCount: 45,
          spread: 60,
          origin: { y: 0.6 },
          colors: ['#f43f5e', '#fb7185', '#ffd700', '#ffffff'],
        });
      } catch {
        // fallback
      }
      setTimeout(() => setSuccessMessage(null), 3000);
    }, 600);
  };

  return (
    <div
      style={{
        minHeight: '100%',
        background: '#111318',
        color: '#f8fafc',
        display: 'flex',
        flexDirection: 'column',
        paddingBottom: '80px',
      }}
    >
      {/* Clean Single Back Header */}
      <header
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 40,
          background: 'rgba(17, 19, 24, 0.95)',
          backdropFilter: 'blur(16px)',
          WebkitBackdropFilter: 'blur(16px)',
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          padding: '12px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <button
          type="button"
          onClick={onBack}
          style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            color: '#f8fafc',
            borderRadius: '999px',
            padding: '6px 12px 6px 8px',
            display: 'flex',
            alignItems: 'center',
            gap: '4px',
            fontSize: '12.5px',
            fontWeight: 600,
            cursor: 'pointer',
          }}
        >
          <ChevronLeft size={16} />
          <span>Back</span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Gem size={17} color="#f43f5e" />
          <span style={{ fontSize: '15px', fontWeight: 800, color: '#f8fafc' }}>
            YoUnMe Rubies
          </span>
        </div>

        <div style={{ width: '60px' }} />
      </header>

      {/* Main Body */}
      <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {/* Toast Notification */}
        {successMessage && (
          <div
            style={{
              background: 'rgba(34, 197, 94, 0.15)',
              border: '1px solid rgba(34, 197, 94, 0.3)',
              color: '#4ade80',
              padding: '10px 14px',
              borderRadius: '12px',
              fontSize: '12.5px',
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
            }}
          >
            <CheckCircle2 size={16} />
            <span>{successMessage}</span>
          </div>
        )}

        {/* Current Ruby Balance Card */}
        <div
          style={{
            background: '#191c24',
            borderRadius: '20px',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '20px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            boxShadow: '0 8px 24px rgba(0, 0, 0, 0.35)',
          }}
        >
          <div>
            <div style={{ fontSize: '11.5px', color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.8px', fontWeight: 600 }}>
              Current Ruby Balance
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: '8px', marginTop: '4px' }}>
              <span style={{ fontSize: '32px', fontWeight: 900, color: '#f8fafc', letterSpacing: '-0.5px' }}>
                {rubyBalance}
              </span>
              <span style={{ fontSize: '14px', color: '#f43f5e', fontWeight: 700 }}>
                Rubies
              </span>
            </div>
            <p style={{ margin: '6px 0 0', fontSize: '12px', color: '#94a3b8', lineHeight: 1.4 }}>
              Used for Mega Crushes, Instant Video Calls & Priority Discovery.
            </p>
          </div>

          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '18px',
              background: 'rgba(244, 63, 94, 0.12)',
              border: '1px solid rgba(244, 63, 94, 0.35)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <Gem size={28} color="#f43f5e" />
          </div>
        </div>

        {/* How Rubies Work */}
        <div
          style={{
            background: '#191c24',
            borderRadius: '18px',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '16px',
          }}
        >
          <div
            onClick={() => setIsHowRubiesWorkOpen(!isHowRubiesWorkOpen)}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              cursor: 'pointer',
              userSelect: 'none',
              marginBottom: isHowRubiesWorkOpen ? '12px' : 0,
            }}
          >
            <div style={{ fontSize: '13.5px', fontWeight: 700, color: '#f8fafc' }}>
              How Rubies Work
            </div>
            <button
              type="button"
              aria-label="Toggle How Rubies Work"
              style={{
                background: 'rgba(255, 255, 255, 0.06)',
                border: 'none',
                borderRadius: '50%',
                width: '26px',
                height: '26px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#94a3b8',
                cursor: 'pointer',
              }}
            >
              {isHowRubiesWorkOpen ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
            </button>
          </div>

          {isHowRubiesWorkOpen && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', marginTop: '6px' }}>
              {/* How to Earn */}
              <div>
                <div style={{ fontSize: '11.5px', fontWeight: 800, color: '#fbbf24', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '8px' }}>
                  Ways to Earn Rubies 🎁
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', fontSize: '12px' }}>
                    <div style={{ width: '26px', height: '26px', borderRadius: '8px', background: 'rgba(251, 191, 36, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Gift size={14} color="#fbbf24" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: '#f8fafc' }}>Daily Streak & Spin Wheel</div>
                      <div style={{ color: '#94a3b8', fontSize: '11px', marginTop: '1px' }}>
                        Collect +10 to +30 free Rubies every day by maintaining your daily fire streak or spinning the daily reward wheel.
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', fontSize: '12px' }}>
                    <div style={{ width: '26px', height: '26px', borderRadius: '8px', background: 'rgba(56, 189, 248, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <CheckCircle2 size={14} color="#38bdf8" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: '#f8fafc' }}>Profile Milestones & Verification</div>
                      <div style={{ color: '#94a3b8', fontSize: '11px', marginTop: '1px' }}>
                        Complete face liveness verification (+50 Rubies) and reach 100% profile bio enrichment.
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* How to Spend */}
              <div style={{ borderTop: '1px solid rgba(255, 255, 255, 0.06)', paddingTop: '10px' }}>
                <div style={{ fontSize: '11.5px', fontWeight: 800, color: '#f43f5e', textTransform: 'uppercase', letterSpacing: '0.6px', marginBottom: '8px' }}>
                  How to Spend Rubies 💎
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', fontSize: '12px' }}>
                    <div style={{ width: '26px', height: '26px', borderRadius: '8px', background: 'rgba(239, 68, 68, 0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Flame size={14} color="#ef4444" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: '#f8fafc' }}>Mega Crushes & Profile Boosts</div>
                      <div style={{ color: '#94a3b8', fontSize: '11px', marginTop: '1px' }}>
                        Send burning fire aura priority cards (50 Rubies) and jump straight to the top of the discovery queue.
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', fontSize: '12px' }}>
                    <div style={{ width: '26px', height: '26px', borderRadius: '8px', background: 'rgba(244, 63, 94, 0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Gem size={14} color="#f43f5e" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: '#f8fafc' }}>Rewind Beyond 5 Free Reverts</div>
                      <div style={{ color: '#94a3b8', fontSize: '11px', marginTop: '1px' }}>
                        Undo accidental left-swipes and rewind any passed profiles even after exhausting your 5 free daily rewinds.
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px', fontSize: '12px' }}>
                    <div style={{ width: '26px', height: '26px', borderRadius: '8px', background: 'rgba(56, 189, 248, 0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <Video size={14} color="#38bdf8" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: '#f8fafc' }}>Instant Video Dates & Direct Spark</div>
                      <div style={{ color: '#94a3b8', fontSize: '11px', marginTop: '1px' }}>
                        Connect on private verified 1-on-1 video dates or dispatch an instant message before matching.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Ruby Packages (Priced in ₹ INR) */}
        <div>
          <div style={{ fontSize: '13.5px', fontWeight: 700, color: '#f8fafc', marginBottom: '10px' }}>
            Top Up Rubies (INR)
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {packages.map((pkg) => (
              <div
                key={pkg.id}
                style={{
                  background: pkg.popular ? '#222631' : '#191c24',
                  borderRadius: '16px',
                  border: pkg.popular
                    ? '1.5px solid rgba(244, 63, 94, 0.5)'
                    : '1px solid rgba(255, 255, 255, 0.08)',
                  padding: '14px 16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '15px', fontWeight: 800, color: '#f8fafc' }}>
                      {pkg.name}
                    </span>
                    {pkg.tag && (
                      <span
                        style={{
                          fontSize: '10px',
                          fontWeight: 700,
                          padding: '2px 7px',
                          borderRadius: '6px',
                          background: pkg.popular ? 'rgba(244, 63, 94, 0.2)' : 'rgba(255, 255, 255, 0.06)',
                          color: pkg.popular ? '#f43f5e' : '#94a3b8',
                        }}
                      >
                        {pkg.tag}
                      </span>
                    )}
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '4px' }}>
                    <Gem size={14} color="#f43f5e" />
                    <span style={{ fontSize: '13px', fontWeight: 700, color: '#f8fafc' }}>
                      {pkg.rubies} Rubies
                    </span>
                    {pkg.bonus > 0 && (
                      <span style={{ fontSize: '11px', color: '#4ade80', fontWeight: 700 }}>
                        +{pkg.bonus} Free Bonus
                      </span>
                    )}
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => handlePurchase(pkg)}
                  disabled={purchasingId === pkg.id}
                  style={{
                    padding: '8px 18px',
                    borderRadius: '10px',
                    border: 'none',
                    background: pkg.popular
                      ? 'linear-gradient(135deg, #f43f5e 0%, #e11d48 100%)'
                      : 'rgba(255, 255, 255, 0.08)',
                    color: '#ffffff',
                    fontSize: '13px',
                    fontWeight: 800,
                    cursor: 'pointer',
                    boxShadow: pkg.popular ? '0 4px 14px rgba(244, 63, 94, 0.35)' : 'none',
                  }}
                >
                  {purchasingId === pkg.id ? 'Processing...' : pkg.priceInr}
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Earn Free Rubies */}
        <div
          style={{
            background: '#191c24',
            borderRadius: '16px',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '14px 16px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
            <Gift size={16} color="#eab308" />
            <span style={{ fontSize: '13px', fontWeight: 700, color: '#f8fafc' }}>
              Ways to Earn Free Rubies
            </span>
          </div>

          <ul style={{ margin: 0, paddingLeft: '20px', fontSize: '11.5px', color: '#94a3b8', lineHeight: 1.6 }}>
            <li>Daily login streak (+10 to +30 Rubies daily)</li>
            <li>Complete Face Liveness verification (+50 Rubies once)</li>
            <li>Invite trusted friends to YoUnMe (+100 Rubies/friend)</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

