function notFound(req, res, next) {
  res.status(404).json({ message: `Route not found: ${req.originalUrl}` });
}

function errorHandler(err, req, res, next) {
  let status = err.status || 500;
  let message = err.message || 'Something went wrong.';

  if (err.name === 'ValidationError') {
    status = 400;
    message = Object.values(err.errors)
      .map((e) => e.message)
      .join(', ');
  } else if (err.code === 11000) {
    status = 409;
    message = 'That email is already registered.';
  } else if (err.name === 'CastError') {
    status = 400;
    message = 'Invalid id.';
  }

    if (status >= 500) {
    console.error(err);
    if (!err.status) {
      message = 'Server error. Try again.';
    }
  }

  res.status(status).json({ message });
}

module.exports = { notFound, errorHandler };