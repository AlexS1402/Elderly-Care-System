module.exports = (sequelize, DataTypes) => {
  const PatientProfile = sequelize.define('PatientProfile', {
    ProfileID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    FirstName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    LastName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    DOB: {
      type: DataTypes.DATE,
      allowNull: false
    },
    Gender: {
      type: DataTypes.ENUM('Male', 'Female', 'Other'),
      allowNull: false
    },
    Address: {
      type: DataTypes.STRING,
      allowNull: true
    },
    EmergencyContact: {
      type: DataTypes.STRING,
      allowNull: true
    },
    UserId: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  }, {
    tableName: 'patientprofiles',
    freezeTableName: true,
    timestamps: false
  });

  PatientProfile.associate = (models) => {
    PatientProfile.belongsTo(models.User, { foreignKey: 'UserId' });
    PatientProfile.hasMany(models.SensorDataHistory, { foreignKey: 'ProfileID' });
  };

  return PatientProfile;
};
