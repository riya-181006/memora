const Card = require('../models/Card');
const Deck = require('../models/Deck');
const { applyReview } = require('../services/sm2.service');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

function publicCard(card) {
  return {
    id: card._id.toString(),
    deckId: card.deck.toString(),
    question: card.question,
    answer: card.answer,
    repetitions: card.repetitions,
    interval: card.interval,
    easeFactor: card.easeFactor,
    nextReview: card.nextReview,
  };
}

async function requireDeck(userId, deckId) {
  const deck = await Deck.findOne({ _id: deckId, user: userId });
  if (!deck) {
    throw httpError(404, 'Deck not found.');
  }
  return deck;
}

const listByDeck = asyncHandler(async (req, res) => {
  await requireDeck(req.user._id, req.params.id);
  const cards = await Card.find({
    user: req.user._id,
    deck: req.params.id,
  }).sort({ createdAt: -1 });
  res.json(cards.map(publicCard));
});

const due = asyncHandler(async (req, res) => {
  const cards = await Card.find({
    user: req.user._id,
    nextReview: { $lte: new Date() },
  })
    .sort({ nextReview: 1 })
    .limit(100);
  res.json(cards.map(publicCard));
});

const create = asyncHandler(async (req, res) => {
  const deckId = String(req.body.deckId || '');
  const question = String(req.body.question || '').trim();
  const answer = String(req.body.answer || '').trim();

  if (!deckId || !question || !answer) {
    throw httpError(400, 'Deck, question, and answer are required.');
  }

  await requireDeck(req.user._id, deckId);

  const card = await Card.create({
    user: req.user._id,
    deck: deckId,
    question,
    answer,
  });
  res.status(201).json(publicCard(card));
});

const update = asyncHandler(async (req, res) => {
  const card = await Card.findOne({ _id: req.params.id, user: req.user._id });
  if (!card) {
    throw httpError(404, 'Card not found.');
  }

  const question = String(req.body.question || '').trim();
  const answer = String(req.body.answer || '').trim();
  if (!question || !answer) {
    throw httpError(400, 'Question and answer are required.');
  }

  card.question = question;
  card.answer = answer;
  await card.save();
  res.json(publicCard(card));
});

const remove = asyncHandler(async (req, res) => {
  const card = await Card.findOneAndDelete({
    _id: req.params.id,
    user: req.user._id,
  });
  if (!card) {
    throw httpError(404, 'Card not found.');
  }
  res.json({ message: 'Card deleted.' });
});

const review = asyncHandler(async (req, res) => {
  const quality = Number(req.body.quality);
  if (!Number.isFinite(quality) || quality < 0 || quality > 5) {
    throw httpError(400, 'Quality must be a number from 0 to 5.');
  }

  const card = await Card.findOne({ _id: req.params.id, user: req.user._id });
  if (!card) {
    throw httpError(404, 'Card not found.');
  }

  Object.assign(card, applyReview(card, quality));
  await card.save();
  res.json(publicCard(card));
});

module.exports = { listByDeck, due, create, update, remove, review };