const express = require('express');
const {
  due,
  create,
  update,
  remove,
  review,
} = require('../controllers/card.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);

router.get('/due', due);
router.post('/', create);
router.put('/:id', update);
router.delete('/:id', remove);
router.post('/:id/review', review);

module.exports = router;