#!/usr/bin/env node
/**
 * YoUnMe — Supabase schema applier
 * ------------------------------------------------------------------
 * Applies database/schema.sql + database/seeds.sql to the Supabase project
 * and verifies the result. Secrets are read from local .env files and are
 * NEVER printed: connection targets are reported in sanitized form only.
 *
 *   node scripts/apply-supabase-schema.mjs              # schema + seeds
 *   node scripts/apply-supabase-schema.mjs --no-seed    # schema only
 *   node scripts/apply-supabase-schema.mjs --check      # verify only
 *   node scripts/apply-supabase-schema.mjs --dry-run    # show plan
 */

import { config } from 'dotenv';
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import pg from 'pg';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const rel = (p) => path.relative(ROOT, p) || p;

const argv = process.argv.slice(2);
const has = (f) => argv.includes(f);
const DRY_RUN = has('--dry-run');
const CHECK_ONLY = has('--check');
const NO_SEED = has('--no-seed');

// ---------------------------------------------------------------- env
const ENV_FILES = [
  path.join(ROOT, '.env'),
  path.join(ROOT, 'services/api-nestjs/.env'),
  path.join(ROOT, 'services/realtime-go/.env'),
];

for (const file of ENV_FILES) {
  if (existsSync(file)) {
    config({ path: file, override: false });
    console.log(`  env   ${rel(file)}`);
  }
}

const PROJECT_REF =
  process.env.SUPABASE_PROJECT_REF ||
  (process.env.SUPABASE_URL || '').match(/https:\/\/([a-z0-9]+)\.supabase\.co/)?.[1] ||
  'ocacwpazrfaecmckmtbz';

const REGION = process.env.SUPABASE_DB_REGION || 'ap-northeast-2';

const PASSWORD =
  process.env.SUPABASE_DB_PASSWORD ||
  process.env.DB_PASSWORD ||
  process.env.POSTGRES_PASSWORD ||
  (() => {
    // Fall back to a password embedded in an existing DATABASE_URL.
    const url = process.env.DATABASE_URL || '';
    if (!url.includes(PROJECT_REF)) return null;
    try {
      const u = new URL(url);
      return decodeURIComponent(u.password) || null;
    } catch {
      return null;
    }
  })();

/** Sanitized view of a postgres URL — password is never included. */
function sanitize(url) {
  try {
    const u = new URL(url);
    return `${u.protocol}//${u.username}:***@${u.hostname}:${u.port || '5432'}${u.pathname}`;
  } catch {
    return '(unparseable)';
  }
}

function buildConnectionString() {
  if (process.env.SUPABASE_DB_URL) return process.env.SUPABASE_DB_URL;

  const existing = process.env.DATABASE_URL;
  if (existing && existing.includes(PROJECT_REF)) return existing;

  if (!PASSWORD) return null;

  // Session pooler (port 5432): IPv4, supports row locks + LISTEN/NOTIFY,
  // which the transaction pooler (6543) does not.
  return (
    `postgresql://${encodeURIComponent(`postgres.${PROJECT_REF}`)}:` +
    `${encodeURIComponent(PASSWORD)}@aws-0-${REGION}.pooler.supabase.com:5432/postgres`
  );
}

// ---------------------------------------------------------------- plan
console.log('\nYoUnMe — Supabase schema applier\n');
console.log(`  project  ${PROJECT_REF}`);
console.log(`  region   ${REGION}`);

const connString = buildConnectionString();

if (!connString) {
  console.error('\n  ERROR: no database credentials found.\n');
  console.error('  Looked for (in .env, services/api-nestjs/.env, services/realtime-go/.env):');
  console.error('    SUPABASE_DB_URL        (full postgresql:// URL)');
  console.error('    SUPABASE_DB_PASSWORD   (or DB_PASSWORD / POSTGRES_PASSWORD)');
  console.error('    DATABASE_URL           (only used if it already points at this project)');
  console.error('\n  Add one of those to .env, e.g. (Dashboard -> Project Settings -> Database):');
  console.error(`    SUPABASE_DB_PASSWORD=<the project database password>\n`);
  process.exit(1);
}

console.log(`  target   ${sanitize(connString)}`);

const schemaPath = path.join(ROOT, 'database/schema.sql');
const seedPath = path.join(ROOT, 'database/seeds.sql');
console.log(`  files    ${rel(schemaPath)}${NO_SEED ? '' : `, ${rel(seedPath)}`}`);

if (DRY_RUN) {
  console.log('\n  --dry-run: no changes made.\n');
  process.exit(0);
}

// ---------------------------------------------------------------- apply
const client = new pg.Client({
  connectionString: connString,
  ssl: { rejectUnauthorized: false },
  connectionTimeoutMillis: 20000,
});

async function run() {
  await client.connect();
  const { host, port, database } = client.connectionParameters ?? {};
  console.log(`\n  connected  ${host}:${port}/${database}\n`);

  if (!CHECK_ONLY) {
    console.log('  applying schema.sql ...');
    await client.query(readFileSync(schemaPath, 'utf8'));
    console.log('  applying seeds.sql ...');
    if (!NO_SEED) {
      await client.query(readFileSync(seedPath, 'utf8'));
    } else {
      console.log('    (skipped: --no-seed)');
    }
  }

  // ------------------------------------------------------------ verify
  const { rows: tables } = await client.query(
    `SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY 1`
  );
  const { rows: funcs } = await client.query(
    `SELECT p.proname FROM pg_proc p
       JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public' ORDER BY 1`
  );
  const { rows: exts } = await client.query(
    `SELECT extname, extversion FROM pg_extension WHERE extname IN ('postgis','uuid-ossp') ORDER BY 1`
  );
  const { rows: rls } = await client.query(
    `SELECT relname, relrowsecurity FROM pg_class
      WHERE relnamespace = 'public'::regnamespace AND relkind = 'r' ORDER BY 1`
  );

  console.log('\n  ── TABLES (public schema) ─────────────────────────────');
  for (const t of tables) {
    const { rows: c } = await client.query(`SELECT count(*)::int AS n FROM public."${t.tablename}"`);
    const sec = rls.find((r) => r.relname === t.tablename);
    console.log(
      `    ${t.tablename.padEnd(16)} rows=${String(c[0].n).padEnd(5)} rls=${sec?.relrowsecurity ? 'ON' : 'OFF'}`
    );
  }

  console.log('\n  ── FUNCTIONS ──────────────────────────────────────────');
  for (const f of funcs) console.log(`    ${f.proname}`);

  console.log('\n  ── EXTENSIONS ─────────────────────────────────────────');
  for (const e of exts) console.log(`    ${e.extname} ${e.extversion}`);

  // live smoke test of the PostGIS deck function
  const { rows: deck } = await client.query(
    `SELECT nickname, ROUND(distance_km::numeric, 2) AS km
       FROM fn_get_nearby_candidates('11111111-1111-1111-1111-111111111111', 50000, 5)`
  );
  console.log('\n  ── fn_get_nearby_candidates() smoke test ─────────────');
  if (deck.length === 0) console.log('    (no candidates — seed data may be empty)');
  for (const d of deck) console.log(`    ${d.nickname}  ${d.km} km`);

  console.log('\n  Done. View in Supabase -> Table Editor.\n');
}

run()
  .then(() => client.end())
  .catch(async (err) => {
    console.error(`\n  FAILED: ${err.message}\n`);
    if (err.code) console.error(`  pg code: ${err.code}`);
    if (err.position) console.error(`  position: ${err.position} (character offset in the file being run)`);
    if (err.detail) console.error(`  detail: ${err.detail}`);
    if (err.hint) console.error(`  hint: ${err.hint}`);
    if (err.where) console.error(`  where: ${err.where}`);
    console.error('');
    try {
      await client.end();
    } catch {}
    process.exit(1);
  });
