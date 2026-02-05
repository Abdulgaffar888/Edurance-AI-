import express from "express";
import { generateTeacherReply } from "../services/teacherAI.js";

const router = express.Router();
const sessions = new Map();

function cleanText(text) {
  if (!text) return "";
  return text
    .replace(/\*\*/g, "")
    .replace(/#+\s?/g, "")
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

  if (message) {
    history.push({ role: "user", content: message });
  }

  try {
    const reply = await generateTeacherReply({
      subject,
      topic,
      history,
    });

    history.push({ role: "assistant", content: reply });

    res.json({ reply });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Teacher unavailable" });
  }
});

export default router;
