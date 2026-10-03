const Deck = require('../models/Deck');
const Card = require('../models/Card');
const asyncHandler = require('../utils/asyncHandler');
const httpError = require('../utils/httpError');

async function countsFor(userId, deckIds) {
  const rows = await Card.aggregate([
    { $match: { user: userId, deck: { $in: deckIds } } },
    {
      $group: {
        _id: '$deck',
        cardCount: { $sum: 1 },
        dueCount: {
          $sum: { $cond: [{ $lte: ['$nextReview', new Date()] }, 1, 0] },
        },
      },
    },
  ]);

  const map = {};
  for (const r of rows) {
    map[r._id.toString()] = { cardCount: r.cardCount, dueCount: r.dueCount };
  }
  return map;
}

function publicDeck(deck, counts) {
  const c = (counts && counts[deck._id.toString()]) || {};
  return {
    id: deck._id.toString(),
    title: deck.title,
    description: deck.description,
    cardCount: c.cardCount || 0,
    dueCount: c.dueCount || 0,
    createdAt: deck.createdAt,
  };
}

const list = asyncHandler(async (req, res) => {
  const decks = await Deck.find({ user: req.user._id }).sort({ createdAt: -1 });
  const counts = await countsFor(
    req.user._id,
    decks.map((d) => d._id)
  );
  res.json(decks.map((d) => publicDeck(d, counts)));
});

const create = asyncHandler(async (req, res) => {
  const title = String(req.body.title || '').trim();
  const description = String(req.body.description || '').trim();

  if (!title) {
    throw httpError(400, 'Deck name is required.');
  }

  const deck = await Deck.create({ user: req.user._id, title, description });
  res.status(201).json(publicDeck(deck, {}));
});

const update = asyncHandler(async (req, res) => {
  const deck = await Deck.findOne({ _id: req.params.id, user: req.user._id });
  if (!deck) {
    throw httpError(404, 'Deck not found.');
  }

  const title = String(req.body.title || '').trim();
  if (!title) {
    throw httpError(400, 'Deck name is required.');
  }

  deck.title = title;
  deck.description = String(req.body.description || '').trim();
  await deck.save();

  const counts = await countsFor(req.user._id, [deck._id]);
  res.json(publicDeck(deck, counts));
});

const remove = asyncHandler(async (req, res) => {
  const deck = await Deck.findOneAndDelete({
    _id: req.params.id,
    user: req.user._id,
  });
  if (!deck) {
    throw httpError(404, 'Deck not found.');
  }

  await Card.deleteMany({ deck: deck._id, user: req.user._id });
  res.json({ message: 'Deck deleted.' });
});

module.exports = { list, create, update, remove };