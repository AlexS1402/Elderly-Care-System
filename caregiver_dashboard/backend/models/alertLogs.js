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
      tableName: 'alertlogs',  // Specify the actual table name
      freezeTableName: true,
      timestamps: false
    });
  
    return AlertLog;
  };
  