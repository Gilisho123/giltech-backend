-- =========================================================
--  Giltech Online Cyber
--  MSSQL-Compatible Database Initialization Script
--  File: create_users_mssql.sql
--  Purpose: Create users and related tables for admin tools
-- =========================================================

-- Create database if it does not exist
IF NOT EXISTS (
  SELECT name FROM sys.databases WHERE name = N'giltechdb'
)
BEGIN
  PRINT 'Creating database giltechdb...';
  CREATE DATABASE giltechdb;
END
GO

USE giltechdb;
GO

-- =========================================================
--  USERS TABLE
-- =========================================================
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U')
)
BEGIN
  CREATE TABLE dbo.users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    is_admin BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT SYSUTCDATETIME()
  );

  PRINT '✅ Table [users] created successfully.';
END
ELSE
BEGIN
  PRINT 'ℹ️ Table [users] already exists. Skipping creation.';
END
GO

-- =========================================================
--  SERVICE REQUESTS TABLE
-- =========================================================
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[service_requests]') AND type in (N'U')
)
BEGIN
  CREATE TABLE dbo.service_requests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    service NVARCHAR(150) NOT NULL,
    file_name NVARCHAR(255),
    created_at DATETIME2 DEFAULT SYSUTCDATETIME()
  );

  PRINT '✅ Table [service_requests] created successfully.';
END
ELSE
BEGIN
  PRINT 'ℹ️ Table [service_requests] already exists. Skipping creation.';
END
GO

-- =========================================================
--  ACTIVITY LOG TABLE
-- =========================================================
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[activity_log]') AND type in (N'U')
)
BEGIN
  CREATE TABLE dbo.activity_log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_email NVARCHAR(255),
    action NVARCHAR(255),
    ip_address NVARCHAR(45),
    created_at DATETIME2 DEFAULT SYSUTCDATETIME()
  );

  PRINT '✅ Table [activity_log] created successfully.';
END
ELSE
BEGIN
  PRINT 'ℹ️ Table [activity_log] already exists. Skipping creation.';
END
GO

-- =========================================================
--  DEFAULT ADMIN USER CREATION (optional)
-- =========================================================
DECLARE @adminEmail NVARCHAR(255) = N'admin@giltech.local';
DECLARE @adminPass NVARCHAR(255) = N'$2b$10$hashgoeshere'; -- bcrypt hash placeholder
DECLARE @exists INT;

SELECT @exists = COUNT(*) FROM dbo.users WHERE email = @adminEmail;

IF (@exists = 0)
BEGIN
  INSERT INTO dbo.users (email, password_hash, is_admin)
  VALUES (@adminEmail, @adminPass, 1);
  PRINT '✅ Default admin account created (admin@giltech.local).';
END
ELSE
BEGIN
  PRINT 'ℹ️ Default admin already exists.';
END
GO

PRINT '🎯 MSSQL initialization completed successfully for Giltech Online Cyber.';
