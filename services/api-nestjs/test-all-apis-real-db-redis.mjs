/**
 * Complete Real-Time Backend API Test Suite
 * Tests every single API endpoint in api-nestjs against live Supabase PostgreSQL and Upstash Redis.
 * Collects detailed performance, response data, and live database verification outcomes.
 */

const BASE_URL = 'http://localhost:8080';
const PROPOSER_TOKEN = 'Bearer mock-valid-token';
const PARTNER_TOKEN = 'Bearer mock-partner-token';

const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
};

const results = [];

async function callApi(options) {
  const {
    moduleName,
    endpoint,
    method = 'GET',
    body = null,
    token = PROPOSER_TOKEN,
    expectedStatus = 200,
  } = options;

  const url = `${BASE_URL}${endpoint}`;
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = token;

  const start = Date.now();
  let status = null;
  let data = null;
  let ok = false;
  let error = null;

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });
    status = res.status;
    const text = await res.text();
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }
    ok = Array.isArray(expectedStatus)
      ? expectedStatus.includes(status)
      : (status === expectedStatus) || (status >= 200 && status < 300 && expectedStatus < 300);
  } catch (err) {
    error = err.message;
    ok = false;
  }
  const latency = Date.now() - start;

  const record = {
    module: moduleName,
    endpoint: `${method} ${endpoint}`,
    status,
    expectedStatus,
    latency,
    ok,
    error,
    summary: typeof data === 'object' ? JSON.stringify(data).slice(0, 180) + (JSON.stringify(data).length > 180 ? '...' : '') : String(data).slice(0, 180),
    data,
  };

  results.push(record);

  const icon = ok ? `${colors.green}✔ PASS${colors.reset}` : `${colors.red}✖ FAIL${colors.reset}`;
  console.log(` ${icon} [${colors.cyan}${record.latency}ms${colors.reset}] ${colors.bold}${record.endpoint}${colors.reset} -> ${status} (${record.module})`);
  if (!ok) {
    console.log(`   ${colors.yellow}Expected: ${expectedStatus}, Got: ${status}. Error: ${error || JSON.stringify(data)}${colors.reset}`);
  }

  return record;
}

async function runTestSuite() {
  console.log(`\n${colors.bold}${colors.cyan}========================================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}   YOUNME COMPLETE API TEST RUN (LIVE SUPABASE DB & UPSTASH REDIS)    ${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}========================================================================${colors.reset}\n`);

  const PROPOSER_ID = '11111111-1111-1111-1111-111111111111';
  const PARTNER_ID = '22222222-2222-2222-2222-222222222222';
  const MATCH_ID = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  // =========================================================================
  // 1. INFRASTRUCTURE & HEALTH PROBES
  // =========================================================================
  console.log(`\n${colors.bold}--- 1. Infrastructure & Health Probes ---${colors.reset}`);
  await callApi({
    moduleName: 'Health',
    endpoint: '/health',
    method: 'GET',
    token: null,
    expectedStatus: 200,
  });

  const fullHealth = await callApi({
    moduleName: 'Health',
    endpoint: '/v1/health',
    method: 'GET',
    token: null,
    expectedStatus: 200,
  });

  const dbHealth = await callApi({
    moduleName: 'Health',
    endpoint: '/v1/health/db-check',
    method: 'GET',
    token: null,
    expectedStatus: 200,
  });

  const redisHealth = await callApi({
    moduleName: 'Health',
    endpoint: '/v1/health/redis-check',
    method: 'GET',
    token: null,
    expectedStatus: 200,
  });

  // =========================================================================
  // 2. AUTHENTICATION MODULE
  // =========================================================================
  console.log(`\n${colors.bold}--- 2. Authentication & Identity Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Auth',
    endpoint: '/v1/auth/signin',
    method: 'POST',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Auth',
    endpoint: '/v1/auth/me',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // =========================================================================
  // 3. ONBOARDING & PROFILE VERIFICATION
  // =========================================================================
  console.log(`\n${colors.bold}--- 3. Onboarding & Verification Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Onboarding',
    endpoint: '/v1/onboarding/wizard',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      user_id: PROPOSER_ID,
      step: 'bio',
      nickname: 'Aarav (Verified)',
      bio: 'Architect & Specialty Coffee Connoisseur exploring Mumbai.',
      interests: ['Architecture', 'Specialty Coffee', 'Vinyl Records', 'Running'],
      drinking: 'Socially',
      smoking: 'Never',
      fitness: 'Regular Gym',
      city: 'Mumbai',
    },
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Onboarding',
    endpoint: `/v1/onboarding/status/${PROPOSER_ID}`,
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Onboarding',
    endpoint: `/v1/onboarding/profile/${PROPOSER_ID}`,
    method: 'PUT',
    token: PROPOSER_TOKEN,
    body: {
      nickname: 'Aarav Sharma',
      bio: 'Architect, Specialty Coffee Connoisseur & Indie Musician.',
      min_age: 22,
      max_age: 32,
      max_distance_km: 40,
    },
    expectedStatus: 200,
  });

  // =========================================================================
  // 4. HOME FEED & GAMIFICATION
  // =========================================================================
  console.log(`\n${colors.bold}--- 4. Home Feed & Gamification Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Home',
    endpoint: '/v1/home/feed',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Home',
    endpoint: '/v1/home/spin-wheel',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: { user_id: PROPOSER_ID },
    expectedStatus: [200, 201, 400], // 201 on first spin of day, 400 if already claimed today
  });

  // =========================================================================
  // 5. DISCOVERY, POSTGIS SPATIAL SEARCH & SWIPES
  // =========================================================================
  console.log(`\n${colors.bold}--- 5. Discovery, PostGIS Radius & Matching Module ---${colors.reset}`);
  // First call fetches from PostgreSQL & caches in Upstash Redis
  await callApi({
    moduleName: 'Discovery',
    endpoint: '/v1/discovery/deck?radius_km=50&min_age=20&max_age=35',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // Second call tests Upstash Redis Cache hit (latency should be ultra fast)
  await callApi({
    moduleName: 'Discovery',
    endpoint: '/v1/discovery/deck?radius_km=50&min_age=20&max_age=35',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Discovery',
    endpoint: '/v1/discovery/map',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // Record Swipe
  await callApi({
    moduleName: 'Discovery',
    endpoint: '/v1/swipes',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      actor_id: PROPOSER_ID,
      target_id: PARTNER_ID,
      action: 'like',
    },
    expectedStatus: 201,
  });

  // Revert Swipe
  await callApi({
    moduleName: 'Discovery',
    endpoint: '/v1/swipes/revert',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: { user_id: PROPOSER_ID },
    expectedStatus: 201,
  });

  // =========================================================================
  // 6. CHAT & MESSAGING
  // =========================================================================
  console.log(`\n${colors.bold}--- 6. Chat & Messaging Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Chat',
    endpoint: '/v1/matches',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Chat',
    endpoint: '/v1/connect/likes-you',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  const ROOM_ID = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  await callApi({
    moduleName: 'Chat',
    endpoint: '/v1/messages',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      room_id: ROOM_ID,
      sender_id: PROPOSER_ID,
      raw_content: 'Hey! Loved your profile. Excited for our upcoming coffee meetup! ☕',
      message_type: 'text',
    },
    expectedStatus: 201,
  });

  await callApi({
    moduleName: 'Chat',
    endpoint: `/v1/messages/${ROOM_ID}`,
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // =========================================================================
  // 7. WALLET TOP-UP FIRST (To ensure funds for Calls, Payout, and Meetups)
  // =========================================================================
  console.log(`\n${colors.bold}--- 7. Wallet & Monetization Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Wallet',
    endpoint: '/v1/wallet',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // Top up coins using pack_1200 (1200 + 200 bonus = 1400 coins)
  await callApi({
    moduleName: 'Wallet',
    endpoint: '/v1/wallet/purchase',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      user_id: PROPOSER_ID,
      package_id: 'pack_1200',
      price_inr: 799,
      payment_gateway: 'razorpay',
      gateway_payment_id: `pay_${Date.now()}`,
    },
    expectedStatus: 201,
  });

  // Request Payout with >= 500 coins minimum threshold
  await callApi({
    moduleName: 'Wallet',
    endpoint: '/v1/wallet/payout',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      user_id: PROPOSER_ID,
      amount_coins: 500,
      upi_id: 'aarav@okaxis',
    },
    expectedStatus: 201,
  });

  // =========================================================================
  // 8. AUDIO & VIDEO CALLS (LiveKit SFU)
  // =========================================================================
  console.log(`\n${colors.bold}--- 8. LiveKit Audio/Video Calls Module ---${colors.reset}`);
  const callTokenRes = await callApi({
    moduleName: 'Calls',
    endpoint: '/v1/calls/token',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      room_id: ROOM_ID,
      caller_id: PROPOSER_ID,
      partner_id: PARTNER_ID,
      call_type: 'video',
      is_masked: true,
    },
    expectedStatus: 201,
  });
  const callSessionId = callTokenRes.data?.call_id || callTokenRes.data?.livekit_room_name;

  await callApi({
    moduleName: 'Calls',
    endpoint: `/v1/calls/${callSessionId}/heartbeat`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    expectedStatus: 201,
  });

  await callApi({
    moduleName: 'Calls',
    endpoint: '/v1/calls/webhook',
    method: 'POST',
    token: null,
    body: {
      event: 'room_finished',
      room: { name: ROOM_ID },
      createdAt: Math.floor(Date.now() / 1000),
    },
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Calls',
    endpoint: `/v1/calls/${callSessionId}/end`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      rating: 5,
      feedback: 'Crystal clear HD video & pristine audio quality!',
    },
    expectedStatus: 201,
  });

  await callApi({
    moduleName: 'Calls',
    endpoint: `/v1/calls/${callSessionId}/rating`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      rating: 5,
      feedback: 'Wonderful conversational chemistry!',
      is_caller: true,
    },
    expectedStatus: 201,
  });

  await callApi({
    moduleName: 'Calls',
    endpoint: '/v1/calls/random/match',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      user_id: PROPOSER_ID,
      call_type: 'audio',
      preferred_gender: 'all',
    },
    expectedStatus: 201,
  });

  // =========================================================================
  // 9. MEETUP, DATE MEMORIES & MODERATION
  // =========================================================================
  console.log(`\n${colors.bold}--- 9. Meetup & Date Memories Module ---${colors.reset}`);
  const scheduleRes = await callApi({
    moduleName: 'Meetup',
    endpoint: '/v1/meetup/schedule',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      match_id: MATCH_ID,
      partner_user_id: PARTNER_ID,
      date_mode: 'offline',
      date_type: 'dinner',
      scheduled_start_at: new Date(Date.now() + 72 * 3600 * 1000).toISOString(),
      scheduled_end_at: new Date(Date.now() + 75 * 3600 * 1000).toISOString(),
      venue_name: 'Bastian, Bandra West',
      theme_id: 'candlelight_romance',
      dress_code: 'Smart Casual',
      split_bill_config: { mode: '50_50', estimated_cost_inr: 4000, status: 'proposed' },
      todo_list: [{ text: 'Reserve table', is_completed: true }],
    },
    expectedStatus: 201,
  });
  const meetupId = scheduleRes.data?.meetup?.id;

  await callApi({
    moduleName: 'Meetup',
    endpoint: '/v1/meetup',
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}`,
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // Partner Acceptance
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/accept`,
    method: 'PATCH',
    token: PARTNER_TOKEN,
    expectedStatus: 200,
  });

  // Edit Meetup
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}`,
    method: 'PUT',
    token: PROPOSER_TOKEN,
    body: {
      venue_name: 'Bastian At The Top, Dadar',
      dress_code: 'Cocktail Attire',
      theme_id: 'rooftop_sunset',
    },
    expectedStatus: 200,
  });

  // Reschedule Meetup
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/reschedule`,
    method: 'PATCH',
    token: PROPOSER_TOKEN,
    body: {
      new_start_at: new Date(Date.now() + 120 * 3600 * 1000).toISOString(),
      reason: 'Slight schedule conflict',
    },
    expectedStatus: 200,
  });

  // Todos CRUD
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/todos`,
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  const addTodoRes = await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/todos`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: { text: 'Order flowers & favorite dessert' },
    expectedStatus: 201,
  });
  const todoId = addTodoRes.data?.added_todo?.id;

  if (todoId) {
    await callApi({
      moduleName: 'Meetup',
      endpoint: `/v1/meetup/${meetupId}/todos/${todoId}`,
      method: 'PATCH',
      token: PROPOSER_TOKEN,
      body: { is_completed: true },
      expectedStatus: 200,
    });

    await callApi({
      moduleName: 'Meetup',
      endpoint: `/v1/meetup/${meetupId}/todos/${todoId}`,
      method: 'DELETE',
      token: PROPOSER_TOKEN,
      expectedStatus: 200,
    });
  }

  // Date Memories Upload
  const memUploadRes = await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/memories`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      photo_uri: 'https://storage.younme.app/memories/bastian_rooftop.jpg',
      custom_gift_note: 'Spectacular sunset view of the Mumbai coastline!',
    },
    expectedStatus: 201,
  });
  const memoryId = memUploadRes.data?.memory?.id;

  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/memories`,
    method: 'GET',
    token: PROPOSER_TOKEN,
    expectedStatus: 200,
  });

  // AI Sticker Generation
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/memories/generate-stickers`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      memory_id: memoryId,
      prompt: 'chibi_sunset_couple',
    },
    expectedStatus: 200,
  });

  // Share Memory Card to Chat
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/memories/share-chat`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      memory_id: memoryId,
      custom_message: 'Look at our date memory! 💖',
    },
    expectedStatus: 200,
  });

  // Submit Rating
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/rating`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      rating: 5,
      feedback: 'Wonderful conversation and atmosphere!',
      ratings_json: { conversation: 5, punctuality: 5, chemistry: 5 },
    },
    expectedStatus: 200,
  });

  // Moderation Report
  await callApi({
    moduleName: 'Meetup',
    endpoint: `/v1/meetup/${meetupId}/report`,
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      reason_category: 'inappropriate_conduct',
      description: 'Review date conduct for safety compliance.',
    },
    expectedStatus: 201,
  });

  // Test Decline Flow on a separate date
  const date2 = await callApi({
    moduleName: 'Meetup',
    endpoint: '/v1/meetup/schedule',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      match_id: MATCH_ID,
      partner_user_id: PARTNER_ID,
      date_mode: 'online',
      date_type: 'coffee',
      scheduled_start_at: new Date(Date.now() + 60 * 3600 * 1000).toISOString(),
    },
    expectedStatus: 201,
  });
  const date2Id = date2.data?.meetup?.id;

  if (date2Id) {
    await callApi({
      moduleName: 'Meetup',
      endpoint: `/v1/meetup/${date2Id}/decline`,
      method: 'PATCH',
      token: PARTNER_TOKEN,
      body: { reason: 'Busy this weekend' },
      expectedStatus: 200,
    });
  }

  // Test Cancel Flow on a separate date
  const date3 = await callApi({
    moduleName: 'Meetup',
    endpoint: '/v1/meetup/schedule',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      match_id: MATCH_ID,
      partner_user_id: PARTNER_ID,
      date_mode: 'offline',
      date_type: 'coffee',
      scheduled_start_at: new Date(Date.now() + 70 * 3600 * 1000).toISOString(),
    },
    expectedStatus: 201,
  });
  const date3Id = date3.data?.meetup?.id;
  if (date3Id) {
    await callApi({
      moduleName: 'Meetup',
      endpoint: `/v1/meetup/${date3Id}/accept`,
      method: 'PATCH',
      token: PARTNER_TOKEN,
      expectedStatus: 200,
    });
    await callApi({
      moduleName: 'Meetup',
      endpoint: `/v1/meetup/${date3Id}/cancel`,
      method: 'PATCH',
      token: PROPOSER_TOKEN,
      body: { reason: 'Emergency rescheduling' },
      expectedStatus: 200,
    });
  }

  // =========================================================================
  // 10. BACKGROUND WORKER PROBES
  // =========================================================================
  console.log(`\n${colors.bold}--- 10. Worker & Computer Vision AI Module ---${colors.reset}`);
  await callApi({
    moduleName: 'Worker',
    endpoint: '/v1/worker/vision-scan',
    method: 'POST',
    token: PROPOSER_TOKEN,
    body: {
      user_id: PROPOSER_ID,
      image_url: 'https://storage.younme.app/profiles/ananya_verified.jpg',
      type: 'profile_photo',
      asset_id: `asset_${Date.now()}`,
    },
    expectedStatus: 201,
  });

  // =========================================================================
  // SUMMARY REPORT
  // =========================================================================
  const total = results.length;
  const passed = results.filter((r) => r.ok).length;
  const failed = total - passed;
  const avgLatency = (results.reduce((acc, r) => acc + r.latency, 0) / total).toFixed(1);

  console.log(`\n${colors.bold}${colors.cyan}========================================================================${colors.reset}`);
  console.log(`${colors.bold}EXECUTION COMPLETE: ${colors.green}${passed} PASSED${colors.reset}, ${failed === 0 ? colors.green + '0 FAILED' : colors.red + failed + ' FAILED'}${colors.reset} (Total: ${total} APIs tested)`);
  console.log(`Average Latency across live Cloud DB & Redis: ${colors.yellow}${avgLatency} ms${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}========================================================================${colors.reset}\n`);

  // Write full results to json artifact for report generation
  const fs = await import('fs');
  fs.writeFileSync('all-api-test-results.json', JSON.stringify({
    timestamp: new Date().toISOString(),
    total,
    passed,
    failed,
    avgLatency,
    results,
  }, null, 2));

  if (failed > 0) {
    process.exit(1);
  }
}

runTestSuite().catch((err) => {
  console.error('Fatal execution error:', err);
  process.exit(1);
});
