const mongoose = require('mongoose');

const cardSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    deck: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Deck',
      required: true,
      index: true,
    },
    question: { type: String, required: true, trim: true },
    answer: { type: String, required: true, trim: true },
    repetitions: { type: Number, default: 0 },
    interval: { type: Number, default: 0 },
    easeFactor: { type: Number, default: 2.5 },
    nextReview: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

cardSchema.index({ user: 1, nextReview: 1 });

module.exports = mongoose.model('Card', cardSchema);