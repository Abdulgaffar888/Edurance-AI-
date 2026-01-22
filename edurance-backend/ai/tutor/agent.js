// ai/tutor/agent.js - HUMAN-LIKE, CURRICULUM-DRIVEN TUTOR
const AIService = require("./ai-service.js");
const aiService = new AIService();
const studentKnowledge = new Map();

// Encouragement library for variety
const encouragements = [
  "You're a natural at this!",
  "Keep going, you're doing great!",
  "That's a brilliant observation!",
  "I love how you're thinking!",
  "Spot on! You've got a real spark for science.",
  "Excellent effort!"
];

async function runTutorAgent({ message, session, context }) {
  const sessionId = session.session_id;
  const studentName = session.user_name || "young scientist";

  if (!studentKnowledge.has(sessionId)) {
    studentKnowledge.set(sessionId, { 
      concepts: {}, 
      isFirstMessage: true 
    });
  }
  const student = studentKnowledge.get(sessionId);
  const randomEncouragement = encouragements[Math.floor(Math.random() * encouragements.length)];

  const systemPrompt = `
You are Edurance AI, a warm, intellectually strong Grade 6 Science teacher.
YOUR GOAL: TEACH the student about Electricity and Circuits. Focus on things they don't know yet.

BE OPEN TO QUESTIONS: 
- If the student asks a question, answer it deeply and clearly before moving back to the curriculum.
- Encourage them to ask "Why?" or "How?".

CURRICULUM ORDER:
1. Electric current (Start here)
2. Potential difference
3. Resistance
4. Ohm’s Law (basic)
5. Ohmic and non-ohmic materials
6. Basic circuit components

HUMAN RULES:
- **ONBOARDING RULE (isFirstMessage: ${student.isFirstMessage})**: 
    1. Start with a warm greeting: "Hi ${studentName}! Hope you're doing well."
    2. Introduce the topic: "Today, we're going to explore the amazing world of Electricity and Circuits!"
    3. Give a basic definition of Electric Current.
    4. ASK A SIMPLE HOOK QUESTION (Rare/Easy): e.g., "Have you ever wondered how your phone stays powered or how a lightbulb stays on?"
    5. DO NOT ask a checking/test question yet. Just ask if they are ready or use the hook.

- **TEACHING RULES (Subsequent messages)**:
    1. VALIDATION: Use "${randomEncouragement}" to acknowledge their answer.
    2. COMFORT: If they say "I don't know," say: "No worries! That's why we're here. Let me explain it differently."
    3. ACKNOWLEDGE: Always reply directly to what the student said before moving to the next point.

TEACHING STRUCTURE:
- Validation/Greeting
- Concept (Definition + Why + Example)
- One Question (either "Did you understand?" or a simple checking question).

STRICT JSON FORMAT:
{
  "teaching_point": "Warm text including validation and science content",
  "question": "The specific question or 'Does that make sense?'",
  "concept_id": "current_basics",
  "is_concept_cleared": false
}
`;

  try {
    const raw = await aiService.generateTeachingResponse(systemPrompt, message, context);
    const res = typeof raw === 'string' ? JSON.parse(raw.replace(/```json|```/g, "").trim()) : raw;

    // After the first turn, set isFirstMessage to false
    student.isFirstMessage = false;

    // Concept Tracking
    const cId = res.concept_id || "intro";
    if (!student.concepts[cId]) {
      student.concepts[cId] = { practiced: 1 };
    } else {
      student.concepts[cId].practiced += 1;
    }

    return {
      teaching_point: res.teaching_point,
      question: res.question,
      concept_id: cId,
      is_concept_cleared: student.concepts[cId].practiced >= 3
    };

  } catch (error) {
    console.error("Tutor Error:", error);
    return {
      teaching_point: `Oh, I'm sorry ${studentName}, my wires got a bit crossed! Let's get back to our lesson.`,
      question: "Are you ready to continue?",
      concept_id: "error_recovery",
      is_concept_cleared: false
    };
  }
}

module.exports = { runTutorAgent };