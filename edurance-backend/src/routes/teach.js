const express = require("express");
const { generateTeacherReply } = require("../services/teacherAI");

// 🆕 SUPABASE (BACKEND ONLY)
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const router = express.Router();
const sessions = new Map();

/**
 * Clean AI output to remove formatting / onboarding / headings
 * REQUIRED for production stability
 */
function cleanText(text) {
  if (!text || typeof text !== "string") return "";

  return text
    .replace(/\*\*/g, "")
    .replace(/#+\s?/g, "")
    .replace(/Onboarding:?/gi, "")
    .replace(/First sub-concept:?/gi, "")
    .replace(/Checking question:?/gi, "")
    .replace(/Concept\s*\d+:?/gi, "")
    .replace(/Let us begin:?/gi, "")
    .replace(/We will now:?/gi, "")
    .trim();
}

/**
 * ===============================
 * 🧠 AI TEACHING ROUTE
 * ===============================
 */
router.post("/", async (req, res) => {
  const { subject, topic, message } = req.body;

  if (!subject || !topic) {
    return res.status(400).json({
      error: "Subject and topic are required",
    });
  }

  const sessionKey = `${subject}::${topic}`;

  if (!sessions.has(sessionKey)) {
    sessions.set(sessionKey, {
      subject,
      topic,
      history: [],
      startedAt: Date.now(),
    });
  }

  const session = sessions.get(sessionKey);

  if (message && message.trim().length > 0) {
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

    session.history.push({
      role: "teacher",
      text: reply,
    });

    return res.json({
      reply,
      waitingForAnswer: true,
    });
  } catch (err) {
    console.error("❌ Teach API failed:");
    console.error(err);

    return res.status(500).json({
      reply: "Teacher is unavailable right now. Please try again.",
      waitingForAnswer: true,
    });
  }
});

/**
 * =================================
 * 🆕 SAVE LESSON PROGRESS
 * =================================
 */
router.post("/save-progress", async (req, res) => {
  const {
    user_id,
    lesson_id,
    lesson_title,
    subject,
    progress,
  } = req.body;

  if (!user_id || !lesson_id) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const { error } = await supabase
    .from("user_lessons")
    .upsert({
      user_id,
      lesson_id,
      lesson_title,
      subject,
      progress,
      completed: progress === 100,
    });

  if (error) {
    console.error("❌ Failed to save progress:", error);
    return res.status(500).json({ error: error.message });
  }

  return res.json({ success: true });
});

module.exports = router;
