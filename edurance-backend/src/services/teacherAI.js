const axios = require("axios");

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

const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

// model priority list
const MODELS = [
  "nvidia/nemotron-nano-9b-v2:free",
  "google/gemma-3-27b-it:free",
];

async function callModel(model, messages) {
  const res = await axios.post(
    OPENROUTER_URL,
    {
      model,
      messages,
      temperature: 0.5,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://edurance.ai",
        "X-Title": "Edurance AI Tutor",
      },
      timeout: 20000,
    }
  );

  return res.data?.choices?.[0]?.message?.content;
}

async function generateTeacherReply({ subject, topic, history }) {
  const messages = [
    { role: "system", content: SYSTEM_PROMPT },
    { role: "system", content: `Subject: ${subject}\nTopic: ${topic}` },
  ];

  // Add subject lock system message just before calling the model
  messages.unshift({
    role: "system",
    content: `
SUBJECT LOCK (ABSOLUTE):
You are teaching ONLY "${subject}".
You must NOT explain concepts from any other subject.
If the topic appears unrelated, reinterpret it strictly within "${subject}".
If still unclear, ask for clarification WITHOUT changing subject.
`,
  });

  if (!history || history.length === 0) {
    messages.push({
      role: "user",
      content: `
Start with a SHORT onboarding (2–3 lines max),
then immediately begin teaching the FIRST concept of the topic.
Do NOT ask which topic to choose.
Assume the topic is fixed and chosen.
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

  let lastError = null;

  for (const model of MODELS) {
    try {
      const text = await callModel(model, messages);

      if (text && text.trim().length > 0) {
        return text.trim();
      }
    } catch (err) {
      console.error(`❌ Model failed: ${model}`);
      console.error(err?.response?.data || err.message);
      lastError = err;
    }
  }

  throw new Error(
    lastError?.response?.data?.error?.message ||
      "All models failed to respond"
  );
}

module.exports = { generateTeacherReply };