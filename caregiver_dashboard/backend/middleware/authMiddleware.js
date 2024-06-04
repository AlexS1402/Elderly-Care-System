const jwt = require('jsonwebtoken');
const { User } = require('../models');

const verifyToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.status(403).send({ message: 'No token provided.' });

  jwt.verify(token.split(' ')[1], process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(500).send({ message: 'Failed to authenticate token.' });
    req.userId = decoded.id;
    next();
  });
};

const verifyAdmin = async (req, res, next) => {
  try {
    console.log('Request userId:', req.userId); // Log the userId
    const user = await User.findByPk(req.userId);
    console.log('User:', user);  // Log the user object
    if (user && user.UserRole === 'Admin') {
      next();
    } else {
      res.status(403).send({ message: 'Require Admin Role!' });
    }
  } catch (error) {
    console.error('Error verifying admin:', error);  // Log any errors
    res.status(500).send({ message: 'Internal server error' });
  }
};

module.exports = { verifyToken, verifyAdmin };
