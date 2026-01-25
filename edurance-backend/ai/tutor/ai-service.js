// ai/tutor/ai-service.js
const { GoogleGenerativeAI } = require("@google/generative-ai");

class AIService {
  constructor() {
    console.log("🔄 Initializing AI Service (Gemini only)...");

    if (!process.env.GEMINI_API_KEY) {
      console.error("❌ GEMINI_API_KEY is missing");
      return;
    }

    this.geminiAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    // Prefer fast + cheap model
    try {
      this.geminiModel = this.geminiAI.getGenerativeModel({
        model: "gemini-1.5-flash",
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 300,
        },
      });
      console.log("✅ Gemini model loaded: gemini-1.5-flash");
    } catch (err) {
      console.error("❌ Failed to initialize Gemini model", err);
      this.geminiModel = null;
    }
  }

  // Main entry used by agent.js
  async generateTeachingResponse(systemPrompt, userPrompt, context = []) {
    if (!this.geminiModel) {
      console.error("❌ Gemini model not initialized, using fallback");
      return this.getSimpleFallback(context);
    }

    try {
      return await this.tryGemini(systemPrompt, userPrompt);
    } catch (err) {
      console.error("❌ Gemini failed completely:", err.message);
      return this.getSimpleFallback(context);
    }
  }

  async tryGemini(systemPrompt, userPrompt) {
    const fullPrompt = `
${systemPrompt}

Student says:
${userPrompt}

IMPORTANT:
- Respond ONLY in valid JSON
- No markdown
- No explanations outside JSON

JSON format:
{
  "teaching_point": "text",
  "question": "text",
  "concept_id": "id",
  "is_concept_cleared": false
}
`;

    const result = await this.geminiModel.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();

    console.log("📥 GEMINI RAW RESPONSE:");
    console.log(text);
    console.log("=".repeat(80));

    // 🔒 Robust JSON extraction
    let parsed;
    try {
      const start = text.indexOf("{");
      const end = text.lastIndexOf("}");

      if (start === -1 || end === -1) {
        throw new Error("No JSON found in Gemini response");
      }

      const jsonString = text.slice(start, end + 1);
      parsed = JSON.parse(jsonString);
    } catch (parseErr) {
      console.error("❌ JSON PARSE FAILED");
      console.error("RAW TEXT:", text);
      throw parseErr;
    }

    console.log("📦 PARSED GEMINI JSON:", parsed);

    // Clean teaching text (teacher should not ask meta questions)
    let teaching = parsed.teaching_point || "";
    teaching = teaching
      .replace(/did you understand.*?\?/gi, "")
      .replace(/do you understand.*?\?/gi, "")
      .replace(/is this clear.*?\?/gi, "")
      .replace(/are you following.*?\?/gi, "")
      .trim();

    if (!teaching) {
      throw new Error("Empty teaching_point after cleaning");
    }

    return {
      teaching_point: teaching,
      question:
        typeof parsed.question === "string" && parsed.question.trim().length > 0
          ? parsed.question
          : "What would you like to understand next?",
      concept_id:
        typeof parsed.concept_id === "string"
          ? parsed.concept_id
          : "electric_current",
      is_concept_cleared: !!parsed.is_concept_cleared,
      _meta: { source: "gemini" },
    };
  }

  // Absolute last-resort fallback (never crashes UI)
  getSimpleFallback(context = []) {
    console.warn("⚠️ Using simple fallback response");

    const chunk = context[0];

    return {
      teaching_point: chunk?.text
        ? chunk.text
        : "Let us start learning Electricity step by step. First, we will understand what electric current means.",
      question: "Shall we begin?",
      concept_id: chunk?.id || "electric_current",
      is_concept_cleared: false,
      _meta: { source: "fallback" },
    };
  }
}

module.exports = AIService;
