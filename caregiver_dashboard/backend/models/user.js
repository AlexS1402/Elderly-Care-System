module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    UserID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    Email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    PasswordHash: {
      type: DataTypes.STRING,
      allowNull: false
    },
    Username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    UserRole: {
      type: DataTypes.ENUM('Admin', 'Caregiver', 'Patient'),
      allowNull: false
    }
  }, {
    tableName: 'users',
    freezeTableName: true,
    timestamps: false
  });

  return User;
};
