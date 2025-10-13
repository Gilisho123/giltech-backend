import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "giltechdb",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

try {
  const connection = await pool.getConnection();
  console.log("✅ Connected to MySQL");
  connection.release();
} catch (error) {
  console.error("❌ DB Connection Error:", error);
}

export default pool;
// DB pool exported for use by application code
