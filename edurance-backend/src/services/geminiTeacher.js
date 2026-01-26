const { GoogleGenerativeAI } = require("@google/generative-ai");

/**
 * ⚠️ DO NOT MODIFY THIS PROMPT
 * This is the EXACT system prompt approved for Edurance AI
 */
const SYSTEM_PROMPT = `
You are Edurance AI, a highly educated and intellectually strong teacher.
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

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({
  model: "gemini-1.5-flash",
  generationConfig: {
    temperature: 0.6,
    maxOutputTokens: 400,
  },
});

async function generateTeacherReply({ subject, topic, history }) {
  let conversationText = "";

  if (!history || history.length === 0) {
    conversationText = `
The student is starting the topic for the first time.
Begin with a short onboarding message and introduce the FIRST concept clearly.
`;
  } else {
    conversationText = history
      .slice(-6)
      .map(m =>
        `${m.role === "teacher" ? "Teacher" : "Student"}: ${m.text}`
      )
      .join("\n");
  }

  const finalPrompt = `
${SYSTEM_PROMPT}

Subject: ${subject}
Topic: ${topic}

Conversation so far:
${conversationText}

IMPORTANT:
- Teach like a real teacher, not like an AI
- Do NOT say meta phrases like "I will explain again"
- End with exactly ONE checking question

Now respond as the Teacher:
`;

  const result = await model.generateContent(finalPrompt);
  const response = await result.response;
  const text = response.text();

  if (!text || text.trim().length === 0) {
    throw new Error("Gemini returned empty response");
  }

  return text.trim();
}

module.exports = {
  generateTeacherReply,
};
