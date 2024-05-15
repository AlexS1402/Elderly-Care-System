module.exports = (sequelize, DataTypes) => {
  const SensorDataHistory = sequelize.define('SensorDataHistory', {
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
  }, {
    tableName: 'sensordatahistory' // Specify the table name explicitly
  });

  SensorDataHistory.associate = (models) => {
    SensorDataHistory.belongsTo(models.PatientProfile, {
      foreignKey: 'ProfileID',
      as: 'patientProfile'
    });
  };

  return SensorDataHistory;
};
