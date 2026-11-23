/**
 * YoUnMe Dating App — Contact & Link Guard Service
 * Normalizes text to catch homoglyphs, phone numbers, social handles, and external URLs.
 */

import { Injectable } from '@nestjs/common';

export interface ContactGuardResult {
  blocked: boolean;
  reason?: string;
  detected?: 'phone_number' | 'social_handle' | 'external_url';
}

@Injectable()
export class ContactGuardService {
  private readonly userStrikes = new Map<string, number>();

  check(text: string, activeDays: number, pairCount: number): ContactGuardResult {
    if (activeDays >= 3 || pairCount >= 20) {
      return { blocked: false };
    }

    const clean = text.replace(/[@0]/g, (m) => (m === '@' ? 'a' : 'o')).toLowerCase();
    const digitsOnly = text.replace(/\D/g, '');

    if (digitsOnly.length >= 10) {
      return {
        blocked: true,
        reason:
          'Sharing phone numbers is restricted during the trust-building phase (Unlocks after 3 days or 20 messages).',
        detected: 'phone_number',
      };
    }

    const socialRegex =
      /(insta|ig|telegram|snap|snapchat|t\.me|wa\.me|whatsapp)\s*[:@\s_-]?\s*([a-zA-Z0-9_.]{3,})/i;
    if (socialRegex.test(clean)) {
      return {
        blocked: true,
        reason:
          'Social handles (Instagram, Telegram, WhatsApp) unlock automatically after 3 days of active connection.',
        detected: 'social_handle',
      };
    }

    const urlRegex = /(https?:\/\/|www\.)[^\s]+|([a-zA-Z0-9-]+\.(com|org|net|io|in|me|app))/i;
    if (urlRegex.test(text)) {
      return {
        blocked: true,
        reason: 'External web links are blocked for anti-fraud and user safety.',
        detected: 'external_url',
      };
    }

    return { blocked: false };
  }

  registerStrike(userId: string): number {
    const current = (this.userStrikes.get(userId) || 0) + 1;
    this.userStrikes.set(userId, current);
    return current;
  }
}
