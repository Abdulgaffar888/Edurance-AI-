const AIService = require("./ai-service.js");
const StudentModel = require("./student-model.js");
const TeachingStrategies = require("./teaching-strategies.js");
const MisconceptionDetector = require("./misconception-detector.js");
const LearningPath = require("./learning-path.js");

class AITeachingAgent {
  constructor() {
    this.ai = new AIService();
    this.misconceptionDetector = new MisconceptionDetector();
    this.learningPath = new LearningPath();
    this.studentModels = new Map(); // session_id → StudentModel
    
    console.log("🚀 YC-Ready AI Teaching Agent initialized");
  }
  
  async teach(studentQuestion, session, context) {
    try {
      // 1. Get or create student model
      const studentModel = this.getStudentModel(session.session_id);
      
      // 2. DIAGNOSE understanding (YC loves this)
      const diagnosis = await this.diagnoseUnderstanding(
        studentQuestion, 
        context, 
        studentModel
      );
      
      // 3. ADAPT teaching strategy (Personalization = $$$)
      const strategy = this.chooseTeachingStrategy(diagnosis, studentModel);
      
      // 4. EXPLAIN with AI that actually understands
      const explanation = await this.generateExplanation(
        diagnosis.concept,
        strategy,
        studentModel
      );
      
      // 5. Detect misconceptions
      const misconceptions = await this.misconceptionDetector.detect(
        studentQuestion,
        diagnosis.correctUnderstanding
      );
      
      // 6. ASSESS (Learning measurement)
      const assessmentQuestion = this.createAssessmentQuestion(
        explanation,
        diagnosis.gap,
        misconceptions
      );
      
      // 7. ITERATE (Continuous improvement)
      this.updateLearningPath(session, diagnosis, explanation.effectiveness);
      
      // 8. Update student model
      studentModel.updateFromInteraction({
        concept: diagnosis.concept,
        question: studentQuestion,
        explanation: explanation,
        assessment: assessmentQuestion,
        misconceptions: misconceptions
      });
      
      return {
        teaching_point: explanation.content,
        question: assessmentQuestion,
        concept_id: diagnosis.concept.id,
        is_concept_cleared: diagnosis.mastery > 0.8,
        // YC wants metrics:
        _metrics: {
          mastery_gain: diagnosis.masteryChange || 0.1,
          time_to_learn: Date.now() - session.startTime || 0,
          engagement_score: this.calculateEngagement(studentModel),
          misconceptions_found: misconceptions.length,
          teaching_strategy: strategy.name
        },
        // For debugging/demo:
        _demo: {
          student_level: studentModel.getLevel(),
          learning_style: studentModel.learningStyle,
          concepts_mastered: studentModel.getMasteredCount(),
          session_progress: `${studentModel.getProgress()}%`
        }
      };
      
    } catch (error) {
      console.error("AI Teaching Agent error:", error);
      return this.getFallbackResponse(context);
    }
  }
  
  async diagnoseUnderstanding(question, context, studentModel) {
    // Use AI to analyze what student understands/misunderstands
    const systemPrompt = `
    You are an expert educational diagnostician. Analyze the student's question to determine:
    1. What concept they're asking about
    2. Their current understanding level (0-1)
    3. Any misconceptions they might have
    4. The gap between their understanding and correct understanding
    
    Student question: "${question}"
    Student history: ${JSON.stringify(studentModel.getRecentInteractions(3))}
    Available context: ${context[0]?.text?.substring(0, 200) || "No context"}
    
    Return JSON: {
      "concept": {"id": "concept_id", "name": "Concept name"},
      "understandingLevel": 0.3,
      "misconceptions": ["list", "of", "misunderstandings"],
      "gap": "What they're missing",
      "mastery": 0.3,
      "masteryChange": 0.1
    }
    `;
    
    const response = await this.ai.generateTeachingResponse(
      systemPrompt,
      JSON.stringify({ question, studentLevel: studentModel.getLevel() }),
      context
    );
    
    return response;
  }
  
  chooseTeachingStrategy(diagnosis, studentModel) {
    return TeachingStrategies.getStrategy(diagnosis, studentModel);
  }
  
  async generateExplanation(concept, strategy, studentModel) {
    const systemPrompt = `
    You are an expert Grade 6 Science teacher. Explain this concept in a way that matches:
    - Teaching strategy: ${strategy.name}
    - Student learning style: ${studentModel.learningStyle}
    - Student level: ${studentModel.getLevel()}
    
    Concept to explain: ${concept.name}
    Strategy details: ${JSON.stringify(strategy)}
    
    Make it engaging, use appropriate analogies, and keep it to 2-3 sentences max.
    `;
    
    const response = await this.ai.generateTeachingResponse(
      systemPrompt,
      `Explain: ${concept.name}`,
      []
    );
    
    return {
      content: response.teaching_point || `Let's learn about ${concept.name}!`,
      strategy: strategy.name,
      effectiveness: 0.8 // Would track actual effectiveness
    };
  }
  
  createAssessmentQuestion(explanation, gap, misconceptions) {
    // Create question that tests if gap was filled
    return `Based on what we just discussed: ${misconceptions.length > 0 ? 
      `You mentioned "${misconceptions[0]}". How would you correct that understanding?` : 
      "Can you explain this concept in your own words?"}`;
  }
  
  calculateEngagement(studentModel) {
    // Simple engagement score based on interaction patterns
    const interactions = studentModel.getInteractionCount();
    const recency = studentModel.getRecencyScore();
    return Math.min(1, (interactions * 0.1 + recency * 0.9));
  }
  
  getStudentModel(sessionId) {
    if (!this.studentModels.has(sessionId)) {
      this.studentModels.set(sessionId, new StudentModel(sessionId));
      console.log(`Created new student model for ${sessionId}`);
    }
    return this.studentModels.get(sessionId);
  }
  
  updateLearningPath(session, diagnosis, effectiveness) {
    this.learningPath.recordOutcome(
      diagnosis.concept.id,
      effectiveness,
      session.session_id
    );
  }
  
  getFallbackResponse(context) {
    const chunk = context[0];
    return {
      teaching_point: `Let's explore: ${chunk?.text?.substring(0, 100) || "electric circuits"}...`,
      question: "What would you like to know more about?",
      concept_id: chunk?.id || "fallback_01",
      is_concept_cleared: false,
      _metrics: { mastery_gain: 0, time_to_learn: 0, engagement_score: 0.5 },
      _demo: { note: "Using fallback response" }
    };
  }
}

module.exports = AITeachingAgent;