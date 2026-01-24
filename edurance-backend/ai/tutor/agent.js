// ai/tutor/agent.js — HARD-GUARDED NCERT TUTOR (NO CONTENT QUESTIONS)

const AIService = require("./ai-service.js");
const aiService = new AIService();

// Fixed NCERT topic order
const TOPIC_SEQUENCE = [
  "electric_current",
  "potential_difference",
  "resistance",
  "ohms_law",
  "ohmic_materials",
  "circuit_components"
];

// Session memory
const studentKnowledge = new Map();

// Understanding detection
function isUnderstandingConfirmed(text) {
  const t = text.toLowerCase().trim();
  return (
    t === "yes" ||
    t === "ok" ||
    t === "okay" ||
    t === "got it" ||
    t === "i understand" ||
    t === "understood" ||
    t === "clear"
  );
}

function isNotUnderstood(text) {
  const t = text.toLowerCase();
  return (
    t.includes("no") ||
    t.includes("confused") ||
    t.includes("not clear") ||
    t.includes("dont understand")
  );
}

async function runTutorAgent({ message, session, context }) {
  try {
    const sessionId = session.session_id;

    // -------------------------------
    // INIT SESSION
    // -------------------------------
    if (!studentKnowledge.has(sessionId)) {
      studentKnowledge.set(sessionId, {
        currentTopicIndex: 0
      });
    }

    const student = studentKnowledge.get(sessionId);

    // -------------------------------
    // HANDLE UNDERSTANDING FLOW
    // -------------------------------
    if (isUnderstandingConfirmed(message)) {
      student.currentTopicIndex++;

      if (student.currentTopicIndex >= TOPIC_SEQUENCE.length) {
        return {
          teaching_point:
            "You have now completed all the NCERT Electricity topics. This concludes the chapter.",
          question: "",
          concept_id: "chapter_complete",
          is_concept_cleared: true
        };
      }

      message = `START_NEXT_TOPIC_${TOPIC_SEQUENCE[student.currentTopicIndex]}`;
    }

    if (isNotUnderstood(message)) {
      message = `REEXPLAIN_${TOPIC_SEQUENCE[student.currentTopicIndex]}`;
    }

    const currentTopic = TOPIC_SEQUENCE[student.currentTopicIndex];

    // -------------------------------
    // SYSTEM PROMPT (CONTENT ONLY)
    // -------------------------------
    const systemPrompt = `
You are Edurance AI, an NCERT Grade 6 Science teacher.

TASK:
Explain ONLY the following topic clearly and concisely:
"${currentTopic}"

STRICT RULES:
- NO questions
- NO confirmation
- NO "does this make sense"
- NO quizzes
- NO asking definitions
- Explanation ONLY

Teaching style:
- NCERT aligned
- Simple language
- Short paragraphs
- Exam-appropriate

Return STRICT JSON:
{
  "teaching_point": "clear explanation only",
  "concept_id": "${currentTopic}"
}
`;

    const aiResponse = await aiService.generateTeachingResponse(
      systemPrompt,
      message,
      context
    );

    // -------------------------------
    // 🔒 HARD OVERRIDE (KEY FIX)
    // -------------------------------
    return {
      teaching_point: aiResponse.teaching_point,
      question: "Did you understand this?", // 🔥 ONLY allowed question
      concept_id: currentTopic,
      is_concept_cleared: false
    };

  } catch (error) {
    console.error("❌ Tutor Agent Error:", error.message);

    return {
      teaching_point:
        "Let us restart calmly. We will continue with the NCERT Electricity chapter step by step.",
      question: "Did you understand this?",
      concept_id: "fallback",
      is_concept_cleared: false
    };
  }
}

module.exports = { runTutorAgent };
