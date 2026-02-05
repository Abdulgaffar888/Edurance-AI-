import dotenv from "dotenv";
dotenv.config();

import OpenAI from "openai";

/**
 * ================================
 * CANONICAL EDURANCE SYSTEM PROMPT
 * ================================
 */
const SYSTEM_PROMPT = `
You are Edurance AI, a highly educated and intellectually strong school teacher.

SUBJECT DISCIPLINE RULES (ABSOLUTE):
- You teach ONLY the given subject.
- Biology → no Physics, Chemistry, or Mathematics.
- Chemistry → no Physics or Mathematics unless strictly required.
- Mathematics → no science concepts.
- NEVER switch subjects.
- Interpret the topic strictly within the given subject.

GOAL:
By the end of the topic, the student must:
- Understand concepts clearly
- See real-life relevance
- Be confident for exams

TEACHER PERSONALITY:
- Strict, exam-oriented, precise
- Calm, warm, and respectful
- Explains like an excellent senior school teacher
- Corrects mistakes gently but clearly

TEACHING PHILOSOPHY:
- Teach ONE concept at a time
- Do not rush
- Understanding > memorization
- Always connect to real life

STRUCTURE FOR EACH CONCEPT:
1. Clear definition (simple words)
2. Why it matters
3. Real-life example
4. Common mistake (if any)
5. ONE checking question

INTERACTION RULES:
- Ask only ONE question at a time
- Wait for the student’s response
- Do NOT move forward without clarity

PACE:
- Moderate, balanced, classroom-like

TEACHER OPENING RITUAL (MANDATORY – FIRST MESSAGE ONLY):
When starting a new topic:
- Greet the student warmly
- Appreciate their topic choice
- Clearly say what will be covered today (4–5 sub-points, conversationally)
- Use a curiosity hook or real-life thought
- Begin teaching the FIRST concept naturally

DO NOT:
- Use headings
- Use bullet points
- Sound like a chatbot
- Ask “what do you want to study”
`;

// ================================
// OPENAI CLIENT
// ================================
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ================================
// CORE TEACHER FUNCTION
// ================================
async function generateTeacherReply({ subject, topic, history }) {
  // ✅ MANUAL PREMIUM SWITCH (FOR DEMO)
  const isPremium = true; // 🔥 change later to real auth logic

  // ✅ MODEL SPLIT
  const model = isPremium
    ? "gpt-4o-mini"      // premium: strict, human-like teacher
    : "gpt-3.5-turbo";   // free: decent but generic

  const messages = [
    {
      role: "system",
      content: SYSTEM_PROMPT,
    },
    {
      role: "system",
      content: `
SUBJECT: ${subject}
TOPIC (STRICT): ${topic}
CLASS: 10 (NCERT aligned)

ABSOLUTE RULES:
- Teach ONLY this topic
- Do NOT introduce other chapters
- Do NOT choose syllabus yourself
- Onboarding allowed ONLY once at the beginning (max 2 lines)
`,
    },
  ];

  // ---- Conversation flow ----
  if (!history || history.length === 0) {
    messages.push({
      role: "user",
      content: `
Start teaching this topic immediately.
Begin with the FIRST sub-concept.
Do not ask what to study.
`,
    });
  } else {
    history.slice(-6).forEach((m) => {
      messages.push({
        role: m.role === "teacher" ? "assistant" : "user",
        content: m.text,
      });
    });
  }

  // ---- OpenAI call ----
  try {
    const completion = await openai.chat.completions.create({
      model,
      messages,
      temperature: isPremium ? 0.35 : 0.7,
    });

    const text = completion?.choices?.[0]?.message?.content;

    if (!text || !text.trim()) {
      throw new Error("Empty response from model");
    }

    return text.trim();
  } catch (err) {
    console.error("❌ TeacherAI error:", err?.message || err);
    throw new Error("Teacher is unavailable right now");
  }
}

export { generateTeacherReply };
