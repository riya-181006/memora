const express = require('express');
const { generate } = require('../controllers/generate.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/', protect, generate);

module.exports = router;