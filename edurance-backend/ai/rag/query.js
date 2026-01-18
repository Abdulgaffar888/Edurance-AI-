// src/ai/rag/query.js
const fs = require("fs");
const path = require("path");
const OpenAI = require("openai");

const DATA_PATH = path.join(__dirname, "ncert_data.json");
const STORE_PATH = path.join(__dirname, "vector_store.json");

// Simple keyword similarity (fallback when embeddings fail)
function simpleSimilarity(query, text) {
  const queryWords = new Set(query.toLowerCase().split(/\W+/).filter(w => w.length > 2));
  const textWords = new Set(text.toLowerCase().split(/\W+/).filter(w => w.length > 2));
  
  let matches = 0;
  for (const word of queryWords) {
    if (textWords.has(word)) matches++;
  }
  
  return matches / Math.max(queryWords.size, 1);
}

// Cosine similarity for embeddings
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
    throw new Error("OPENAI_API_KEY is required for embeddings.");
  }
  const openai = new OpenAI({ apiKey });
  
  try {
    const resp = await openai.embeddings.create({
      model: "text-embedding-3-small",
      input: text,
    });
    return resp.data[0].embedding;
  } catch (error) {
    console.error("Embedding API Error:", error.message);
    throw error; // Re-throw so caller knows it failed
  }
}

async function ensureVectorStore() {
  if (fs.existsSync(STORE_PATH)) {
    console.log("Vector store exists, loading...");
    return true;
  }

  console.log("Building vector store...");
  
  const raw = fs.readFileSync(DATA_PATH, "utf8");
  const chunks = JSON.parse(raw);
  const apiKey = getApiKey();
  
  if (!apiKey) {
    console.warn("No API key for embeddings. Will use keyword matching.");
    return false;
  }
  
  const openai = new OpenAI({ apiKey });
  
  try {
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
    console.log(`✅ Vector store created with ${chunks.length} items`);
    return true;
    
  } catch (error) {
    console.error("❌ Failed to create vector store:", error.message);
    console.log("Will use keyword matching instead.");
    return false;
  }
}

function loadStore() {
  if (!fs.existsSync(STORE_PATH)) return null;
  try {
    return JSON.parse(fs.readFileSync(STORE_PATH, "utf8"));
  } catch (error) {
    console.error("Error loading vector store:", error.message);
    return null;
  }
}

function loadRawChunks() {
  try {
    return JSON.parse(fs.readFileSync(DATA_PATH, "utf8"));
  } catch (error) {
    console.error("Error loading raw chunks:", error.message);
    return [];
  }
}

/**
 * Smart RAG query: tries embeddings first, falls back to keyword matching
 */
async function queryRag({ userMessage, clearedConceptIds = [], topK = 3 }) {
  const cleared = new Set(Array.isArray(clearedConceptIds) ? clearedConceptIds : []);
  
  // Always load raw data as fallback
  const rawChunks = loadRawChunks();
  const availableChunks = rawChunks.filter(c => !cleared.has(c.id));
  
  if (availableChunks.length === 0) {
    console.log("No chunks available after filtering cleared concepts");
    return { chunks: [] };
  }

  try {
    // Try to use embeddings if vector store exists
    const hasVectorStore = await ensureVectorStore();
    const store = loadStore();
    
    if (hasVectorStore && store && store.items && store.items.length > 0) {
      console.log("Using embeddings-based RAG...");
      
      try {
        const q = await embedQuery(userMessage);
        
        const ranked = store.items
          .filter(it => !cleared.has(it.id))
          .map(it => ({
            id: it.id,
            text: it.text,
            difficulty: it.difficulty,
            score: cosineSimilarity(q, it.embedding),
          }))
          .sort((a, b) => b.score - a.score)
          .slice(0, Math.max(1, topK));

        console.log(`Found ${ranked.length} chunks via embeddings`);
        return { chunks: ranked };
        
      } catch (embedError) {
        console.log("Embeddings failed, falling back to keyword matching...");
        // Fall through to keyword matching
      }
    }
  } catch (error) {
    console.log("Embedding system error, using keyword matching:", error.message);
  }

  // Fallback: keyword matching
  console.log("Using keyword-based RAG...");
  
  const ranked = availableChunks
    .map(c => ({
      id: c.id,
      text: c.text,
      difficulty: c.difficulty,
      score: simpleSimilarity(userMessage, c.text),
    }))
    .sort((a, b) => b.score - a.score)
    .slice(0, Math.max(1, topK));

  // If no keywords match, return first few chunks
  if (ranked.length === 0 || ranked[0].score === 0) {
    console.log("No keyword matches, returning first available chunks");
    const fallback = availableChunks
      .slice(0, Math.max(1, topK))
      .map(c => ({
        id: c.id,
        text: c.text,
        difficulty: c.difficulty,
        score: 0
      }));
    return { chunks: fallback };
  }

  console.log(`Found ${ranked.length} chunks via keywords`);
  return { chunks: ranked };
}

module.exports = { queryRag };