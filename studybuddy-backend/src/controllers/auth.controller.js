const jwt = require('jsonwebtoken');
const env = require('../config/env');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

function signToken(userId) {
  return jwt.sign({ id: userId }, env.jwtSecret, {
    expiresIn: env.jwtExpiresIn,
  });
}

function publicUser(user) {
  return { id: user._id.toString(), name: user.name, email: user.email };
}

const register = asyncHandler(async (req, res) => {
  const name = String(req.body.name || '').trim();
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');

  if (!name || !email || !password) {
    throw httpError(400, 'Name, email, and password are required.');
  }
  if (!email.includes('@')) {
    throw httpError(400, 'Enter a valid email.');
  }
  if (password.length < 6) {
    throw httpError(400, 'Password must be at least 6 characters.');
  }

  const exists = await User.findOne({ email });
  if (exists) {
    throw httpError(409, 'That email is already registered.');
  }

  const user = await User.create({ name, email, password });

  res.status(201).json({ token: signToken(user._id), user: publicUser(user) });
});

const login = asyncHandler(async (req, res) => {
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');

  if (!email || !password) {
    throw httpError(400, 'Email and password are required.');
  }

  const user = await User.findOne({ email }).select('+password');
  const ok = user && (await user.comparePassword(password));

  if (!ok) {
    throw httpError(401, 'Wrong email or password.');
  }

  res.json({ token: signToken(user._id), user: publicUser(user) });
});

const me = asyncHandler(async (req, res) => {
  res.json({ user: publicUser(req.user) });
});

module.exports = { register, login, me };