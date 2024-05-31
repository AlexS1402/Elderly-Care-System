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
    UserId: {
      type: DataTypes.INTEGER,
      references: {
        model: 'users', // name of the target model/table
        key: 'UserID', // key in the target model/table that we're referencing
      }
    },
  }, {
    tableName: 'patientprofiles',
    timestamps: false,
  });

  PatientProfile.associate = function(models) {
    PatientProfile.hasMany(models.PatientMedication, { foreignKey: 'ProfileID' });
    PatientProfile.belongsTo(models.User, { foreignKey: 'UserId' }); // Establish the association
  };

  return PatientProfile;
};
