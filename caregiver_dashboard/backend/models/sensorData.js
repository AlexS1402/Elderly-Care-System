module.exports = (sequelize, DataTypes) => {
  const SensorData = sequelize.define('SensorData', {
    DataHistoryID: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    ProfileID: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    SensorType: {
      type: DataTypes.STRING,
      allowNull: false
    },
    Timestamp: {
      type: DataTypes.DATE,
      allowNull: false
    },
    Value: {
      type: DataTypes.DOUBLE,
      allowNull: false
    }
  });

  SensorData.associate = (models) => {
    SensorData.belongsTo(models.PatientProfile, {
      foreignKey: 'ProfileID',
      as: 'patientProfile'
    });
  };

  return SensorData;
};
