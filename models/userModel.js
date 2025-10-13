import pool from "../config/db.js";

export const createUser = async (email, passwordHash, isAdmin = 0) => {
  const query = `INSERT INTO users (email, password_hash, is_admin) VALUES (?, ?, ?)`;
  const [result] = await pool.query(query, [email, passwordHash, isAdmin]);
  return { id: result.insertId, email, is_admin: isAdmin };
};

export const findUserByEmail = async (email) => {
  const [rows] = await pool.query("SELECT * FROM users WHERE email = ? LIMIT 1", [email]);
  return rows[0];
};
