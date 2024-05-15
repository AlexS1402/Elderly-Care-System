module.exports = (sequelize, DataTypes) => {
    const PatientMedication = sequelize.define('PatientMedication', {
      PatientMedicationID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      MedicationName: DataTypes.STRING,
      Dosage: DataTypes.STRING,
      FrequencyPerDay: DataTypes.INTEGER,
      StartDate: DataTypes.DATE,
      EndDate: DataTypes.DATE,
      ProfileID: DataTypes.INTEGER,
    }, {
      tableName: 'patientmedications',
      timestamps: false,
    });
  
    PatientMedication.associate = function(models) {
      PatientMedication.hasMany(models.MedicationSchedule, { foreignKey: 'PatientMedicationID' });
      PatientMedication.belongsTo(models.PatientProfile, { foreignKey: 'ProfileID' });
    };
  
    return PatientMedication;
  };
  