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
    const cols = await pool.query(`
      SELECT column_name, data_type, udt_name 
      FROM information_schema.columns 
      WHERE table_name = 'meetup' 
      ORDER BY ordinal_position
    `);
    console.log('MEETUP COLS:');
    for (const c of cols.rows) {
      console.log(` - ${c.column_name} (${c.data_type} / ${c.udt_name})`);
    }

    const cons = await pool.query(`
      SELECT conname, pg_get_constraintdef(c.oid) as def 
      FROM pg_constraint c 
      WHERE conrelid = 'meetup'::regclass
    `);
    console.log('\nMEETUP CONSTRAINTS:');
    for (const cn of cons.rows) {
      console.log(` - ${cn.conname}: ${cn.def}`);
    }

    const dateMemoriesCols = await pool.query(`
      SELECT column_name, data_type, udt_name 
      FROM information_schema.columns 
      WHERE table_name = 'date_memories' 
      ORDER BY ordinal_position
    `);
    console.log('\nDATE_MEMORIES COLS:');
    for (const c of dateMemoriesCols.rows) {
      console.log(` - ${c.column_name} (${c.data_type} / ${c.udt_name})`);
    }

    const walletCons = await pool.query(`
      SELECT conname, pg_get_constraintdef(c.oid) as def 
      FROM pg_constraint c 
      WHERE conrelid = 'wallet_transactions'::regclass
    `);
    console.log('\nWALLET_TRANSACTIONS CONSTRAINTS:');
    for (const c of walletCons.rows) {
      console.log(` - ${c.conname}: ${c.def}`);
    }

  } catch (e) {
    console.error('ERROR:', e.message);
  } finally {
    await pool.end();
  }
}

main();
