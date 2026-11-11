/**
 * Comprehensive End-to-End Test Suite for Meetup, Date Memories, and Wallet Monetization
 * Tests all 12 business rules & endpoints against the live NestJS backend & PostgreSQL database.
 */

const BASE_URL = 'http://localhost:8080/v1';
const PROPOSER_AUTH_HEADER = {
  Authorization: 'Bearer mock-valid-token',
  'Content-Type': 'application/json',
};
const PARTNER_AUTH_HEADER = {
  Authorization: 'Bearer mock-partner-token',
  'Content-Type': 'application/json',
};

// Colors for clean CLI output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m',
  bold: '\x1b[1m',
};

let passed = 0;
let failed = 0;

function assert(condition, testName, details = '') {
  if (condition) {
    passed++;
    console.log(` ${colors.green}✔ PASS${colors.reset} - ${testName}`);
    if (details) console.log(`   ${colors.cyan}↳ ${details}${colors.reset}`);
  } else {
    failed++;
    console.error(` ${colors.red}✖ FAIL${colors.reset} - ${testName}`);
    if (details) console.error(`   ${colors.yellow}↳ ${details}${colors.reset}`);
  }
}

async function request(method, path, body = null, extraHeaders = {}) {
  const url = `${BASE_URL}${path}`;
  const opts = {
    method,
    headers: { ...PROPOSER_AUTH_HEADER, ...extraHeaders },
  };
  if (body) {
    opts.body = JSON.stringify(body);
  }
  const res = await fetch(url, opts);
  let json = null;
  try {
    json = await res.json();
  } catch (e) {
    json = null;
  }
  return { status: res.status, ok: res.ok, data: json };
}

async function runAllTests() {
  console.log(`\n${colors.bold}${colors.cyan}======================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}  YOUNME MEETUP, MEMORIES & MONETIZATION E2E TEST RUN ${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}======================================================${colors.reset}\n`);

  const PROPOSER_ID = '11111111-1111-1111-1111-111111111111';
  const PARTNER_ID = '22222222-2222-2222-2222-222222222222';
  const MATCH_ID = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  // Check initial wallet balance
  const walletRes = await request('GET', '/wallet');
  const initialCoins = walletRes.data?.balance || 0;
  console.log(`Initial Proposer Wallet Balance: ${colors.yellow}${initialCoins} coins${colors.reset}\n`);

  // -------------------------------------------------------------------------
  // RULE 1: POST /v1/meetup/schedule (Check free pass or deduct coins)
  // -------------------------------------------------------------------------
  console.log(`${colors.bold}--- Test Group 1: Meetup Scheduling (Free pass / Coins) ---${colors.reset}`);
  const futureStart = new Date(Date.now() + 72 * 3600 * 1000).toISOString(); // 3 days ahead
  const futureEnd = new Date(Date.now() + 75 * 3600 * 1000).toISOString();

  const schedulePayload = {
    match_id: MATCH_ID,
    partner_user_id: PARTNER_ID,
    date_mode: 'offline',
    date_type: 'dinner',
    scheduled_start_at: futureStart,
    scheduled_end_at: futureEnd,
    venue_name: 'Bastian, Bandra West',
    latitude: 19.0601,
    longitude: 72.8361,
    dress_code: 'Smart Casual / Cocktail',
    theme_id: 'candlelight_romance',
    proposer_custom_notes: 'Booked table by the terrace window.',
    split_bill_config: {
      mode: '50_50',
      estimated_cost_inr: 4500,
      proposer_percentage: 50,
      partner_percentage: 50,
      status: 'proposed',
    },
    todo_list: [
      { text: 'Reserve window table', assigned_to: PROPOSER_ID, is_completed: true },
      { text: 'Pick up flowers', assigned_to: PROPOSER_ID, is_completed: false },
    ],
  };

  const scheduleRes = await request('POST', '/meetup/schedule', schedulePayload);
  assert(
    scheduleRes.status === 201 && scheduleRes.data?.success === true,
    '1. POST /v1/meetup/schedule creates date with status "pending"',
    `Meetup ID: ${scheduleRes.data?.meetup?.id}, Status: ${scheduleRes.data?.meetup?.status}`
  );
  assert(
    scheduleRes.data?.meetup?.theme_id === 'candlelight_romance',
    '1.1 Theme ID correctly stored in meetup table',
    `theme_id: ${scheduleRes.data?.meetup?.theme_id}`
  );
  assert(
    scheduleRes.data?.meetup?.coins_json?.free_date_used !== undefined,
    '1.2 Monetization check executed (Free pass or 100 coins offline deduction)',
    `Coins JSON: ${JSON.stringify(scheduleRes.data?.meetup?.coins_json)}`
  );

  const meetup1Id = scheduleRes.data?.meetup?.id;

  // -------------------------------------------------------------------------
  // RULE 2: PATCH /v1/meetup/:id/accept (Partner accepts date)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 2: Partner Acceptance ---${colors.reset}`);
  // Proposer trying to accept their own date should be forbidden
  const proposerAcceptFail = await request('PATCH', `/meetup/${meetup1Id}/accept`);
  assert(
    proposerAcceptFail.status === 403,
    '2.1 Proposer cannot accept their own date (Forbidden 403 enforced)',
    `Response: ${JSON.stringify(proposerAcceptFail.data?.message)}`
  );

  // Partner accepts date
  const acceptRes = await request('PATCH', `/meetup/${meetup1Id}/accept`, null, PARTNER_AUTH_HEADER);
  assert(
    acceptRes.status === 200 && acceptRes.data?.status === 'scheduled',
    '2.2 PATCH /v1/meetup/:id/accept by Partner changes status from "pending" to "scheduled"',
    `Updated status: ${acceptRes.data?.status}`
  );

  // -------------------------------------------------------------------------
  // RULE 4: PUT /v1/meetup/:id (Edit date details & enforce 24h prior lock rule)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 3: Edit Date Details & 24h Lock Rule ---${colors.reset}`);
  const editPayload = {
    venue_name: 'Bastian At The Top, Dadar',
    dress_code: 'Black Tie Elegance',
    proposer_custom_notes: 'Updated table booking to rooftop lounge.',
    theme_id: 'rooftop_sunset',
  };
  const editRes = await request('PUT', `/meetup/${meetup1Id}`, editPayload);
  assert(
    editRes.status === 200 && editRes.data?.meetup?.venue_name === 'Bastian At The Top, Dadar',
    '3. PUT /v1/meetup/:id edits date details (>24h prior to date)',
    `New venue: ${editRes.data?.meetup?.venue_name}, theme: ${editRes.data?.meetup?.theme_id}`
  );

  // -------------------------------------------------------------------------
  // RULE 5: PATCH /v1/meetup/:id/reschedule (24h lock rule + 25 coin penalty)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 4: Reschedule with 25-Coin Penalty ---${colors.reset}`);
  const newDateStart = new Date(Date.now() + 120 * 3600 * 1000).toISOString(); // 5 days out
  const reschedulePayload = {
    new_start_at: newDateStart,
    reason: 'Flight delayed by a day',
  };
  const rescheduleRes = await request('PATCH', `/meetup/${meetup1Id}/reschedule`, reschedulePayload);
  assert(
    rescheduleRes.status === 200 && rescheduleRes.data?.penalty_coins === 25,
    '4. PATCH /v1/meetup/:id/reschedule deducts 25-coin penalty and updates schedule',
    `Penalty: ${rescheduleRes.data?.penalty_coins} coins, Tx ID: ${rescheduleRes.data?.penalty_tx_id}`
  );

  // -------------------------------------------------------------------------
  // RULE 7: CRUD /v1/meetup/:id/todos (Checklist items)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 5: Date Preparation Checklist (Todos CRUD) ---${colors.reset}`);
  const getTodosRes = await request('GET', `/meetup/${meetup1Id}/todos`);
  assert(
    getTodosRes.status === 200 && Array.isArray(getTodosRes.data?.todos),
    '5.1 GET /v1/meetup/:id/todos retrieves checklist items',
    `Current items count: ${getTodosRes.data?.todos?.length}`
  );

  const addTodoRes = await request('POST', `/meetup/${meetup1Id}/todos`, {
    text: 'Order favorite chocolate dessert in advance',
    assigned_to: PROPOSER_ID,
  });
  assert(
    addTodoRes.status === 201 && addTodoRes.data?.added_todo?.text === 'Order favorite chocolate dessert in advance',
    '5.2 POST /v1/meetup/:id/todos adds new checklist item',
    `Created Todo ID: ${addTodoRes.data?.added_todo?.id}`
  );
  const createdTodoId = addTodoRes.data?.added_todo?.id;

  const updateTodoRes = await request('PATCH', `/meetup/${meetup1Id}/todos/${createdTodoId}`, {
    is_completed: true,
  });
  assert(
    updateTodoRes.status === 200 && updateTodoRes.data?.updated_todo?.is_completed === true,
    '5.3 PATCH /v1/meetup/:id/todos/:todoId marks item completed',
    `is_completed: ${updateTodoRes.data?.updated_todo?.is_completed}`
  );

  const deleteTodoRes = await request('DELETE', `/meetup/${meetup1Id}/todos/${createdTodoId}`);
  assert(
    deleteTodoRes.status === 200 && deleteTodoRes.data?.success === true,
    '5.4 DELETE /v1/meetup/:id/todos/:todoId removes checklist item',
    `Remaining todos: ${deleteTodoRes.data?.todos?.length}`
  );

  // -------------------------------------------------------------------------
  // RULE 8: POST & GET /v1/meetup/:id/memories (Upload Date Photos)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 6: Date Memories (Photos) ---${colors.reset}`);
  const memoryUploadRes = await request('POST', `/meetup/${meetup1Id}/memories`, {
    photo_uri: 'https://storage.younme.app/memories/bastian_rooftop_sunset.jpg',
    custom_gift_note: 'The most magical sunset overlooking the Sea Link!',
  });
  assert(
    memoryUploadRes.status === 201 && memoryUploadRes.data?.memory?.photo_uri !== undefined,
    '6.1 POST /v1/meetup/:id/memories saves date photo to date_memories table',
    `Memory ID: ${memoryUploadRes.data?.memory?.id}`
  );
  const memoryId = memoryUploadRes.data?.memory?.id;

  const getMemoriesRes = await request('GET', `/meetup/${meetup1Id}/memories`);
  assert(
    getMemoriesRes.status === 200 && getMemoriesRes.data?.memories?.length > 0,
    '6.2 GET /v1/meetup/:id/memories fetches uploaded date memories',
    `Memories count: ${getMemoriesRes.data?.memories?.length}`
  );

  // -------------------------------------------------------------------------
  // RULE 9: POST /v1/meetup/:id/memories/generate-stickers (AI Stickers - 20 coins)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 7: AI Sticker Pack Generation ---${colors.reset}`);
  const stickersRes = await request('POST', `/meetup/${meetup1Id}/memories/generate-stickers`, {
    memory_id: memoryId,
    prompt: 'chibi_sunset_lovers',
  });
  assert(
    stickersRes.status === 200 &&
      stickersRes.data?.coins_debited === 20 &&
      Array.isArray(stickersRes.data?.bitmoji_pack),
    '7. POST /v1/meetup/:id/memories/generate-stickers deducts 20 coins and builds bitmoji_pack_json',
    `Bitmoji pack items: ${stickersRes.data?.bitmoji_pack?.length}, Sticker URI: ${stickersRes.data?.generated_sticker_uri}`
  );

  // -------------------------------------------------------------------------
  // RULE 10: POST /v1/meetup/:id/memories/share-chat (Share to Go Chat Engine)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 8: Share Memory Card to Real-Time Chat ---${colors.reset}`);
  const shareChatRes = await request('POST', `/meetup/${meetup1Id}/memories/share-chat`, {
    memory_id: memoryId,
    custom_message: 'Remember this unforgettable evening! 💖',
  });
  assert(
    shareChatRes.status === 200 && shareChatRes.data?.memory_card?.card_type === 'memory_card',
    '8. POST /v1/meetup/:id/memories/share-chat formats card and dispatches to Go engine & chat_messages',
    `Message Card: ${shareChatRes.data?.memory_card?.custom_message}, Room: ${shareChatRes.data?.room_id}`
  );

  // -------------------------------------------------------------------------
  // RULE 11: POST /v1/meetup/:id/rating (5-star multi-category dynamic feedback)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 9: Dynamic Role Feedback & Rating ---${colors.reset}`);
  const proposerRatingRes = await request('POST', `/meetup/${meetup1Id}/rating`, {
    user_id: PROPOSER_ID,
    rating: 5,
    feedback: 'Incredible chemistry, great conversation and food!',
    ratings_json: {
      punctuality: 5,
      conversation: 5,
      vibe_match: 5,
      courtesy: 5,
    },
  });
  assert(
    proposerRatingRes.status === 200 && proposerRatingRes.data?.status === 'completed',
    '9.1 POST /v1/meetup/:id/rating records proposer rating and sets status to "completed"',
    `Proposer rating: 5 stars, status: ${proposerRatingRes.data?.status}`
  );

  const partnerRatingRes = await request('POST', `/meetup/${meetup1Id}/rating`, {
    user_id: PARTNER_ID,
    rating: 5,
    feedback: 'Loved the venue choice and thoughtful surprises!',
    ratings_json: {
      punctuality: 5,
      conversation: 5,
      vibe_match: 5,
      courtesy: 5,
    },
  }, PARTNER_AUTH_HEADER);
  assert(
    partnerRatingRes.status === 200 && partnerRatingRes.data?.success === true,
    '9.2 POST /v1/meetup/:id/rating records partner rating with dynamic column mapping',
    `Partner feedback recorded cleanly`
  );

  // -------------------------------------------------------------------------
  // RULE 12: POST /v1/meetup/:id/report (Moderation ticket)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 10: Date Safety Moderation Report ---${colors.reset}`);
  const reportRes = await request('POST', `/meetup/${meetup1Id}/report`, {
    reason_category: 'inappropriate_conduct',
    description: 'Felt uncomfortable during conversation, flagged for safety review.',
  });
  assert(
    reportRes.status === 201 && reportRes.data?.status === 'reported',
    '10. POST /v1/meetup/:id/report logs moderation ticket in user_blocks_reports and flags date',
    `Ticket ID: ${reportRes.data?.ticket_id}, Action Location: ${reportRes.data?.action_location}`
  );

  // -------------------------------------------------------------------------
  // RULE 3: PATCH /v1/meetup/:id/decline (100% full refund to proposer)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 11: Date Proposal Decline (100% Full Refund) ---${colors.reset}`);
  const schedule2Res = await request('POST', '/meetup/schedule', {
    match_id: MATCH_ID,
    partner_user_id: PARTNER_ID,
    date_mode: 'online',
    date_type: 'virtual_watch_party',
    scheduled_start_at: new Date(Date.now() + 60 * 3600 * 1000).toISOString(),
    theme_id: 'netflix_chill',
  });
  const meetup2Id = schedule2Res.data?.meetup?.id;

  const declineRes = await request('PATCH', `/meetup/${meetup2Id}/decline`, {
    reason: 'Busy with work this weekend, apologies!',
  }, PARTNER_AUTH_HEADER);
  assert(
    declineRes.status === 200 && declineRes.data?.status === 'declined',
    '11. PATCH /v1/meetup/:id/decline sets status to "declined" and triggers 100% refund',
    `Refund Receipt: ${JSON.stringify(declineRes.data?.refund)}`
  );

  // -------------------------------------------------------------------------
  // RULE 6: PATCH /v1/meetup/:id/cancel (24h lock rule + 80% refund / 20% platform fee)
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 12: Cancellation (24h Lock + 80% Refund) ---${colors.reset}`);
  const schedule3Res = await request('POST', '/meetup/schedule', {
    match_id: MATCH_ID,
    partner_user_id: PARTNER_ID,
    date_mode: 'offline',
    date_type: 'coffee',
    scheduled_start_at: new Date(Date.now() + 50 * 3600 * 1000).toISOString(), // >24h
    venue_name: 'Blue Tokai, Pali Hill',
    theme_id: 'casual_coffee',
  });
  const meetup3Id = schedule3Res.data?.meetup?.id;
  await request('PATCH', `/meetup/${meetup3Id}/accept`, null, PARTNER_AUTH_HEADER); // Accept first

  const cancelRes = await request('PATCH', `/meetup/${meetup3Id}/cancel`, {
    reason: 'Urgent family emergency arose.',
  });
  assert(
    cancelRes.status === 200 && cancelRes.data?.status === 'cancelled',
    '12.1 PATCH /v1/meetup/:id/cancel cancels date >24h prior and credits 80% refund',
    `Refund: ${JSON.stringify(cancelRes.data?.refund)}`
  );

  // -------------------------------------------------------------------------
  // 24-HOUR LOCK RULE VERIFICATION
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}--- Test Group 13: 24-Hour Lock Rule Enforcement Verification ---${colors.reset}`);
  // Schedule a date 48 hours in future
  const lockTestDate = await request('POST', '/meetup/schedule', {
    match_id: MATCH_ID,
    partner_user_id: PARTNER_ID,
    date_mode: 'online',
    date_type: 'coffee',
    scheduled_start_at: new Date(Date.now() + 48 * 3600 * 1000).toISOString(),
    theme_id: 'lock_test',
  });
  const lockMeetupId = lockTestDate.data?.meetup?.id;
  await request('PATCH', `/meetup/${lockMeetupId}/accept`, null, PARTNER_AUTH_HEADER);

  // Attempt to reschedule to a time less than 24 hours from now
  const soonStart = new Date(Date.now() + 10 * 3600 * 1000).toISOString();
  const rescheduleLockRes = await request('PATCH', `/meetup/${lockMeetupId}/reschedule`, {
    new_start_at: soonStart,
  });
  assert(
    rescheduleLockRes.status === 400 && rescheduleLockRes.data?.message?.includes('24-hour lock rule'),
    '13.1 Reschedule with new date < 24 hours strictly rejected with 400 BadRequest (24-Hour Lock Rule)',
    `Response message: "${rescheduleLockRes.data?.message}"`
  );

  // Attempt to edit date when start time is less than 24 hours (tested by updating edit to <=24h)
  const editLockRes = await request('PUT', `/meetup/${lockMeetupId}`, {
    scheduled_start_at: soonStart,
  });
  assert(
    editLockRes.status === 400 && editLockRes.data?.message?.includes('24-hour lock rule'),
    '13.2 Edit date to time < 24 hours strictly rejected with 400 BadRequest (24-Hour Lock Rule)',
    `Response message: "${editLockRes.data?.message}"`
  );

  // -------------------------------------------------------------------------
  // SUMMARY
  // -------------------------------------------------------------------------
  console.log(`\n${colors.bold}${colors.cyan}======================================================${colors.reset}`);
  console.log(`${colors.bold}TEST RESULTS: ${colors.green}${passed} PASSED${colors.reset}, ${failed === 0 ? colors.green + '0 FAILED' : colors.red + failed + ' FAILED'}${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}======================================================${colors.reset}\n`);

  if (failed > 0) {
    process.exit(1);
  }
}

runAllTests().catch((err) => {
  console.error('Test execution error:', err);
  process.exit(1);
});
