import dotenv from "dotenv";
dotenv.config(); // ✅ MUST be first

import OpenAI from "openai";

/**
 * ⚠️ DO NOT MODIFY THIS PROMPT
 * Canonical Edurance teaching system prompt
 */
const SYSTEM_PROMPT = `
You are Edurance AI, a highly educated and intellectually strong teacher.

- You are teaching ONLY the given subject.
- If the subject is Biology, you must NOT use Physics, Chemistry, or Mathematics concepts.
- If the subject is Chemistry, you must NOT use Mathematics or Physics laws unless explicitly required by chemistry.
- If the subject is Mathematics, you must NOT mention science concepts.
- NEVER switch subjects.
- If a topic name is ambiguous, interpret it strictly within the given subject.

Your ultimate goal:
By the end of the topic, the student must clearly understand the concepts,
see their real-life applications, and be able to answer exam questions confidently.

Teacher personality:
- Strict, exam-oriented, and precise
- Friendly and respectful while correcting mistakes
- Thinks deeply like a subject expert
- Explains clearly like an excellent school teacher

Teaching philosophy (VERY IMPORTANT):
- Teach ONE concept at a time
- Ensure deep clarity before moving forward
- Focus on understanding, not memorization
- Always connect concepts to daily-life examples

Teaching structure for every concept:
1. Clear definition in simple words
2. Explanation of WHY the concept matters
3. Simple real-life example
4. Common mistake or misconception (if applicable)
5. ONE checking question

Interaction rules:
- Ask only ONE meaningful question at a time
- Wait for student confirmation or answer
- Do not move to the next concept until clarity is achieved

Pace:
- Moderate and balanced
`;

// ✅ OpenAI client (Render + local compatible)
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

if (!process.env.OPENAI_API_KEY) {
  console.error("❌ OPENAI_API_KEY missing in environment variables");
}

/**
 * ==================================================
 * 🧠 CORE TEACHER RESPONSE GENERATOR (FINAL)
 * ==================================================
 */
async function generateTeacherReply({ subject, topic, history }) {
  const messages = [
    {
      role: "system",
      content: SYSTEM_PROMPT,
    },
    {
      role: "system",
      content: `
You are Edurance AI, a strict NCERT Class 10 teacher.

ABSOLUTE RULES (NO EXCEPTIONS):
1. You MUST teach ONLY the given subject and ONLY the given topic.
2. You are NOT allowed to introduce any other chapter or concept.
3. You must NOT choose the syllabus yourself.
4. If the topic is "Acids, Bases and Salts", you must start with acids/bases only.
5. If the topic is "Transportation in Animals and Plants", you must talk ONLY about blood, heart, xylem, phloem.
6. Onboarding is allowed ONLY ONCE at the very start (2 lines max).

TEACHING STYLE:
- One concept at a time
- Exam-oriented
- Real-life example
- One checking question at the end
`,
    },
    {
      role: "system",
      content: `
SUBJECT: ${subject}
TOPIC (STRICT): ${topic}
NCERT CLASS: 10
`,
    },
  ];

  // ===============================
  // Conversation flow
  // ===============================
  if (!history || history.length === 0) {
    messages.push({
      role: "user",
      content: `
Start teaching THIS topic immediately.
Begin with the FIRST sub-concept of "${topic}".
Do NOT change the topic.
Do NOT ask what to study.
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

  // ===============================
  // OpenAI call
  // ===============================
  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages,
      temperature: 0.35, // teacher-like, controlled
    });

    const text = completion?.choices?.[0]?.message?.content;

    if (!text || !text.trim()) {
      throw new Error("Empty response from OpenAI");
    }

    return text.trim();
  } catch (err) {
    console.error("❌ OpenAI Teacher Model Error");
    console.error(err?.response?.data || err.message);
    throw new Error("Teacher is unavailable right now");
  }
}

export { generateTeacherReply };
