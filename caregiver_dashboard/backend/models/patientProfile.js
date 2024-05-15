module.exports = (sequelize, DataTypes) => {
  const PatientProfile = sequelize.define('PatientProfile', {
    ProfileID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    FirstName: DataTypes.STRING,
    LastName: DataTypes.STRING,
    DOB: DataTypes.DATE,
    Gender: DataTypes.ENUM('Male', 'Female', 'Other'),
    Address: DataTypes.STRING,
    EmergencyContact: DataTypes.STRING,
    UserId: DataTypes.INTEGER,
  }, {
    tableName: 'patientprofiles',
    timestamps: false,
  });

  PatientProfile.associate = function(models) {
    PatientProfile.hasMany(models.PatientMedication, { foreignKey: 'ProfileID' });
  };

  return PatientProfile;
};
