const express = require("express");
const { queryRag } = require("../rag/query");
const { runTutorAgent } = require("./agent");

const router = express.Router();

// In-memory sessions store: session_id -> { clearedConcepts: string[] }
const sessions = Object.create(null);

function getOrCreateSession(session_id) {
  if (!session_id || typeof session_id !== "string") return null;
  if (!sessions[session_id]) {
    sessions[session_id] = { session_id, clearedConcepts: [] };
  }
  if (!Array.isArray(sessions[session_id].clearedConcepts)) {
    sessions[session_id].clearedConcepts = [];
  }
  return sessions[session_id];
}

function ensureSchemaResponse(obj) {
  return {
    teaching_point: typeof obj?.teaching_point === "string" ? obj.teaching_point : "That's interesting, but let's stick to our NCERT circuits chapter!",
    question: typeof obj?.question === "string" ? obj.question : "Can you tell me what a switch does in a circuit?",
    concept_id: typeof obj?.concept_id === "string" ? obj.concept_id : "switch_01",
    is_concept_cleared: typeof obj?.is_concept_cleared === "boolean" ? obj.is_concept_cleared : false,
  };
}

// POST /api/tutor/chat (mounted at /api/tutor)
router.post("/chat", async (req, res) => {
  try {
    const { message, session_id } = req.body || {};
    if (typeof message !== "string" || message.trim().length === 0) {
      return res.status(400).json(
        ensureSchemaResponse({
          teaching_point: "Please type a question about electric cells, bulbs, circuits, or switches.",
          question: "What do you want to learn first: cell, bulb, circuit, or switch?",
          concept_id: "circuit_01",
          is_concept_cleared: false,
        })
      );
    }
    if (typeof session_id !== "string" || session_id.trim().length === 0) {
      return res.status(400).json(
        ensureSchemaResponse({
          teaching_point: "Please include a session_id so I can track what you've mastered.",
          question: "Can you resend your message with a session_id?",
          concept_id: "circuit_01",
          is_concept_cleared: false,
        })
      );
    }

    const session = getOrCreateSession(session_id.trim());
    const cleared = session?.clearedConcepts || [];

    const rag = await queryRag({
      userMessage: message,
      clearedConceptIds: cleared,
      topK: 1,
    });

    const context = rag?.chunks || [];
    const agentResp = await runTutorAgent({ message, session, context });
    const finalResp = ensureSchemaResponse(agentResp);

    // Update session memory if concept cleared
    if (finalResp.is_concept_cleared && typeof finalResp.concept_id === "string") {
      if (!session.clearedConcepts.includes(finalResp.concept_id)) {
        session.clearedConcepts.push(finalResp.concept_id);
      }
    }

    return res.json(finalResp);
  } catch (e) {
    return res.status(200).json(
      ensureSchemaResponse({
        teaching_point: "That's interesting, but let's stick to our NCERT circuits chapter!",
        question: "Can you tell me what makes a circuit complete?",
        concept_id: "circuit_01",
        is_concept_cleared: false,
      })
    );
  }
});

module.exports = router;


