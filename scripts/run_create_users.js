import fs from 'fs';
import path from 'path';
import pool from '../config/db.js';

async function run() {
  const sqlPath = path.join(path.dirname(new URL(import.meta.url).pathname), '..', 'create_users.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  try {
    const [result] = await pool.query(sql);
    console.log('Migration executed successfully.');
  } catch (err) {
    console.error('Migration failed:', err.message || err);
  } finally {
    process.exit(0);
  }
}

run();
