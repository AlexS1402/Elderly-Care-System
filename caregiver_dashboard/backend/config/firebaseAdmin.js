const admin = require('firebase-admin');
const serviceAccount = require('../ssl/caregiver-dashboard-firebase-adminsdk-m31ww-9e38d7a748.json'); // Replace with your service account key file path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
