/**
 * Real Authentication & Session Verification Integration Test Suite
 * Tests live NestJS Auth endpoints against live Supabase / PostgreSQL.
 */

import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const BASE_URL = process.env.API_BASE_URL || 'http://localhost:8080';

const { Pool } = pg;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m',
  bold: '\x1b[1m',
};

async function runTests() {
  console.log(`\n${colors.bold}${colors.cyan}==============================================================${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}  YoUnMe Authentication & Session Verification Integration Suite ${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}==============================================================${colors.reset}\n`);

  let allPassed = true;
  let createdUserId = null;
  let activeAccessToken = null;
  let activeRefreshToken = null;

  const timestamp = Date.now();
  const testEmail = `test.user.${timestamp}@younme.social`;
  const testPassword = 'TestPassword123!';
  const testPhone = `+9198${Math.floor(10000000 + Math.random() * 90000000)}`;

  // Test 1: New User Registration (POST /v1/auth/signup)
  try {
    process.stdout.write(`1. [POST /v1/auth/signup] Registering real new user (${testEmail})... `);
    const res = await fetch(`${BASE_URL}/v1/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: testPassword,
        phone: testPhone,
        firstName: 'DatingTest',
        lastName: 'User',
      }),
    });

    const data = await res.json();
    if (res.status === 201 && data.success && data.user && data.session) {
      createdUserId = data.user.id || data.user.uid;
      activeAccessToken = data.session.access_token;
      activeRefreshToken = data.session.refresh_token;
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: ${res.status}, User ID: ${createdUserId})`);
    } else {
      throw new Error(`Expected 201 Created, got ${res.status}: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 2: PostgreSQL Database Verification
  try {
    process.stdout.write(`2. [PostgreSQL DB] Verifying newly registered user in app_users & user_profiles... `);
    const userRow = await pool.query('SELECT id, email, phone_number, account_status FROM app_users WHERE id = $1', [createdUserId]);
    const profileRow = await pool.query('SELECT user_id, nickname, profile_progress FROM user_profiles WHERE user_id = $1', [createdUserId]);
    const walletRow = await pool.query('SELECT user_id, coin_balance FROM user_wallets WHERE user_id = $1', [createdUserId]);

    if (userRow.rows.length > 0 && profileRow.rows.length > 0 && walletRow.rows.length > 0) {
      console.log(`${colors.green}✓ PASS${colors.reset} (Found in app_users, user_profiles, user_wallets [Coins: ${walletRow.rows[0].coin_balance}])`);
    } else {
      throw new Error(`Records not found in all tables: user=${userRow.rows.length}, profile=${profileRow.rows.length}, wallet=${walletRow.rows.length}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 3: Existing User Login (POST /v1/auth/signin)
  try {
    process.stdout.write(`3. [POST /v1/auth/signin] Logging in with valid credentials... `);
    const res = await fetch(`${BASE_URL}/v1/auth/signin`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: testPassword,
      }),
    });

    const data = await res.json();
    if (res.status === 200 && data.success && data.session?.access_token) {
      activeAccessToken = data.session.access_token;
      activeRefreshToken = data.session.refresh_token || activeRefreshToken;
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: ${res.status}, Authenticated JWT acquired)`);
    } else {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 4: Invalid Password Rejection (POST /v1/auth/signin)
  try {
    process.stdout.write(`4. [POST /v1/auth/signin] Attempting login with invalid password... `);
    const res = await fetch(`${BASE_URL}/v1/auth/signin`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: testEmail,
        password: 'IncorrectPassword999!',
      }),
    });

    if (res.status === 401) {
      const data = await res.json();
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: 401 Unauthorized, Message: "${data.message}")`);
    } else {
      throw new Error(`Expected 401 Unauthorized, got ${res.status}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 5: Authenticated API Request (GET /v1/auth/me)
  try {
    process.stdout.write(`5. [GET /v1/auth/me] Fetching current user profile with Bearer token... `);
    const res = await fetch(`${BASE_URL}/v1/auth/me`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${activeAccessToken}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await res.json();
    if (res.status === 200 && data.success && data.user) {
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: 200, User: ${data.user.email}, Progress: ${data.profile?.profile_progress}%)`);
    } else {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 6: Token Refresh (POST /v1/auth/refresh)
  try {
    process.stdout.write(`6. [POST /v1/auth/refresh] Refreshing access token with refresh_token... `);
    const res = await fetch(`${BASE_URL}/v1/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        refresh_token: activeRefreshToken,
      }),
    });

    const data = await res.json();
    if (res.status === 200 && data.success && data.session?.access_token) {
      activeAccessToken = data.session.access_token;
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: 200, New Access Token received)`);
    } else {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 7: OTP Dispatch and Verify (POST /v1/auth/otp/send & POST /v1/auth/otp/verify)
  try {
    process.stdout.write(`7. [POST /v1/auth/otp/*] Testing OTP flow for phone number... `);
    const sendRes = await fetch(`${BASE_URL}/v1/auth/otp/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: 'phone',
        identifier: '+919820099999',
      }),
    });

    const verifyRes = await fetch(`${BASE_URL}/v1/auth/otp/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: 'phone',
        identifier: '+919820099999',
        token: '123456',
      }),
    });

    const verifyData = await verifyRes.json();
    if (sendRes.status === 200 && verifyRes.status === 200 && verifyData.success) {
      console.log(`${colors.green}✓ PASS${colors.reset} (OTP dispatched and verified successfully)`);
    } else {
      throw new Error(`OTP failed: send=${sendRes.status}, verify=${verifyRes.status}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 8: Onboarding Status (GET /v1/onboarding/status/:userId)
  try {
    process.stdout.write(`8. [GET /v1/onboarding/status/:userId] Checking onboarding progress... `);
    const res = await fetch(`${BASE_URL}/v1/onboarding/status/${createdUserId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${activeAccessToken}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await res.json();
    if (res.status === 200 && data.progress !== undefined) {
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: 200, Progress: ${data.progress}%, Missing: ${data.missing_items?.length} items)`);
    } else {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(data)}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  // Test 9: Unauthorized Home/Me Access Prevention
  try {
    process.stdout.write(`9. [Security Guard] Rejecting unauthenticated access to /v1/auth/me... `);
    const res = await fetch(`${BASE_URL}/v1/auth/me`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });

    if (res.status === 401) {
      console.log(`${colors.green}✓ PASS${colors.reset} (Status: 401 Unauthorized, unauthenticated access blocked)`);
    } else {
      throw new Error(`Expected 401, got ${res.status}`);
    }
  } catch (err) {
    allPassed = false;
    console.log(`${colors.red}✗ FAIL${colors.reset} (${err.message})`);
  }

  console.log(`\n${colors.bold}--------------------------------------------------------------${colors.reset}`);
  if (allPassed) {
    console.log(`${colors.bold}${colors.green}🎉 ALL 9 AUTHENTICATION & DATABASE INTEGRATION TESTS PASSED!${colors.reset}`);
  } else {
    console.log(`${colors.bold}${colors.red}❌ SOME TESTS FAILED. See details above.${colors.reset}`);
  }
  console.log(`${colors.bold}--------------------------------------------------------------${colors.reset}\n`);

  await pool.end();
  process.exit(allPassed ? 0 : 1);
}

runTests();
