#!/usr/bin/env node
/**
 * Builds a single paste-ready SQL bundle from the two canonical files:
 *   database/schema.sql  +  database/seeds.sql
 *      -> database/supabase-dashboard-bundle.sql
 *
 * Use it when applying via the Supabase Dashboard SQL Editor (no psql needed).
 * The bundle is generated — never edit it by hand.
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const schema = readFileSync(path.join(ROOT, 'database/schema.sql'), 'utf8');
const seeds = readFileSync(path.join(ROOT, 'database/seeds.sql'), 'utf8');

const banner = (title) =>
  [
    '',
    '-- ' + '='.repeat(68),
    `-- ${title}`,
    '-- ' + '='.repeat(68),
    '',
  ].join('\n');

const out = [
  '-- ' + '='.repeat(68),
  '-- YoUnMe — Supabase Dashboard Bundle (generated)',
  '-- Project: ocacwpazrfaecmckmtbz  (region: ap-northeast-2 / Tokyo)',
  '--',
  '-- SOURCE : database/schema.sql + database/seeds.sql',
  '-- REBUILD: npm run db:bundle',
  '-- ' + '='.repeat(68),
  banner('PART 1/2 — SCHEMA (tables, indexes, functions, RLS)'),
  schema,
  banner('PART 2/2 — SEED DATA (5 users, 5 profiles, wallets, match, messages)'),
  seeds,
  '',
].join('\n');

const target = path.join(ROOT, 'database/supabase-dashboard-bundle.sql');
writeFileSync(target, out, 'utf8');

console.log(`Wrote ${path.relative(ROOT, target)}  (${out.length.toLocaleString()} chars)`);
console.log('Paste it into: Supabase Dashboard -> SQL Editor -> New query -> Run');
