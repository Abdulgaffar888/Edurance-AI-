import express from "express";
import { generateTeacherReply } from "./teacherAI.js";

const router = express.Router();
const sessions = new Map();

router.post("/", async (req, res) => {
  const { subject, topic, message } = req.body;

  if (!subject || !topic) {
    return res.status(400).json({ error: "subject and topic required" });
  }

  const key = `${subject}::${topic}`;
  if (!sessions.has(key)) sessions.set(key, []);

  const history = sessions.get(key);

  if (message && message.trim()) {
    history.push({ role: "student", text: message });
  }

  try {
    const reply = await generateTeacherReply({
      subject,
      topic,
      history,
    });

    history.push({ role: "teacher", text: reply });

    res.json({ reply });
  } catch (e) {
    console.error(e);
    res.status(500).json({ reply: "Teacher unavailable" });
  }
});

export default router;
