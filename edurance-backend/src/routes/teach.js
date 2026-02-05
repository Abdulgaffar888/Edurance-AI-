import express from "express";
import { generateTeacherReply } from "../services/teacherAI.js";

const router = express.Router();

// In-memory session store
const sessions = new Map();

// ===== CONFIG =====
const FREE_LIMIT = 5;

/**
 * Clean AI output (keeps teacher tone)
 */
function cleanText(text) {
  if (!text || typeof text !== "string") return "";

  return text
    .replace(/\*\*/g, "")
    .replace(/#+\s?/g, "")
    .replace(/Onboarding:?/gi, "")
    .replace(/Checking question:?/gi, "")
    .replace(/Concept\s*\d+:?/gi, "")
    .trim();
}

/**
 * ===============================
 * 🧠 AI TEACH ROUTE
 * ===============================
 */
router.post("/", async (req, res) => {
  const { subject, topic, message } = req.body;

  if (!subject || !topic) {
    return res.status(400).json({
      error: "subject and topic are required",
    });
  }

  // ---- SESSION KEY (per subject + topic) ----
  const sessionKey = `${subject}::${topic}`;

  if (!sessions.has(sessionKey)) {
    sessions.set(sessionKey, {
      history: [],
      count: 0, // 👈 response count for free tier
    });
  }

  const session = sessions.get(sessionKey);

  // ---- FREE TIER LIMIT ----
  if (session.count >= FREE_LIMIT) {
    return res.json({
      reply:
        "You’ve completed today’s free learning session.\nUpgrade to Premium to continue learning with a real AI teacher.",
      waitingForAnswer: false,
      limitReached: true,
    });
  }

  // ---- SAVE STUDENT MESSAGE ----
  if (message && message.trim()) {
    session.history.push({
      role: "student",
      text: message.trim(),
    });
  }

  try {
    const rawReply = await generateTeacherReply({
      subject,
      topic,
      history: session.history,
    });

    const reply = cleanText(rawReply);

    // ---- SAVE TEACHER MESSAGE ----
    session.history.push({
      role: "teacher",
      text: reply,
    });

    // ---- INCREMENT FREE RESPONSE COUNT ----
    session.count += 1;

    return res.json({
      reply,
      waitingForAnswer: true,
      remainingFreeResponses: FREE_LIMIT - session.count,
    });
  } catch (err) {
    console.error("❌ Teach API failed:", err);
    return res.status(500).json({
      reply: "Teacher is unavailable right now. Please try again.",
      waitingForAnswer: true,
    });
  }
});

export default router;
