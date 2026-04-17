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
- Biology → teach ONLY Biology concepts.
- Mathematics → teach ONLY Mathematics concepts.
- Physics → teach BOTH Physics and Chemistry topics as part of Physical Science.
- NEVER refuse a topic provided by the system.
- Interpret every topic strictly in its Class 10 NCERT syllabus context.

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
- Wait for the student's response
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
- Ask "what do you want to study"
`;

// ================================
// OPENAI CLIENT
// ================================
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ================================
// CORE TEACHER FUNCTION (chat mode)
// ================================
async function generateTeacherReply({ subject, topic, history }) {
  const isPremium = true;
  const model = isPremium ? "gpt-4o-mini" : "gpt-3.5-turbo";
  const isFirstTurn = !history || history.length === 0;
  const temperature = isFirstTurn ? 0.2 : 0.35;

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

TEACHING INSTRUCTIONS:
- Teach exactly this topic
- Do NOT introduce other chapters
- Do NOT choose syllabus yourself
- Onboarding allowed ONLY once at the beginning (max 2 lines)
`,
    },
  ];

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
    history.slice(-3).forEach((m) => {
      messages.push({
        role: m.role === "teacher" ? "assistant" : "user",
        content: m.text,
      });
    });
  }

  try {
    const completion = await openai.chat.completions.create({
      model,
      messages,
      temperature: isPremium ? 0.25 : 0.7,
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

// ================================
// 🎞️ SLIDES GENERATOR FUNCTION
// ================================
async function generateSlides({ subject, topic, classLevel }) {
  const classContext = classLevel || "Class 9";

  const prompt = `
You are an expert ${classContext} school teacher creating a lesson presentation.

SUBJECT: ${subject}
TOPIC: ${topic}
CLASS: ${classContext} (NCERT syllabus)

Create 7 to 10 slides that teach this topic like a real classroom lesson.

STRICT OUTPUT RULES:
- Return ONLY a valid JSON array. No markdown, no explanation, no text outside JSON.
- Each slide must follow EXACTLY this structure:

{
  "title": "Short clear slide title (max 8 words)",
  "content": [
    "Complete sentence 1 — a key fact or concept (15–30 words)",
    "Complete sentence 2 — explanation or elaboration (15–30 words)",
    "Complete sentence 3 — real-life example or application (15–30 words)",
    "Complete sentence 4 — exam tip, common mistake, or deeper insight (15–30 words)"
  ],
  "teacherNote": "Write this as if you are standing in front of students and verbally explaining this slide. Be natural, warm, and thorough — like a real teacher talking through the concept. Sometimes be detailed (4–6 sentences) when the concept is complex. Sometimes be brief (2–3 sentences) for simpler ideas. Include a real-life connection, a trick to remember it, or a question to make students think. Never sound robotic. Use phrases like 'Now look at this carefully...', 'Here is the trick...', 'Think about it this way...', 'Many students confuse this with...', 'In your exam, remember...'"
}

CONTENT RULES:
- content: 4 bullet points per slide, each a full meaningful sentence (not keywords)
- teacherNote: 2–6 sentences of natural teacher speech — vary the length based on concept complexity
- First slide: Overview/Introduction with curiosity hook in teacherNote
- Last slide: Summary + exam tips in teacherNote
- Cover all major sub-concepts of "${topic}" across the slides
- Language appropriate for ${classContext} students
- No markdown, no asterisks, no hashtags inside JSON

RETURN FORMAT:
[
  {
    "title": "...",
    "content": ["...", "...", "...", "..."],
    "teacherNote": "..."
  },
  ...
]

Return ONLY the JSON array.
`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.25,
    });

    const raw = completion?.choices?.[0]?.message?.content;

    if (!raw || !raw.trim()) {
      throw new Error("Empty slides response from model");
    }

    let parsed;
    try {
      const cleaned = raw.replace(/```json|```/g, "").trim();
      const match = cleaned.match(/\[[\s\S]*\]/);
      parsed = match ? JSON.parse(match[0]) : JSON.parse(cleaned);
    } catch {
      throw new Error("Failed to parse slides JSON from model");
    }

    const slidesArray = Array.isArray(parsed)
      ? parsed
      : parsed.slides || parsed.data || Object.values(parsed)[0];

    if (!Array.isArray(slidesArray) || slidesArray.length === 0) {
      throw new Error("No valid slides array in response");
    }

    return slidesArray
      .filter((s) => s.title && Array.isArray(s.content) && s.content.length > 0)
      .map((s) => ({
        title: String(s.title).replace(/\*\*/g, "").trim(),
        content: s.content
          .filter((c) => c && String(c).trim().length > 0)
          .map((c) =>
            String(c)
              .replace(/\*\*/g, "")
              .replace(/^[-•*]\s*/, "")
              .trim()
          ),
        teacherNote: s.teacherNote ? String(s.teacherNote).trim() : null,
      }));
  } catch (err) {
    console.error("❌ generateSlides error:", err?.message || err);
    throw new Error("Could not generate slides");
  }
}

export { generateTeacherReply, generateSlides };