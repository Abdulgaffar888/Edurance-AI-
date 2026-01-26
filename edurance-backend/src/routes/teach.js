const express = require("express");
const { generateTeacherReply } = require("../services/geminiTeacher");

const router = express.Router();

// In-memory per-topic session store
const sessions = new Map();

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

  // Store student message if present
  if (message && message.trim().length > 0) {
    session.history.push({
      role: "student",
      text: message.trim(),
    });
  }

  try {
    const reply = await generateTeacherReply({
      subject,
      topic,
      history: session.history,
    });

    session.history.push({
      role: "teacher",
      text: reply,
    });

    res.json({
      reply,
      waitingForAnswer: true,
    });

  } catch (err) {
    console.error("❌ Teach API failed:");
    console.error(err);

    res.status(500).json({
      reply: `ERROR FROM AI SERVICE: ${err.message || err.toString()}`,
      waitingForAnswer: true,
    });
  }
});

module.exports = router;
