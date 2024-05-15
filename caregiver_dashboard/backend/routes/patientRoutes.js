const express = require('express');
const router = express.Router();
const { Sequelize, PatientProfile, PatientMedication, MedicationSchedule } = require('../models');
const verifyToken = require('../middleware/authMiddleware');

// Get patients for a specific caregiver with optional search query and pagination
router.get('/:userId', verifyToken, async (req, res) => {
  const userId = req.params.userId;
  const searchQuery = req.query.search || '';
  const page = parseInt(req.query.page) || 1;
  const pageSize = parseInt(req.query.pageSize) || 8;
  const offset = (page - 1) * pageSize;

  try {
    const { count, rows } = await PatientProfile.findAndCountAll({
      where: {
        UserId: userId,
        [Sequelize.Op.or]: [
          { FirstName: { [Sequelize.Op.like]: `%${searchQuery}%` } },
          { LastName: { [Sequelize.Op.like]: `%${searchQuery}%` } },
        ],
      },
      attributes: ['ProfileID', 'FirstName', 'LastName', 'DOB', 'Gender', 'Address', 'EmergencyContact'],
      limit: pageSize,
      offset: offset,
    });

    const totalPages = Math.ceil(count / pageSize);
    res.json({ patients: rows, totalPages });
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ message: 'Error fetching patients' });
  }
});

// Get patient details along with their medications and schedules
router.get('/detail/:patientId', verifyToken, async (req, res) => {
  const patientId = req.params.patientId;

  try {
    const patientProfile = await PatientProfile.findByPk(patientId, {
      include: [{
        model: PatientMedication,
        include: [MedicationSchedule]
      }]
    });

    if (!patientProfile) {
      return res.status(404).json({ message: 'Patient not found' });
    }

    res.json(patientProfile);
  } catch (error) {
    console.error('Error fetching patient details:', error);
    res.status(500).json({ message: 'Error fetching patient details' });
  }
});

module.exports = router;
