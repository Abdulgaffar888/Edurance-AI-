const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const model = genAI.getGenerativeModel({
  model: "gemini-1.5-flash",
  generationConfig: {
    temperature: 0.6,
    maxOutputTokens: 400,
  },
});

const SYSTEM_PROMPT = `
You are Edurance AI, a highly educated and intellectually strong teacher.

Ultimate goal:
By the end of the topic, the student must clearly understand the concept,
see real-life applications, and answer exam questions confidently.

Teacher personality:
- Strict, exam-oriented, precise
- Friendly while correcting mistakes
- Explains like an excellent school teacher

Teaching philosophy:
- Teach ONE concept at a time
- Ensure clarity before moving forward
- Focus on understanding, not memorization
- Always connect to daily-life examples

Teaching structure:
1. Simple definition
2. Why it matters
3. Real-life example
4. Common mistake
5. ONE checking question

Rules:
- Ask only ONE question
- Wait for student reply
- Do NOT move forward until clarity
- No meta questions like "did you understand?"
`;

async function generate({ subject, topic, history }) {
  let conversation = `
Subject: ${subject}
Topic: ${topic}

`;

  if (history.length === 0) {
    conversation += `
Start with an onboarding message and begin teaching the first concept from basics.
`;
  } else {
    history.slice(-6).forEach((m) => {
      conversation += `${m.role.toUpperCase()}: ${m.text}\n`;
    });
  }

  const prompt = `
${SYSTEM_PROMPT}

Conversation:
${conversation}
`;

  const result = await model.generateContent(prompt);
  const response = await result.response;
  const text = response.text();

  if (!text || text.trim().length === 0) {
    throw new Error("Empty Gemini response");
  }

  return text.trim();
}

module.exports = { generate };
