const express = require('express');
const router = express.Router();
const { SensorDataHistory, sequelize } = require('../models');
const verifyToken = require('../middleware/authMiddleware');

// Get heart rate data for a specific patient profile
router.get('/:profileId/heartRate', verifyToken, async (req, res) => {
  const profileId = req.params.profileId;

  try {
    const heartRateData = await SensorDataHistory.findAll({
      attributes: [
        [sequelize.fn('DATE_FORMAT', sequelize.col('Timestamp'), '%Y-%m-%d %H:%i:00'), 'timeInterval'],
        [sequelize.fn('AVG', sequelize.col('Value')), 'avgHeartRate']
      ],
      where: {
        ProfileID: profileId,
        SensorType: 'Heart Rate'
      },
      group: ['timeInterval'],
      order: [['timeInterval', 'ASC']]
    });

    res.json(heartRateData);
  } catch (error) {
    console.error('Error fetching heart rate data:', error);
    res.status(500).json({ message: 'Error fetching heart rate data' });
  }
});

module.exports = router;
