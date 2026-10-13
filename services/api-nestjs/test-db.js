require('dotenv').config();
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
pool.query('SELECT NOW()').then(res => { console.log('Connected:', res.rows[0]); pool.end(); }).catch(err => { console.error('Code:', err.code); console.error('Error:', err); pool.end(); });
