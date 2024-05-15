const express = require('express');
const router = express.Router();
const { SensorData } = require('../models');
const verifyToken = require('../middleware/authMiddleware');

// Get sensor data for a specific patient and sensor type
router.get('/:patientId', verifyToken, async (req, res) => {
  const patientId = req.params.patientId;
  const sensorType = req.query.sensorType;

  try {
    const sensorData = await SensorData.findAll({
      where: {
        ProfileID: patientId,
        SensorType: sensorType
      },
      order: [['Timestamp', 'ASC']]
    });

    res.json(sensorData);
  } catch (error) {
    console.error('Error fetching sensor data:', error);
    res.status(500).json({ message: 'Error fetching sensor data' });
  }
});

module.exports = router;