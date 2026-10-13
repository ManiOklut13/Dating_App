import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

export interface VerifiedFirebaseUser {
  uid: string;
  email?: string;
  email_verified?: boolean;
}

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private firebaseApp: admin.app.App | null = null;
  private isMockMode = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase(): void {
    if (admin.apps.length > 0) {
      this.firebaseApp = admin.apps[0]!;
      this.logger.log('Reusing existing Firebase Admin App instance.');
      return;
    }

    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKeyRaw = this.configService.get<string>('FIREBASE_PRIVATE_KEY');
    const googleAppCreds = this.configService.get<string>('GOOGLE_APPLICATION_CREDENTIALS');

    if (projectId && clientEmail && privateKeyRaw) {
      try {
        const privateKey = privateKeyRaw.replace(/\\n/g, '\n');
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
        this.logger.log(`Firebase Admin initialized successfully with Service Account for project: ${projectId}`);
        return;
      } catch (err: any) {
        this.logger.error(`Failed to initialize Firebase with Service Account credentials: ${err.message}`);
      }
    }

    if (googleAppCreds) {
      try {
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.applicationDefault(),
        });
        this.logger.log('Firebase Admin initialized with Application Default Credentials.');
        return;
      } catch (err: any) {
        this.logger.error(`Failed to initialize Firebase with Application Default Credentials: ${err.message}`);
      }
    }

    // Auto-detect local serviceAccountKey.json file if present
    const potentialKeyPaths = [
      path.resolve(process.cwd(), 'serviceAccountKey.json'),
      path.resolve(process.cwd(), 'services/api-nestjs/serviceAccountKey.json'),
    ];
    for (const keyPath of potentialKeyPaths) {
      if (fs.existsSync(keyPath)) {
        try {
          const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
          this.firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          this.logger.log(
            `Firebase Admin initialized successfully using ${path.basename(keyPath)} for project: ${serviceAccount.project_id}`,
          );
          return;
        } catch (err: any) {
          this.logger.error(`Failed to initialize Firebase from ${keyPath}: ${err.message}`);
        }
      }
    }

    // Fallback for automated tests and development without active GCP credentials
    try {
      this.firebaseApp = admin.initializeApp({
        projectId: projectId || 'younme-dev-mock',
      });
      this.isMockMode = true;
      this.logger.warn('Firebase Admin initialized without credentials (Mock/Local Mode). Live verification requires valid credentials.');
    } catch (err: any) {
      this.isMockMode = true;
      this.logger.warn(`Firebase Admin local initialization notice: ${err.message}`);
    }
  }

  /**
   * Verifies a Firebase ID token.
   * Never logs raw tokens or sensitive headers.
   */
  async verifyIdToken(idToken: string): Promise<VerifiedFirebaseUser> {
    if (!idToken || typeof idToken !== 'string') {
      throw new Error('MISSING_TOKEN');
    }

    if (!this.firebaseApp) {
      throw new Error('FIREBASE_NOT_INITIALIZED');
    }

    try {
      const decoded: admin.auth.DecodedIdToken = await admin.auth(this.firebaseApp).verifyIdToken(idToken);
      return {
        uid: decoded.uid,
        email: decoded.email,
        email_verified: decoded.email_verified,
      };
    } catch (error: any) {
      // Map Firebase error codes to internal identifiers without leaking internal stack traces
      if (error.code === 'auth/id-token-expired') {
        throw new Error('TOKEN_EXPIRED');
      }
      if (
        error.code === 'auth/argument-error' ||
        error.code === 'auth/invalid-id-token' ||
        error.code === 'auth/id-token-revoked' ||
        error.code === 'auth/user-disabled'
      ) {
        throw new Error('TOKEN_INVALID');
      }
      throw error;
    }
  }
}
