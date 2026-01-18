// ai/tutor/agent.js - SIMPLE WORKING VERSION
const AIService = require("./ai-service.js");

// Initialize AI service
const aiService = new AIService();

// Simple student tracking
const studentKnowledge = new Map(); // session_id → {concepts: {}}

async function runTutorAgent({ message, session, context }) {
  console.log(`🤖 Teaching: "${message.substring(0, 50)}..."`);
  
  try {
    // Get student knowledge
    const sessionId = session.session_id;
    if (!studentKnowledge.has(sessionId)) {
      studentKnowledge.set(sessionId, { concepts: {} });
    }
    const student = studentKnowledge.get(sessionId);
    
    // Simple system prompt
    const systemPrompt = `You are a friendly Grade 6 Science teacher named Edurance AI.
    Teach about electricity and circuits in simple terms.
    Explain one concept at a time, then ask one question.
    Keep responses short and engaging.
    
    Context: ${context[0]?.text?.substring(0, 200) || "Electric circuits basics"}
    
    Student question: "${message}"
    
    Return JSON: {
      "teaching_point": "Your explanation here",
      "question": "One follow-up question",
      "concept_id": "unique_id",
      "is_concept_cleared": false
    }`;
    
    // Get AI response
    const aiResponse = await aiService.generateTeachingResponse(
      systemPrompt,
      message,
      context
    );
    
    // Track concept
    const conceptId = aiResponse.concept_id;
    if (!student.concepts[conceptId]) {
      student.concepts[conceptId] = { practiced: 1, lastTime: Date.now() };
    } else {
      student.concepts[conceptId].practiced += 1;
      student.concepts[conceptId].lastTime = Date.now();
    }
    
    // Check if concept cleared (practiced 3+ times)
    const isCleared = student.concepts[conceptId].practiced >= 3;
    
    console.log(`✅ Teaching complete (${aiResponse._meta?.source})`);
    console.log(`Concept: ${conceptId}, Practiced: ${student.concepts[conceptId].practiced} times`);
    
    return {
      teaching_point: aiResponse.teaching_point,
      question: aiResponse.question,
      concept_id: conceptId,
      is_concept_cleared: isCleared,
      _meta: {
        source: aiResponse._meta?.source || 'unknown',
        practiced_count: student.concepts[conceptId].practiced
      }
    };
    
  } catch (error) {
    console.error("Agent error:", error.message);
    
    // Simple fallback
    const chunk = context[0];
    return {
      teaching_point: chunk?.text ? `Based on: ${chunk.text.substring(0, 80)}...` : "Let's learn about electricity!",
      question: "What would you like to explore?",
      concept_id: chunk?.id || "fallback_01",
      is_concept_cleared: false,
      _meta: { source: 'error_fallback' }
    };
  }
}

module.exports = { runTutorAgent };