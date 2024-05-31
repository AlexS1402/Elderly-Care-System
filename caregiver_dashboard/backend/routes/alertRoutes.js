const express = require('express');
const router = express.Router();
const { AlertLog, PatientProfile } = require('../models');
const { verifyToken, verifyAdmin } = require('../middleware/authMiddleware');

// Get recent alert logs for a specific caregiver
router.get('/recent/:userId', verifyToken, async (req, res) => {
  const userId = req.params.userId;
  const page = parseInt(req.query.page) || 1;
  const pageSize = 5;
  const offset = (page - 1) * pageSize;

  try {
    const { count, rows } = await AlertLog.findAndCountAll({
      include: [
        {
          model: PatientProfile,
          where: { UserId: userId },
          attributes: ['FirstName', 'LastName', 'EmergencyContact', 'ProfileID'],
        },
      ],
      attributes: ['AlertID', 'AlertTimestamp', 'AlertType', 'ProfileID', 'Resolved'],
      order: [['AlertTimestamp', 'DESC']],
      limit: pageSize,
      offset: offset,
    });

    const totalPages = Math.ceil(count / pageSize);
    res.json({ logs: rows, totalPages });
  } catch (error) {
    console.error('Error fetching alert logs:', error);
    res.status(500).json({ message: 'Error fetching alert logs' });
  }
});

// Get all alert logs for admin
router.get('/recent', verifyToken, verifyAdmin, async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const pageSize = 5;
  const offset = (page - 1) * pageSize;

  try {
    const { count, rows } = await AlertLog.findAndCountAll({
      include: [
        {
          model: PatientProfile,
          attributes: ['FirstName', 'LastName', 'EmergencyContact', 'ProfileID'],
        },
      ],
      attributes: ['AlertID', 'AlertTimestamp', 'AlertType', 'ProfileID', 'Resolved'],
      order: [['AlertTimestamp', 'DESC']],
      limit: pageSize,
      offset: offset,
    });

    const totalPages = Math.ceil(count / pageSize);
    res.json({ logs: rows, totalPages });
  } catch (error) {
    console.error('Error fetching alert logs:', error);
    res.status(500).json({ message: 'Error fetching alert logs' });
  }
});

// Update alert log to resolved
router.put('/resolve/:alertId', verifyToken, async (req, res) => {
  const alertId = req.params.alertId;

  try {
    const alertLog = await AlertLog.findByPk(alertId);
    if (!alertLog) {
      return res.status(404).json({ message: 'Alert log not found' });
    }

    alertLog.Resolved = true;
    await alertLog.save();
    res.json({ message: 'Alert log marked as resolved' });
  } catch (error) {
    console.error('Error updating alert log:', error);
    res.status(500).json({ message: 'Error updating alert log' });
  }
});

module.exports = router;
