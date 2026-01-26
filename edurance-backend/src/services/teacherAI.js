const OpenAI = require("openai");

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * DO NOT MODIFY THIS PROMPT
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

async function generateTeacherReply({ subject, topic, history }) {
  try {
    const messages = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "system", content: `Subject: ${subject}\nTopic: ${topic}` },
    ];

    if (!history || history.length === 0) {
      messages.push({
        role: "user",
        content:
          "The student is starting this topic for the first time. Begin with onboarding and explain the first concept.",
      });
    } else {
      history.slice(-6).forEach((m) => {
        messages.push({
          role: m.role === "teacher" ? "assistant" : "user",
          content: m.text,
        });
      });
    }

    const response = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages,
      temperature: 0.5,
    });

    const text = response.choices?.[0]?.message?.content;

    if (!text) {
      throw new Error("Empty response from OpenAI");
    }

    return text.trim();
  } catch (err) {
    console.error("❌ OpenAI call failed:", err);
    throw new Error("Connection error.");
  }
}

module.exports = { generateTeacherReply };
