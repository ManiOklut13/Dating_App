import React from 'react';

// Plan a Date Theme Tokens
// One theme file - no hardcoded colours elsewhere

export const planDateTheme = {
  colors: {
    background: '#0e0a14',
    card: '#1b1624',
    cardBorder: '#2a2234',
    innerField: '#0F0A16',
    innerFieldBorder: '#2B2236',
    idleChip: '#1E1727',
    idleChipBorder: '#2B2236',
    raisedButton: '#241833',
    raisedButtonBorder: '#3A2646',
    highlightCardGradientStart: '#1E1429',
    highlightCardGradientEnd: '#15101C',
    highlightCardBorder: '#3A2646',
    primaryGradientStart: '#E8226F',
    primaryGradientEnd: '#A8189B',
    text: '#F6F1FA',
    muted: '#B9ADC9',
    placeholder: '#9A8DAD',
    softText: '#C9BED8',
    accentText: '#FF7FAE',
    violetText: '#C9A4FF',
    success: '#34D399',
    coin: '#FFC53D',
    disabledBg: '#120C19',
    disabledText: '#7A6E8C',
    disabledBorder: '#1E1727',
    // Specific accents
    accentPink: '#FF5C9A',
    accentViolet: '#8B5CF6',
    accentPink2: '#FF7FAE',
    accentPink3: '#FF6FA3',
    accentPink4: '#FF8FB5',
    // Selection/glow
    selectedShadow: '0 8px 20px rgba(232,34,111,.32)',
    ctaShadow: '0 12px 32px rgba(232,34,111,.40)',
  },
  gradients: {
    backgroundRadialPink: 'radial-gradient(ellipse 80% 60% at 85% 10%, rgba(232,34,111,.30) 0%, transparent 60%)',
    backgroundRadialViolet: 'radial-gradient(ellipse 70% 50% at 15% 20%, rgba(139,92,246,.18) 0%, transparent 65%)',
    primary: 'linear-gradient(135deg, #E8226F 0%, #A8189B 100%)',
    highlightCard: 'linear-gradient(135deg, #1E1429 0%, #15101C 100%)',
    partnerRing: 'linear-gradient(135deg, #FF5C9A 0%, #8B5CF6 100%)',
    dateText: 'linear-gradient(90deg, #FF5C9A 0%, #C77DFF 100%)',
    splitYou: 'linear-gradient(90deg, #E8226F 0%, #FF5C9A 100%)',
    splitPartner: 'linear-gradient(90deg, #8B5CF6 0%, #C77DFF 100%)',
  },
  borderRadius: {
    card: 24,
    inner: 14,
    button: 14,
    pill: 999,
    small: 12,
    medium: 16,
    large: 18,
    cta: 20,
  },
  spacing: {
    screenPadding: 20,
    cardGap: 16,
    cardPadding: 16,
  },
  typography: {
    fontFamily: "'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    weights: {
      medium: 500,
      semibold: 600,
      bold: 700,
      extrabold: 800,
    },
  },
  sizes: {
    minTouchTarget: 44,
    avatar: 64,
    headerHeight: 48,
    iconButton: 44,
    segmentButtonHeight: 48,
    timeColumn: 84,
    timeBoxHeight: 54,
    durationButton: 48,
    chipHeight: 44,
    checkbox: 26,
    todoRowMinHeight: 48,
    notesHeight: 96,
    iconSquare: 32,
    stepCircle: 26,
    ctaHeight: 60,
  },
} as const;

export type PlanDateTheme = typeof planDateTheme;

export const getPlanDateStyles = () => {
  return {
    container: {
      backgroundColor: planDateTheme.colors.background,
      backgroundImage: `${planDateTheme.gradients.backgroundRadialPink}, ${planDateTheme.gradients.backgroundRadialViolet}`,
      backgroundPosition: 'top right, top left',
      backgroundRepeat: 'no-repeat',
      minHeight: '100vh',
      fontFamily: planDateTheme.typography.fontFamily,
      color: planDateTheme.colors.text,
      padding: `${planDateTheme.spacing.screenPadding}px`,
    } as React.CSSProperties,
  };
};
