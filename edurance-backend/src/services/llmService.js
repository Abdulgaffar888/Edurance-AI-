const axios = require("axios");

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

// Priority order (fast → strong fallback)
const MODELS = [
  "nvidia/nemotron-nano-9b-v2:free",
  "google/gemma-3-27b-it:free",
];

async function callModel(model, messages) {
  const res = await axios.post(
    OPENROUTER_URL,
    {
      model,
      messages,
      temperature: 0.5,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://edurance.ai",
        "X-Title": "Edurance AI Tutor",
      },
      timeout: 20000,
    }
  );

  return res.data?.choices?.[0]?.message?.content;
}

async function generateLLMResponse(messages) {
  let lastError = null;

  for (const model of MODELS) {
    try {
      const text = await callModel(model, messages);
      if (text && text.trim().length > 0) {
        return text.trim();
      }
    } catch (err) {
      console.error(`❌ Model failed: ${model}`);
      console.error(err?.response?.data || err.message);
      lastError = err;
    }
  }

  throw new Error(
    lastError?.response?.data?.error?.message ||
      "All OpenRouter models failed"
  );
}

module.exports = { generateLLMResponse };
