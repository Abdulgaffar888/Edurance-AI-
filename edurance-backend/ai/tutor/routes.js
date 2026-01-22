const express = require("express");
const { queryRag } = require("../rag/query");
const { runTutorAgent } = require("./agent.js");
const { startDiagnosticTest, submitDiagnosticTest } = require("./diagnostic.js");
const { getLearningProgress } = require("./progress.js");

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
    teaching_point:
      typeof obj?.teaching_point === "string" && obj.teaching_point.trim().length > 0
        ? obj.teaching_point
        : "Let us continue with electricity using a simple, clear example.",

    question:
      typeof obj?.question === "string" && obj.question.trim().length > 0
        ? obj.question
        : "Can you tell me what part you want to understand better?",

    concept_id:
      typeof obj?.concept_id === "string"
        ? obj.concept_id
        : "electricity_basics",

    is_concept_cleared:
      typeof obj?.is_concept_cleared === "boolean"
        ? obj.is_concept_cleared
        : false,
  };
}


// POST /api/tutor/chat
router.post("/chat", async (req, res) => {
  try {
    console.log("🎯 TUTOR CHAT REQUEST");
    console.log("Session ID:", req.body.session_id);
    console.log("Message:", req.body.message?.substring(0, 100));

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
    
    console.log(`📚 Context found: ${context.length} chunks`);
    if (context.length > 0) {
      console.log("First chunk:", context[0].text?.substring(0, 100) + "...");
    }

    // FIXED: Make sure runTutorAgent is properly called
    const agentResp = await runTutorAgent({ message, session, context });
    const finalResp = ensureSchemaResponse(agentResp);

    // Update session memory if concept cleared
    if (finalResp.is_concept_cleared && typeof finalResp.concept_id === "string") {
      if (!session.clearedConcepts.includes(finalResp.concept_id)) {
        session.clearedConcepts.push(finalResp.concept_id);
      }
    }

    // Add metadata
    finalResp.session_id = session_id;
    finalResp.timestamp = new Date().toISOString();

    console.log("✅ Response generated:");
    console.log("Teaching:", finalResp.teaching_point?.substring(0, 100) + "...");
    console.log("Question:", finalResp.question);

    return res.json(finalResp);
  } catch (e) {
    console.error("❌ Tutor error:", e.message);
    console.error("Stack:", e.stack);
    
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

// POST /api/tutor/diagnostic/start
router.post("/diagnostic/start", async (req, res) => {
  try {
    console.log("🎯 DIAGNOSTIC TEST START REQUEST");

    const testData = startDiagnosticTest();

    console.log("✅ Diagnostic test started - 12 questions ready");

    return res.json({
      success: true,
      ...testData
    });

  } catch (error) {
    console.error("❌ Diagnostic start error:", error.message);
    return res.status(500).json({
      success: false,
      error: "Failed to start diagnostic test",
      message: error.message
    });
  }
});

// POST /api/tutor/diagnostic/submit
router.post("/diagnostic/submit", async (req, res) => {
  try {
    console.log("🎯 DIAGNOSTIC TEST SUBMIT REQUEST");

    const { session_id, answers } = req.body;

    if (!session_id || !answers) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields: session_id and answers"
      });
    }

    const result = submitDiagnosticTest(session_id, answers);

    if (result.success) {
      console.log("✅ Diagnostic test submitted successfully");
      return res.json(result);
    } else {
      console.error("❌ Diagnostic submission failed:", result.error);
      return res.status(400).json(result);
    }

  } catch (error) {
    console.error("❌ Diagnostic submit error:", error.message);
    return res.status(500).json({
      success: false,
      error: "Failed to submit diagnostic test",
      message: error.message
    });
  }
});

// GET /api/tutor/progress/:session_id
router.get("/progress/:session_id", async (req, res) => {
  try {
    console.log("🎯 PROGRESS REQUEST");

    const { session_id } = req.params;

    if (!session_id) {
      return res.status(400).json({
        success: false,
        error: "Session ID is required"
      });
    }

    const progressData = getLearningProgress(session_id);

    if (progressData.success) {
      console.log("✅ Progress data retrieved successfully");
      return res.json(progressData);
    } else {
      console.log("⚠️ No progress data found");
      return res.status(404).json(progressData);
    }

  } catch (error) {
    console.error("❌ Progress retrieval error:", error.message);
    return res.status(500).json({
      success: false,
      error: "Failed to retrieve progress data",
      message: error.message
    });
  }
});

module.exports = router;