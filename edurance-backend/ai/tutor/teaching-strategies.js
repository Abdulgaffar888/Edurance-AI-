// ai/tutor/teaching-strategies.js - FIXED
class TeachingStrategies {
    static getStrategy(diagnosis, studentModel) {
      // FIX: Add null checks
      if (!diagnosis || !studentModel) {
        return this.getDefaultStrategy();
      }
      
      const understandingLevel = diagnosis.understandingLevel || 0;
      const misconceptions = diagnosis.misconceptions || [];
      const concept = diagnosis.concept || { name: 'electricity' };
      const learningStyle = studentModel.learningStyle || 'visual';
      const level = studentModel.getLevel ? studentModel.getLevel() : 'beginner';
      
      // Rest of your code...
      if (understandingLevel < 0.3) {
        return this.getBeginnerStrategy(concept, learningStyle);
      } 
      // ... rest of code
    }
    
    static getDefaultStrategy() {
      return {
        name: 'default_explanation',
        description: 'Basic explanation with example',
        template: 'Let me explain this concept simply...',
        example: 'Think of electricity like water flowing',
        duration: '2-3 minutes'
      };
    }
    
    // ... rest of your methods
  }