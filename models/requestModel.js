import pool from "../config/db.js";

export const createRequest = async (name, phone, service, fileName) => {
  const query = `
    INSERT INTO service_requests (name, phone, service, file_name)
    VALUES (?, ?, ?, ?)
  `;
  const [result] = await pool.query(query, [name, phone, service, fileName]);
  return { id: result.insertId, name, phone, service, file_name: fileName };
};

export const getAllRequests = async () => {
  const [rows] = await pool.query("SELECT * FROM service_requests ORDER BY created_at DESC");
  return rows;
};
