-- Create the database (only if it doesn’t exist)
CREATE DATABASE IF NOT EXISTS giltechdb;

-- Select it for use
USE giltechdb;

-- Create the service requests table
CREATE TABLE IF NOT EXISTS service_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(100) NULL,
  service VARCHAR(100) NOT NULL,
  file_name VARCHAR(255),
  status ENUM('Pending', 'In Progress', 'Completed') DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
