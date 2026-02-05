import express from "express";
import { generateTeacherReply } from "../services/teacherAI.js";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const router = express.Router();
const sessions = new Map();

// ===== CONFIG =====
const FREE_DAILY_LIMIT = 10;

// ===== UTILS =====
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

// ===== MAIN TEACH ROUTE =====
router.post("/", async (req, res) => {
  const { user_id, subject, topic, message } = req.body;

  if (!user_id || !subject || !topic) {
    return res.status(400).json({
      error: "user_id, subject, and topic are required",
    });
  }

  // ---- CHECK USER PLAN ----
  const { data: user, error: userError } = await supabase
    .from("users")
    .select("plan")
    .eq("id", user_id)
    .single();

  if (userError || !user) {
    return res.status(401).json({ error: "Invalid user" });
  }

  const isPremium = user.plan === "premium";
  const today = new Date().toISOString().slice(0, 10);

  // ---- FREE PLAN LIMIT ----
  if (!isPremium) {
    const { data: usage } = await supabase
      .from("user_daily_usage")
      .select("responses_used")
      .eq("user_id", user_id)
      .eq("date", today)
      .single();

    if (usage && usage.responses_used >= FREE_DAILY_LIMIT) {
      return res.status(403).json({
        reply:
          "You’ve completed today’s free learning session.\n\nUpgrade to Premium to continue learning without limits.",
        waitingForAnswer: false,
        limitReached: true,
      });
    }
  }

  // ---- SESSION MEMORY ----
  const sessionKey = `${user_id}::${subject}::${topic}`;

  if (!sessions.has(sessionKey)) {
    sessions.set(sessionKey, { history: [] });
  }

  const session = sessions.get(sessionKey);

  if (message && message.trim()) {
    session.history.push({ role: "student", text: message.trim() });
  }

  try {
    const rawReply = await generateTeacherReply({
      subject,
      topic,
      history: session.history,
    });

    const reply = cleanText(rawReply);

    session.history.push({ role: "teacher", text: reply });

    // ---- INCREMENT USAGE ----
    if (!isPremium) {
      await supabase.from("user_daily_usage").upsert({
        user_id,
        date: today,
        responses_used:
          session.history.filter((m) => m.role === "teacher").length,
      });
    }

    return res.json({
      reply,
      waitingForAnswer: true,
      isPremium,
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
