import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const { Pool } = pg;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function main() {
  try {
    console.log('Running migration on meetup table...');
    await pool.query(`ALTER TABLE meetup ADD COLUMN IF NOT EXISTS theme_id VARCHAR(32) DEFAULT 'default'`);
    await pool.query(`ALTER TABLE meetup DROP CONSTRAINT IF EXISTS meetup_status_check`);
    await pool.query(`ALTER TABLE meetup ADD CONSTRAINT meetup_status_check CHECK (status IN ('pending', 'scheduled', 'completed', 'cancelled', 'declined', 'missed', 'reported'))`);
    await pool.query(`ALTER TABLE meetup ALTER COLUMN status SET DEFAULT 'pending'`);
    console.log('✅ MEETUP TABLE MIGRATED SUCCESSFULLY!');

    const cons = await pool.query(`
      SELECT conname, pg_get_constraintdef(c.oid) as def 
      FROM pg_constraint c 
      WHERE conrelid = 'meetup'::regclass AND conname = 'meetup_status_check'
    `);
    console.log('New constraint:', cons.rows[0]);
  } catch (err) {
    console.error('Migration failed:', err.message);
  } finally {
    await pool.end();
  }
}

main();
