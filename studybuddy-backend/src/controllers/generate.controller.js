const { generateCards } = require('../services/llm.service');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

const MAX_TEXT = 12000;

const generate = asyncHandler(async (req, res) => {
  let text = String(req.body.text || '').trim();
  const count = Math.min(20, Math.max(1, parseInt(req.body.count, 10) || 10));

  if (text.length < 30) {
    throw httpError(400, 'Add a bit more text (30+ characters).');
  }
  if (text.length > MAX_TEXT) {
    text = text.slice(0, MAX_TEXT);
  }

  const cards = await generateCards(text, count);
  res.json({ cards });
});

module.exports = { generate };