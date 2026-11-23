/**
 * YoUnMe Worker — Firebase Cloud Messaging (FCM) Client Singleton
 *
 * Exclusively handles mobile push notification dispatch via Firebase Admin SDK.
 * Does NOT initialize Firebase Authentication or Firebase Realtime/Firestore DB.
 *
 * Follows Cloud Run best practices:
 *  - Initialized safely and only once per process.
 *  - Credentials loaded from Secret Manager (FIREBASE_SERVICE_ACCOUNT_KEY) or
 *    Google Cloud Workload Identity / Application Default Credentials.
 *  - Fails safely without crashing if credentials are not configured in dev/test.
 *  - Secrets and access tokens are never logged.
 */

import { initializeApp, getApps, cert, applicationDefault } from 'firebase-admin/app';
import { getMessaging, type Messaging } from 'firebase-admin/messaging';
import { env, fcmConfigured } from './config.js';

let _messaging: Messaging | null = null;

/**
 * Obtain the initialized Firebase Messaging singleton.
 * Returns null if credentials are not configured (graceful degradation).
 */
export function getMessagingClient(): Messaging | null {
  if (_messaging) return _messaging;

  if (!fcmConfigured) {
    return null;
  }

  if (getApps().length === 0) {
    let credential;

    if (env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      const raw = env.FIREBASE_SERVICE_ACCOUNT_KEY.trim();
      try {
        if (raw.startsWith('{')) {
          credential = cert(JSON.parse(raw));
        } else {
          // Check for base64 encoded JSON
          const decoded = Buffer.from(raw, 'base64').toString('utf8');
          if (decoded.trim().startsWith('{')) {
            credential = cert(JSON.parse(decoded));
          } else {
            // Assume file path
            credential = cert(raw);
          }
        }
      } catch (err) {
        console.warn(
          `[FCM] Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY as JSON or base64. ` +
            `Falling back to applicationDefault credentials. Error: ${err instanceof Error ? err.message : String(err)}`,
        );
        credential = applicationDefault();
      }
    } else {
      credential = applicationDefault();
    }

    initializeApp({
      credential,
      ...(env.FIREBASE_PROJECT_ID ? { projectId: env.FIREBASE_PROJECT_ID } : {}),
    });
  }

  _messaging = getMessaging();
  return _messaging;
}

