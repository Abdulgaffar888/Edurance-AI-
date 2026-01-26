const express = require("express");
const GeminiTeacher = require("../services/geminiTeacher");

const router = express.Router();
const sessions = new Map();

router.post("/", async (req, res) => {
  const { subject, topic, message } = req.body;

  if (!subject || !topic) {
    return res.status(400).json({ error: "Subject and topic are required" });
  }

  const sessionKey = `${subject}::${topic}`;

  if (!sessions.has(sessionKey)) {
    sessions.set(sessionKey, {
      subject,
      topic,
      messages: [],
      startedAt: Date.now(),
    });
  }

  const session = sessions.get(sessionKey);

  // If user sends a message, add it
  if (message && message.trim().length > 0) {
    session.messages.push({
      role: "student",
      text: message.trim(),
    });
  }

  try {
    const aiReply = await GeminiTeacher.generate({
      subject,
      topic,
      history: session.messages,
    });

    session.messages.push({
      role: "teacher",
      text: aiReply,
    });

    res.json({
      reply: aiReply,
      waitingForAnswer: true,
    });

  } catch (err) {
    console.error("❌ Teach API failed:", err.message);
    res.status(500).json({
      reply:
        "Let us pause for a moment. I will explain this concept again clearly.",
      waitingForAnswer: true,
    });
  }
});

module.exports = router;
