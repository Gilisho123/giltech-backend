import express from 'express';
import pool from '../config/db.js';
import bcrypt from 'bcryptjs';

const router = express.Router();

// POST /api/admin-tools/create-admin
// Body: { email, password, token }
// Requires ADMIN_TOOL_TOKEN env var to be set to allow creating an admin via HTTP.
router.post('/create-admin', async (req, res) => {
  try {
    const secret = process.env.ADMIN_TOOL_TOKEN;
    if (!secret) return res.status(403).json({ error: 'Admin tool disabled' });

    const { token, email, password } = req.body;
    if (!token || token !== secret) return res.status(401).json({ error: 'Invalid token' });
    if (!email || !password) return res.status(400).json({ error: 'Email and password required' });

    const hashed = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (email, password_hash, is_admin) VALUES (?, ?, 1) ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash), is_admin = 1',
      [email, hashed]
    );

    res.json({ success: true, insertedId: result.insertId });
  } catch (err) {
    console.error('admin-tools error', err);
    res.status(500).json({ error: 'Server error' });
  }
});

export default router;
