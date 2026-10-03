const mongoose = require('mongoose');

const deckSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: { type: String, required: true, trim: true, maxlength: 80 },
    description: { type: String, default: '', trim: true, maxlength: 300 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Deck', deckSchema);