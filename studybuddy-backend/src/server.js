const env = require('./config/env');
const connectDB = require('./config/db');
const app = require('./app');

async function start() {
  try {
    await connectDB();
    app.listen(env.port, '0.0.0.0', () => {
      console.log(`API running on port ${env.port}`);
    });
  } catch (e) {
    console.error('Could not start the server:', e.message);
    process.exit(1);
  }
}

start();