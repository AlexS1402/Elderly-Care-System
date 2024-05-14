module.exports = (sequelize, DataTypes) => {
    const MedicationSchedule = sequelize.define('MedicationSchedule', {
      ScheduleID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      PatientMedicationID: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      ScheduledTime: {
        type: DataTypes.TIME,
        allowNull: false
      }
    }, {
      tableName: 'medicationschedules',  // Specify the actual table name
      freezeTableName: true,
      timestamps: false
    });
  
    MedicationSchedule.associate = (models) => {
      MedicationSchedule.belongsTo(models.PatientMedication, { foreignKey: 'PatientMedicationID' });
    };
  
    return MedicationSchedule;
  };
  