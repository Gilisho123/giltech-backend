-- MSSQL-compatible users table creation script
-- Use this if your SQL extension / Problems tab expects T-SQL syntax
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
