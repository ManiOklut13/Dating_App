/**
 * Comprehensive API Test Runner for YoUnMe NestJS Core API
 * Executes tests against all registered endpoints on http://localhost:8080
 */

const BASE_URL = process.env.API_BASE_URL || 'http://localhost:8080';
const DEV_TOKEN = 'mock-valid-token';
const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';
const TEST_PARTNER_ID = '22222222-2222-2222-2222-222222222222';
const SEEDED_ROOM_ID = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

const results = [];

async function testEndpoint({
  name,
  method,
  path,
  body = null,
  auth = true,
  expectedStatuses = [200, 201],
}) {
  const url = `${BASE_URL}${path}`;
  const headers = {};

  if (auth) {
    headers['Authorization'] = `Bearer ${DEV_TOKEN}`;
  }

  if (body) {
    headers['Content-Type'] = 'application/json';
  }

  const startTime = Date.now();
  let status = 0;
  let responseData = null;
  let pass = false;
  let errorMsg = null;

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });
    status = res.status;
    const latency = Date.now() - startTime;
    const text = await res.text();

    try {
      responseData = JSON.parse(text);
    } catch {
      responseData = text;
    }

    pass = expectedStatuses.includes(status);
    if (!pass) {
      errorMsg = typeof responseData === 'object' ? JSON.stringify(responseData) : String(responseData);
    }

    const testItem = {
      name,
      method,
      path,
      auth: auth ? 'Bearer' : 'None',
      status,
      expected: expectedStatuses.join('/'),
      latencyMs: latency,
      pass,
      errorMsg,
      data: responseData,
    };
    results.push(testItem);
    return testItem;
  } catch (err) {
    const latency = Date.now() - startTime;
    const testItem = {
      name,
      method,
      path,
      auth: auth ? 'Bearer' : 'None',
      status: 'ERR',
      expected: expectedStatuses.join('/'),
      latencyMs: latency,
      pass: false,
      errorMsg: err.message,
      data: null,
    };
    results.push(testItem);
    return testItem;
  }
}

async function runAllTests() {
  console.log('='.repeat(80));
  console.log(`🚀 Starting Comprehensive API Tests against: ${BASE_URL}`);
  console.log('='.repeat(80));

  // 1. Root / Infrastructure
  await testEndpoint({
    name: '1. Root Health Probe',
    method: 'GET',
    path: '/health',
    auth: false,
    expectedStatuses: [200],
  });

  // 2. Auth Security Guard Check (Unauthenticated request should return 401)
  await testEndpoint({
    name: '2. Auth Guard Security (No Token -> 401)',
    method: 'GET',
    path: '/v1/auth/me',
    auth: false,
    expectedStatuses: [401],
  });

  // 3. Auth Sign In
  await testEndpoint({
    name: '3. Auth: Sign In via Supabase Token',
    method: 'POST',
    path: '/v1/auth/signin',
    auth: true,
    expectedStatuses: [200],
  });

  // 4. Auth Get Current User
  await testEndpoint({
    name: '4. Auth: Get Current User Profile',
    method: 'GET',
    path: '/v1/auth/me',
    auth: true,
    expectedStatuses: [200],
  });

  // 5. Onboarding Status
  await testEndpoint({
    name: '5. Onboarding: Get Verification & Completion Status',
    method: 'GET',
    path: `/v1/onboarding/status/${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 6. Onboarding Wizard Submit
  await testEndpoint({
    name: '6. Onboarding: Submit Wizard Step (Basic Info)',
    method: 'POST',
    path: '/v1/onboarding/wizard',
    body: {
      step: 'basic_info',
      nickname: 'Aarav',
      city: 'Mumbai',
      bio: 'Coffee lover, photographer & traveller',
    },
    auth: true,
    expectedStatuses: [200],
  });

  // 6b. Onboarding Profile PUT Update
  await testEndpoint({
    name: '6b. Onboarding: PUT Idempotent Profile Update in DB',
    method: 'PUT',
    path: `/v1/onboarding/profile/${TEST_USER_ID}`,
    body: {
      bio: 'Updated bio: Tech founder, runner & photographer',
      city: 'South Mumbai',
    },
    auth: true,
    expectedStatuses: [200],
  });

  // 7. Home Feed
  await testEndpoint({
    name: '7. Home: Get User Feed & Daily Highlights',
    method: 'GET',
    path: `/v1/home/feed?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 8. Home Spin Wheel
  await testEndpoint({
    name: '8. Home: Spin Daily Reward Wheel',
    method: 'POST',
    path: '/v1/home/spin-wheel',
    body: { user_id: TEST_USER_ID },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 9. Discovery Candidate Deck
  await testEndpoint({
    name: '9. Discovery: Get Candidate Profiles Deck',
    method: 'GET',
    path: `/v1/discovery/deck?radius_km=50&min_age=18&max_age=35`,
    auth: true,
    expectedStatuses: [200],
  });

  // 10. Discovery Map Radar
  await testEndpoint({
    name: '10. Discovery: Get Interactive Geo Radar Map',
    method: 'GET',
    path: `/v1/discovery/map?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 11. Discovery Swipe
  await testEndpoint({
    name: '11. Discovery: Record Candidate Swipe Action (Like)',
    method: 'POST',
    path: '/v1/swipes',
    body: {
      target_id: TEST_PARTNER_ID,
      action: 'like',
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 12. Discovery Revert Swipe
  await testEndpoint({
    name: '12. Discovery: Revert Last Swipe Action (Rewind)',
    method: 'POST',
    path: '/v1/swipes/revert',
    body: { user_id: TEST_USER_ID },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 13. Chat Matches
  await testEndpoint({
    name: '13. Chat: Get Mutual Matches List',
    method: 'GET',
    path: `/v1/matches?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 14. Chat Likes You
  await testEndpoint({
    name: '14. Chat: Get Incoming Likes Profiles (Likes You)',
    method: 'GET',
    path: `/v1/connect/likes-you?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 15. Chat Messages History
  await testEndpoint({
    name: '15. Chat: Get Conversation Room Messages',
    method: 'GET',
    path: `/v1/messages/${SEEDED_ROOM_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 16. Chat Send Message
  await testEndpoint({
    name: '16. Chat: Send Instant Message',
    method: 'POST',
    path: '/v1/messages',
    body: {
      room_id: SEEDED_ROOM_ID,
      raw_content: 'Hey there! Nice to connect with you.',
      message_type: 'text',
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 17. Wallet Info & Catalog
  await testEndpoint({
    name: '17. Wallet: Get Coin Balance & Coin Packs Catalog',
    method: 'GET',
    path: `/v1/wallet?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 18. Wallet Purchase Package (Pack 500 gives +550 coins ensuring balance >= 500 for payout)
  await testEndpoint({
    name: '18. Wallet: Purchase Coin Package via Razorpay',
    method: 'POST',
    path: '/v1/wallet/purchase',
    body: {
      package_id: 'pack_500',
      razorpay_payment_id: `pay_test_${Date.now()}`,
      idempotency_key: `test_tx_${Date.now()}`,
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 19. Wallet Request Payout (>= 500 minimum coin threshold)
  await testEndpoint({
    name: '19. Wallet: Request Creator Cashout Payout',
    method: 'POST',
    path: '/v1/wallet/payout',
    body: {
      coins_to_withdraw: 500,
      upi_id: 'aarav@okaxis',
      idempotency_key: `payout_${Date.now()}`,
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 20. Calls LiveKit Token
  const tokenTest = await testEndpoint({
    name: '20. Calls: Provision LiveKit WebRTC Token',
    method: 'POST',
    path: '/v1/calls/token',
    body: {
      callee_id: TEST_PARTNER_ID,
      kind: 'audio',
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  const activeCallId = tokenTest.data?.call_id || `call_${Date.now()}`;

  // 21. Calls Heartbeat (using the active provisioned call session ID)
  await testEndpoint({
    name: '21. Calls: Billing Heartbeat (Per-minute)',
    method: 'POST',
    path: `/v1/calls/${activeCallId}/heartbeat`,
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 22. Calls Webhook (LiveKit server-to-server)
  await testEndpoint({
    name: '22. Calls: Public LiveKit Webhook Handler',
    method: 'POST',
    path: '/v1/calls/webhook',
    body: {
      event: 'participant_joined',
      room: { name: 'rm_test_room' },
      participant: { identity: TEST_USER_ID },
    },
    auth: false,
    expectedStatuses: [200],
  });

  // 23. Calls End Call
  await testEndpoint({
    name: '23. Calls: End Active Call Session',
    method: 'POST',
    path: `/v1/calls/${activeCallId}/end`,
    body: {
      rating: 5,
      feedback: 'Excellent audio quality and low latency',
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 24. Calls Submit Rating
  await testEndpoint({
    name: '24. Calls: Submit Call Rating & Review',
    method: 'POST',
    path: `/v1/calls/${activeCallId}/rating`,
    body: {
      rating: 5,
      feedback: 'Smooth connection without jitters',
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 25. Calls Random Speed Dating Match
  await testEndpoint({
    name: '25. Calls: Queue for Random Speed Dating Match',
    method: 'POST',
    path: '/v1/calls/random/match',
    body: { kind: 'audio' },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 26. Meetup Schedule
  const scheduleTest = await testEndpoint({
    name: '26. Meetup: Schedule Real-Life Date',
    method: 'POST',
    path: '/v1/meetup/schedule',
    body: {
      match_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      proposer_user_id: TEST_USER_ID,
      partner_user_id: TEST_PARTNER_ID,
      date_mode: 'offline',
      date_type: 'coffee',
      scheduled_start_at: new Date(Date.now() + 86400000).toISOString(),
      venue_name: 'Blue Tokai Cafe, Bandra West',
      dress_code: 'Smart Casual',
    },
    auth: true,
    expectedStatuses: [201],
  });

  const activeMeetupId = scheduleTest.data?.meetup?.id || `meetup_seed_1`;

  // 27. Meetup List
  await testEndpoint({
    name: '27. Meetup: List User Meetups',
    method: 'GET',
    path: `/v1/meetup?user_id=${TEST_USER_ID}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 28. Meetup Get by ID
  await testEndpoint({
    name: '28. Meetup: Get Meetup Details by ID',
    method: 'GET',
    path: `/v1/meetup/${activeMeetupId}`,
    auth: true,
    expectedStatuses: [200],
  });

  // 29. Meetup Update Status (PATCH)
  await testEndpoint({
    name: '29. Meetup: Update Date Status (PATCH)',
    method: 'PATCH',
    path: `/v1/meetup/${activeMeetupId}/status`,
    body: { status: 'completed' },
    auth: true,
    expectedStatuses: [200],
  });

  // 29b. Meetup Update Status (PUT)
  await testEndpoint({
    name: '29b. Meetup: PUT Update Date Status in DB',
    method: 'PUT',
    path: `/v1/meetup/${activeMeetupId}/status`,
    body: { status: 'completed' },
    auth: true,
    expectedStatuses: [200],
  });

  // 30. Meetup Split Bill
  await testEndpoint({
    name: '30. Meetup: Update Split Bill Arrangement',
    method: 'POST',
    path: `/v1/meetup/${activeMeetupId}/split-bill`,
    body: {
      split_bill_config: {
        mode: '50_50',
        estimated_cost_inr: 1200,
        status: 'agreed',
      },
    },
    auth: true,
    expectedStatuses: [200, 201],
  });

  // 31. Meetup Submit Rating
  await testEndpoint({
    name: '31. Meetup: Post-Date Rating and Feedback',
    method: 'POST',
    path: `/v1/meetup/${activeMeetupId}/rating`,
    body: {
      rating: 5,
      user_id: TEST_USER_ID,
      feedback: 'Had a wonderful time and great conversations!',
    },
    auth: true,
    expectedStatuses: [200],
  });

  // 32. Meetup Add Memories
  await testEndpoint({
    name: '32. Meetup: Add Date Memory Photo & Note',
    method: 'POST',
    path: `/v1/meetup/${activeMeetupId}/memories`,
    body: {
      photo_uri: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38',
      custom_note: 'Unforgettable evening at Blue Tokai!',
    },
    auth: true,
    expectedStatuses: [201],
  });

  // 33. Worker Vision Scan Dispatch
  // Expected: 200/201 if BullMQ worker is up, or 503 Service Unavailable if background worker is offline.
  await testEndpoint({
    name: '33. Worker: Vision Scan Media Dispatch',
    method: 'POST',
    path: '/v1/worker/vision-scan',
    body: {
      asset_id: 'ast_test_photo_01',
      user_id: TEST_USER_ID,
      image_url: 'https://example.com/profile.jpg',
      type: 'profile_photo',
    },
    auth: true,
    expectedStatuses: [200, 201, 503],
  });

  // Print Summary Table
  console.log('\n' + '='.repeat(80));
  console.log('📊 TEST EXECUTION SUMMARY REPORT');
  console.log('='.repeat(80));

  let passedCount = 0;
  let failedCount = 0;

  for (const r of results) {
    const symbol = r.pass ? '✅ PASS' : '❌ FAIL';
    if (r.pass) passedCount++;
    else failedCount++;

    const latency = `${r.latencyMs}ms`.padStart(7);
    const code = `[${r.status}]`.padEnd(6);
    console.log(
      `${symbol} | ${code} | ${latency} | ${r.method.padEnd(5)} | ${r.path.padEnd(46)} | ${r.name}`,
    );
    if (!r.pass && r.errorMsg) {
      console.log(`   └─ Error: ${r.errorMsg}`);
    }
  }

  console.log('='.repeat(80));
  console.log(
    `Total: ${results.length} | Passed: ${passedCount} | Failed: ${failedCount} | Pass Rate: ${(
      (passedCount / results.length) *
      100
    ).toFixed(1)}%`,
  );
  console.log('='.repeat(80));
}

runAllTests().catch((err) => {
  console.error('Fatal error during test execution:', err);
  process.exit(1);
});
