const OpenAI = require("openai");

function getApiKey() {
  return process.env.OPENAI_API_KEY || null;
}

function safeFallbackResponse() {
  return {
    teaching_point: "That's interesting, but let's stick to our NCERT circuits chapter!",
    question: "Can you tell me what makes a circuit complete?",
    concept_id: "circuit_01",
    is_concept_cleared: false,
  };
}

/**
 * runTutorAgent({ message, session, context })
 * - Persona: Grade 6 Science Teacher named Edurance AI
 * - Socratic: one small concept from context then one question
 * - No spoilers
 * - If missing info from context: fixed NCERT-only message
 * - Output ONLY strict JSON schema
 */
async function runTutorAgent({ message, session, context }) {
  const apiKey = getApiKey();
  if (!apiKey) {
    // Keep API contract even if server misconfigured.
    return safeFallbackResponse();
  }

  const openai = new OpenAI({ apiKey });

  const chosen =
    Array.isArray(context) && context.length > 0
      ? context[0]
      : null;

  const system = [
    "You are a Grade 6 Science Teacher named Edurance AI.",
    "Use the Socratic method: teach ONE small concept, then ask ONE question.",
    "No spoilers: do not give the full answer at once.",
    'If the needed information is missing from the provided NCERT context, say exactly: "That\'s interesting, but let\'s stick to our NCERT circuits chapter!" and then ask a circuits-related question.',
    "Return ONLY valid JSON matching this schema:",
    '{ "teaching_point": "Simple explanation", "question": "One follow-up question", "concept_id": "current_chunk_id", "is_concept_cleared": boolean }',
    "Do not include markdown. Do not include extra keys.",
  ].join("\n");

  const userPayload = {
    student_message: message,
    session: {
      session_id: session?.session_id || null,
      clearedConcepts: Array.isArray(session?.clearedConcepts) ? session.clearedConcepts : [],
    },
    ncert_context: chosen
      ? { id: chosen.id, text: chosen.text, difficulty: chosen.difficulty }
      : null,
  };

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: system },
        { role: "user", content: JSON.stringify(userPayload) },
      ],
      temperature: 0.4,
      response_format: { type: "json_object" },
    });

    const raw = completion.choices?.[0]?.message?.content || "";
    const parsed = JSON.parse(raw);

    // Enforce schema strictly; coerce/fallback if needed.
    const teaching_point =
      typeof parsed.teaching_point === "string" ? parsed.teaching_point : safeFallbackResponse().teaching_point;
    const question =
      typeof parsed.question === "string" ? parsed.question : safeFallbackResponse().question;
    const concept_id =
      typeof parsed.concept_id === "string"
        ? parsed.concept_id
        : (chosen?.id || safeFallbackResponse().concept_id);
    const is_concept_cleared =
      typeof parsed.is_concept_cleared === "boolean" ? parsed.is_concept_cleared : false;

    return { teaching_point, question, concept_id, is_concept_cleared };
  } catch {
    return safeFallbackResponse();
  }
}

module.exports = { runTutorAgent };


