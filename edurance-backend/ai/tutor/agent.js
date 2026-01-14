const OpenAI = require("openai");

function getApiKey() {
  return process.env.OPENAI_API_KEY || null;
}

// Fixed fallback to remove "NCERT" word
function safeFallbackResponse() {
  return {
    teaching_point: "That's a great thought! Let's stay focused on our lesson about electricity and circuits.",
    question: "Can you tell me what happens when you turn a switch on?",
    concept_id: "circuit_01",
    is_concept_cleared: false,
  };
}

async function runTutorAgent({ message, session, context }) {
  const apiKey = getApiKey();
  if (!apiKey) return safeFallbackResponse();

  const openai = new OpenAI({ apiKey });

  const chosen = Array.isArray(context) && context.length > 0 ? context[0] : null;

  // REWRITTEN SYSTEM PROMPT
  const system = [
    "You are a friendly Grade 6 Science Teacher named Edurance AI.",
    "STRICT RULE: Do NOT use the word 'NCERT'. Instead, say 'your textbook' or 'our lesson'.",
    "METHOD: Use the Socratic method. Teach ONLY ONE tiny concept at a time, then ask ONE question.",
    "NO SPOILERS: Do not explain the whole chapter. Do not give the answer to your own question.",
    
    // Onboarding handler
    "If the user message is 'START_LESSON_ONBOARDING', start by welcoming the student to the world of Electricity. Briefly mention how exciting it is to see a bulb glow, then introduce the first concept from the context and ask a question.",
    
    "If context is missing, say: 'That's interesting! But let's stay focused on our electricity and circuits lesson.'",
    "Return ONLY valid JSON: { 'teaching_point': '', 'question': '', 'concept_id': '', 'is_concept_cleared': boolean }",
  ].join("\n");

  const userPayload = {
    student_message: message,
    session_info: {
      clearedConcepts: Array.isArray(session?.clearedConcepts) ? session.clearedConcepts : [],
    },
    lesson_material: chosen ? { id: chosen.id, text: chosen.text } : null,
  };

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: system },
        { role: "user", content: JSON.stringify(userPayload) },
      ],
      temperature: 0.5, // Slightly higher for better conversational flow
      response_format: { type: "json_object" },
    });

    const raw = completion.choices?.[0]?.message?.content || "";
    const parsed = JSON.parse(raw);

    return {
      teaching_point: parsed.teaching_point || "Let's look at how electricity flows!",
      question: parsed.question || "Ready to start?",
      concept_id: parsed.concept_id || (chosen?.id || "intro_01"),
      is_concept_cleared: !!parsed.is_concept_cleared,
    };
  } catch (error) {
    console.error("Agent Error:", error);
    return safeFallbackResponse();
  }
}

module.exports = { runTutorAgent };