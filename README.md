# YoUnMe Dating App — Master Technical Architecture & Core MVP (v3.2)

> **Production Topology:** Google Cloud Run Tri-Microservices (`asia-south1` Mumbai)  
> **Backend Stack:** Node.js / NestJS API • Go Real-Time Engine • Cloud Run Worker (BullMQ + Redis)  
> **Database & Spatial:** Supabase Pro Managed PostgreSQL + PostGIS (`ST_DWithin` & Spatial Indexing)  
> **Media & Communications:** LiveKit Cloud WebRTC SFU • Twilio WhatsApp OTP (Firebase SMS Fallback)  
> **Client Applications:** Cross-Platform Web MVP & Flutter Mobile Client (iOS & Android)  

---

## 1. Executive Summary & Architecture Overview

YoUnMe is a high-concurrency, mobile-first social discovery platform engineered on a containerized microservices topology. The platform decouples synchronous stateless operations, persistent high-throughput WebSocket streams, and asynchronous worker queues:

```
                                 [ Cloudflare Edge & DDoS WAF ]
                                                │
                                                ▼
                                [ Google Cloud Load Balancer ]
                                 /            │            \
                     /v1/*      /             │ /ws/*       \  async queues
                               ▼              ▼              ▼
                     [ NestJS Core API ]  [ Go Engine ]  [ BullMQ Worker ]
                       (0.25 vCPU, 512M)    (1.0 vCPU, 1G)   (1.0 vCPU, 512M)
                               │              │              │
                               ▼              ▼              ▼
                     [ Supabase PostgreSQL ]  [ Memorystore Redis ]  [ Google Cloud Vision ]
                       (PostGIS ST_DWithin)     (Basic Tier 1 GiB)     (SafeSearch & OCR)
                               │                                     │
                     [ Double-Entry Ledger ]               [ LiveKit WebRTC SFU ]
```

---

## 2. Domain Microservices & Module Inventory

| Microservice | Technology & Runtime | Key Responsibilities | Service SLA |
| :--- | :--- | :--- | :--- |
| **API Backend** | Node.js / NestJS • Cloud Run `0.25 vCPU, 512 MiB` | User Onboarding, Dual JWT Auth, Swipe limits, Profile settings, Wallet Double-Entry Ledger, LiveKit token issuance | P0 (< 300ms) |
| **Real-Time Engine** | Go (Golang) • Cloud Run `1.0 vCPU, 1.0 GiB` | High-concurrency WebSockets (`/ws/*`), Presence heartbeats, Matchmaking queue, In-flight Contact & Link Guard | P0 (< 200ms) |
| **Background Worker** | Node.js + BullMQ • Cloud Run `1.0 vCPU, 512 MiB` | Asynchronous Google Cloud Vision API scans (Image OCR & SafeSearch), Batch push notifications (FCM/APNs) | P1 (< 1s dispatch) |
| **Database** | Supabase Pro Managed PostgreSQL + PostGIS | System of record: `users`, `profiles`, `swipes`, `matches`, `messages`, `calls`, `wallets`, `transactions` | P0 (< 50ms) |

---

## 3. Database Schema (PostgreSQL + PostGIS)

### Tables & Key Constraints:
- `users`: UUID PK, Phone (UNIQUE), Email, Google ID, DOB, Gender, `is_verified` (Blue Tick flag), Status.
- `profiles`: PostGIS geometry point (`geometry(Point, 4326)`), `photo_urls` (text array: 6 photos + 1 appearance avatar), `call_avatar_ref`, `profile_progress` (0-100%).
- `swipes`: Actor ID, Target ID, Action (`like`, `dislike`, `spark`, `snooze`), Compound Index on `(actor_id, target_id)`.
- `matches`: User A, User B (UNIQUE pair), Matched At, Source (`swipe`, `call`, `spark`), `message_pair_count`.
- `messages`: Conv ID, Sender ID, Type (`text`, `bitmoji`, `audio`), Body (encrypted text), Vanish mode `expires_at`, `is_flagged`.
- `calls`: Caller ID, Callee ID, Kind (`audio`, `video`, `random`), `livekit_room_sid`, `duration_s`, `cost_coins`, Status.
- `wallets`: User ID PK, Balance (`CHECK (balance >= 0)`), Updated At.
- `transactions`: Append-only double-entry ledger, Type (`grant`, `purchase`, `spend`, `earn`, `payout`), `idempotency_key` (UNIQUE).

### Stored Database Functions:
- `fn_execute_coin_transaction(p_user_id, p_type, p_coins, p_reference_id, p_idempotency_key)`: Atomic debit/credit guaranteeing zero double-spending with row-level locks.
- `fn_record_swipe(p_actor_id, p_target_id, p_action)`: Instant reciprocal match detection returning match UUID upon mutual swipe.
- `fn_get_nearby_candidates(p_user_id, p_max_distance_meters, p_limit)`: PostGIS `ST_DWithin` spatial query sorted by geodesic distance.

---

## 4. Monetization, Coin Ledger & Creator Economy

The coin economy operates under strict server-authoritative rules:

| Interaction Category | Male Account Action (Spend) | Female Creator Action (Earn) | Platform Verification & System Rules |
| :--- | :--- | :--- | :--- |
| **Random Audio Call** | 20 coins / minute | 5 coins / minute | Wallet pre-authorized; server-side 60s tick deduction via LiveKit webhook. |
| **Random Video Call** | 50 coins / minute | 10 coins / minute | Mandatory Google Cloud Vision preview scan; automated per-minute tick deduction. |
| **Revert Swipe** | 5 coins / action (10 free/day) | N/A (System item) | Restores previous candidate card in Redis deck; daily quota resets midnight. |
| **Spark / Mega-Crush**| 15 coins / action (20 free/day)| N/A (System item) | Bypasses candidate stack; delivers immediate high-priority push notification. |
| **Direct Message Request** | 20 coins / request (15 free/day)| 5 coins credited | Enforces 150-char text limit, Bitmoji gift, or 2-minute encrypted audio note. |
| **Creator Cash-Out** | N/A | Fixed token-to-payout conversion | Available strictly to verified profiles with >500 coins via secure payout webhook. |

---

## 5. Trust, Safety & In-Flight Security Pipeline

- **Google Cloud Vision API**: Safe Search explicit content filtering and text OCR detection to block contact leaks in profile photos.
- **Contact & Link Guard**: Intercepts phone numbers, WhatsApp, Telegram, Instagram handles, and external URLs.  
  *Unlock Threshold:* Automatically unlocks after **3 days of active matching** OR **20 message pairs exchanged**.
- **9-Step Onboarding Verification**: Automatically awards the **Blue Tick Verified Badge** when profile completion reaches **70%+** with facial liveness verification.

---

## 6. Quickstart: Running the MVP Locally

### Prerequisites:
- Node.js `v20+` (tested on Node.js `v24`)
- npm `10+`

### Step 1: Install Dependencies
```bash
# In services/api-nestjs:
npm install

# In client:
npm install
```

### Step 2: Start All Services
```bash
npm run dev
# Or run backend and frontend separately:
# Terminal 1: npm --prefix services/api-nestjs run start
# Terminal 2: npm --prefix client run dev
```

### Step 3: Open the Application
Navigate to `http://localhost:5173` in your web browser.
- **Discovery Tab:** Gesture swipe cards, test Revert (restores card), Spark, or Like (triggers mutual match!).
- **Connect Tab:** View mutual matches and 'Likes You' blurred stack.
- **Chat Tab:** Test 1-on-1 messaging, vanish mode, voice notes, and test the **Contact Guard** (try sending a phone number or Instagram handle to see real-time blocking).
- **LiveKit Calls Tab:** Test blind audio/video calls with live **60-second billing heartbeat ticks** deducting coins in real time!
- **Profile & Ledger Tab:** Inspect 9-step verification status, verified Blue Tick, and audit the immutable transaction ledger.

---

## 7. GCP Cloud Run Production Deployment (Mumbai `asia-south1`)

Deploy the tri-microservices directly to GCP:
```bash
export GCP_PROJECT_ID="your-gcp-project-id"
chmod +x scripts/gcp_deploy.sh
./scripts/gcp_deploy.sh
```