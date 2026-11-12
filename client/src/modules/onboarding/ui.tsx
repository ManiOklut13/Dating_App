import React, { useEffect, useRef } from 'react';
import { ArrowLeft, Check, Eye, EyeOff, X, Info } from 'lucide-react';
import { useOnboarding } from './OnboardingContext';
import { ONBOARDING_STEPS } from './types';
import { AvatarConfig } from './types';

/* ==========================================================================
   Layout shell — header (back + progress + optional skip) and sticky CTA
   ========================================================================== */

interface ScreenProps {
  title?: string;
  description?: string;
  /** Index into ONBOARDING_STEPS; omit for auth screens (no progress bar). */
  step?: number;
  onBack?: () => void;
  skipLabel?: string;
  onSkip?: () => void;
  footer?: React.ReactNode;
  wide?: boolean;
  bare?: boolean;
  children: React.ReactNode;
}

export const Screen: React.FC<ScreenProps> = ({
  title,
  description,
  step,
  onBack,
  skipLabel,
  onSkip,
  footer,
  wide,
  bare,
  children,
}) => {
  const { back, stepProgress } = useOnboarding();
  const meta = typeof step === 'number' ? ONBOARDING_STEPS[step] : undefined;

  return (
    <div className="ob-root">
      {!bare && (
        <header className="ob-header">
          <div className="ob-header-row">
            <button
              type="button"
              className="ob-back"
              onClick={onBack || back}
              aria-label="Go back"
            >
              <ArrowLeft size={18} />
            </button>

            <div className="ob-step-meta">
              {meta ? (
                <>
                  <div className="ob-step-label">
                    <span>
                      Step {step! + 1} of {ONBOARDING_STEPS.length} · {meta.label}
                    </span>
                    <span>{stepProgress}%</span>
                  </div>
                  <div
                    className="ob-progress"
                    role="progressbar"
                    aria-valuemin={0}
                    aria-valuemax={100}
                    aria-valuenow={stepProgress}
                    aria-label="Onboarding progress"
                  >
                    <span style={{ width: `${stepProgress}%` }} />
                  </div>
                </>
              ) : (
                <div className="ob-step-label" style={{ marginBottom: 0 }}>
                  <span>YoUnMe</span>
                </div>
              )}
            </div>

            {skipLabel && onSkip && (
              <button type="button" className="ob-skip" onClick={onSkip}>
                {skipLabel}
              </button>
            )}
          </div>
        </header>
      )}

      <div className="ob-body">
        <div className={`ob-container${wide ? ' wide' : ''}`}>
          {title && <h1 className="ob-title">{title}</h1>}
          {description && <p className="ob-desc">{description}</p>}
          {children}
          {footer && <div className="ob-actions">{footer}</div>}
        </div>
      </div>
    </div>
  );
};

/* ==========================================================================
   Form primitives
   ========================================================================== */

export const Field: React.FC<{
  label: string;
  htmlFor?: string;
  error?: string | null;
  hint?: string;
  children: React.ReactNode;
}> = ({ label, htmlFor, error, hint, children }) => (
  <div className="ob-field">
    <label className="ob-label" htmlFor={htmlFor}>
      {label}
    </label>
    {children}
    {error && (
      <div className="ob-error" role="alert">
        <Info size={13} />
        {error}
      </div>
    )}
    {hint && !error && <div className="ob-hint">{hint}</div>}
  </div>
);

interface TextFieldProps {
  id?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  type?: string;
  placeholder?: string;
  error?: string | null;
  hint?: string;
  autoComplete?: string;
  inputMode?: 'text' | 'numeric' | 'email' | 'tel';
  maxLength?: number;
  required?: boolean;
}

export const TextField: React.FC<TextFieldProps> = ({
  id,
  label,
  value,
  onChange,
  type = 'text',
  placeholder,
  error,
  hint,
  autoComplete,
  inputMode,
  maxLength,
  required,
}) => {
  const fieldId = id || `f-${label.replace(/\s+/g, '-').toLowerCase()}`;
  return (
    <Field label={required ? `${label} *` : label} htmlFor={fieldId} error={error} hint={hint}>
      <input
        id={fieldId}
        className="ob-input"
        type={type}
        value={value}
        placeholder={placeholder}
        autoComplete={autoComplete}
        inputMode={inputMode}
        maxLength={maxLength}
        aria-invalid={error ? 'true' : undefined}
        aria-describedby={error ? `${fieldId}-err` : undefined}
        onChange={(e) => onChange(e.target.value)}
      />
    </Field>
  );
};

export const PasswordField: React.FC<{
  id?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  error?: string | null;
  hint?: string;
  autoComplete?: string;
  required?: boolean;
}> = ({ id, label, value, onChange, error, hint, autoComplete, required }) => {
  const [visible, setVisible] = React.useState(false);
  const fieldId = id || `pw-${label.replace(/\s+/g, '-').toLowerCase()}`;
  return (
    <Field label={required ? `${label} *` : label} htmlFor={fieldId} error={error} hint={hint}>
      <div style={{ position: 'relative' }}>
        <input
          id={fieldId}
          className="ob-input"
          type={visible ? 'text' : 'password'}
          value={value}
          autoComplete={autoComplete}
          aria-invalid={error ? 'true' : undefined}
          onChange={(e) => onChange(e.target.value)}
          style={{ paddingRight: '46px' }}
        />
        <button
          type="button"
          className="ob-link muted"
          onClick={() => setVisible((v) => !v)}
          aria-label={visible ? 'Hide password' : 'Show password'}
          aria-pressed={visible}
          style={{
            position: 'absolute',
            right: '6px',
            top: '50%',
            transform: 'translateY(-50%)',
            padding: '8px',
            color: 'var(--text-secondary)',
            textDecoration: 'none',
          }}
        >
          {visible ? <EyeOff size={17} /> : <Eye size={17} />}
        </button>
      </div>
    </Field>
  );
};

export const TextAreaField: React.FC<{
  id?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  maxLength?: number;
  error?: string | null;
  hint?: string;
  rows?: number;
}> = ({ id, label, value, onChange, placeholder, maxLength, error, hint, rows = 4 }) => {
  const fieldId = id || `ta-${label.replace(/\s+/g, '-').toLowerCase()}`;
  return (
    <Field label={label} htmlFor={fieldId} error={error} hint={hint}>
      <textarea
        id={fieldId}
        className="ob-textarea"
        rows={rows}
        value={value}
        placeholder={placeholder}
        maxLength={maxLength}
        aria-invalid={error ? 'true' : undefined}
        onChange={(e) => onChange(e.target.value)}
      />
      {maxLength && (
        <div className="ob-hint" style={{ textAlign: 'right' }}>
          {value.length}/{maxLength}
        </div>
      )}
    </Field>
  );
};

/* ==========================================================================
   Selection controls
   ========================================================================== */

export const ChoiceCard: React.FC<{
  selected: boolean;
  onClick: () => void;
  title: string;
  hint?: string;
  emoji?: string;
  icon?: React.ReactNode;
  multi?: boolean;
  children?: React.ReactNode;
}> = ({ selected, onClick, title, hint, emoji, icon, multi, children }) => (
  <button
    type="button"
    className={`ob-choice${selected ? ' selected' : ''}`}
    role={multi ? 'checkbox' : 'radio'}
    aria-checked={selected}
    onClick={onClick}
  >
    <span className="ob-choice-mark" aria-hidden="true">
      <Check size={13} strokeWidth={3} style={{ opacity: selected ? 1 : 0 }} />
    </span>
    <span style={{ flex: 1, minWidth: 0 }}>
      <span className="ob-choice-title" style={{ display: 'flex', gap: '7px', alignItems: 'center' }}>
        {emoji && <span aria-hidden="true">{emoji}</span>}
        {icon}
        {title}
      </span>
      {hint && <span className="ob-choice-hint" style={{ display: 'block' }}>{hint}</span>}
      {children}
    </span>
  </button>
);

export const Chip: React.FC<{
  selected: boolean;
  onClick: () => void;
  children: React.ReactNode;
  onRemove?: () => void;
  ariaLabel?: string;
}> = ({ selected, onClick, children, onRemove, ariaLabel }) => (
  <span style={{ display: 'inline-flex', gap: '6px', alignItems: 'center' }}>
    <button
      type="button"
      className={`ob-chip${selected ? ' selected' : ''}`}
      role="checkbox"
      aria-checked={selected}
      aria-label={ariaLabel}
      onClick={onClick}
    >
      {children}
    </button>
    {onRemove && (
      <button
        type="button"
        className="ob-link muted"
        onClick={onRemove}
        aria-label={`Remove ${typeof children === 'string' ? children : 'item'}`}
        style={{ padding: '2px 4px', color: '#ff4757' }}
      >
        <X size={13} />
      </button>
    )}
  </span>
);

export const SegmentedControl: React.FC<{
  label: string;
  value: string;
  options: Array<{ value: string; label: string }>;
  onChange: (value: string) => void;
}> = ({ label, value, options, onChange }) => (
  <div className="segmented" role="radiogroup" aria-label={label}>
    {options.map((option) => (
      <button
        key={option.value}
        type="button"
        role="radio"
        aria-checked={value === option.value}
        className={`segmented-item${value === option.value ? ' active' : ''}`}
        onClick={() => onChange(option.value)}
      >
        {option.label}
      </button>
    ))}
  </div>
);

export const ToggleRow: React.FC<{
  label: string;
  hint?: string;
  checked: boolean;
  onChange: (value: boolean) => void;
  disabled?: boolean;
  icon?: React.ReactNode;
}> = ({ label, hint, checked, onChange, disabled, icon }) => (
  <div className="ob-list-item" style={{ alignItems: 'center' }}>
    <div style={{ minWidth: 0 }}>
      <div style={{ display: 'flex', gap: '7px', alignItems: 'center', fontSize: '13px', fontWeight: 700 }}>
        {icon}
        {label}
      </div>
      {hint && (
        <div style={{ fontSize: '11.5px', color: 'var(--text-muted)', marginTop: '3px', lineHeight: 1.45 }}>
          {hint}
        </div>
      )}
    </div>
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      className={`switch${checked ? ' on' : ''}`}
      style={disabled ? { opacity: 0.5, cursor: 'not-allowed' } : undefined}
      onClick={() => !disabled && onChange(!checked)}
    >
      <span className="switch-knob" />
    </button>
  </div>
);

export const RangeField: React.FC<{
  label: string;
  min: number;
  max: number;
  step?: number;
  value: number;
  onChange: (value: number) => void;
  format?: (value: number) => string;
  minLabel?: string;
  maxLabel?: string;
}> = ({ label, min, max, step = 1, value, onChange, format, minLabel, maxLabel }) => (
  <div className="ob-field">
    <div style={{ display: 'flex', justifyContent: 'space-between', gap: '10px', marginBottom: '6px' }}>
      <span className="ob-label" style={{ marginBottom: 0 }}>{label}</span>
      <span style={{ fontSize: '13px', fontWeight: 800, color: 'var(--flame-pink)' }}>
        {format ? format(value) : value}
      </span>
    </div>
    <input
      className="ob-range"
      type="range"
      min={min}
      max={max}
      step={step}
      value={value}
      aria-label={label}
      aria-valuetext={format ? format(value) : String(value)}
      onChange={(e) => onChange(Number(e.target.value))}
    />
    {(minLabel || maxLabel) && (
      <div className="ob-range-meta">
        <span>{minLabel}</span>
        <span>{maxLabel}</span>
      </div>
    )}
  </div>
);

/* ==========================================================================
   OTP input — auto-advance, backspace, paste support
   ========================================================================== */

export const OtpInput: React.FC<{
  value: string;
  onChange: (value: string) => void;
  length?: number;
  invalid?: boolean;
  autoFocus?: boolean;
  onComplete?: (value: string) => void;
}> = ({ value, onChange, length = 6, invalid, autoFocus, onComplete }) => {
  const refs = useRef<Array<HTMLInputElement | null>>([]);

  useEffect(() => {
    if (autoFocus) refs.current[0]?.focus();
  }, [autoFocus]);

  const digits = Array.from({ length }, (_, i) => value[i] ?? '');

  const commit = (next: string) => {
    onChange(next);
    if (next.replace(/\D/g, '').length === length && onComplete) onComplete(next);
  };

  const setAt = (index: number, char: string) => {
    const arr = Array.from({ length }, (_, i) => value[i] ?? '');
    arr[index] = char;
    commit(arr.join(''));
  };

  return (
    <div className="ob-otp" role="group" aria-label="Six digit verification code">
      {digits.map((char, index) => (
        <input
          key={index}
          ref={(el) => {
            refs.current[index] = el;
          }}
          value={char}
          inputMode="numeric"
          autoComplete={index === 0 ? 'one-time-code' : 'off'}
          maxLength={1}
          aria-label={`Digit ${index + 1}`}
          aria-invalid={invalid ? 'true' : undefined}
          onChange={(e) => {
            const clean = e.target.value.replace(/\D/g, '').slice(-1);
            setAt(index, clean);
            if (clean && index < length - 1) refs.current[index + 1]?.focus();
          }}
          onKeyDown={(e) => {
            if (e.key === 'Backspace') {
              if (!digits[index] && index > 0) {
                e.preventDefault();
                setAt(index - 1, '');
                refs.current[index - 1]?.focus();
              }
            } else if (e.key === 'ArrowLeft' && index > 0) {
              refs.current[index - 1]?.focus();
            } else if (e.key === 'ArrowRight' && index < length - 1) {
              refs.current[index + 1]?.focus();
            }
          }}
          onPaste={(e) => {
            e.preventDefault();
            const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, length);
            if (!pasted) return;
            commit(pasted);
            refs.current[Math.min(pasted.length, length - 1)]?.focus();
          }}
        />
      ))}
    </div>
  );
};

/* ==========================================================================
   Modal — Escape close, focus management, labelled
   ========================================================================== */

export const Modal: React.FC<{
  open: boolean;
  onClose: () => void;
  title: string;
  wide?: boolean;
  children: React.ReactNode;
}> = ({ open, onClose, title, wide, children }) => {
  const panelRef = useRef<HTMLDivElement>(null);
  const previousFocus = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (!open) return;
    previousFocus.current = document.activeElement as HTMLElement | null;
    panelRef.current?.focus();
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener('keydown', onKey);
      previousFocus.current?.focus?.();
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="ob-modal-backdrop" onClick={onClose}>
      <div
        ref={panelRef}
        tabIndex={-1}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className={`ob-modal${wide ? ' wide' : ''}`}
        style={{ outline: 'none' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="ob-modal-head">
          <div className="ob-modal-title">{title}</div>
          <button
            type="button"
            className="ob-back"
            onClick={onClose}
            aria-label={`Close ${title}`}
          >
            <X size={17} />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
};

/* ==========================================================================
   Small display helpers
   ========================================================================== */

export const DemoBadge: React.FC<{ children?: React.ReactNode }> = ({ children }) => (
  <span className="ob-demo">{children || 'Demo'}</span>
);

export const SectionLabel: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="ob-section-label">{children}</div>
);

export const Notice: React.FC<{
  tone?: 'info' | 'warn';
  children: React.ReactNode;
}> = ({ tone = 'info', children }) => (
  <div
    style={{
      padding: '12px 14px',
      borderRadius: 'var(--radius-md)',
      fontSize: '12.5px',
      lineHeight: 1.55,
      display: 'flex',
      gap: '9px',
      alignItems: 'flex-start',
      background: tone === 'warn' ? 'rgba(255, 170, 0, 0.09)' : 'rgba(0, 229, 255, 0.07)',
      border: `1px solid ${tone === 'warn' ? 'rgba(255, 170, 0, 0.32)' : 'rgba(0, 229, 255, 0.28)'}`,
      color: 'var(--text-secondary)',
    }}
  >
    <Info size={15} style={{ flexShrink: 0, marginTop: '1px', color: tone === 'warn' ? '#ffa502' : '#00e5ff' }} />
    <span>{children}</span>
  </div>
);

export const AvatarPreview: React.FC<{
  avatar: AvatarConfig | null;
  photo?: string;
  size?: number;
  alt?: string;
}> = ({ avatar, photo, size = 84, alt = 'Avatar preview' }) => {
  if (photo) {
    return (
      <img
        src={photo}
        alt={alt}
        style={{
          width: size,
          height: size,
          borderRadius: '50%',
          objectFit: 'cover',
          border: '3px solid var(--flame-pink)',
          boxShadow: 'var(--shadow-glow)',
        }}
      />
    );
  }
  if (!avatar) {
    return (
      <div
        aria-label="No avatar selected"
        style={{
          width: size,
          height: size,
          borderRadius: '50%',
          background: 'var(--gradient-flame)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: size * 0.45,
          border: '3px solid var(--border-glass)',
        }}
      >
        👤
      </div>
    );
  }
  return (
    <div
      aria-label="Avatar preview"
      style={{
        position: 'relative',
        width: size,
        height: size,
        borderRadius: '50%',
        background: `radial-gradient(circle at 50% 32%, #ffffff33 0%, transparent 55%), ${avatar.skin}`,
        border: `3px solid ${avatar.outfit}`,
        boxShadow: 'var(--shadow-glow)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'visible',
      }}
    >
      <span style={{ fontSize: size * 0.52, lineHeight: 1 }} aria-hidden="true">
        {avatar.base}
      </span>
      {avatar.accessory && (
        <span
          style={{
            position: 'absolute',
            bottom: -4,
            right: -4,
            fontSize: size * 0.3,
            background: 'var(--bg-surface)',
            borderRadius: '50%',
            padding: '2px',
            lineHeight: 1,
          }}
          aria-hidden="true"
        >
          {avatar.accessory}
        </span>
      )}
    </div>
  );
};

export const InlineButton: React.FC<{
  onClick: () => void;
  children: React.ReactNode;
  tone?: 'default' | 'danger';
}> = ({ onClick, children, tone = 'default' }) => (
  <button
    type="button"
    className="btn-ghost"
    onClick={onClick}
    style={{
      padding: '8px 14px',
      fontSize: '12.5px',
      fontWeight: 700,
      color: tone === 'danger' ? '#ff4757' : 'var(--text-primary)',
      borderColor: tone === 'danger' ? 'rgba(255, 71, 87, 0.35)' : 'var(--border-glass)',
    }}
  >
    {children}
  </button>
);
