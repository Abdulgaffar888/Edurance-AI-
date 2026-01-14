const fs = require("fs");
const path = require("path");
const OpenAI = require("openai");

const DATA_PATH = path.join(__dirname, "ncert_data.json");
const STORE_PATH = path.join(__dirname, "vector_store.json");

function mustGetApiKey() {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is required to run ingest.");
  }
  return apiKey;
}

async function embedTexts(texts) {
  const openai = new OpenAI({ apiKey: mustGetApiKey() });
  const resp = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: texts,
  });
  return resp.data.map((d) => d.embedding);
}

async function ingest() {
  const raw = fs.readFileSync(DATA_PATH, "utf8");
  const chunks = JSON.parse(raw);
  if (!Array.isArray(chunks) || chunks.length === 0) {
    throw new Error("ncert_data.json must be a non-empty JSON array.");
  }

  const texts = chunks.map((c) => c.text);
  const embeddings = await embedTexts(texts);

  const store = {
    version: 1,
    embedding_model: "text-embedding-3-small",
    createdAt: new Date().toISOString(),
    items: chunks.map((c, idx) => ({
      id: c.id,
      text: c.text,
      difficulty: c.difficulty,
      embedding: embeddings[idx],
    })),
  };

  fs.writeFileSync(STORE_PATH, JSON.stringify(store, null, 2), "utf8");
  console.log(`✅ Vector store written: ${STORE_PATH}`);
}

if (require.main === module) {
  ingest().catch((err) => {
    console.error("❌ Ingest failed:", err);
    process.exitCode = 1;
  });
}

module.exports = { ingest };


