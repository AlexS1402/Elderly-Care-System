module.exports = (sequelize, DataTypes) => {
    const MedicationSchedule = sequelize.define('MedicationSchedule', {
      ScheduleID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ScheduledTime: DataTypes.TIME,
      PatientMedicationID: DataTypes.INTEGER,
    }, {
      tableName: 'medicationschedules',
      timestamps: false,
    });
  
    MedicationSchedule.associate = function(models) {
      MedicationSchedule.belongsTo(models.PatientMedication, { foreignKey: 'PatientMedicationID' });
    };
  
    return MedicationSchedule;
  };
  