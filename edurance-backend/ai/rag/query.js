const fs = require("fs");
const path = require("path");
const OpenAI = require("openai");

const DATA_PATH = path.join(__dirname, "ncert_data.json");
const STORE_PATH = path.join(__dirname, "vector_store.json");

function cosineSimilarity(a, b) {
  let dot = 0;
  let na = 0;
  let nb = 0;
  const len = Math.min(a.length, b.length);
  for (let i = 0; i < len; i++) {
    const av = a[i];
    const bv = b[i];
    dot += av * bv;
    na += av * av;
    nb += bv * bv;
  }
  const denom = Math.sqrt(na) * Math.sqrt(nb);
  return denom === 0 ? 0 : dot / denom;
}

function getApiKey() {
  return process.env.OPENAI_API_KEY || null;
}

async function embedQuery(text) {
  const apiKey = getApiKey();
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is required for tutor RAG embeddings.");
  }
  const openai = new OpenAI({ apiKey });
  const resp = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: text,
  });
  return resp.data[0].embedding;
}

async function ensureVectorStore() {
  if (fs.existsSync(STORE_PATH)) return;

  // Lazy ingest on first query so the server works out-of-the-box.
  const raw = fs.readFileSync(DATA_PATH, "utf8");
  const chunks = JSON.parse(raw);
  const apiKey = getApiKey();
  if (!apiKey) {
    // Can't build embeddings without key; leave store missing.
    return;
  }
  const openai = new OpenAI({ apiKey });
  const resp = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: chunks.map((c) => c.text),
  });
  const store = {
    version: 1,
    embedding_model: "text-embedding-3-small",
    createdAt: new Date().toISOString(),
    items: chunks.map((c, idx) => ({
      id: c.id,
      text: c.text,
      difficulty: c.difficulty,
      embedding: resp.data[idx].embedding,
    })),
  };
  fs.writeFileSync(STORE_PATH, JSON.stringify(store, null, 2), "utf8");
}

function loadStore() {
  if (!fs.existsSync(STORE_PATH)) return null;
  try {
    return JSON.parse(fs.readFileSync(STORE_PATH, "utf8"));
  } catch {
    return null;
  }
}

function loadRawChunks() {
  try {
    return JSON.parse(fs.readFileSync(DATA_PATH, "utf8"));
  } catch {
    return [];
  }
}

/**
 * queryRag
 * - userMessage: string
 * - clearedConceptIds: string[] (filter out mastered chunks)
 * Returns: { chunks: [{id,text,difficulty,score}] }
 */
async function queryRag({ userMessage, clearedConceptIds = [], topK = 3 }) {
  await ensureVectorStore();
  const cleared = new Set(Array.isArray(clearedConceptIds) ? clearedConceptIds : []);

  const store = loadStore();
  if (!store || !Array.isArray(store.items) || store.items.length === 0) {
    // Fallback: return raw chunks (unranked) excluding cleared ones.
    const raw = loadRawChunks().filter((c) => !cleared.has(c.id));
    return {
      chunks: raw.slice(0, Math.max(1, topK)).map((c) => ({
        id: c.id,
        text: c.text,
        difficulty: c.difficulty,
        score: 0,
      })),
    };
  }

  const q = await embedQuery(userMessage);
  const ranked = store.items
    .filter((it) => !cleared.has(it.id))
    .map((it) => ({
      id: it.id,
      text: it.text,
      difficulty: it.difficulty,
      score: cosineSimilarity(q, it.embedding),
    }))
    .sort((a, b) => b.score - a.score)
    .slice(0, Math.max(1, topK));

  return { chunks: ranked };
}

module.exports = { queryRag };


