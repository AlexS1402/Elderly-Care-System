const express = require('express');
const router = express.Router();
const { SensorDataHistory, sequelize } = require('../models');
const verifyToken = require('../middleware/authMiddleware');

// Get hourly average heart rate data for a specific patient profile on a specific date
router.get('/:profileId/heartRate', verifyToken, async (req, res) => {
  const profileId = req.params.profileId;
  const date = req.query.date; // Expect date in 'YYYY-MM-DD' format

  try {
    const heartRateData = await SensorDataHistory.findAll({
      attributes: [
        [sequelize.fn('DATE_FORMAT', sequelize.col('Timestamp'), '%Y-%m-%d %H:00:00'), 'timeInterval'],
        [sequelize.fn('AVG', sequelize.col('Value')), 'avgHeartRate']
      ],
      where: {
        ProfileID: profileId,
        SensorType: 'Heart Rate',
        Timestamp: sequelize.where(sequelize.fn('DATE', sequelize.col('Timestamp')), date)
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
