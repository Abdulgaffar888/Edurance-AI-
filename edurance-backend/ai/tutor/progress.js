// ai/tutor/progress.js - REAL Progress Tracking
const { getStudentProgress, ALL_TOPICS } = require('./agent.js');

function getLearningProgress(sessionId) {
  try {
    const studentProgress = getStudentProgress(sessionId);

    if (!studentProgress) {
      return {
        success: false,
        error: "No learning session found",
        message: "Start learning with the AI tutor to see progress."
      };
    }

    const topicsTaught = studentProgress.topics_taught || [];
    const topicsMastered = studentProgress.topics_mastered || [];
    const totalTopics = ALL_TOPICS.length;

    const overallProgress = Math.round((topicsTaught.length / totalTopics) * 100);

    // Build topic-wise progress
    const topics = {};
    ALL_TOPICS.forEach(topic => {
      const isTaught = topicsTaught.includes(topic);
      const isMastered = topicsMastered.includes(topic);
      const diagnosticResult = studentProgress.diagnostic_results?.[topic];
      const score = diagnosticResult?.score ?? null;

      topics[topic] = {
        taught: isTaught,
        mastered: isMastered,
        score: score
      };
    });

    const recommendations = generateRecommendations(studentProgress);

    return {
      success: true,
      progress: {
        topics,
        overall: {
          topics_taught: topicsTaught.length,
          topics_mastered: topicsMastered.length,
          total_topics: totalTopics,
          percentage: overallProgress
        },
        recommendations
      }
    };

  } catch (error) {
    console.error("❌ Progress error:", error.message);
    return {
      success: false,
      error: error.message,
      message: "Failed to retrieve progress."
    };
  }
}

function generateRecommendations(studentProgress) {
  const recs = [];

  const taught = studentProgress.topics_taught || [];
  const mastered = studentProgress.topics_mastered || [];
  const diagnostic = studentProgress.diagnostic_results || {};

  // 1. If nothing taught yet
  if (taught.length === 0) {
    recs.push("Start learning with the AI tutor to begin your journey.");
    return recs;
  }

  // 2. Weak diagnostic areas not yet mastered
  const weakFromDiagnostic = Object.entries(diagnostic)
    .filter(([_, r]) => r.mastery === 'weak')
    .map(([topic]) => topic);

  const weakAndNotMastered = weakFromDiagnostic.filter(t => !mastered.includes(t));
  if (weakAndNotMastered.length > 0) {
    recs.push(`Focus on weak areas: ${weakAndNotMastered.map(t => t.replace(/_/g,' ')).join(', ')}`);
  }

  // 3. Topics started but not mastered
  const inProgress = taught.filter(t => !mastered.includes(t));
  if (inProgress.length > 0) {
    recs.push(`Practice more: ${inProgress.map(t => t.replace(/_/g,' ')).join(', ')}`);
  }

  // 4. Topics not started
  const notStarted = ALL_TOPICS.filter(t => !taught.includes(t));
  if (notStarted.length > 0) {
    recs.push(`Next topics to learn: ${notStarted.map(t => t.replace(/_/g,' ')).join(', ')}`);
  }

  if (recs.length === 0) {
    recs.push("Excellent! Revise all topics to stay exam-ready.");
  }

  return recs;
}

module.exports = {
  getLearningProgress
};
