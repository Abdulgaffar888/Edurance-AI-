// src/ai/tutor/learning-path.js
class LearningPath {
    constructor() {
      this.conceptGraph = {
        'electric_cell': { prerequisites: [], next: ['simple_circuit'] },
        'simple_circuit': { prerequisites: ['electric_cell'], next: ['switch', 'bulb'] },
        'switch': { prerequisites: ['simple_circuit'], next: ['complex_circuit'] },
        'bulb': { prerequisites: ['simple_circuit'], next: ['series_circuit'] },
        'series_circuit': { prerequisites: ['bulb', 'simple_circuit'], next: ['parallel_circuit'] },
        'parallel_circuit': { prerequisites: ['series_circuit'], next: [] }
      };
      
      this.pathOutcomes = new Map(); // concept → {success: count, failure: count}
    }
    
    getNextConcept(currentConcepts) {
      // Find concepts where all prerequisites are met
      const available = Object.entries(this.conceptGraph)
        .filter(([concept, data]) => {
          if (currentConcepts.includes(concept)) return false; // Already learned
          return data.prerequisites.every(pre => currentConcepts.includes(pre));
        })
        .map(([concept]) => concept);
      
      // Choose based on success rates
      return available.sort((a, b) => {
        const aSuccess = this.getSuccessRate(a);
        const bSuccess = this.getSuccessRate(b);
        return bSuccess - aSuccess; // Higher success rate first
      })[0] || 'electric_cell';
    }
    
    recordOutcome(concept, success, studentId) {
      const key = `${concept}_${studentId}`;
      const outcomes = this.pathOutcomes.get(key) || { success: 0, failure: 0 };
      
      if (success) {
        outcomes.success++;
      } else {
        outcomes.failure++;
      }
      
      this.pathOutcomes.set(key, outcomes);
      console.log(`Recorded ${success ? 'success' : 'failure'} for ${concept} by ${studentId}`);
    }
    
    getSuccessRate(concept) {
      const allOutcomes = Array.from(this.pathOutcomes.entries())
        .filter(([key]) => key.startsWith(concept + '_'))
        .map(([, outcome]) => outcome);
      
      if (allOutcomes.length === 0) return 0.7; // Default
      
      const total = allOutcomes.reduce((sum, o) => sum + o.success + o.failure, 0);
      const successes = allOutcomes.reduce((sum, o) => sum + o.success, 0);
      
      return total > 0 ? successes / total : 0.5;
    }
    
    getOptimalPath(studentLevel) {
      const basePath = ['electric_cell', 'simple_circuit'];
      
      if (studentLevel === 'beginner') {
        return [...basePath, 'bulb', 'switch'];
      } else if (studentLevel === 'intermediate') {
        return [...basePath, 'switch', 'series_circuit'];
      } else {
        return [...basePath, 'series_circuit', 'parallel_circuit'];
      }
    }
    
    // For YC demo: Show adaptive learning
    getAdaptivePath(studentModel) {
      const mastered = Object.keys(studentModel.knowledgeGraph)
        .filter(k => studentModel.getMastery(k) > 0.8);
      
      return this.getNextConcept(mastered);
    }
  }
  
  module.exports = LearningPath;