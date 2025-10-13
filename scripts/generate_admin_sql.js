import bcrypt from 'bcryptjs';

(async function(){
  const password = 'ChangeMe@1234';
  const salt = await bcrypt.genSalt(10);
  const hash = await bcrypt.hash(password, salt);
  const email = 'admin@giltech.local';

  console.log('-- SQL to insert admin user (run after create_users.sql has been applied)');
  console.log("-- Replace DB_NAME and connection method as needed");
  console.log('');
  console.log("INSERT INTO users (email, password_hash, is_admin) VALUES ('" + email + "', '" + hash + "', 1);\n");
  console.log('-- Plaintext credentials:');
  console.log('Email:', email);
  console.log('Password:', password);
})();
