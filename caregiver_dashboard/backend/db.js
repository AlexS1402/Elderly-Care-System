require('dotenv').config();
const { Sequelize } = require('sequelize');
const fs = require('fs');
const path = require('path');

// Path to the SSL certificate
const sslCertPath = path.resolve(__dirname, 'ssl/DigiCertGlobalRootCA.crt.pem');

const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
  host: process.env.DB_HOST,
  dialect: 'mysql',
  dialectOptions: {
    ssl: {
      ca: fs.readFileSync(sslCertPath),
      rejectUnauthorized: true
    }
  },
  logging: false
});

sequelize.authenticate()
  .then(() => console.log('Database connection successful'))
  .catch(err => console.error('Error connecting to the database:', err));

module.exports = sequelize;
