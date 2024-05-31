const express = require("express");
const router = express.Router();
const {
  PatientProfile,
  PatientMedication,
  MedicationSchedule,
  Sequelize,
} = require("../models");
const { verifyToken, verifyAdmin } = require("../middleware/authMiddleware");

// Middleware to log request body
router.use(express.json());

// Get patients for a specific caregiver with optional search query and pagination
router.get("/:userId", verifyToken, async (req, res) => {
  const userId = req.params.userId;
  const searchQuery = req.query.search || "";
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
      attributes: [
        "ProfileID",
        "FirstName",
        "LastName",
        "DOB",
        "Gender",
        "Address",
        "EmergencyContact",
      ],
      limit: pageSize,
      offset: offset,
    });

    const totalPages = Math.ceil(count / pageSize);
    res.json({ patients: rows, totalPages });
  } catch (error) {
    console.error("Error fetching patients:", error);
    res.status(500).json({ message: "Error fetching patients" });
  }
});

// Get patient details along with their medications and schedules
router.get("/detail/:patientId", verifyToken, async (req, res) => {
  const patientId = req.params.patientId;

  try {
    const patientProfile = await PatientProfile.findByPk(patientId, {
      include: [
        {
          model: PatientMedication,
          include: [MedicationSchedule],
        },
      ],
    });

    if (!patientProfile) {
      return res.status(404).json({ message: "Patient not found" });
    }

    res.json(patientProfile);
  } catch (error) {
    console.error("Error fetching patient details:", error);
    res.status(500).json({ message: "Error fetching patient details" });
  }
});

// Get all patient information (Admin only)
router.get("/", verifyToken, verifyAdmin, async (req, res) => {
  try {
    const patients = await PatientProfile.findAll();
    res.json(patients);
  } catch (error) {
    console.error("Error fetching patients:", error);
    res.status(500).json({ message: "Error fetching patients" });
  }
});

// Add a new patient (Admin only)
router.post("/", verifyToken, verifyAdmin, async (req, res) => {
  const {
    firstName,
    lastName,
    dob,
    gender,
    address,
    emergencyContact,
    userId,
  } = req.body;
  try {
    const newPatient = await PatientProfile.create({
      FirstName: firstName,
      LastName: lastName,
      DOB: dob,
      Gender: gender,
      Address: address,
      EmergencyContact: emergencyContact,
      UserId: userId,
    });
    res.status(201).json(newPatient);
  } catch (error) {
    console.error("Error adding new patient:", error);
    res.status(500).json({ message: "Error adding new patient" });
  }
});

// Edit patient information (Admin only)
router.put("/:patientId", verifyToken, verifyAdmin, async (req, res) => {
  try {
    const patientId = req.params.patientId;
    const {
      firstName,
      lastName,
      dob,
      gender,
      address,
      emergencyContact,
      userId,
    } = req.body;

    const updated = await PatientProfile.update(
      {
        FirstName: firstName,
        LastName: lastName,
        DOB: dob,
        Gender: gender,
        Address: address,
        EmergencyContact: emergencyContact,
        UserId: userId,
      },
      {
        where: { ProfileID: patientId },
      }
    );

    if (updated[0] === 0) {
      res.status(404).send({ error: "Patient not found" });
    } else {
      res.send({ message: "Patient updated successfully" });
    }
  } catch (error) {
    console.error("Error updating patient:", error);
    res.status(500).send({ error: "Error updating patient" });
  }
});

// Delete a patient (Admin only)
router.delete("/:patientId", verifyToken, verifyAdmin, async (req, res) => {
  const patientId = req.params.patientId;
  try {
    const patient = await PatientProfile.findByPk(patientId);
    if (patient) {
      await patient.destroy();
      res.status(200).json({ message: "Patient deleted" });
    } else {
      res.status(404).json({ message: "Patient not found" });
    }
  } catch (error) {
    console.error("Error deleting patient:", error);
    res.status(500).json({ message: "Error deleting patient" });
  }
});

module.exports = router;
