// ai/tutor/ai-service.js - REPLACE ENTIRE FILE
const { GoogleGenerativeAI } = require("@google/generative-ai");
// const Groq = require("groq-sdk");

class AIService {
  constructor() {
    console.log("🔄 Initializing AI Services...");
    
    // Gemini - USE CORRECT MODEL
    if (process.env.GEMINI_API_KEY) {
      console.log("🔧 Initializing Gemini");
      this.geminiAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      // TRY THESE MODELS (one will work):
      try {
        this.geminiModel = this.geminiAI.getGenerativeModel({ 
          model: "gemini-1.5-flash",  // Try this first
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 200,
          }
        });
        console.log("✅ Gemini model: gemini-1.5-flash");
      } catch (e) {
        // Fallback to pro model
        this.geminiModel = this.geminiAI.getGenerativeModel({ 
          model: "gemini-1.5-pro",  // Fallback
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 200,
          }
        });
        console.log("✅ Gemini model: gemini-1.5-pro");
      }
    }

    // Groq - USE CORRECT MODEL
    if (process.env.GROQ_API_KEY) {
      console.log("🔧 Initializing Groq");
      this.groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
    }
  }

  async generateTeachingResponse(systemPrompt, userPrompt, context) {
    // SIMPLE WORKING VERSION - No complex fallbacks
    try {
      return await this.tryGeminiSimple(systemPrompt, userPrompt);
    } catch (error) {
      console.log("Gemini failed, trying Groq...");
      try {
        return await this.tryGroqSimple(systemPrompt, userPrompt);
      } catch (groqError) {
        console.log("Both APIs failed, using fallback");
        return this.getSimpleFallback(context);
      }
    }
  }

  async tryGeminiSimple(systemPrompt, userPrompt) {
    if (!this.geminiModel) throw new Error("Gemini not initialized");
    
    const fullPrompt = `${systemPrompt}\n\nStudent: ${userPrompt}\n\nReturn JSON only: {"teaching_point":"text","question":"text","concept_id":"id","is_concept_cleared":false}`;
    
    const result = await this.geminiModel.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();
    
    console.log("Gemini raw:", text.substring(0, 100));
    
    // Extract JSON
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("No JSON in response");
    
    const parsed = JSON.parse(jsonMatch[0]);
    
    return {
      teaching_point: parsed.teaching_point || "Let's learn about electricity!",
      question: parsed.question || "What would you like to know?",
      concept_id: parsed.concept_id || "concept_01",
      is_concept_cleared: !!parsed.is_concept_cleared,
      _meta: { source: 'gemini' }
    };
  }

  async tryGroqSimple(systemPrompt, userPrompt) {
    if (!this.groq) throw new Error("Groq not initialized");
    
    const completion = await this.groq.chat.completions.create({
      messages: [
        { 
          role: "system", 
          content: systemPrompt + "\n\nReturn ONLY JSON with teaching_point, question, concept_id, is_concept_cleared" 
        },
        { role: "user", content: userPrompt }
      ],
      model: "llama-3.1-8b-instant",  // CORRECT MODEL
      temperature: 0.7,
      max_tokens: 200,
      response_format: { type: "json_object" }
    });

    const content = completion.choices[0]?.message?.content;
    if (!content) throw new Error("Empty response");
    
    console.log("Groq raw:", content.substring(0, 100));
    
    const parsed = JSON.parse(content);
    
    return {
      teaching_point: parsed.teaching_point || "Great question!",
      question: parsed.question || "Tell me more",
      concept_id: parsed.concept_id || "concept_01",
      is_concept_cleared: !!parsed.is_concept_cleared,
      _meta: { source: 'groq' }
    };
  }

  getSimpleFallback(context) {
    const chunk = context?.[0];
    return {
      teaching_point: chunk?.text ? `Let's explore: ${chunk.text.substring(0, 80)}...` : "Welcome to electricity circuits!",
      question: "What aspect interests you most?",
      concept_id: chunk?.id || "fallback_01",
      is_concept_cleared: false,
      _meta: { source: 'fallback' }
    };
  }
}

module.exports = AIService;