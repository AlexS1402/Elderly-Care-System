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

// Load all models
const models = {};
const modelsDir = path.resolve(__dirname, 'models');
fs.readdirSync(modelsDir).forEach(file => {
  const model = require(path.join(modelsDir, file))(sequelize, Sequelize.DataTypes);
  models[model.name] = model;
});

Object.keys(models).forEach(modelName => {
  if (models[modelName].associate) {
    models[modelName].associate(models);
  }
});

models.sequelize = sequelize;
models.Sequelize = Sequelize;

module.exports = models;
