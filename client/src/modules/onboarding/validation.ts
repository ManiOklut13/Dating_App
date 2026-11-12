import { MIN_AGE } from './types';

export const isEmail = (value: string): boolean => /^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$/.test(value.trim());

export const isPhone = (value: string): boolean => /^[0-9]{7,15}$/.test(value.replace(/\D/g, ''));

export const formatPhone = (value: string): string => {
  const digits = value.replace(/\D/g, '');
  if (digits.length <= 5) return digits;
  if (digits.length <= 9) return `${digits.slice(0, 5)} ${digits.slice(5)}`;
  return `${digits.slice(0, 5)} ${digits.slice(5, 10)} ${digits.slice(10)}`;
};

/** 0 = empty/weak … 4 = very strong */
export const passwordScore = (value: string): number => {
  if (!value) return 0;
  let score = 0;
  if (value.length >= 8) score += 1;
  if (value.length >= 12) score += 1;
  if (/[A-Z]/.test(value) && /[a-z]/.test(value)) score += 1;
  if (/[0-9]/.test(value) && /[^A-Za-z0-9]/.test(value)) score += 1;
  return Math.min(score, 4);
};

export const passwordChecks = (value: string) => [
  { id: 'len', label: 'At least 8 characters', ok: value.length >= 8 },
  { id: 'case', label: 'Upper & lower case letters', ok: /[A-Z]/.test(value) && /[a-z]/.test(value) },
  { id: 'num', label: 'At least one number', ok: /[0-9]/.test(value) },
  { id: 'sym', label: 'One symbol (!@#…)', ok: /[^A-Za-z0-9]/.test(value) },
];

export const passwordLabel = (score: number) =>
  ['', 'Weak', 'Fair', 'Good', 'Strong'][score] || 'Weak';

/** Age in whole years from an ISO date (YYYY-MM-DD), or null when invalid. */
export const ageFromDob = (dob: string): number | null => {
  if (!dob) return null;
  const birth = new Date(`${dob}T00:00:00`);
  if (Number.isNaN(birth.getTime())) return null;
  const now = new Date();
  if (birth > now) return null;
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age -= 1;
  return age;
};

export interface DobValidation {
  age: number | null;
  error: string | null;
}

export const validateDob = (dob: string, minAge = MIN_AGE): DobValidation => {
  if (!dob) return { age: null, error: 'Please select your date of birth.' };
  const birth = new Date(`${dob}T00:00:00`);
  if (Number.isNaN(birth.getTime())) return { age: null, error: 'Enter a valid date.' };
  if (birth > new Date()) return { age: null, error: 'Date of birth cannot be in the future.' };
  const age = ageFromDob(dob);
  if (age === null) return { age: null, error: 'Enter a valid date.' };
  if (age < minAge) return { age, error: `You must be at least ${minAge} years old to use YoUnMe.` };
  if (age > 120) return { age, error: 'Please enter a realistic date of birth.' };
  return { age, error: null };
};

export const maskEmail = (email: string): string => {
  const [user, domain] = email.split('@');
  if (!domain) return email;
  const head = user.slice(0, 2);
  return `${head}${'*'.repeat(Math.max(user.length - 2, 1))}@${domain}`;
};

export const maskPhone = (countryCode: string, phone: string): string => {
  const digits = phone.replace(/\D/g, '');
  const tail = digits.slice(-4);
  return `${countryCode} ${'*'.repeat(Math.max(digits.length - 4, 0))}${tail}`;
};

/** Demo-only pattern detection for the chat-safety preview. */
export interface Detection {
  kind: 'link' | 'phone' | 'handle' | 'profanity';
  label: string;
  value: string;
}

const PATTERNS: Array<{ kind: Detection['kind']; re: RegExp; label: string }> = [
  { kind: 'link', re: /\b(?:https?:\/\/|www\.)\S+/gi, label: 'External link' },
  { kind: 'handle', re: /\b(?:instagram|telegram|whatsapp|snapchat|tiktok)\b\S*/gi, label: 'Social handle / app' },
  { kind: 'handle', re: /@[a-z0-9._]{3,}/gi, label: 'Social handle' },
  { kind: 'phone', re: /(?:\+?\d[\d\s-]{8,}\d)/g, label: 'Phone number' },
];

export const detectUnsafeContent = (message: string, profanity: string[] = []): Detection[] => {
  const found: Detection[] = [];
  const seen = new Set<string>();
  for (const { kind, re, label } of PATTERNS) {
    const matches = message.match(re) || [];
    for (const raw of matches) {
      const value = raw.trim();
      if (!value || seen.has(value.toLowerCase())) continue;
      seen.add(value.toLowerCase());
      found.push({ kind, label, value });
    }
  }
  const lower = message.toLowerCase();
  for (const word of profanity) {
    if (lower.includes(word.toLowerCase())) {
      found.push({ kind: 'profanity', label: 'Restricted word', value: word });
    }
  }
  return found;
};

export const maskProfanity = (message: string, profanity: string[]): string => {
  let out = message;
  for (const word of profanity) {
    if (!word) continue;
    out = out.replace(new RegExp(`\\b${word}\\b`, 'gi'), '*'.repeat(word.length));
  }
  return out;
};
