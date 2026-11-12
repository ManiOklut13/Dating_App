import React, { useState } from 'react';
import {
  ChevronLeft,
  Mail,
  Lock,
  Eye,
  EyeOff,
  AlertCircle,
  ArrowRight,
  Smartphone,
  CheckCircle2,
  KeyRound,
  ShieldCheck,
} from 'lucide-react';
import confetti from 'canvas-confetti';

export interface LoginPayload {
  identifier: string;
  password?: string;
  otp?: string;
  remember: boolean;
  method?: 'password' | 'otp' | 'google' | 'apple';
}

interface SignInPageProps {
  onBack: () => void;
  onLogin: (payload: LoginPayload) => void;
  onGoToSignUp: () => void;
}

export const SignInPage: React.FC<SignInPageProps> = ({
  onBack,
  onLogin,
  onGoToSignUp,
}) => {
  // Standard Login State
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // 3-Step Forgot Password State (0 = Default Login, 1 = Identifier, 2 = OTP, 3 = Reset Password)
  const [recoveryStep, setRecoveryStep] = useState<0 | 1 | 2 | 3>(0);
  const [recoveryIdentifier, setRecoveryIdentifier] = useState('');
  const [recoveryOtp, setRecoveryOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [recoverySuccess, setRecoverySuccess] = useState('');
  const [otpResendCountdown, setOtpResendCountdown] = useState(45);

  // Standard Login Submit
  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');

    if (!identifier.trim()) {
      setErrorMessage('Please enter your Email or Phone Number.');
      return;
    }

    if (password.length < 6) {
      setErrorMessage('Password must be at least 6 characters.');
      return;
    }

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      onLogin({
        identifier: identifier.trim(),
        password,
        remember,
        method: 'password',
      });
    }, 600);
  };

  // Step 1: Submit Identifier for Password Reset
  const handleRecoveryStep1Submit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');
    if (!recoveryIdentifier.trim()) {
      setErrorMessage('Please enter your registered Email or Phone Number.');
      return;
    }

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      setRecoveryStep(2);
      setOtpResendCountdown(45);
    }, 500);
  };

  // Step 2: Validate OTP Code
  const handleRecoveryStep2Submit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');
    if (recoveryOtp.trim().length < 4) {
      setErrorMessage('Please enter the 6-digit verification code.');
      return;
    }

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      setRecoveryStep(3);
    }, 500);
  };

  // Step 3: Create New Password & Complete Reset
  const handleRecoveryStep3Submit = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');

    if (newPassword.length < 6) {
      setErrorMessage('New password must be at least 6 characters.');
      return;
    }
    if (newPassword !== confirmPassword) {
      setErrorMessage('Passwords do not match. Please verify both fields.');
      return;
    }

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      setRecoverySuccess('Password reset successfully! Logging you in...');
      try {
        confetti({
          particleCount: 50,
          spread: 60,
          origin: { y: 0.6 },
          colors: ['#22c55e', '#ff8da1', '#ffd700'],
        });
      } catch {}

      setTimeout(() => {
        onLogin({
          identifier: recoveryIdentifier.trim() || identifier.trim() || 'user@younme.love',
          password: newPassword,
          remember: true,
          method: 'password',
        });
      }, 1000);
    }, 700);
  };

  const handleSocialLogin = (provider: 'google' | 'apple') => {
    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      onLogin({
        identifier: provider === 'google' ? 'aarav.google@younme.love' : 'aarav.apple@younme.love',
        remember: true,
        method: provider,
      });
    }, 500);
  };

  return (
    <div
      style={{
        position: 'relative',
        minHeight: '100%',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: '24px 20px 20px',
        background: 'radial-gradient(circle at 50% 12%, #380d25 0%, #200816 50%, #14040e 100%)',
        color: '#FFFFFF',
        boxSizing: 'border-box',
        overflowY: 'auto',
      }}
    >
      {/* Background ambient glow blobs */}
      <div
        style={{
          position: 'absolute',
          top: '-40px',
          right: '-40px',
          width: '200px',
          height: '200px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(255, 141, 161, 0.18) 0%, transparent 70%)',
          pointerEvents: 'none',
          filter: 'blur(35px)',
          zIndex: 0,
        }}
      />

      <div style={{ position: 'relative', zIndex: 2 }}>
        {/* Top App Bar with Back Button */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
          <button
            type="button"
            onClick={() => {
              if (recoveryStep > 0) {
                setRecoveryStep(0);
                setErrorMessage('');
              } else {
                onBack();
              }
            }}
            style={{
              background: 'rgba(255, 141, 161, 0.12)',
              border: '1px solid rgba(255, 141, 161, 0.25)',
              borderRadius: '12px',
              width: '38px',
              height: '38px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#ff8da1',
              cursor: 'pointer',
              transition: 'all 0.18s ease',
            }}
          >
            <ChevronLeft size={20} />
          </button>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              fontSize: '11.5px',
              fontWeight: 700,
              color: '#ff8da1',
              letterSpacing: '0.8px',
              textTransform: 'uppercase',
            }}
          >
            <img
              src="/younme-logo.png"
              alt="YoUnMe App Icon"
              style={{ width: '18px', height: '18px', borderRadius: '5px', objectFit: 'cover' }}
            />
            <span>{recoveryStep > 0 ? 'Account Recovery' : 'YoUnMe Sign In'}</span>
          </div>

          <div style={{ width: '38px' }} />
        </div>

        {/* Global Error Banner */}
        {errorMessage && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '12px 14px',
              borderRadius: '14px',
              background: 'rgba(255, 77, 136, 0.18)',
              border: '1px solid rgba(255, 77, 136, 0.45)',
              color: '#ffd6df',
              fontSize: '12.5px',
              fontWeight: 600,
              marginBottom: '16px',
            }}
          >
            <AlertCircle size={16} color="#ff8da1" style={{ flexShrink: 0 }} />
            <span>{errorMessage}</span>
          </div>
        )}

        {/* Global Success Banner */}
        {recoverySuccess && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '12px 14px',
              borderRadius: '14px',
              background: 'rgba(34, 197, 94, 0.18)',
              border: '1px solid rgba(34, 197, 94, 0.45)',
              color: '#4ade80',
              fontSize: '12.5px',
              fontWeight: 600,
              marginBottom: '16px',
            }}
          >
            <CheckCircle2 size={16} color="#4ade80" style={{ flexShrink: 0 }} />
            <span>{recoverySuccess}</span>
          </div>
        )}

        {/* =================================================================== */}
        {/* VIEW 0: STANDARD CREDENTIAL LOGIN (NO DIRECT OTP ON DEFAULT SCREEN) */}
        {/* =================================================================== */}
        {recoveryStep === 0 && (
          <>
            <div style={{ marginBottom: '22px' }}>
              <h1 style={{ fontSize: '26px', fontWeight: 900, margin: '0 0 6px', letterSpacing: '-0.5px', color: '#FFFFFF' }}>
                Welcome Back 👋
              </h1>
              <p style={{ fontSize: '13px', color: '#e2c0ce', margin: 0, lineHeight: 1.45 }}>
                Sign in with your credentials to check admirer stack & live calls.
              </p>
            </div>

            <form onSubmit={handleLoginSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {/* Field 1: Email or Phone Number */}
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <Mail size={13} color="#ff8da1" />
                    Email or Phone Number
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type="text"
                    value={identifier}
                    onChange={(e) => {
                      setIdentifier(e.target.value);
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="name@example.com or +91 9876543210"
                    className="form-field-input"
                    required
                  />
                </div>
              </div>

              {/* Field 2: Password */}
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <Lock size={13} color="#ff8da1" />
                    Password
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="Enter your password"
                    className="form-field-input"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    style={{ background: 'transparent', border: 'none', color: '#ff8da1', cursor: 'pointer', padding: '4px' }}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>

                {/* Compact "Forgot Password?" text link aligned below password input field */}
                <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '6px' }}>
                  <button
                    type="button"
                    onClick={() => {
                      setRecoveryStep(1);
                      setRecoveryIdentifier(identifier);
                      setErrorMessage('');
                    }}
                    style={{
                      background: 'transparent',
                      border: 'none',
                      color: '#ff8da1',
                      fontSize: '11.5px',
                      fontWeight: 700,
                      cursor: 'pointer',
                      padding: '2px 0',
                    }}
                  >
                    Forgot Password?
                  </button>
                </div>
              </div>

              {/* Remember Me Checkbox */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', margin: '2px 0' }}>
                <input
                  type="checkbox"
                  id="remember-device"
                  checked={remember}
                  onChange={(e) => setRemember(e.target.checked)}
                  style={{ width: '16px', height: '16px', accentColor: '#ff4d88', cursor: 'pointer' }}
                />
                <label htmlFor="remember-device" style={{ fontSize: '12px', color: '#ffd6df', cursor: 'pointer' }}>
                  Remember me on this device
                </label>
              </div>

              {/* Primary Submit CTA */}
              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-rose-primary"
                style={{
                  width: '100%',
                  height: '52px',
                  minHeight: '52px',
                  padding: '0 24px',
                  fontSize: '15.5px',
                  fontWeight: 700,
                  letterSpacing: '0.3px',
                  borderRadius: '999px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  marginTop: '8px',
                  boxSizing: 'border-box',
                }}
              >
                {isSubmitting ? (
                  <span>Authenticating...</span>
                ) : (
                  <>
                    <span>Sign in to YoUnMe</span>
                    <ArrowRight size={17} />
                  </>
                )}
              </button>
            </form>

            {/* Social Logins */}
            <div style={{ margin: '24px 0 16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '14px' }}>
                <div style={{ flex: 1, height: '1px', background: 'rgba(255, 255, 255, 0.1)' }} />
                <span style={{ fontSize: '11px', color: '#a68294', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  Or continue with
                </span>
                <div style={{ flex: 1, height: '1px', background: 'rgba(255, 255, 255, 0.1)' }} />
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <button
                  type="button"
                  onClick={() => handleSocialLogin('google')}
                  style={{
                    flex: 1,
                    padding: '11px 0',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.06)',
                    border: '1px solid rgba(255, 255, 255, 0.12)',
                    color: '#ffffff',
                    fontSize: '12.5px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                  }}
                >
                  <span style={{ color: '#ea4335', fontWeight: 900 }}>G</span>
                  <span>Google</span>
                </button>

                <button
                  type="button"
                  onClick={() => handleSocialLogin('apple')}
                  style={{
                    flex: 1,
                    padding: '11px 0',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.06)',
                    border: '1px solid rgba(255, 255, 255, 0.12)',
                    color: '#ffffff',
                    fontSize: '12.5px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '8px',
                  }}
                >
                  <span></span>
                  <span>Apple</span>
                </button>
              </div>
            </div>
          </>
        )}

        {/* =================================================================== */}
        {/* RECOVERY STEP 1: IDENTIFIER (EMAIL / PHONE NUMBER) */}
        {/* =================================================================== */}
        {recoveryStep === 1 && (
          <div>
            <div style={{ marginBottom: '22px' }}>
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, rgba(255, 141, 161, 0.25), rgba(255, 77, 136, 0.15))',
                  border: '1px solid rgba(255, 141, 161, 0.4)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: '12px',
                }}
              >
                <KeyRound size={22} color="#ff8da1" />
              </div>
              <h1 style={{ fontSize: '24px', fontWeight: 900, margin: '0 0 6px', color: '#FFFFFF' }}>
                Forgot Password? 🔒
              </h1>
              <p style={{ fontSize: '12.5px', color: '#e2c0ce', margin: 0, lineHeight: 1.45 }}>
                Enter your registered Email or Phone Number and we'll send you a verification code to reset your password.
              </p>
            </div>

            <form onSubmit={handleRecoveryStep1Submit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <Mail size={13} color="#ff8da1" />
                    Registered Email or Phone
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type="text"
                    value={recoveryIdentifier}
                    onChange={(e) => {
                      setRecoveryIdentifier(e.target.value);
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="name@example.com or +91 9876543210"
                    className="form-field-input"
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-rose-primary"
                style={{
                  width: '100%',
                  height: '50px',
                  borderRadius: '999px',
                  fontSize: '15px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  marginTop: '10px',
                }}
              >
                {isSubmitting ? <span>Sending Code...</span> : <span>Send Verification Code</span>}
              </button>
            </form>
          </div>
        )}

        {/* =================================================================== */}
        {/* RECOVERY STEP 2: OTP VERIFICATION */}
        {/* =================================================================== */}
        {recoveryStep === 2 && (
          <div>
            <div style={{ marginBottom: '22px' }}>
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, rgba(56, 189, 248, 0.25), rgba(2, 132, 199, 0.15))',
                  border: '1px solid rgba(56, 189, 248, 0.4)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: '12px',
                }}
              >
                <Smartphone size={22} color="#38bdf8" />
              </div>
              <h1 style={{ fontSize: '24px', fontWeight: 900, margin: '0 0 6px', color: '#FFFFFF' }}>
                Verify Code 📩
              </h1>
              <p style={{ fontSize: '12.5px', color: '#e2c0ce', margin: 0, lineHeight: 1.45 }}>
                Enter the 6-digit verification code sent to <strong style={{ color: '#ff8da1' }}>{recoveryIdentifier}</strong>.
              </p>
            </div>

            <form onSubmit={handleRecoveryStep2Submit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <ShieldCheck size={13} color="#38bdf8" />
                    6-Digit Verification Code
                  </span>
                  <span style={{ fontSize: '11px', color: '#94a3b8' }}>
                    Resend in {otpResendCountdown}s
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type="text"
                    maxLength={6}
                    value={recoveryOtp}
                    onChange={(e) => {
                      setRecoveryOtp(e.target.value.replace(/\D/g, ''));
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="123456"
                    className="form-field-input"
                    style={{ fontSize: '18px', fontWeight: 800, letterSpacing: '6px', textAlign: 'center' }}
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-rose-primary"
                style={{
                  width: '100%',
                  height: '50px',
                  borderRadius: '999px',
                  fontSize: '15px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  marginTop: '10px',
                }}
              >
                {isSubmitting ? <span>Validating...</span> : <span>Verify & Continue</span>}
              </button>
            </form>
          </div>
        )}

        {/* =================================================================== */}
        {/* RECOVERY STEP 3: CREATE NEW PASSWORD */}
        {/* =================================================================== */}
        {recoveryStep === 3 && (
          <div>
            <div style={{ marginBottom: '22px' }}>
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, rgba(34, 197, 94, 0.25), rgba(22, 163, 74, 0.15))',
                  border: '1px solid rgba(34, 197, 94, 0.4)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: '12px',
                }}
              >
                <Lock size={22} color="#4ade80" />
              </div>
              <h1 style={{ fontSize: '24px', fontWeight: 900, margin: '0 0 6px', color: '#FFFFFF' }}>
                Create New Password 🔑
              </h1>
              <p style={{ fontSize: '12.5px', color: '#e2c0ce', margin: 0, lineHeight: 1.45 }}>
                Enter your new password below. Make sure it is at least 6 characters.
              </p>
            </div>

            <form onSubmit={handleRecoveryStep3Submit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {/* New Password */}
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <Lock size={13} color="#ff8da1" />
                    New Password
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => {
                      setNewPassword(e.target.value);
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="Enter at least 6 characters"
                    className="form-field-input"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                    style={{ background: 'transparent', border: 'none', color: '#ff8da1', cursor: 'pointer', padding: '4px' }}
                  >
                    {showNewPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              {/* Confirm Password */}
              <div className="form-field-group">
                <label className="form-field-label">
                  <span className="form-field-label-text">
                    <ShieldCheck size={13} color="#ff8da1" />
                    Confirm Password
                  </span>
                </label>
                <div className="form-field-input-wrap">
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => {
                      setConfirmPassword(e.target.value);
                      if (errorMessage) setErrorMessage('');
                    }}
                    placeholder="Re-enter your new password"
                    className="form-field-input"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    style={{ background: 'transparent', border: 'none', color: '#ff8da1', cursor: 'pointer', padding: '4px' }}
                  >
                    {showConfirmPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-rose-primary"
                style={{
                  width: '100%',
                  height: '50px',
                  borderRadius: '999px',
                  fontSize: '15px',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  marginTop: '10px',
                }}
              >
                {isSubmitting ? <span>Updating Password...</span> : <span>Reset Password & Sign In</span>}
              </button>
            </form>
          </div>
        )}
      </div>

      {/* Footer Navigation Link */}
      <div style={{ textAlign: 'center', marginTop: '16px', position: 'relative', zIndex: 2 }}>
        <p style={{ fontSize: '13px', color: '#e2c0ce', margin: 0 }}>
          Don't have an account?{' '}
          <button
            type="button"
            onClick={onGoToSignUp}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#ff8da1',
              fontWeight: 800,
              cursor: 'pointer',
              padding: '4px',
            }}
          >
            Create Account
          </button>
        </p>
      </div>
    </div>
  );
};
