import React, { useEffect, useMemo, useState } from 'react';
import { ArrowRight, Check, Flame, Mail, Phone, AlertTriangle, Loader2, RotateCcw } from 'lucide-react';
import { useOnboarding } from './OnboardingContext';
import { Screen, TextField, PasswordField, ChoiceCard, OtpInput, DemoBadge, Modal, Notice, SegmentedControl } from './ui';
import { COUNTRY_CODES, DEMO_MESSAGE_SUGGESTIONS } from './mockData';
import {
  MOCK_CREDENTIALS,
  MOCK_OTP,
  OTP_RESEND_SECONDS,
  SignupMethod,
} from './types';
import {
  isEmail,
  isPhone,
  maskEmail,
  maskPhone,
  passwordChecks,
  passwordLabel,
  passwordScore,
} from './validation';

const LEGAL_CONTENT: Record<'terms' | 'privacy', { title: string; body: string[] }> = {
  terms: {
    title: 'Terms of Service',
    body: [
      'Welcome to YoUnMe. By creating an account you agree to use the app respectfully and lawfully.',
      'You must be 18 years or older. Your account is personal and cannot be transferred.',
      'Coins and rewards are digital credits with no cash value and are non-refundable.',
      'We may restrict or remove accounts that breach these terms or the Community Guidelines.',
      'This is sample copy for a frontend demonstration and is not a real legal document.',
    ],
  },
  privacy: {
    title: 'Privacy Policy',
    body: [
      'We collect the profile details you add, approximate location for discovery, and basic device information.',
      'Your precise location is never shown to other members — only an approximate distance.',
      'Contact details stay masked by Trust Guard and are never sold to advertisers.',
      'You can download or delete your data at any time from Account → Delete Account.',
      'This is sample copy for a frontend demonstration.',
    ],
  },
};

const LegalLinks: React.FC<{ onOpen: (key: 'terms' | 'privacy') => void }> = ({ onOpen }) => (
  <div style={{ display: 'flex', gap: '14px', justifyContent: 'center', flexWrap: 'wrap', marginTop: '18px' }}>
    <button type="button" className="ob-link muted" onClick={() => onOpen('terms')}>
      Terms of Service
    </button>
    <span style={{ color: 'var(--text-muted)' }}>·</span>
    <button type="button" className="ob-link muted" onClick={() => onOpen('privacy')}>
      Privacy Policy
    </button>
  </div>
);

const StrengthMeter: React.FC<{ password: string }> = ({ password }) => {
  const score = passwordScore(password);
  return (
    <div>
      <div className={`ob-strength s${score}`} aria-hidden="true">
        <span />
        <span />
        <span />
        <span />
      </div>
      <div className="ob-hint" style={{ display: 'flex', justifyContent: 'space-between', gap: '8px' }}>
        <span>Password strength: <strong>{passwordLabel(score)}</strong></span>
      </div>
      <ul style={{ listStyle: 'none', display: 'grid', gap: '4px', marginTop: '8px' }}>
        {passwordChecks(password).map((check) => (
          <li
            key={check.id}
            style={{
              fontSize: '11.5px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              color: check.ok ? '#00e676' : 'var(--text-muted)',
            }}
          >
            <Check size={12} strokeWidth={3} style={{ opacity: check.ok ? 1 : 0.25 }} />
            {check.label}
          </li>
        ))}
      </ul>
    </div>
  );
};

/* ==========================================================================
   Screen 1 — Splash / Welcome
   ========================================================================== */

export const WelcomeScreen: React.FC = () => {
  const { go } = useOnboarding();
  const [legal, setLegal] = useState<'terms' | 'privacy' | null>(null);

  return (
    <Screen
      bare
      footer={
        <>
          <button
            type="button"
            className="btn-primary ob-btn block"
            onClick={() => go('signup')}
          >
            Create New Account
            <ArrowRight size={17} />
          </button>
          <button type="button" className="btn-ghost ob-btn block" onClick={() => go('login')}>
            Sign In
          </button>
        </>
      }
    >
      <div className="ob-hero" style={{ marginTop: '26px' }}>
        <div className="ob-logo">
          <Flame size={34} color="#ffffff" />
        </div>
        <h1 className="ob-title" style={{ position: 'relative', zIndex: 1 }}>
          YoUnMe
        </h1>
        <p className="ob-desc" style={{ position: 'relative', zIndex: 1, maxWidth: '380px', margin: '10px auto 0' }}>
          Meaningful connections, lasting friendship and safe conversations — verified people, kinder chats.
        </p>
        <div style={{ position: 'relative', zIndex: 1, display: 'flex', gap: '8px', justifyContent: 'center', flexWrap: 'wrap', marginTop: '16px' }}>
          {['💬 Secure chat', '✅ Verified profiles', '📍 Discover nearby'].map((badge) => (
            <span key={badge} className="badge-vibe" style={{ fontSize: '11px' }}>
              {badge}
            </span>
          ))}
        </div>
      </div>

      <p className="ob-hint" style={{ textAlign: 'center', marginTop: '18px' }}>
        Join in under two minutes — your details stay on this device in this demo build.
      </p>

      <LegalLinks onOpen={setLegal} />

      <Modal open={legal !== null} onClose={() => setLegal(null)} title={legal ? LEGAL_CONTENT[legal].title : ''}>
        {legal &&
          LEGAL_CONTENT[legal].body.map((paragraph) => (
            <p
              key={paragraph}
              style={{ fontSize: '13px', lineHeight: 1.65, color: 'var(--text-secondary)', marginBottom: '12px' }}
            >
              {paragraph}
            </p>
          ))}
        <div style={{ marginTop: '4px' }}>
          <DemoBadge>Sample content</DemoBadge>
        </div>
      </Modal>
    </Screen>
  );
};

/* ==========================================================================
   Screen 2 — Create Account
   ========================================================================== */

interface SignUpErrors {
  email?: string;
  phone?: string;
  password?: string;
  confirm?: string;
  terms?: string;
}

export const SignUpScreen: React.FC = () => {
  const { state, patch, go, showToast } = useOnboarding();
  const [errors, setErrors] = useState<SignUpErrors>({});
  const [googleOpen, setGoogleOpen] = useState(false);
  const [legal, setLegal] = useState<'terms' | 'privacy' | null>(null);

  const method: SignupMethod = state.method;

  const validate = (): SignUpErrors => {
    const next: SignUpErrors = {};
    if (method === 'email') {
      if (!state.email.trim()) next.email = 'Email address is required.';
      else if (!isEmail(state.email)) next.email = 'Enter a valid email address, e.g. you@example.com.';
    }
    if (method === 'mobile') {
      if (!state.phone.trim()) next.phone = 'Mobile number is required.';
      else if (!isPhone(state.phone)) next.phone = 'Enter a valid mobile number (7–15 digits).';
    }
    if (!state.password) next.password = 'Password is required.';
    else if (passwordScore(state.password) < 2) next.password = 'Password is too weak — follow the requirements below.';
    if (state.confirmPassword !== state.password) next.confirm = 'Passwords do not match.';
    if (!state.acceptedTerms) next.terms = 'Please accept the Terms and Privacy Policy to continue.';
    return next;
  };

  const submit = () => {
    const found = validate();
    setErrors(found);
    if (Object.keys(found).length > 0) {
      showToast('Please fix the highlighted fields.', 'error');
      return;
    }
    if (method === 'email') {
      patch({ destinationType: 'email', destination: state.email.trim() });
    } else if (method === 'mobile') {
      patch({ destinationType: 'mobile', destination: `${state.countryCode} ${state.phone}` });
    } else {
      patch({ destinationType: 'email', destination: state.email.trim() });
    }
    go('verify');
  };

  const pickMethod = (next: SignupMethod) => {
    patch({ method: next });
    setErrors({});
    if (next === 'google') setGoogleOpen(true);
  };

  const chooseGoogleAccount = (email: string) => {
    patch({
      method: 'google',
      email,
      destinationType: 'email',
      destination: email,
      acceptedTerms: true,
    });
    setGoogleOpen(false);
    showToast('Google account linked (simulated).', 'success');
    go('verify');
  };

  return (
    <Screen
      title="Create Your Account"
      description="Pick how you'd like to sign up. Everything in this flow is simulated on-device."
      footer={
        <>
          <button type="button" className="btn-primary ob-btn block" onClick={submit}>
            Continue
            <ArrowRight size={17} />
          </button>
          <div style={{ textAlign: 'center', marginTop: '4px' }}>
            <span style={{ fontSize: '12.5px', color: 'var(--text-secondary)' }}>
              Already have an account?{' '}
            </span>
            <button type="button" className="ob-link" onClick={() => go('login')}>
              Sign In
            </button>
          </div>
        </>
      }
    >
      <div className="ob-grid" style={{ marginTop: '18px' }} role="radiogroup" aria-label="Sign up method">
        <ChoiceCard
          multi={false}
          selected={method === 'email'}
          onClick={() => pickMethod('email')}
          title="Email"
          hint="Sign up with your email address"
          icon={<Mail size={16} color="#00e5ff" />}
        />
        <ChoiceCard
          multi={false}
          selected={method === 'mobile'}
          onClick={() => pickMethod('mobile')}
          title="Mobile"
          hint="Sign up with your phone number"
          icon={<Phone size={16} color="#00e676" />}
        />
        <ChoiceCard
          multi={false}
          selected={method === 'google'}
          onClick={() => pickMethod('google')}
          title="Google"
          hint="Simulated Google continuation"
          icon={<span style={{ fontWeight: 800, color: '#ff2d55' }}>G</span>}
        />
      </div>

      {method === 'email' && (
        <div style={{ marginTop: '18px' }}>
          <TextField
            label="Email address"
            value={state.email}
            onChange={(value) => patch({ email: value })}
            type="email"
            inputMode="email"
            autoComplete="email"
            placeholder="you@example.com"
            error={errors.email}
            required
          />
          <PasswordField
            label="Password"
            value={state.password}
            onChange={(value) => patch({ password: value })}
            error={errors.password}
            autoComplete="new-password"
            required
          />
          {state.password && <StrengthMeter password={state.password} />}
          <PasswordField
            label="Confirm password"
            value={state.confirmPassword}
            onChange={(value) => patch({ confirmPassword: value })}
            error={errors.confirm}
            autoComplete="new-password"
            required
          />
        </div>
      )}

      {method === 'mobile' && (
        <div style={{ marginTop: '18px' }}>
          <div className="ob-row">
            <div style={{ flex: '0 0 120px' }}>
              <label className="ob-label" htmlFor="country-code">
                Country code
              </label>
              <select
                id="country-code"
                className="ob-select"
                value={state.countryCode}
                onChange={(e) => patch({ countryCode: e.target.value })}
              >
                {COUNTRY_CODES.map((entry) => (
                  <option key={entry.code} value={entry.code}>
                    {entry.label}
                  </option>
                ))}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <TextField
                label="Mobile number"
                value={state.phone}
                onChange={(value) => patch({ phone: value.replace(/\D/g, '') })}
                type="tel"
                inputMode="numeric"
                autoComplete="tel-national"
                placeholder="98765 43210"
                error={errors.phone}
                maxLength={15}
                required
              />
            </div>
          </div>
          <PasswordField
            label="Password"
            value={state.password}
            onChange={(value) => patch({ password: value })}
            error={errors.password}
            autoComplete="new-password"
            required
          />
          {state.password && <StrengthMeter password={state.password} />}
          <PasswordField
            label="Confirm password"
            value={state.confirmPassword}
            onChange={(value) => patch({ confirmPassword: value })}
            error={errors.confirm}
            autoComplete="new-password"
            required
          />
        </div>
      )}

      <div style={{ marginTop: '6px' }}>
        <button
          type="button"
          className="ob-choice"
          role="checkbox"
          aria-checked={state.acceptedTerms}
          onClick={() => patch({ acceptedTerms: !state.acceptedTerms })}
          style={{ marginTop: '4px' }}
        >
          <span className="ob-choice-mark" aria-hidden="true">
            <Check size={13} strokeWidth={3} style={{ opacity: state.acceptedTerms ? 1 : 0 }} />
          </span>
          <span style={{ fontSize: '12.5px', color: 'var(--text-secondary)', lineHeight: 1.55 }}>
            I agree to the{' '}
            <span
              role="button"
              tabIndex={0}
              className="ob-link"
              onClick={(e) => {
                e.stopPropagation();
                setLegal('terms');
              }}
              onKeyDown={(e) => e.key === 'Enter' && setLegal('terms')}
              style={{ padding: 0 }}
            >
              Terms
            </span>{' '}
            and{' '}
            <span
              role="button"
              tabIndex={0}
              className="ob-link"
              onClick={(e) => {
                e.stopPropagation();
                setLegal('privacy');
              }}
              onKeyDown={(e) => e.key === 'Enter' && setLegal('privacy')}
              style={{ padding: 0 }}
            >
              Privacy Policy
            </span>
            .
          </span>
        </button>
        {errors.terms && (
          <div className="ob-error" role="alert">
            <AlertTriangle size={13} />
            {errors.terms}
          </div>
        )}
      </div>

      <div style={{ marginTop: '14px' }}>
        <DemoBadge>Simulated signup · no data leaves this device</DemoBadge>
      </div>

      {/* Mock Google account chooser */}
      <Modal open={googleOpen} onClose={() => setGoogleOpen(false)} title="Choose an account">
        <p className="ob-hint" style={{ marginTop: 0 }}>
          Continue to YoUnMe with one of these simulated Google accounts.
        </p>
        <div style={{ display: 'grid', gap: '8px', marginTop: '12px' }}>
          {[
            { name: 'Alex Demo', email: 'alex.demo@gmail.com' },
            { name: 'Sam Sample', email: 'sam.sample@gmail.com' },
          ].map((account) => (
            <button
              key={account.email}
              type="button"
              className="ob-choice"
              onClick={() => chooseGoogleAccount(account.email)}
            >
              <span
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: '50%',
                  background: 'var(--gradient-flame)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: 800,
                  color: '#fff',
                  flexShrink: 0,
                }}
              >
                {account.name[0]}
              </span>
              <span>
                <span className="ob-choice-title">{account.name}</span>
                <span className="ob-choice-hint" style={{ display: 'block' }}>{account.email}</span>
              </span>
            </button>
          ))}
        </div>
        <div style={{ marginTop: '14px' }}>
          <DemoBadge>Mock Google picker · no OAuth</DemoBadge>
        </div>
      </Modal>

      <Modal open={legal !== null} onClose={() => setLegal(null)} title={legal ? LEGAL_CONTENT[legal].title : ''}>
        {legal &&
          LEGAL_CONTENT[legal].body.map((paragraph) => (
            <p
              key={paragraph}
              style={{ fontSize: '13px', lineHeight: 1.65, color: 'var(--text-secondary)', marginBottom: '12px' }}
            >
              {paragraph}
            </p>
          ))}
      </Modal>
    </Screen>
  );
};

/* ==========================================================================
   Screen 3 — OTP verification
   ========================================================================== */

export const VerifyScreen: React.FC = () => {
  const { state, go, showToast, back } = useOnboarding();
  const [otp, setOtp] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [status, setStatus] = useState<'idle' | 'checking' | 'success'>('idle');
  const [countdown, setCountdown] = useState(OTP_RESEND_SECONDS);

  useEffect(() => {
    if (countdown <= 0) return;
    const timer = window.setTimeout(() => setCountdown((c) => c - 1), 1000);
    return () => window.clearTimeout(timer);
  }, [countdown]);

  const destinationLabel = useMemo(
    () =>
      state.destinationType === 'email'
        ? maskEmail(state.destination)
        : maskPhone(state.countryCode, state.destination.replace(state.countryCode, '').trim() || state.destination),
    [state],
  );

  const verify = () => {
    if (otp.replace(/\D/g, '').length < 6) {
      setError('Enter all six digits of the code.');
      return;
    }
    setStatus('checking');
    setError(null);
    window.setTimeout(() => {
      if (otp === MOCK_OTP) {
        setStatus('success');
        showToast('Account verified!', 'success');
        window.setTimeout(() => go('/onboarding/basic-profile'), 650);
      } else {
        setStatus('idle');
        setError('That code is not correct. Check the demo code above and try again.');
      }
    }, 900);
  };

  if (status === 'success') {
    return (
      <Screen>
        <div style={{ textAlign: 'center', padding: '60px 0' }}>
          <div className="ob-check">
            <Check size={44} color="#fff" strokeWidth={3} />
          </div>
          <h1 className="ob-title">Verified!</h1>
          <p className="ob-desc">Taking you to your profile setup…</p>
        </div>
      </Screen>
    );
  }

  return (
    <Screen
      title="Verify Your Account"
      description={`We sent a six digit code to ${destinationLabel}. Enter it below to continue.`}
      footer={
        <>
          <button
            type="button"
            className="btn-primary ob-btn block"
            onClick={verify}
            disabled={status === 'checking'}
          >
            {status === 'checking' ? (
              <>
                <Loader2 size={17} className="radar-spinner" /> Verifying…
              </>
            ) : (
              <>
                Verify & Continue <ArrowRight size={17} />
              </>
            )}
          </button>
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: '10px', marginTop: '4px' }}>
            <button
              type="button"
              className="ob-link"
              onClick={() => {
                back();
                showToast('You can edit your details on the previous screen.', 'info');
              }}
            >
              Change {state.destinationType === 'email' ? 'email' : 'phone'}
            </button>
            <button
              type="button"
              className="ob-link"
              disabled={countdown > 0}
              style={countdown > 0 ? { opacity: 0.55, cursor: 'not-allowed' } : undefined}
              onClick={() => {
                setCountdown(OTP_RESEND_SECONDS);
                showToast('New code sent (simulated).', 'info');
              }}
            >
              {countdown > 0 ? (
                <span style={{ display: 'inline-flex', gap: '5px', alignItems: 'center' }}>
                  <RotateCcw size={13} /> Resend in {countdown}s
                </span>
              ) : (
                'Resend code'
              )}
            </button>
          </div>
        </>
      }
    >
      <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', margin: '18px 0 16px' }}>
        <DemoBadge>
          Demo code: {MOCK_OTP}
        </DemoBadge>
        <span className="ob-demo" style={{ background: 'rgba(255, 170, 0, 0.12)', borderColor: 'rgba(255, 170, 0, 0.4)', color: '#ffa502' }}>
          No SMS / email is sent
        </span>
      </div>

      <OtpInput
        value={otp}
        onChange={(value) => {
          setOtp(value);
          if (error) setError(null);
        }}
        invalid={Boolean(error)}
        autoFocus
        onComplete={() => {
          setError(null);
          if (status === 'idle') verify();
        }}
      />

      {error && (
        <div className="ob-error" role="alert" style={{ justifyContent: 'center', marginTop: '14px' }}>
          <AlertTriangle size={14} />
          {error}
        </div>
      )}

      <p className="ob-hint" style={{ textAlign: 'center', marginTop: '16px' }}>
        The code verifies automatically once all six digits are entered — or tap Verify below.
      </p>
    </Screen>
  );
};

/* ==========================================================================
   Screen 18 — Existing user login
   ========================================================================== */

export const LoginScreen: React.FC = () => {
  const { go, patch, showToast } = useOnboarding();
  const [mode, setMode] = useState<'email' | 'mobile'>('email');
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const succeed = (message: string) => {
    patch({ completed: true });
    showToast(message, 'success');
    go('home');
  };

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (mode === 'email' && !isEmail(identifier)) {
      setError('Enter a valid email address.');
      return;
    }
    if (mode === 'mobile' && !isPhone(identifier)) {
      setError('Enter a valid mobile number.');
      return;
    }
    if (!password) {
      setError('Enter your password.');
      return;
    }

    setLoading(true);
    window.setTimeout(() => {
      setLoading(false);
      const expectedUser = mode === 'email' ? MOCK_CREDENTIALS.email : MOCK_CREDENTIALS.phone;
      const userOk = identifier.replace(/\D/g, '') === expectedUser.replace(/\D/g, '') || identifier.trim() === expectedUser;
      if (userOk && password === MOCK_CREDENTIALS.password) {
        succeed('Welcome back, Alex!');
      } else {
        setError('Invalid email, phone number, or password.');
      }
    }, 850);
  };

  return (
    <Screen
      title="Welcome Back"
      description="Sign in to continue your connections."
      footer={
        <button type="submit" form="login-form" className="btn-primary ob-btn block" disabled={loading}>
          {loading ? (
            <>
              <Loader2 size={17} className="radar-spinner" /> Signing in…
            </>
          ) : (
            <>
              Sign In <ArrowRight size={17} />
            </>
          )}
        </button>
      }
    >
      <form id="login-form" onSubmit={submit} style={{ marginTop: '18px' }}>
        <SegmentedControl
          label="Sign in method"
          value={mode}
          options={[
            { value: 'email', label: 'Email' },
            { value: 'mobile', label: 'Mobile' },
          ]}
          onChange={(value) => {
            setMode(value as 'email' | 'mobile');
            setError(null);
          }}
        />

        <div style={{ marginTop: '16px' }}>
          {mode === 'email' ? (
            <TextField
              label="Email address"
              value={identifier}
              onChange={(value) => {
                setIdentifier(value);
                if (error) setError(null);
              }}
              type="email"
              inputMode="email"
              autoComplete="email"
              placeholder="you@example.com"
              error={error && error.includes('email') ? error : null}
              required
            />
          ) : (
            <div className="ob-row">
              <div style={{ flex: '0 0 92px' }}>
                <span className="ob-label">Code</span>
                <div className="ob-input" style={{ padding: '12px 14px', color: 'var(--text-secondary)', fontWeight: 700 }}>
                  +91
                </div>
              </div>
              <div style={{ flex: 1 }}>
                <TextField
                  label="Mobile number"
                  value={identifier}
                  onChange={(value) => {
                    setIdentifier(value.replace(/\D/g, ''));
                    if (error) setError(null);
                  }}
                  type="tel"
                  inputMode="numeric"
                  autoComplete="tel-national"
                  placeholder="98765 43210"
                  error={error && error.includes('number') ? error : null}
                  maxLength={15}
                  required
                />
              </div>
            </div>
          )}

          <PasswordField
            label="Password"
            value={password}
            onChange={(value) => {
              setPassword(value);
              if (error) setError(null);
            }}
            autoComplete="current-password"
            error={error && error.includes('password') ? error : null}
            required
          />
        </div>

        {error && !error.includes('email') && !error.includes('number') && !error.includes('password') && (
          <div className="ob-error" role="alert" style={{ marginBottom: '12px' }}>
            <AlertTriangle size={14} />
            {error}
          </div>
        )}

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '10px' }}>
          <button type="button" className="ob-link" onClick={() => go('recover')}>
            Forgot password?
          </button>
          <DemoBadge>Mock auth</DemoBadge>
        </div>
      </form>

      <div style={{ marginTop: '16px' }}>
        <button
          type="button"
          className="btn-ghost ob-btn block"
          onClick={() => succeed('Signed in with Google (simulated).')}
        >
          <span style={{ fontWeight: 800, color: '#ff2d55' }}>G</span> Continue with Google
        </button>
      </div>

      <div
        className="ob-card"
        style={{ marginTop: '16px', fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.6 }}
      >
        <strong style={{ color: 'var(--text-primary)' }}>Demo credentials</strong>
        <div>Email: {MOCK_CREDENTIALS.email}</div>
        <div>Mobile: {MOCK_CREDENTIALS.phone}</div>
        <div>Password: {MOCK_CREDENTIALS.password}</div>
      </div>

      <div style={{ textAlign: 'center', marginTop: '16px' }}>
        <span style={{ fontSize: '12.5px', color: 'var(--text-secondary)' }}>New here? </span>
        <button type="button" className="ob-link" onClick={() => go('signup')}>
          Create New Account
        </button>
      </div>

      <p className="ob-hint" style={{ textAlign: 'center' }}>
        Try any of these chat tips later: {DEMO_MESSAGE_SUGGESTIONS[0]}
      </p>
    </Screen>
  );
};

/* ==========================================================================
   Screen 18b — Account recovery (frontend only)
   ========================================================================== */

export const RecoveryScreen: React.FC = () => {
  const { go, showToast } = useOnboarding();
  const [sub, setSub] = useState<'identify' | 'otp' | 'password' | 'done'>('identify');
  const [method, setMethod] = useState<'email' | 'mobile'>('email');
  const [identifier, setIdentifier] = useState('');
  const [otp, setOtp] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [countdown, setCountdown] = useState(OTP_RESEND_SECONDS);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (sub !== 'otp' || countdown <= 0) return;
    const timer = window.setTimeout(() => setCountdown((c) => c - 1), 1000);
    return () => window.clearTimeout(timer);
  }, [countdown, sub]);

  const stepLabel =
    sub === 'identify' ? 'Step 1 of 4 · Verify it’s you'
      : sub === 'otp' ? 'Step 2 of 4 · Enter the code'
      : sub === 'password' ? 'Step 3 of 4 · New password'
      : 'Step 4 of 4 · Done';

  const footerByStep = () => {
    if (sub === 'identify') {
      return (
        <button
          type="button"
          className="btn-primary ob-btn block"
          onClick={() => {
            if (method === 'email' && !isEmail(identifier)) {
              setError('Enter a valid email address.');
              return;
            }
            if (method === 'mobile' && !isPhone(identifier)) {
              setError('Enter a valid mobile number.');
              return;
            }
            setError(null);
            setOtp('');
            setCountdown(OTP_RESEND_SECONDS);
            setSub('otp');
          }}
        >
          Send Code <ArrowRight size={17} />
        </button>
      );
    }
    if (sub === 'otp') {
      return (
        <>
          <button
            type="button"
            className="btn-primary ob-btn block"
            disabled={loading}
            onClick={() => {
              if (otp !== MOCK_OTP) {
                setError('That code is not correct. Use the demo code shown above.');
                return;
              }
              setLoading(true);
              window.setTimeout(() => {
                setLoading(false);
                setError(null);
                setSub('password');
              }, 700);
            }}
          >
            {loading ? <Loader2 size={17} className="radar-spinner" /> : <>Continue <ArrowRight size={17} /></>}
          </button>
          <button type="button" className="btn-ghost ob-btn block" onClick={() => setSub('identify')}>
            Change details
          </button>
        </>
      );
    }
    if (sub === 'password') {
      return (
        <button
          type="button"
          className="btn-primary ob-btn block"
          onClick={() => {
            if (passwordScore(password) < 2) {
              setError('Choose a stronger password (8+ characters, mixed case, a number).');
              return;
            }
            if (password !== confirm) {
              setError('Passwords do not match.');
              return;
            }
            setError(null);
            setSub('done');
            showToast('Password updated (simulated).', 'success');
          }}
        >
          Save New Password
        </button>
      );
    }
    return (
      <button type="button" className="btn-primary ob-btn block" onClick={() => go('login')}>
        Back to Sign In <ArrowRight size={17} />
      </button>
    );
  };

  return (
    <Screen
      title="Reset Your Password"
      description={
        sub === 'done'
          ? 'Your password has been updated.'
          : 'Recover access with a simulated verification code — no real reset email or SMS is sent.'
      }
      footer={footerByStep()}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', gap: '8px', margin: '16px 0 4px' }}>
        <span className="ob-step-label" style={{ marginBottom: 0 }}>{stepLabel}</span>
        <span className="ob-demo">Demo</span>
      </div>

      {sub === 'identify' && (
        <div style={{ marginTop: '12px' }}>
          <SegmentedControl
            label="Verification method"
            value={method}
            options={[
              { value: 'email', label: 'Email' },
              { value: 'mobile', label: 'Mobile' },
            ]}
            onChange={(value) => {
              setMethod(value as 'email' | 'mobile');
              setError(null);
            }}
          />
          <div style={{ marginTop: '16px' }}>
            <TextField
              label={method === 'email' ? 'Account email' : 'Account mobile number'}
              value={identifier}
              onChange={(value) => {
                setIdentifier(method === 'mobile' ? value.replace(/\D/g, '') : value);
                if (error) setError(null);
              }}
              type={method === 'email' ? 'email' : 'tel'}
              inputMode={method === 'email' ? 'email' : 'numeric'}
              placeholder={method === 'email' ? 'you@example.com' : '98765 43210'}
              error={error}
              required
            />
          </div>
        </div>
      )}

      {sub === 'otp' && (
        <div style={{ marginTop: '18px' }}>
          <DemoBadge>Demo code: {MOCK_OTP}</DemoBadge>
          <div style={{ marginTop: '16px' }}>
            <OtpInput value={otp} onChange={setOtp} invalid={Boolean(error)} autoFocus />
          </div>
          {error && (
            <div className="ob-error" role="alert" style={{ justifyContent: 'center' }}>
              <AlertTriangle size={14} />
              {error}
            </div>
          )}
          <div style={{ textAlign: 'center', marginTop: '14px' }}>
            <button
              type="button"
              className="ob-link"
              disabled={countdown > 0}
              style={countdown > 0 ? { opacity: 0.55, cursor: 'not-allowed' } : undefined}
              onClick={() => setCountdown(OTP_RESEND_SECONDS)}
            >
              {countdown > 0 ? `Resend in ${countdown}s` : 'Resend code'}
            </button>
          </div>
        </div>
      )}

      {sub === 'password' && (
        <div style={{ marginTop: '16px' }}>
          <PasswordField
            label="New password"
            value={password}
            onChange={(value) => {
              setPassword(value);
              if (error) setError(null);
            }}
            autoComplete="new-password"
            required
          />
          {password && <StrengthMeter password={password} />}
          <PasswordField
            label="Confirm new password"
            value={confirm}
            onChange={(value) => {
              setConfirm(value);
              if (error) setError(null);
            }}
            autoComplete="new-password"
            error={error && error.includes('match') ? error : null}
            required
          />
          {error && !error.includes('match') && (
            <div className="ob-error" role="alert">
              <AlertTriangle size={14} />
              {error}
            </div>
          )}
        </div>
      )}

      {sub === 'done' && (
        <div style={{ textAlign: 'center', padding: '40px 0' }}>
          <div className="ob-check" style={{ width: 76, height: 76 }}>
            <Check size={36} color="#fff" strokeWidth={3} />
          </div>
          <h2 className="ob-title" style={{ fontSize: '20px' }}>Password Changed</h2>
          <p className="ob-desc">You can now sign in with your new password.</p>
          <div style={{ marginTop: '12px' }}>
            <Notice>This was a frontend-only reset — no email or SMS was dispatched.</Notice>
          </div>
        </div>
      )}
    </Screen>
  );
};
