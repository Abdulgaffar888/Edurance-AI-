// src/ai/tutor/misconception-detector.js
const AIService = require("./ai-service");

class MisconceptionDetector {
  constructor() {
    this.ai = new AIService();
    this.commonMisconceptions = {
      'electricity': [
        'Electricity gets "used up" as it flows through wires',
        'Batteries store electricity (they store chemical energy)',
        'Current flows from negative to positive (it flows both ways in AC)',
        'Insulators can never conduct electricity (they can under high voltage)'
      ],
      'circuits': [
        'A circuit needs only a battery and bulb to work (needs complete path)',
        'More batteries always make bulb brighter (can burn out)',
        'Switches "create" electricity (they just control flow)',
        'Wires don\'t matter as long as connected (thickness/material matters)'
      ]
    };
  }
  
  async detect(studentStatement, correctConcept) {
    try {
      // Use AI to detect misconceptions
      const systemPrompt = `
      You are an expert science teacher detecting student misconceptions.
      Common misconceptions about ${correctConcept}: ${JSON.stringify(this.commonMisconceptions[correctConcept] || [])}
      
      Analyze this student statement: "${studentStatement}"
      
      Return JSON: {
        "hasMisconception": boolean,
        "misconceptions": ["list of detected misconceptions"],
        "confidence": 0-1,
        "correctUnderstanding": "The correct understanding"
      }
      `;
      
      const response = await this.ai.generateTeachingResponse(
        systemPrompt,
        `Analyze: "${studentStatement}"`,
        []
      );
      
      return {
        hasMisconception: response.misconceptions?.length > 0,
        misconceptions: response.misconceptions || [],
        confidence: response.confidence || 0.7,
        correctUnderstanding: response.correctUnderstanding || correctConcept,
        detectedAt: new Date().toISOString()
      };
      
    } catch (error) {
      console.error("Misconception detection failed:", error);
      return {
        hasMisconception: false,
        misconceptions: [],
        confidence: 0,
        correctUnderstanding: correctConcept,
        error: error.message
      };
    }
  }
  
  addMisconception(concept, misconception) {
    if (!this.commonMisconceptions[concept]) {
      this.commonMisconceptions[concept] = [];
    }
    if (!this.commonMisconceptions[concept].includes(misconception)) {
      this.commonMisconceptions[concept].push(misconception);
      console.log(`Added new misconception for ${concept}: ${misconception}`);
    }
  }
  
  getCommonMisconceptions(concept) {
    return this.commonMisconceptions[concept] || [];
  }
}

module.exports = MisconceptionDetector;