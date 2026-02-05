import express from "express";
import { generateTeacherReply } from "../services/teacherAI.js";

const router = express.Router();
const sessions = new Map();

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

router.post("/", async (req, res) => {
  const { subject, topic, message } = req.body;

  if (!subject || !topic) {
    return res.status(400).json({ error: "subject and topic required" });
  }

  const key = `${subject}::${topic}`;
  if (!sessions.has(key)) sessions.set(key, []);

  const history = sessions.get(key);

  if (message && message.trim()) {
    history.push({ role: "student", text: message.trim() });
  }

  try {
    const rawReply = await generateTeacherReply({
      subject,
      topic,
      history,
    });

    const reply = cleanText(rawReply);
    history.push({ role: "teacher", text: reply });

    res.json({ reply });
  } catch (e) {
    console.error("Teach error:", e);
    res.status(500).json({ reply: "Teacher unavailable" });
  }
});

export default router;
