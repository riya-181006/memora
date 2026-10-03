const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');
const deckRoutes = require('./routes/deck.routes');
const cardRoutes = require('./routes/card.routes');
const generateRoutes = require('./routes/generate.routes');
const { notFound, errorHandler } = require('./middleware/error.middleware');

const app = express();

app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.get('/api/health', (req, res) => {
  res.json({ ok: true });
});

app.use('/api/auth', authRoutes);
app.use('/api/decks', deckRoutes);
app.use('/api/cards', cardRoutes);
app.use('/api/generate', generateRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;