#!/usr/bin/env node
/**
 * Guards against drift between the two copies of the schema:
 *   database/schema.sql                        (human reference)
 *   supabase/migrations/0001_yo_unme_core_schema.sql  (what `supabase db push` runs)
 *
 * Header comment blocks are ignored — only the executable SQL is compared.
 */

import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const A = path.join(ROOT, 'database/schema.sql');
const B = path.join(ROOT, 'supabase/migrations/0001_yo_unme_core_schema.sql');

/** Strip leading `--` comment lines and collapse whitespace. */
function normalize(file) {
  return readFileSync(file, 'utf8')
    .split('\n')
    .filter((line) => !line.trim().startsWith('--'))
    .join('\n')
    .replace(/\s+/g, ' ')
    .trim();
}

if (!existsSync(A) || !existsSync(B)) {
  console.error('schema:check — one of the schema files is missing.');
  process.exit(1);
}

const a = normalize(A);
const b = normalize(B);

if (a === b) {
  console.log('schema:check — OK, database/schema.sql and supabase/migrations/ are in sync.');
  process.exit(0);
}

console.error('schema:check — DRIFT DETECTED between:');
console.error('  database/schema.sql');
console.error('  supabase/migrations/0001_yo_unme_core_schema.sql');
console.error('\nCopy the newer one over the other, then re-run this check.');
process.exit(1);
