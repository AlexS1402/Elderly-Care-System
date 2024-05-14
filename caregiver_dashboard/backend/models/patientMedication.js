module.exports = (sequelize, DataTypes) => {
    const PatientMedication = sequelize.define('PatientMedication', {
      PatientMedicationID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      MedicationName: {
        type: DataTypes.STRING,
        allowNull: false
      },
      Dosage: {
        type: DataTypes.STRING,
        allowNull: false
      },
      StartDate: {
        type: DataTypes.DATE,
        allowNull: false
      },
      EndDate: {
        type: DataTypes.DATE,
        allowNull: true
      },
      FrequencyPerDay: {
        type: DataTypes.INTEGER,
        allowNull: false
      }
    }, {
      tableName: 'patientmedications',  // Specify the actual table name
      freezeTableName: true,
      timestamps: false
    });
  
    PatientMedication.associate = (models) => {
      PatientMedication.hasMany(models.MedicationSchedule, { foreignKey: 'PatientMedicationID' });
    };
  
    return PatientMedication;
  };
  