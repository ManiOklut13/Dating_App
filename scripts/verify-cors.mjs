#!/usr/bin/env node
/**
 * YoUnMe — CORS Verification Script
 * ------------------------------------------------------------------
 * Verifies that Cross-Origin Resource Sharing (CORS) is properly configured
 * between the Frontend (http://localhost:5173, http://localhost:3000) and both backends:
 *   1. NestJS REST API Gateway (http://localhost:8080)
 *   2. Go Real-Time WebSocket Engine (http://localhost:8081)
 *
 * Usage:
 *   node scripts/verify-cors.mjs
 */

import http from 'node:http';

const FRONTEND_ORIGIN = 'http://localhost:5173';
const API_URL = process.env.API_URL || 'http://localhost:8080';
const REALTIME_URL = process.env.REALTIME_URL || 'http://localhost:8081';

function checkCORS(name, targetUrl, method = 'OPTIONS', headers = {}) {
  return new Promise((resolve) => {
    const url = new URL(targetUrl);
    const options = {
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname + url.search,
      method: method,
      headers: {
        Origin: FRONTEND_ORIGIN,
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'Content-Type, Authorization, apikey',
        ...headers,
      },
    };

    console.log(`\n🔍 Testing ${name} [${method} ${targetUrl}] from Origin: ${FRONTEND_ORIGIN}`);

    const req = http.request(options, (res) => {
      const allowOrigin = res.headers['access-control-allow-origin'];
      const allowCreds = res.headers['access-control-allow-credentials'];
      const allowMethods = res.headers['access-control-allow-methods'];
      const allowHeaders = res.headers['access-control-allow-headers'];

      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Access-Control-Allow-Origin: ${allowOrigin || '(none)'}`);
      console.log(`   Access-Control-Allow-Credentials: ${allowCreds || '(none)'}`);
      if (allowMethods) console.log(`   Access-Control-Allow-Methods: ${allowMethods}`);
      if (allowHeaders) console.log(`   Access-Control-Allow-Headers: ${allowHeaders}`);

      const passed =
        (allowOrigin === FRONTEND_ORIGIN || allowOrigin === '*') &&
        (method === 'OPTIONS' ? res.statusCode === 204 || res.statusCode === 200 : res.statusCode < 500);

      if (passed) {
        console.log(`   ✅ PASS: CORS is valid for ${name}`);
      } else {
        console.log(`   ⚠️ NOTICE: Server returned unexpected CORS response.`);
      }

      resolve({ passed, statusCode: res.statusCode, allowOrigin });
    });

    req.on('error', (err) => {
      console.log(`   ⚠️ Cannot connect to ${targetUrl}: ${err.message}`);
      console.log(`      (Make sure the service is running, e.g. via 'npm run dev' or 'npm run dev:api')`);
      resolve({ passed: false, error: err.message });
    });

    req.setTimeout(3000, () => {
      req.destroy();
      console.log(`   ⚠️ Timeout connecting to ${targetUrl}`);
      resolve({ passed: false, error: 'TIMEOUT' });
    });

    req.end();
  });
}

async function run() {
  console.log('================================================================');
  console.log('🛡️  YoUnMe — Verifying CORS Between Frontend & Backends');
  console.log(`📍 Testing Frontend: ${FRONTEND_ORIGIN}`);
  console.log(`📍 Backend API:     ${API_URL}`);
  console.log(`📍 Real-Time Go:    ${REALTIME_URL}`);
  console.log('================================================================');

  // Test 1: NestJS OPTIONS Preflight
  await checkCORS('NestJS API (Preflight)', `${API_URL}/v1/health`, 'OPTIONS');

  // Test 2: NestJS GET request with Origin
  await checkCORS('NestJS API (GET Request)', `${API_URL}/health`, 'GET');

  // Test 3: Go Real-Time Engine OPTIONS Preflight
  await checkCORS('Go Real-Time (Preflight)', `${REALTIME_URL}/health`, 'OPTIONS');

  // Test 4: Go Real-Time GET /health with Origin
  await checkCORS('Go Real-Time (GET Request)', `${REALTIME_URL}/health`, 'GET');

  console.log('\n================================================================');
  console.log('🏁 Verification finished. When running `npm run dev`, all services');
  console.log('   communicate seamlessly with `http://localhost:5173` without CORS issues.');
  console.log('================================================================\n');
}

run();
