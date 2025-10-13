-- MSSQL-compatible users table creation script
-- Use this file if your editor or Problems tab expects T-SQL syntax.
IF NOT EXISTS (
  SELECT * FROM sys.objects
  WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U')
)
BEGIN
  CREATE TABLE dbo.users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    is_admin BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT SYSUTCDATETIME()
  );
END

-- If you need a MySQL version, use `create_users_mssql.sql` (also provided) or replace this file with the MySQL script:
-- CREATE TABLE IF NOT EXISTS users (
--   id INT AUTO_INCREMENT PRIMARY KEY,
--   email VARCHAR(255) NOT NULL UNIQUE,
--   password_hash VARCHAR(255) NOT NULL,
--   is_admin TINYINT(1) DEFAULT 0,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
