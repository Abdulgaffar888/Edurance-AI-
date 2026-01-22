// ai/tutor/agent.js
const AIService = require("./ai-service.js");
const aiService = new AIService();
const studentKnowledge = new Map();

const encouragements = [
  "You're a natural at this!",
  "Keep going, you're doing great!",
  "That's a brilliant observation!",
  "I love how you're thinking!",
  "Spot on! You've got a real spark for science."
];

async function runTutorAgent({ message, session, context }) {
  const sessionId = session.session_id;
  const studentName = session.user_name || "young scientist";

  const cleanContext = context.filter(
    c => !c.text?.toLowerCase().includes("stick to")
  );

  
  // 1. PERSISTENT STATE MANAGEMENT
  if (!studentKnowledge.has(sessionId)) {
    studentKnowledge.set(sessionId, { 
      concepts: {}, 
      isFirstMessage: true,
      currentTopicIndex: 0 
    });
  }
  const student = studentKnowledge.get(sessionId);
  const randomEncouragement = encouragements[Math.floor(Math.random() * encouragements.length)];

  // 2. CURRICULUM DEFINITION
  const curriculum = [
    "Electric current (flow of electrons)",
    "Potential difference (voltage)",
    "Resistance",
    "Ohm’s Law",
    "Circuit components (cells, bulbs, switches)"
  ];
  const currentTopic = curriculum[student.currentTopicIndex];

  // 3. ENHANCED SYSTEM PROMPT
  const systemPrompt = `
You are Edurance AI, a warm Grade 6 Science teacher. 
GOAL: Teach Electricity and Circuits. Be a guide, not a quiz bot.
Each response must start differently from the previous one.

STATE DATA:
- Student Name: ${studentName}
- Is Onboarding: ${student.isFirstMessage}
- Current Lesson: ${currentTopic}

RULES:
1. **NO REPETITION**: If isFirstMessage is false, DO NOT say "Hi/Hope you're doing well" again. Start by acknowledging the student's specific answer: "${message}".
2. **VALIDATION**: If the student answers (like "battery"), say: "${randomEncouragement} Yes, a battery provides the push!"
3. **TEACHING OVER TESTING**: Explain the concept deeply. For Grade 6, use the "Water Pipe" analogy. 
4. **ONBOARDING ONLY**: Use the "Phone/Lightbulb" hook ONLY if isFirstMessage is true. If false, move to explaining HOW the battery works.
5. **QUESTION RULE**: Only ask "Does that make sense?" or "Want to know how the battery pushes the electricity?" Stop asking quiz questions.

ANTI-REPETITION RULE (CRITICAL):
- You must NEVER repeat the same sentence, phrase, or opening line
  that you have used in any previous response in this session.
- If you detect similar wording, you MUST rephrase completely.
- Especially NEVER repeat fallback or redirection sentences.


STRICT JSON FORMAT:
{
  "teaching_point": "Warm acknowledgement of '${message}' + Deep science explanation.",
  "question": "A gentle check-in or invitation to ask a question.",
  "concept_id": "current_basics"
}
`;

  try {
    const raw = await aiService.generateTeachingResponse(systemPrompt, message, context);
    
    // Cleaning and Parsing logic
    let res;
    try {
        const cleaned = typeof raw === 'string' ? raw.replace(/```json|```/g, "").trim() : raw;
        res = typeof cleaned === 'string' ? JSON.parse(cleaned) : cleaned;
    } catch (e) {
        console.error("JSON Parse Error, using fallback");
        res = { teaching_point: raw, question: "did you understand ?", concept_id: "fallback" };
    }

    // 4. UPDATE STATE AFTER SUCCESSFUL RESPONSE
    if (student.isFirstMessage) {
        student.isFirstMessage = false; 
    }

    // Increment progress if they seem to understand
    const cId = res.concept_id || "basics";
    student.concepts[cId] = (student.concepts[cId] || 0) + 1;
    if (student.concepts[cId] >= 3) {
      student.currentTopicIndex = Math.min(student.currentTopicIndex + 1, curriculum.length - 1);
    }

    return {
      teaching_point: res.teaching_point,
      question: res.question,
      concept_id: cId,
      is_concept_cleared: student.concepts[cId] >= 3
    };
  } catch (error) {
    console.error("Tutor Agent Error:", error);
    return {
      teaching_point: "I'm sorry, I lost my train of thought! Let's continue talking about " + currentTopic,
      question: "Shall we?",
      concept_id: "error",
      is_concept_cleared: false
    };
  }
}

module.exports = { runTutorAgent };