const express = require('express');
const router = express.Router();
const { PatientMedication, MedicationSchedule, Sequelize } = require('../models');
const { verifyToken, verifyAdmin } = require('../middleware/authMiddleware');

// Add a new medication (Admin only)
router.post('/', verifyToken, verifyAdmin, async (req, res) => {
  const { MedicationName, Dosage, FrequencyPerDay, StartDate, EndDate, ProfileID } = req.body;
  try {
    const newMedication = await PatientMedication.create({
      MedicationName,
      Dosage,
      FrequencyPerDay,
      StartDate,
      EndDate,
      ProfileID,
    });
    res.status(201).json(newMedication);
  } catch (error) {
    console.error('Error adding new medication:', error);
    res.status(500).json({ message: 'Error adding new medication' });
  }
});

// Get medications for a specific patient
router.get('/:patientId', verifyToken, async (req, res) => {
  const patientId = req.params.patientId;

  try {
    const medications = await PatientMedication.findAll({
      where: { ProfileID: patientId },
      include: [MedicationSchedule],
    });

    res.json(medications);
  } catch (error) {
    console.error('Error fetching medications:', error);
    res.status(500).json({ message: 'Error fetching medications' });
  }
});

// Update medication (Admin only)
router.put('/:medicationId', verifyToken, verifyAdmin, async (req, res) => {
  const medicationId = req.params.medicationId;
  const {
    MedicationName,
    Dosage,
    FrequencyPerDay,
    StartDate,
    EndDate,
    ProfileID,
    MedicationSchedules,
  } = req.body;

  try {
    const medication = await PatientMedication.findByPk(medicationId);

    if (!medication) {
      return res.status(404).json({ message: 'Medication not found' });
    }

    await medication.update({
      MedicationName,
      Dosage,
      FrequencyPerDay,
      StartDate,
      EndDate,
      ProfileID,
    });

    // Update medication schedules
    for (const schedule of MedicationSchedules) {
      if (schedule.ScheduleID) {
        // Update existing schedule
        await MedicationSchedule.update(
          {
            ScheduledTime: schedule.ScheduledTime,
          },
          {
            where: { ScheduleID: schedule.ScheduleID },
          }
        );
      } else {
        // Create new schedule
        await MedicationSchedule.create({
          ScheduledTime: schedule.ScheduledTime,
          PatientMedicationID: medicationId,
        });
      }
    }

    res.json({ message: 'Medication updated successfully' });
  } catch (error) {
    console.error('Error updating medication:', error);
    res.status(500).json({ message: 'Error updating medication' });
  }
});

// Delete medication (Admin only)
router.delete('/:medicationId', verifyToken, verifyAdmin, async (req, res) => {
  const medicationId = req.params.medicationId;

  try {
    const medication = await PatientMedication.findByPk(medicationId);

    if (!medication) {
      return res.status(404).json({ message: 'Medication not found' });
    }

    await medication.destroy();
    res.json({ message: 'Medication deleted successfully' });
  } catch (error) {
    console.error('Error deleting medication:', error);
    res.status(500).json({ message: 'Error deleting medication' });
  }
});

module.exports = router;
