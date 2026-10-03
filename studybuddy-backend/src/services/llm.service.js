const env = require('../config/env');
const httpError = require('../utils/httpError');

const BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';
const RETRYABLE = new Set([500, 502, 503, 504]);
const MAX_ATTEMPTS = 3;

const SYSTEM_PROMPT =
  'You turn study notes into flashcards. Reply with a JSON array only, no other text.';

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function buildPrompt(text, count) {
  return [
    `Make up to ${count} flashcards from the notes below.`,
    'Return a JSON array like: [{"question": "...", "answer": "..."}]',
    'Rules:',
    '- Use only facts that are in the notes.',
    '- One idea per card. Keep questions clear and answers short (1 to 2 sentences).',
    '- No duplicate cards.',
    '- The notes come from OCR and may have typos. Fix obvious ones.',
    '- Write in the same language as the notes.',
    '',
    'Notes:',
    text,
  ].join('\n');
}

function parseCards(raw, count) {
  const start = raw.indexOf('[');
  const end = raw.lastIndexOf(']');
  if (start === -1 || end === -1 || end <= start) {
    throw httpError(502, 'The AI sent a bad response. Try again.');
  }

  let parsed;
  try {
    parsed = JSON.parse(raw.slice(start, end + 1));
  } catch (e) {
    throw httpError(502, 'The AI sent a bad response. Try again.');
  }

  if (!Array.isArray(parsed)) {
    throw httpError(502, 'The AI sent a bad response. Try again.');
  }

  return parsed
    .map((c) => ({
      question: String((c && c.question) || '').trim(),
      answer: String((c && c.answer) || '').trim(),
    }))
    .filter((c) => c.question && c.answer)
    .slice(0, count);
}

function extractCards(data, count) {
  if (data.promptFeedback && data.promptFeedback.blockReason) {
    throw httpError(400, 'The AI could not use this text. Try different notes.');
  }

  const parts =
    (data.candidates &&
      data.candidates[0] &&
      data.candidates[0].content &&
      data.candidates[0].content.parts) ||
    [];
  const raw = parts.map((p) => p.text || '').join('');

  return parseCards(raw, count);
}

function errorFor(status, body) {
  if (status === 429) {
    return httpError(429, 'Free AI limit reached. Wait a minute and try again.');
  }
  if (status === 503) {
    return httpError(503, 'The AI is busy right now. Try again in a minute.');
  }

  let reason = '';
  try {
    reason = JSON.parse(body).error.message || '';
  } catch (e) {
    reason = body.slice(0, 150);
  }
  return httpError(502, `AI error ${status}: ${reason}`.slice(0, 220));
}

async function requestModel(model, text, count) {
  try {
    return await fetch(`${BASE_URL}/${model}:generateContent`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-goog-api-key': env.llmApiKey,
      },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents: [{ role: 'user', parts: [{ text: buildPrompt(text, count) }] }],
        generationConfig: {
          responseMimeType: 'application/json',
          temperature: 0.4,
          maxOutputTokens: 8000,
        },
      }),
    });
  } catch (e) {
    console.error(`LLM request failed (${model}):`, e.message);
    return null;
  }
}

async function generateCards(text, count) {
  if (!env.llmApiKey) {
    throw httpError(500, 'AI is not set up on the server yet.');
  }

  const models = [...new Set([env.llmModel, env.llmFallbackModel].filter(Boolean))];
  let lastError = httpError(502, 'The AI service failed. Try again.');

  for (const model of models) {
    for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
      const res = await requestModel(model, text, count);

      if (!res) {
        lastError = httpError(502, 'Could not reach the AI service. Try again.');
        if (attempt < MAX_ATTEMPTS) await sleep(1500 * attempt);
        continue;
      }

      if (res.ok) {
        return extractCards(await res.json(), count);
      }

      const body = await res.text();
      console.error(`LLM error ${res.status} (${model})`, body);
      lastError = errorFor(res.status, body);

      if (RETRYABLE.has(res.status) && attempt < MAX_ATTEMPTS) {
        await sleep(2000 * attempt);
        continue;
      }
      break;
    }
  }

  throw lastError;
}

module.exports = { generateCards };