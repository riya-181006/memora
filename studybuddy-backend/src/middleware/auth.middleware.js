const jwt = require('jsonwebtoken');
const env = require('../config/env');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

const protect = asyncHandler(async (req, res, next) => {
  const header = req.headers.authorization || '';

  if (!header.startsWith('Bearer ')) {
    throw httpError(401, 'Please log in to continue.');
  }

  const token = header.split(' ')[1];
  let decoded;

  try {
    decoded = jwt.verify(token, env.jwtSecret);
  } catch (e) {
    throw httpError(401, 'Your session expired. Log in again.');
  }

  const user = await User.findById(decoded.id);
  if (!user) {
    throw httpError(401, 'Account not found. Log in again.');
  }

  req.user = user;
  next();
});

module.exports = { protect };