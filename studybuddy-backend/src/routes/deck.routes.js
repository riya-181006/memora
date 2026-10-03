const express = require('express');
const { list, create, update, remove } = require('../controllers/deck.controller');
const { listByDeck } = require('../controllers/card.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);

router.get('/', list);
router.post('/', create);
router.put('/:id', update);
router.delete('/:id', remove);
router.get('/:id/cards', listByDeck);

module.exports = router;