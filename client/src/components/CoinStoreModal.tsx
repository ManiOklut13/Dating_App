import React, { useState } from 'react';
import { X, Coins, ShieldCheck, CheckCircle2, ArrowRight } from 'lucide-react';
import confetti from 'canvas-confetti';

interface CoinStoreModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentBalance: number;
  onCoinsUpdated: (newBalance: number) => void;
}

export const CoinStoreModal: React.FC<CoinStoreModalProps> = ({
  isOpen,
  onClose,
  currentBalance,
  onCoinsUpdated,
}) => {
  const [activeSubTab, setActiveSubTab] = useState<'buy' | 'cashout'>('buy');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [cashoutAmount, setCashoutAmount] = useState('500');
  const [upiId, setUpiId] = useState('creator.arjun@okhdfcbank');

  if (!isOpen) return null;

  const packages = [
    { id: 'pack_100', name: 'Starter Spark', coins: 100, price: '₹99', bonus: 0, tag: 'Quick Refill' },
    { id: 'pack_500', name: 'Popular Flame', coins: 500, price: '₹399', bonus: 50, tag: 'Most Popular', highlight: true },
    { id: 'pack_1200', name: 'VIP Inferno', coins: 1200, price: '₹799', bonus: 200, tag: 'Best Value' },
  ];

  const handlePurchase = async (pkg: typeof packages[0]) => {
    setLoading(true);
    setMessage(null);
    try {
      const res = await fetch('/v1/wallet/purchase', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: '11111111-1111-1111-1111-111111111111',
          package_id: pkg.id,
          razorpay_payment_id: `rzp_test_${Date.now()}`,
        }),
      });
      const data = await res.json();
      if (data.success) {
        onCoinsUpdated(data.new_balance);
        setMessage(`🎉 Success! Added ${data.coins_added} coins to your wallet.`);
        confetti({ particleCount: 70, spread: 60, origin: { y: 0.6 } });
      }
    } catch (err: any) {
      setMessage('Transaction failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCashout = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    try {
      const res = await fetch('/v1/wallet/payout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: '11111111-1111-1111-1111-111111111111',
          coins_to_withdraw: parseInt(cashoutAmount, 10),
          upi_id: upiId,
        }),
      });
      const data = await res.json();
      if (data.success) {
        onCoinsUpdated(data.remaining_balance);
        setMessage(`✅ ${data.message}`);
        confetti({ particleCount: 50, spread: 50 });
      } else {
        setMessage(`❌ ${data.message || data.error}`);
      }
    } catch (err: any) {
      setMessage('Failed to process cashout request.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ position: 'fixed', inset: 0, zIndex: 50, display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'rgba(0, 0, 0, 0.75)', backdropFilter: 'blur(8px)', padding: '16px' }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '520px', borderRadius: 'var(--radius-lg)', padding: '24px', position: 'relative' }}>
        
        {/* Close Button */}
        <button
          onClick={onClose}
          style={{ position: 'absolute', top: '18px', right: '18px', background: 'rgba(255, 255, 255, 0.1)', border: 'none', borderRadius: '50%', width: '32px', height: '32px', color: '#ffffff', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        >
          <X size={18} />
        </button>

        {/* Modal Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
          <div style={{ width: '48px', height: '48px', borderRadius: '16px', background: 'var(--gradient-gold)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-gold)' }}>
            <Coins size={26} color="#1a1002" />
          </div>
          <div>
            <h2 style={{ fontSize: '22px', fontWeight: 700 }}>YoUnMe Coin Economy</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Current Balance: <strong style={{ color: '#ffd700' }}>{currentBalance} Coins</strong></p>
          </div>
        </div>

        {/* Sub Tabs: Buy Coins vs Creator Cash-Out */}
        <div style={{ display: 'flex', background: 'rgba(255, 255, 255, 0.05)', borderRadius: 'var(--radius-md)', padding: '4px', marginBottom: '20px' }}>
          <button
            onClick={() => { setActiveSubTab('buy'); setMessage(null); }}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              fontWeight: 600,
              fontSize: '13px',
              cursor: 'pointer',
              background: activeSubTab === 'buy' ? 'var(--gradient-flame)' : 'transparent',
              color: '#ffffff',
              transition: 'all var(--transition-fast)',
            }}
          >
            Buy Coin Bundles
          </button>
          <button
            onClick={() => { setActiveSubTab('cashout'); setMessage(null); }}
            style={{
              flex: 1,
              padding: '10px',
              borderRadius: 'var(--radius-sm)',
              border: 'none',
              fontWeight: 600,
              fontSize: '13px',
              cursor: 'pointer',
              background: activeSubTab === 'cashout' ? 'var(--gradient-gold)' : 'transparent',
              color: activeSubTab === 'cashout' ? '#1a1002' : '#ffffff',
              transition: 'all var(--transition-fast)',
            }}
          >
            Creator Cash-Out (&gt;500)
          </button>
        </div>

        {message && (
          <div style={{ padding: '12px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 255, 255, 0.06)', border: '1px solid rgba(255, 255, 255, 0.15)', fontSize: '13px', marginBottom: '16px', color: '#ffffff' }}>
            {message}
          </div>
        )}

        {/* Tab 1: Buy Coin Bundles */}
        {activeSubTab === 'buy' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {packages.map((pkg) => (
              <div
                key={pkg.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '16px',
                  borderRadius: 'var(--radius-md)',
                  background: pkg.highlight ? 'rgba(255, 45, 85, 0.1)' : 'rgba(255, 255, 255, 0.03)',
                  border: pkg.highlight ? '1px solid rgba(255, 45, 85, 0.4)' : '1px solid var(--border-glass)',
                  transition: 'transform var(--transition-fast)',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontWeight: 700, fontSize: '15px' }}>{pkg.name}</span>
                    <span style={{ fontSize: '11px', background: pkg.highlight ? 'var(--gradient-flame)' : 'rgba(255, 255, 255, 0.1)', padding: '2px 8px', borderRadius: 'var(--radius-full)', fontWeight: 600 }}>
                      {pkg.tag}
                    </span>
                  </div>
                  <div style={{ fontSize: '13px', color: '#ffd700', marginTop: '4px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                    <Coins size={14} />
                    <strong>{pkg.coins} Coins</strong>
                    {pkg.bonus > 0 && <span style={{ color: '#00e676', fontSize: '11px' }}>(+{pkg.bonus} Bonus)</span>}
                  </div>
                </div>

                <button
                  disabled={loading}
                  onClick={() => handlePurchase(pkg)}
                  className={pkg.highlight ? 'btn-primary' : 'btn-ghost'}
                  style={{ padding: '8px 16px', fontSize: '13px' }}
                >
                  Pay {pkg.price}
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Tab 2: Creator Cash-Out */}
        {activeSubTab === 'cashout' && (
          <form onSubmit={handleCashout} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div style={{ padding: '12px', borderRadius: 'var(--radius-md)', background: 'rgba(0, 230, 118, 0.08)', border: '1px solid rgba(0, 230, 118, 0.3)', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <ShieldCheck size={20} color="#00e676" />
              <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                <strong>Creator Settlement Policy:</strong> Verified creators can withdraw coins directly to their bank UPI at 100 Coins = ₹80. Min 500 coins.
              </div>
            </div>

            <div>
              <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>Coins to Cash-Out (Min 500)</label>
              <input
                type="number"
                min="500"
                step="50"
                value={cashoutAmount}
                onChange={(e) => setCashoutAmount(e.target.value)}
                style={{ width: '100%', padding: '10px 14px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 255, 255, 0.05)', border: '1px solid var(--border-glass)', color: '#ffffff', fontSize: '14px' }}
              />
              <span style={{ fontSize: '11px', color: '#ffd700', marginTop: '4px', display: 'block' }}>
                Estimated payout: ₹{Math.floor(parseInt(cashoutAmount || '0', 10) * 0.8)} INR
              </span>
            </div>

            <div>
              <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>Recipient UPI ID</label>
              <input
                type="text"
                value={upiId}
                onChange={(e) => setUpiId(e.target.value)}
                placeholder="name@okhdfcbank"
                style={{ width: '100%', padding: '10px 14px', borderRadius: 'var(--radius-md)', background: 'rgba(255, 255, 255, 0.05)', border: '1px solid var(--border-glass)', color: '#ffffff', fontSize: '14px' }}
              />
            </div>

            <button
              type="submit"
              disabled={loading || currentBalance < 500}
              className="btn-gold"
              style={{ padding: '12px', width: '100%', fontSize: '14px', marginTop: '8px', opacity: currentBalance < 500 ? 0.5 : 1 }}
            >
              {currentBalance < 500 ? 'Requires ≥ 500 Coins' : 'Request Instant UPI Cashout'}
            </button>
          </form>
        )}

      </div>
    </div>
  );
};
