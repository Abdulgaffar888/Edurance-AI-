// src/ai/tutor/student-model.js
class StudentModel {
    constructor(sessionId) {
      this.sessionId = sessionId;
      this.knowledgeGraph = {}; // conceptId → {mastery: 0-1, lastPracticed: timestamp}
      this.interactions = [];
      this.learningStyle = this.detectLearningStyle(); // visual/auditory/kinesthetic
      this.attentionSpan = 5; // minutes (would adjust based on behavior)
      this.misconceptions = new Map(); // misconception → frequency
      this.startTime = Date.now();
    }
    
    detectLearningStyle() {
      // Simple heuristic - would use AI in production
      const styles = ['visual', 'auditory', 'kinesthetic'];
      return styles[Math.floor(Math.random() * styles.length)];
    }
    
    updateFromInteraction(interaction) {
      this.interactions.push({
        ...interaction,
        timestamp: Date.now()
      });
      
      // Update mastery
      if (interaction.concept?.id) {
        const currentMastery = this.knowledgeGraph[interaction.concept.id]?.mastery || 0;
        this.knowledgeGraph[interaction.concept.id] = {
          mastery: Math.min(1, currentMastery + 0.2), // Learning gain
          lastPracticed: Date.now(),
          timesPracticed: (this.knowledgeGraph[interaction.concept.id]?.timesPracticed || 0) + 1
        };
      }
      
      // Track misconceptions
      if (interaction.misconceptions?.length > 0) {
        interaction.misconceptions.forEach(misconception => {
          const count = this.misconceptions.get(misconception) || 0;
          this.misconceptions.set(misconception, count + 1);
        });
      }
      
      // Keep only recent interactions
      if (this.interactions.length > 50) {
        this.interactions = this.interactions.slice(-50);
      }
    }
    
    getMastery(conceptId) {
      return this.knowledgeGraph[conceptId]?.mastery || 0;
    }
    
    getLevel() {
      const masteries = Object.values(this.knowledgeGraph).map(k => k.mastery);
      const avgMastery = masteries.length > 0 ? 
        masteries.reduce((a, b) => a + b, 0) / masteries.length : 0;
      
      if (avgMastery < 0.3) return 'beginner';
      if (avgMastery < 0.7) return 'intermediate';
      return 'advanced';
    }
    
    getRecentInteractions(count = 5) {
      return this.interactions.slice(-count);
    }
    
    getInteractionCount() {
      return this.interactions.length;
    }
    
    getRecencyScore() {
      if (this.interactions.length === 0) return 0.5;
      const lastInteraction = this.interactions[this.interactions.length - 1].timestamp;
      const minutesAgo = (Date.now() - lastInteraction) / (1000 * 60);
      return Math.max(0, 1 - (minutesAgo / 60)); // Decays over hour
    }
    
    getProgress() {
      const concepts = Object.keys(this.knowledgeGraph).length;
      const totalMastery = Object.values(this.knowledgeGraph)
        .reduce((sum, k) => sum + k.mastery, 0);
      return concepts > 0 ? Math.round((totalMastery / concepts) * 100) : 0;
    }
    
    getMasteredCount() {
      return Object.values(this.knowledgeGraph)
        .filter(k => k.mastery > 0.8).length;
    }
    
    getSnapshot() {
      return {
        sessionId: this.sessionId,
        level: this.getLevel(),
        learningStyle: this.learningStyle,
        conceptsMastered: this.getMasteredCount(),
        totalConcepts: Object.keys(this.knowledgeGraph).length,
        progress: this.getProgress(),
        commonMisconceptions: Array.from(this.misconceptions.entries())
          .sort((a, b) => b[1] - a[1])
          .slice(0, 3)
      };
    }
  }
  
  module.exports = StudentModel;