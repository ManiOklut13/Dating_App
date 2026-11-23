# YoUnMe Worker — Unresolved Decisions

This document tracks decisions that must be made before production deployment.

---

## 🟢 RESOLVED: Native Push Notification Provider (Firebase Cloud Messaging)

**Status:** Decided & Implemented.

**Decision:** Firebase Cloud Messaging (FCM) is approved exclusively as the native mobile
push notification delivery provider. Supabase remains the sole authentication and database platform.
No Firebase Auth or Firebase Realtime/Firestore DB is introduced.

**Implementation Summary:**
1. Dedicated queue `younme:push-delivery` added to isolate push delivery latency, retries, and rate limits from in-app notification persistence.
2. `firebase-admin` (v14.5.0) installed and initialized via `src/fcm.ts` singleton.
3. Additive migration added to `database/worker-migration.sql` for `device_tokens` table with RLS.
4. Auto-pruning of stale/unregistered tokens (`messaging/registration-token-not-registered`, `messaging/invalid-registration-token`).
5. Exponential backoff retries for transient FCM provider outages.
6. Privacy-preserving notification payloads (no PII or raw tokens logged).

---

## 🟡 MEDIUM: Cloud Run Deployment Configuration

**Status:** Not verified.

The Dockerfile and worker code are ready for Cloud Run, but the following
infrastructure items must be confirmed:

- [ ] Google Cloud project and region (`asia-south1`) are provisioned.
- [ ] Redis instance (Google Cloud Memorystore for Redis) is provisioned and the
      `REDIS_URL` (private VPC IP) is available.
- [ ] A Cloud Run service for `worker-bullmq` is created separately from the NestJS service.
- [ ] `SUPABASE_SERVICE_ROLE_KEY` is stored in Secret Manager and mounted as an env var.
- [ ] `GOOGLE_APPLICATION_CREDENTIALS` or Workload Identity is configured on the
      Cloud Run service account with `roles/cloudvision.user`.
- [ ] `SUPABASE_STORAGE_BUCKET_PREFIX` is set to the production bucket prefix.
- [ ] Min-instances is set to 1 to avoid cold-start delays on job processing.

---

## 🟡 MEDIUM: NestJS Producer Integration

**Status:** Partial.

The `queue-producer.ts` file provides typed `enqueue*` helper functions.
These are not yet called from the NestJS controllers.

To complete integration:
1. Update `onboarding.controller.ts` — after a photo_url is saved, call `enqueueVisionScan`.
2. Update `chat.controller.ts` — after a Contact Guard block, call `enqueueContactGuardAudit`.
3. Update `discovery.controller.ts` / `chat.controller.ts` — after a match is created,
   call `enqueueNotification` for the matched user.

See `src/queue-producer.ts` for usage examples.

---

## 🟢 LOW: Strike Accumulation / Account Suspension

**Status:** Not implemented.

The contact guard audit table records violations, but the NestJS `chat.controller.ts`
uses an in-memory `userStrikes` map that resets on restart. A persistent strike system
with thresholds and cooldowns requires:

1. A `user_strikes` table (user_id, current_count, last_violation_at, reset_at).
2. Suspension logic in NestJS when a threshold is crossed.
3. Agreement on thresholds (3 strikes? 5 strikes?) — this is a product decision.
