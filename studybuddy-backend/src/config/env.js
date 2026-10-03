require('dotenv').config();

const required = ['MONGO_URI', 'JWT_SECRET'];

for (const key of required) {
  if (!process.env[key]) {
    console.error(`Missing env var: ${key}`);
    process.exit(1);
  }
}

module.exports = {
  port: Number(process.env.PORT) || 5000,
  mongoUri: process.env.MONGO_URI,
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '30d',
  llmApiKey: process.env.LLM_API_KEY || '',
  llmFallbackModel: process.env.GEMINI_FALLBACK_MODEL || '',
  llmModel: process.env.GEMINI_MODEL || 'gemini-3.8-flash',
};