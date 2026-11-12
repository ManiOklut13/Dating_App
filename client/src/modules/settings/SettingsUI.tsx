import React, { useEffect, useRef } from 'react';
import { ArrowLeft, ChevronRight, X } from 'lucide-react';
import { useSettings } from './SettingsContext';

/* ==========================================================================
   Reusable building blocks for the Instagram-style Settings screens.
   All primitives reuse the design-system classes already defined in
   styles/index.css (.settings-row, .switch, .radio-option, ...) so the new
   pages stay visually consistent with the rest of the app and inherit the
   existing light/dark theme support for free.
   ========================================================================== */

/* --------------------------------------------------------------------------
   Page shell — sticky header with a back arrow at the top-left, centered
   title, and a scrollable content column. Responsive: full width on mobile,
   max 720px centered column on desktop.
   -------------------------------------------------------------------------- */
export const SettingsPage: React.FC<{
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  /** Rendered on the right side of the header (e.g. an action button). */
  headerAction?: React.ReactNode;
}> = ({ title, subtitle, children, headerAction }) => {
  const { back } = useSettings();
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: 0 });
  }, [title]);

  return (
    <div className="settings-page" role="region" aria-label={title}>
      <header className="settings-page-header">
        <button type="button" className="settings-back-btn" onClick={back} aria-label="Go back">
          <ArrowLeft size={20} />
        </button>
        <div className="settings-page-heading">
          <h1 className="settings-page-title">{title}</h1>
          {subtitle && <p className="settings-page-subtitle">{subtitle}</p>}
        </div>
        <div className="settings-page-action">{headerAction}</div>
      </header>
      <div className="settings-page-scroll" ref={scrollRef}>
        <div className="settings-page-body">{children}</div>
      </div>
    </div>
  );
};

/* --------------------------------------------------------------------------
   Section — Instagram-style grouped card with an optional uppercase label.
   -------------------------------------------------------------------------- */
export const SettingsSection: React.FC<{
  label?: string;
  note?: React.ReactNode;
  children: React.ReactNode;
}> = ({ label, note, children }) => (
  <section className="settings-group-wrap">
    {label && <h2 className="settings-group-label">{label}</h2>}
    <div className="settings-group">{children}</div>
    {note && <p className="settings-group-note">{note}</p>}
  </section>
);

/* --------------------------------------------------------------------------
   Divider between rows inside a group.
   -------------------------------------------------------------------------- */
export const SettingsDivider: React.FC = () => <div className="settings-row-divider" role="separator" />;

/* --------------------------------------------------------------------------
   Nav row — icon, label, optional hint/value, chevron. Whole row clickable.
   -------------------------------------------------------------------------- */
export const SettingsNavRow: React.FC<{
  icon: React.ReactNode;
  label: string;
  hint?: string;
  value?: string;
  onClick: () => void;
  danger?: boolean;
  showChevron?: boolean;
}> = ({ icon, label, hint, value, onClick, danger, showChevron = true }) => (
  <button
    type="button"
    className="settings-row settings-nav-row"
    onClick={onClick}
    data-testid={`row-${label.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}
  >
    <span className="settings-row-icon" style={danger ? { color: '#ff4757' } : undefined} aria-hidden="true">
      {icon}
    </span>
    <span className="settings-row-text">
      <span className="settings-row-label" style={danger ? { color: '#ff4757' } : undefined}>
        {label}
      </span>
      {hint && <span className="settings-row-hint">{hint}</span>}
    </span>
    {value && <span className="settings-row-value">{value}</span>}
    {showChevron && <ChevronRight size={16} className="settings-row-chevron" aria-hidden="true" />}
  </button>
);

/* --------------------------------------------------------------------------
   Toggle row — label + description on the left, rounded switch on the right.
   -------------------------------------------------------------------------- */
export const ToggleRow: React.FC<{
  label: string;
  description?: string;
  icon?: React.ReactNode;
  checked: boolean;
  onChange: (value: boolean) => void;
  disabled?: boolean;
}> = ({ label, description, icon, checked, onChange, disabled }) => (
  <div className={`settings-inline settings-toggle-row${disabled ? ' disabled' : ''}`}>
    <div className="settings-toggle-text">
      <div className="settings-inline-label">
        {icon}
        {label}
      </div>
      {description && <div className="settings-inline-hint">{description}</div>}
    </div>
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      className={`switch${checked ? ' on' : ''}`}
      onClick={() => onChange(!checked)}
    >
      <span className="switch-knob" />
    </button>
  </div>
);

/* --------------------------------------------------------------------------
   Radio group — mutually exclusive selectable options with descriptions.
   -------------------------------------------------------------------------- */
export interface SettingsRadioOption {
  value: string;
  label: string;
  description?: string;
}

export const RadioGroup: React.FC<{
  label: string;
  value: string;
  options: SettingsRadioOption[];
  onChange: (value: string) => void;
}> = ({ label, value, options, onChange }) => (
  <div role="radiogroup" aria-label={label} className="settings-radio-group">
    {options.map((opt) => {
      const isActive = value === opt.value;
      return (
        <button
          key={opt.value}
          type="button"
          role="radio"
          aria-checked={isActive}
          className={`radio-option${isActive ? ' active' : ''}`}
          onClick={() => onChange(opt.value)}
        >
          <span className="radio-dot" aria-hidden="true" />
          <span className="radio-text">
            <span>{opt.label}</span>
            {opt.description && <span className="radio-desc">{opt.description}</span>}
          </span>
        </button>
      );
    })}
  </div>
);

/* --------------------------------------------------------------------------
   Empty state — used for blocked accounts, login activity, support requests.
   -------------------------------------------------------------------------- */
export const EmptyState: React.FC<{
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: React.ReactNode;
}> = ({ icon, title, description, action }) => (
  <div className="settings-empty-state">
    <div className="settings-empty-icon" aria-hidden="true">
      {icon}
    </div>
    <p className="settings-empty-title">{title}</p>
    <p className="settings-empty-desc">{description}</p>
    {action && <div className="settings-empty-action">{action}</div>}
  </div>
);

/* --------------------------------------------------------------------------
   Confirmation dialog — required for sensitive actions.
   -------------------------------------------------------------------------- */
export const ConfirmDialog: React.FC<{
  open: boolean;
  icon?: React.ReactNode;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  danger?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}> = ({
  open,
  icon,
  title,
  message,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  danger,
  onConfirm,
  onCancel,
}) => {
  const confirmRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!open) return;
    confirmRef.current?.focus();
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onCancel();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [open, onCancel]);

  if (!open) return null;

  return (
    <div className="settings-dialog-backdrop" onClick={onCancel} role="presentation">
      <div
        className="settings-dialog glass-panel"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="settings-dialog-title"
        onClick={(e) => e.stopPropagation()}
      >
        <button type="button" className="settings-icon-btn settings-dialog-close" onClick={onCancel} aria-label="Close dialog">
          <X size={16} />
        </button>
        {icon && <div className="settings-dialog-icon" aria-hidden="true">{icon}</div>}
        <h3 id="settings-dialog-title" className="settings-dialog-title">
          {title}
        </h3>
        <p className="settings-dialog-message">{message}</p>
        <div className="settings-dialog-actions">
          <button type="button" className="btn-ghost settings-dialog-btn" onClick={onCancel}>
            {cancelLabel}
          </button>
          <button
            ref={confirmRef}
            type="button"
            className={`settings-dialog-btn ${danger ? 'danger' : 'primary'}`}
            onClick={onConfirm}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
};

/* --------------------------------------------------------------------------
   Info banner used across the settings screens.
   -------------------------------------------------------------------------- */
export const SettingsBanner: React.FC<{ children: React.ReactNode; tone?: 'info' | 'warning' }> = ({
  children,
  tone = 'info',
}) => <div className={`settings-banner settings-banner-${tone}`}>{children}</div>;
