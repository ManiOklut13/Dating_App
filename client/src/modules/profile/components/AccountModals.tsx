import React, { useState } from 'react';
import {
  X,
  Mail,
  Phone,
  KeyRound,
  UserX,
  UserMinus,
  PauseCircle,
  Trash2,
  LogOut,
  AlertTriangle,
  Check,
} from 'lucide-react';
import { useProfile } from '../ProfileContext';

export const AccountModals: React.FC = () => {
  const {
    profile,
    updateAccountSettings,
    unblockUser,
    unrestrictUser,
    deactivateAccount,
    deleteAccount,
    logout,
    showToast,

    isEmailModalOpen,
    setIsEmailModalOpen,
    isPhoneModalOpen,
    setIsPhoneModalOpen,
    isPasswordModalOpen,
    setIsPasswordModalOpen,
    isBlockedUsersModalOpen,
    setIsBlockedUsersModalOpen,
    isRestrictedUsersModalOpen,
    setIsRestrictedUsersModalOpen,
    isDeactivateModalOpen,
    setIsDeactivateModalOpen,
    isDeleteModalOpen,
    setIsDeleteModalOpen,
    isLogoutConfirmOpen,
    setIsLogoutConfirmOpen,
  } = useProfile();

  // Local Form States
  const [newEmail, setNewEmail] = useState(profile.settings.email);
  const [newPhone, setNewPhone] = useState(profile.settings.phone);
  const [otpCode, setOtpCode] = useState('');
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [deactivateReason, setDeactivateReason] = useState('Found a match on YoUnMe');
  const [deactivateDuration, setDeactivateDuration] = useState('1 month');
  const [deleteConfirmationText, setDeleteConfirmationText] = useState('');

  // 1. Email Submit
  const handleEmailSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newEmail.includes('@')) {
      showToast('Please enter a valid email address', 'error');
      return;
    }
    updateAccountSettings({ email: newEmail });
    setIsEmailModalOpen(false);
  };

  // 2. Phone Submit
  const handlePhoneSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newPhone.length < 8) {
      showToast('Please enter a valid phone number', 'error');
      return;
    }
    updateAccountSettings({ phone: newPhone });
    setIsPhoneModalOpen(false);
  };

  // 3. Password Submit
  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newPassword.length < 6) {
      showToast('Password must be at least 6 characters', 'error');
      return;
    }
    showToast('Password updated.', 'info');
    setIsPasswordModalOpen(false);
    setCurrentPassword('');
    setNewPassword('');
  };

  // 4. Deactivate Submit
  const handleDeactivateSubmit = () => {
    deactivateAccount(deactivateReason, deactivateDuration);
    setIsDeactivateModalOpen(false);
  };

  // 5. Delete Submit
  const handleDeleteSubmit = () => {
    if (deleteConfirmationText !== 'DELETE') {
      showToast('Please type "DELETE" to confirm account deletion', 'error');
      return;
    }
    deleteAccount();
    setIsDeleteModalOpen(false);
  };

  return (
    <>
      {/* 1. CHANGE EMAIL MODAL */}
      {isEmailModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsEmailModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Mail size={18} color="#00e5ff" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Update Email Address</h3>
              </div>
              <button onClick={() => setIsEmailModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <form onSubmit={handleEmailSubmit} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Enter your new email address. A confirmation email will be dispatched.
              </p>
              <input
                type="email"
                required
                value={newEmail}
                onChange={(e) => setNewEmail(e.target.value)}
                style={inputStyle}
              />
              <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
                <button type="button" onClick={() => setIsEmailModalOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
                <button type="submit" className="btn-primary" style={{ flex: 1, padding: '10px' }}>Save Email</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 2. CHANGE PHONE MODAL */}
      {isPhoneModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsPhoneModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Phone size={18} color="#00e676" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Update Mobile Number</h3>
              </div>
              <button onClick={() => setIsPhoneModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <form onSubmit={handlePhoneSubmit} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                Enter your new mobile number for SMS/WhatsApp verification.
              </p>
              <input
                type="tel"
                required
                value={newPhone}
                onChange={(e) => setNewPhone(e.target.value)}
                style={inputStyle}
              />
              <div>
                <label style={{ fontSize: '11px', color: 'var(--text-muted)', display: 'block', marginBottom: '4px' }}>
                  4-Digit OTP Code:
                </label>
                <input
                  type="text"
                  maxLength={4}
                  placeholder="1234"
                  value={otpCode}
                  onChange={(e) => setOtpCode(e.target.value)}
                  style={{ ...inputStyle, width: '120px', textAlign: 'center', letterSpacing: '4px' }}
                />
              </div>
              <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
                <button type="button" onClick={() => setIsPhoneModalOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
                <button type="submit" className="btn-primary" style={{ flex: 1, padding: '10px' }}>Verify & Save</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 3. CHANGE PASSWORD MODAL */}
      {isPasswordModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsPasswordModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <KeyRound size={18} color="#ffd700" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Change Password</h3>
              </div>
              <button onClick={() => setIsPasswordModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <form onSubmit={handlePasswordSubmit} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '4px' }}>Current Password</label>
                <input
                  type="password"
                  required
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  style={inputStyle}
                />
              </div>
              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '4px' }}>New Password (min 6 characters)</label>
                <input
                  type="password"
                  required
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  style={inputStyle}
                />
              </div>
              <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
                <button type="button" onClick={() => setIsPasswordModalOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
                <button type="submit" className="btn-primary" style={{ flex: 1, padding: '10px' }}>Update Password</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 4. BLOCKED USERS MODAL */}
      {isBlockedUsersModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsBlockedUsersModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <UserX size={18} color="#ff4757" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Blocked Users ({profile.privacy.blockedUsers.length})</h3>
              </div>
              <button onClick={() => setIsBlockedUsersModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '60vh', overflowY: 'auto' }}>
              {profile.privacy.blockedUsers.length === 0 ? (
                <div style={{ color: 'var(--text-muted)', textAlign: 'center', padding: '20px' }}>No blocked accounts.</div>
              ) : (
                profile.privacy.blockedUsers.map((u) => (
                  <div key={u.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 12px', borderRadius: 'var(--radius-sm)', background: 'rgba(255, 71, 87, 0.08)', border: '1px solid rgba(255, 71, 87, 0.2)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <img src={u.avatar} alt={u.name} style={{ width: '34px', height: '34px', borderRadius: '50%', objectFit: 'cover' }} />
                      <div>
                        <div style={{ fontSize: '13px', fontWeight: 700 }}>{u.name}</div>
                        <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>Blocked on {u.blockedAt}</div>
                      </div>
                    </div>
                    <button onClick={() => unblockUser(u.id)} className="btn-ghost" style={{ padding: '4px 10px', fontSize: '11px', color: '#00e676', borderColor: 'rgba(0, 230, 118, 0.3)' }}>
                      Unblock
                    </button>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* 5. RESTRICTED USERS MODAL */}
      {isRestrictedUsersModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsRestrictedUsersModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <UserMinus size={18} color="#ffa502" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Restricted Accounts</h3>
              </div>
              <button onClick={() => setIsRestrictedUsersModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '10px', maxHeight: '60vh', overflowY: 'auto' }}>
              {profile.privacy.restrictedUsers.length === 0 ? (
                <div style={{ color: 'var(--text-muted)', textAlign: 'center', padding: '20px' }}>No restricted accounts.</div>
              ) : (
                profile.privacy.restrictedUsers.map((u) => (
                  <div key={u.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 12px', borderRadius: 'var(--radius-sm)', background: 'rgba(255, 170, 0, 0.08)', border: '1px solid rgba(255, 170, 0, 0.2)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <img src={u.avatar} alt={u.name} style={{ width: '34px', height: '34px', borderRadius: '50%', objectFit: 'cover' }} />
                      <div>
                        <div style={{ fontSize: '13px', fontWeight: 700 }}>{u.name}</div>
                        <div style={{ fontSize: '10px', color: 'var(--text-secondary)' }}>Restricted on {u.restrictedAt}</div>
                      </div>
                    </div>
                    <button onClick={() => unrestrictUser(u.id)} className="btn-ghost" style={{ padding: '4px 10px', fontSize: '11px', color: '#ffd700', borderColor: 'rgba(255, 215, 0, 0.3)' }}>
                      Remove Restriction
                    </button>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* 6. DEACTIVATE ACCOUNT MODAL */}
      {isDeactivateModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsDeactivateModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <PauseCircle size={18} color="#ffa502" />
                <h3 style={{ fontSize: '17px', fontWeight: 800 }}>Deactivate Account</h3>
              </div>
              <button onClick={() => setIsDeactivateModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                Temporarily pause your dating presence. Your profile will be hidden from new discovery feeds, but your existing matches and chat history will be preserved.
              </p>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-primary)', display: 'block', marginBottom: '6px' }}>Reason for leaving:</label>
                <select
                  value={deactivateReason}
                  onChange={(e) => setDeactivateReason(e.target.value)}
                  style={inputStyle}
                >
                  <option value="Found a match on YoUnMe" style={{ background: 'var(--bg-surface)' }}>Found a match on YoUnMe</option>
                  <option value="Taking a mental health / digital break" style={{ background: 'var(--bg-surface)' }}>Taking a digital break</option>
                  <option value="Too busy with work/studies" style={{ background: 'var(--bg-surface)' }}>Too busy with work/studies</option>
                  <option value="Other" style={{ background: 'var(--bg-surface)' }}>Other</option>
                </select>
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 700, color: 'var(--text-primary)', display: 'block', marginBottom: '6px' }}>Pause duration:</label>
                <div style={{ display: 'flex', gap: '6px' }}>
                  {['1 week', '1 month', 'Until I log back in'].map((dur) => (
                    <button
                      type="button"
                      key={dur}
                      onClick={() => setDeactivateDuration(dur)}
                      style={{
                        flex: 1,
                        padding: '8px',
                        borderRadius: 'var(--radius-sm)',
                        border: deactivateDuration === dur ? '1px solid #ffa502' : '1px solid var(--border-glass)',
                        background: deactivateDuration === dur ? 'rgba(255, 165, 2, 0.2)' : 'var(--surface-soft)',
                        color: 'var(--text-primary)',
                        fontSize: '11.5px',
                        fontWeight: deactivateDuration === dur ? 700 : 500,
                        cursor: 'pointer',
                      }}
                    >
                      {dur}
                    </button>
                  ))}
                </div>
              </div>

              <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                <button onClick={() => setIsDeactivateModalOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
                <button onClick={handleDeactivateSubmit} className="btn-primary" style={{ flex: 1, padding: '10px', background: '#ffa502', color: '#000' }}>Confirm Deactivation</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 7. DELETE ACCOUNT MODAL */}
      {isDeleteModalOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsDeleteModalOpen(false)}>
          <div className="glass-panel" style={modalBoxStyle} onClick={(e) => e.stopPropagation()}>
            <div style={modalHeaderStyle}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Trash2 size={18} color="#ff4757" />
                <h3 style={{ fontSize: '17px', fontWeight: 800, color: '#ff4757' }}>Delete Account Permanently</h3>
              </div>
              <button onClick={() => setIsDeleteModalOpen(false)} style={iconBtnStyle}><X size={18} /></button>
            </div>
            <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div style={{ padding: '12px', background: 'rgba(255, 71, 87, 0.12)', border: '1px solid #ff4757', borderRadius: 'var(--radius-md)', fontSize: '12px', color: 'var(--text-primary)', lineHeight: 1.5 }}>
                ⚠️ <strong>Warning:</strong> Deleting your account is irreversible. All profile photos, mutual matches, chat messages, and YoUnMe coin balances will be permanently expunged.
              </div>

              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-secondary)', display: 'block', marginBottom: '6px' }}>
                  Type <strong>DELETE</strong> below to confirm:
                </label>
                <input
                  type="text"
                  placeholder="DELETE"
                  value={deleteConfirmationText}
                  onChange={(e) => setDeleteConfirmationText(e.target.value)}
                  style={{ ...inputStyle, borderColor: deleteConfirmationText === 'DELETE' ? '#ff4757' : 'var(--border-glass)' }}
                />
              </div>

              <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
                <button onClick={() => setIsDeleteModalOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
                <button onClick={handleDeleteSubmit} className="btn-primary" style={{ flex: 1, padding: '10px', background: '#ff4757' }}>Permanently Delete</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 8. LOGOUT CONFIRMATION MODAL */}
      {isLogoutConfirmOpen && (
        <div style={modalBackdropStyle} onClick={() => setIsLogoutConfirmOpen(false)}>
          <div className="glass-panel" style={{ ...modalBoxStyle, maxWidth: '400px', textAlign: 'center', padding: '24px' }} onClick={(e) => e.stopPropagation()}>
            <LogOut size={38} color="#ff4757" style={{ margin: '0 auto 12px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: 800, marginBottom: '8px' }}>Log Out of YoUnMe?</h3>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
              Are you sure you want to end your current session? You can sign back in at any time.
            </p>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button onClick={() => setIsLogoutConfirmOpen(false)} className="btn-ghost" style={{ flex: 1, padding: '10px' }}>Cancel</button>
              <button onClick={() => { logout(); setIsLogoutConfirmOpen(false); }} className="btn-primary" style={{ flex: 1, padding: '10px', background: '#ff4757' }}>Log Out</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export const modalBackdropStyle: React.CSSProperties = {
  position: 'fixed',
  inset: 0,
  zIndex: 99999,
  background: 'rgba(5, 6, 12, 0.85)',
  backdropFilter: 'blur(20px)',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  padding: '16px',
};

export const modalBoxStyle: React.CSSProperties = {
  width: '100%',
  maxWidth: '480px',
  borderRadius: 'var(--radius-lg)',
  overflow: 'hidden',
  border: '1px solid var(--border-glass)',
  display: 'flex',
  flexDirection: 'column',
};

export const modalHeaderStyle: React.CSSProperties = {
  padding: '16px 20px',
  background: 'var(--bg-surface)',
  borderBottom: '1px solid var(--border-glass)',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
};

export const inputStyle: React.CSSProperties = {
  width: '100%',
  padding: '10px 12px',
  borderRadius: 'var(--radius-sm)',
  background: 'var(--bg-glass)',
  border: '1px solid var(--border-glass)',
  color: 'var(--text-primary)',
  fontSize: '13px',
  outline: 'none',
};

export const iconBtnStyle: React.CSSProperties = {
  background: 'transparent',
  border: 'none',
  color: 'var(--text-secondary)',
  cursor: 'pointer',
};
