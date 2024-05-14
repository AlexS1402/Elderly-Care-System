module.exports = (sequelize, DataTypes) => {
    const SensorDataHistory = sequelize.define('SensorDataHistory', {
      DataHistoryID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
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
      tableName: 'sensordatahistory',
      freezeTableName: true,
      timestamps: false
    });
  
    SensorDataHistory.associate = (models) => {
      SensorDataHistory.belongsTo(models.PatientProfile, { foreignKey: 'ProfileID' });
    };
  
    return SensorDataHistory;
  };
  