require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./db'); 

const registerUser = async () => {
  const username = 'user';
  const password = 'password';
  const email = 'example@domain.com';
  const userRole = 'Caregiver';

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    pool.query(
      'INSERT INTO users (Username, PasswordHash, Email, UserRole) VALUES (?, ?, ?, ?)',
      [username, hashedPassword, email, userRole],
      (error, results) => {
        if (error) {
          console.error('Error inserting user into the database:', error);
        } else {
          console.log('User registered successfully:', username);
        }
        pool.end(); // Close the pool connection after the query is done
      }
    );
  } catch (err) {
    console.error('Error hashing password:', err);
  }
};

registerUser();
