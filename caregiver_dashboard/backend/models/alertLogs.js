module.exports = (sequelize, DataTypes) => {
    const AlertLog = sequelize.define('AlertLog', {
      AlertID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      AlertTimestamp: {
        type: DataTypes.DATE,
        allowNull: false
      },
      AlertType: {
        type: DataTypes.STRING,
        allowNull: false
      },
      ProfileID: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      Resolved: {
        type: DataTypes.BOOLEAN,
        allowNull: false
      }
    }, {
      tableName: 'alertlogs',
      freezeTableName: true,
      timestamps: false
    });

    AlertLog.associate = function(models) {
        AlertLog.belongsTo(models.PatientProfile, { foreignKey: 'ProfileID' });
      };
  
    return AlertLog;
  };
  