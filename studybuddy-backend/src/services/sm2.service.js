const DAY_MS = 24 * 60 * 60 * 1000;

function applyReview(card, rawQuality) {
  const quality = Math.min(5, Math.max(0, Math.round(rawQuality)));

  let repetitions = card.repetitions;
  let interval = card.interval;
  let easeFactor = card.easeFactor;

  if (quality < 3) {
    repetitions = 0;
    interval = 1;
  } else {
    if (repetitions === 0) {
      interval = 1;
    } else if (repetitions === 1) {
      interval = 6;
    } else {
      interval = Math.round(interval * easeFactor);
    }
    repetitions += 1;
  }

  const miss = 5 - quality;
  easeFactor = easeFactor + (0.1 - miss * (0.08 + miss * 0.02));
  if (easeFactor < 1.3) easeFactor = 1.3;

  return {
    repetitions,
    interval,
    easeFactor: Math.round(easeFactor * 100) / 100,
    nextReview: new Date(Date.now() + interval * DAY_MS),
  };
}

module.exports = { applyReview };