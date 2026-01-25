// ai/tutor/agent.js — NCERT TUTOR WITH MARKS-BASED ANSWERS

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

// Topic display names
const TOPIC_NAMES = {
  electric_current: "Electric Current",
  potential_difference: "Potential Difference (Voltage)",
  resistance: "Resistance",
  ohms_law: "Ohm's Law",
  ohmic_materials: "Ohmic and Non-Ohmic Materials",
  circuit_components: "Circuit Components"
};

// Session memory
const studentKnowledge = new Map();

// Detect marks request
function detectMarksRequest(text) {
  const t = text.toLowerCase();
  
  // Match patterns like "explain for 2 marks", "2 mark answer", "answer in 4 marks"
  const patterns = [
    /(\d+)\s*marks?/i,
    /for\s*(\d+)\s*marks?/i,
    /in\s*(\d+)\s*marks?/i,
    /(\d+)\s*mark\s*answer/i,
    /(\d+)\s*mark\s*question/i
  ];
  
  for (const pattern of patterns) {
    const match = t.match(pattern);
    if (match) {
      const marks = parseInt(match[1]);
      if (marks >= 1 && marks <= 15) {
        return marks;
      }
    }
  }
  
  return null;
}

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
    t === "clear" ||
    t === "ya" ||
    t === "yep" ||
    t === "sure"
  );
}

function isNotUnderstood(text) {
  const t = text.toLowerCase();
  return (
    t.includes("no") ||
    t.includes("confused") ||
    t.includes("not clear") ||
    t.includes("dont understand") ||
    t.includes("don't understand") ||
    t.includes("explain again") ||
    t.includes("didnt get") ||
    t.includes("didn't get")
  );
}

async function runTutorAgent({ message, session, context }) {
  try {
    const sessionId = session.session_id;

    // -------------------------------
    // INIT SESSION WITH WELCOME
    // -------------------------------
    if (!studentKnowledge.has(sessionId)) {
      studentKnowledge.set(sessionId, {
        currentTopicIndex: 0,
        exchangeCount: 0,
        isFirstMessage: true
      });
    }

    const student = studentKnowledge.get(sessionId);

    // WELCOME MESSAGE (only first time)
    if (student.isFirstMessage) {
      student.isFirstMessage = false;
      
      const topicList = TOPIC_SEQUENCE.map((t, i) => 
        `${i + 1}. ${TOPIC_NAMES[t]}`
      ).join("\n");

      return {
        teaching_point: `Hello! Welcome to your Electricity tutorial. Today we'll learn about these 6 important topics from your NCERT syllabus:\n\n${topicList}\n\nWe'll go through each topic one by one at your pace. Let's begin with the first topic: Electric Current.`,
        question: "Are you ready to start?",
        concept_id: "welcome",
        is_concept_cleared: false
      };
    }

    // -------------------------------
    // CHECK FOR MARKS-BASED REQUEST
    // -------------------------------
    const requestedMarks = detectMarksRequest(message);
    
    if (requestedMarks) {
      console.log(`🎯 Detected marks request: ${requestedMarks} marks`);
      
      // Determine answer length based on marks
      let lengthGuideline;
      let detailLevel;
      
      if (requestedMarks <= 2) {
        lengthGuideline = "2-3 sentences (around 40-60 words)";
        detailLevel = "brief and concise";
      } else if (requestedMarks <= 3) {
        lengthGuideline = "1 short paragraph (around 80-100 words)";
        detailLevel = "moderately detailed";
      } else if (requestedMarks <= 5) {
        lengthGuideline = "2 paragraphs (around 120-150 words)";
        detailLevel = "detailed with examples";
      } else {
        lengthGuideline = "3-4 paragraphs (around 200-250 words)";
        detailLevel = "comprehensive with multiple examples and explanations";
      }
      
      const currentTopic = TOPIC_SEQUENCE[student.currentTopicIndex];
      
      const systemPrompt = `
You are Edurance AI, an NCERT Grade 10 Science teacher.

STUDENT REQUEST: The student wants an answer worth ${requestedMarks} marks.

CURRENT TOPIC: ${TOPIC_NAMES[currentTopic]}

ANSWER LENGTH REQUIREMENT: ${lengthGuideline}
DETAIL LEVEL: ${detailLevel}

EXAM ANSWER GUIDELINES:
- Write in a structured, exam-appropriate format
- Include key terminology and definitions
- Add relevant examples where needed
- Use proper scientific language
- Keep it NCERT Class 10 level

For ${requestedMarks} marks answers:
${requestedMarks <= 2 ? "- Give only the core concept in 2-3 lines" : ""}
${requestedMarks >= 3 && requestedMarks <= 5 ? "- Include definition, explanation, and one example" : ""}
${requestedMarks > 5 ? "- Include definition, detailed explanation, multiple examples, and applications" : ""}

STRICT OUTPUT FORMAT (JSON only):
{
  "teaching_point": "your exam-style answer here"
}

DO NOT include questions in teaching_point.
`;

      const aiResponse = await aiService.generateTeachingResponse(
        systemPrompt,
        message,
        context
      );

      return {
        teaching_point: `**[${requestedMarks} Marks Answer]**\n\n${aiResponse.teaching_point}`,
        question: "Would you like me to explain any part in more detail?",
        concept_id: currentTopic,
        is_concept_cleared: false
      };
    }

    // -------------------------------
    // HANDLE UNDERSTANDING FLOW
    // -------------------------------
    if (isUnderstandingConfirmed(message)) {
      // Move to next topic
      student.currentTopicIndex++;
      student.exchangeCount = 0; // Reset counter

      if (student.currentTopicIndex >= TOPIC_SEQUENCE.length) {
        return {
          teaching_point: "Excellent! You have now completed all 6 topics on Electricity from the NCERT chapter. You've learned about electric current, potential difference, resistance, Ohm's law, material properties, and circuit components. Well done!",
          question: "",
          concept_id: "chapter_complete",
          is_concept_cleared: true
        };
      }

      const nextTopic = TOPIC_SEQUENCE[student.currentTopicIndex];
      message = `START_EXPLAINING:${nextTopic}`;
    }

    if (isNotUnderstood(message)) {
      const currentTopic = TOPIC_SEQUENCE[student.currentTopicIndex];
      message = `EXPLAIN_AGAIN_SIMPLY:${currentTopic}`;
    }

    const currentTopic = TOPIC_SEQUENCE[student.currentTopicIndex];
    student.exchangeCount++;

    // -------------------------------
    // REMOVED: No more automatic "Did you understand?" checks
    // Students will naturally say "yes" to continue or ask for re-explanation
    // -------------------------------

    // -------------------------------
    // SYSTEM PROMPT
    // -------------------------------
    const systemPrompt = `
You are Edurance AI, a friendly NCERT Grade 10 Science teacher teaching Electricity chapter.

CURRENT TOPIC: ${TOPIC_NAMES[currentTopic]}

YOUR TASK:
Explain the concept of ${TOPIC_NAMES[currentTopic]} clearly and simply.

TEACHING GUIDELINES:
- Use simple, student-friendly language
- Give real-world examples where possible
- Break complex ideas into small parts
- Keep explanations concise (2-4 short paragraphs)
- Be encouraging and supportive
- NCERT Class 10 level appropriate

${message.includes("START_EXPLAINING") 
  ? `Start by introducing the new topic: "${TOPIC_NAMES[currentTopic]}" and explain its basic concept.`
  : ""
}

${message.includes("EXPLAIN_AGAIN") 
  ? "The student didn't understand. Explain the same concept using a different approach or simpler words, with more examples."
  : ""
}

STRICT OUTPUT FORMAT (JSON only):
{
  "teaching_point": "your clear explanation here"
}

DO NOT include questions in teaching_point.
`;

    const aiResponse = await aiService.generateTeachingResponse(
      systemPrompt,
      message,
      context
    );

    // -------------------------------
    // RESPONSE WITHOUT AUTO-QUESTIONING
    // -------------------------------
    return {
      teaching_point: aiResponse.teaching_point,
      question: "Can you tell me what part you want to understand better?",
      concept_id: currentTopic,
      is_concept_cleared: false
    };

  } catch (error) {
    console.error("❌ Tutor Agent Error:", error.message);

    return {
      teaching_point: "I apologize, I encountered a technical issue. Let's continue with our Electricity lesson. We can go over the previous topic again if needed.",
      question: "Should we continue? (yes/no)",
      concept_id: "error_recovery",
      is_concept_cleared: false
    };
  }
}

module.exports = { runTutorAgent };