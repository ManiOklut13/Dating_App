import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const { Pool } = pg;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function run() {
  try {
    const res = await pool.query(`
      SELECT conname, pg_get_constraintdef(c.oid) as def 
      FROM pg_constraint c 
      WHERE conrelid = 'meetup'::regclass
    `);
    console.log('Meetup constraints:');
    for (const r of res.rows) {
      console.log(` - ${r.conname}: ${r.def}`);
    }

    const cols = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'user_profiles' 
      ORDER BY ordinal_position
    `);
    console.log('\nuser_profiles columns:', cols.rows.map(c => `${c.column_name} (${c.data_type})`));

    const matches = await pool.query('SELECT id, user_a_id, user_b_id FROM matches LIMIT 5');
    console.log('\nMatches in DB:', matches.rows);

    const meetups = await pool.query('SELECT id, match_id, proposer_user_id, partner_user_id, status FROM meetup LIMIT 5');
    console.log('\nMeetups in DB:', meetups.rows);

    const callSessions = await pool.query('SELECT id, livekit_room_name, caller_user_id, status FROM call_sessions LIMIT 5');
    console.log('\nCall sessions in DB:', callSessions.rows);

    const wallets = await pool.query('SELECT user_id, coin_balance FROM user_wallets LIMIT 5');
    console.log('\nWallets in DB:', wallets.rows);

    const swipes = await pool.query('SELECT id, actor_user_id, target_user_id, action_type FROM swipes_interactions LIMIT 5');
    console.log('\nSwipes in DB:', swipes.rows);
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await pool.end();
  }
}

run();
