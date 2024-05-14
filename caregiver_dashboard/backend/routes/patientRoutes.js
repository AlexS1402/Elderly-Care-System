const express = require('express');
const router = express.Router();
const { PatientProfile } = require('../models');
const verifyToken = require('../middleware/authMiddleware');

// Get patients for a specific caregiver
router.get('/:userId/patients', verifyToken, async (req, res) => {
  const userId = req.params.userId;

  try {
    const patients = await PatientProfile.findAll({ where: { UserId: userId } });
    res.json(patients);
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ message: 'Error fetching patients' });
  }
});

module.exports = router;
