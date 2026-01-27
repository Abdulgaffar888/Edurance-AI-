// ai/tutor/diagnostic.js - Diagnostic Test System
const { updateDiagnosticResults, ALL_TOPICS } = require('./agent.js');

// 12 diagnostic questions (2 per topic)
const DIAGNOSTIC_QUESTIONS = [
  // Electric Current (2 questions)
  {
    id: "q1",
    question: "What is electric current?",
    options: ["The pressure that pushes electricity", "The flow of electric charge through a conductor", "The resistance in a circuit", "The brightness of a bulb"],
    correctAnswer: 1,
    topic: "electric_current",
    difficulty: "easy",
    explanation: "Electric current is the flow of electric charge through a conductor, like water flowing through a pipe."
  },
  {
    id: "q2",
    question: "What unit is used to measure electric current?",
    options: ["Volt", "Ampere", "Ohm", "Watt"],
    correctAnswer: 1,
    topic: "electric_current",
    difficulty: "easy",
    explanation: "Electric current is measured in amperes (A), often called amps."
  },

  // Potential Difference (2 questions)
  {
    id: "q3",
    question: "What is potential difference also called?",
    options: ["Current", "Resistance", "Voltage", "Power"],
    correctAnswer: 2,
    topic: "potential_difference",
    difficulty: "easy",
    explanation: "Potential difference is the same as voltage - it is the electrical pressure that pushes current through a circuit."
  },
  {
    id: "q4",
    question: "Which component provides potential difference in a circuit?",
    options: ["Bulb", "Wire", "Switch", "Cell or Battery"],
    correctAnswer: 3,
    topic: "potential_difference",
    difficulty: "easy",
    explanation: "A cell or battery provides the potential difference (voltage) that pushes electric current through the circuit."
  },

  // Resistance (2 questions)
  {
    id: "q5",
    question: "What does resistance do in an electric circuit?",
    options: ["Creates electricity", "Opposes the flow of current", "Makes current stronger", "Changes the color of wires"],
    correctAnswer: 1,
    topic: "resistance",
    difficulty: "easy",
    explanation: "Resistance opposes the flow of electric current, like friction opposes the movement of objects."
  },
  {
    id: "q6",
    question: "What unit measures electrical resistance?",
    options: ["Ampere", "Volt", "Ohm", "Watt"],
    correctAnswer: 2,
    topic: "resistance",
    difficulty: "easy",
    explanation: "Resistance is measured in ohms (Ω), named after Georg Ohm."
  },

  // Ohm's Law (2 questions)
  {
    id: "q7",
    question: "What does Ohm's Law state?",
    options: ["Current = Resistance ÷ Voltage", "Voltage = Current × Resistance", "Power = Current × Voltage", "Resistance = Current ÷ Voltage"],
    correctAnswer: 1,
    topic: "ohms_law",
    difficulty: "medium",
    explanation: "Ohm's Law states that Voltage (V) = Current (I) × Resistance (R), or V = I × R."
  },
  {
    id: "q8",
    question: "If a circuit has 3 volts and 2 ohms resistance, what is the current?",
    options: ["6 amps", "1.5 amps", "0.67 amps", "9 amps"],
    correctAnswer: 1,
    topic: "ohms_law",
    difficulty: "medium",
    explanation: "Using Ohm's Law: Current = Voltage ÷ Resistance = 3V ÷ 2Ω = 1.5A."
  },

  // Ohmic Materials (2 questions)
  {
    id: "q9",
    question: "Which material is a good conductor of electricity?",
    options: ["Plastic", "Rubber", "Copper wire", "Wood"],
    correctAnswer: 2,
    topic: "ohmic_materials",
    difficulty: "easy",
    explanation: "Copper is a good conductor because it allows electric current to flow easily through it."
  },
  {
    id: "q10",
    question: "What is the difference between a conductor and an insulator?",
    options: ["Conductors are hot, insulators are cold", "Conductors allow current to flow, insulators do not", "Conductors are thick, insulators are thin", "Conductors glow, insulators don't"],
    correctAnswer: 1,
    topic: "ohmic_materials",
    difficulty: "easy",
    explanation: "Conductors allow electric current to flow through them easily, while insulators prevent or resist the flow of current."
  },

  // Circuit Components (2 questions)
  {
    id: "q11",
    question: "What is the main purpose of a switch in a circuit?",
    options: ["To provide power", "To make light", "To open or close the circuit", "To measure current"],
    correctAnswer: 2,
    topic: "circuit_components",
    difficulty: "easy",
    explanation: "A switch is used to open or close an electric circuit, controlling whether current can flow or not."
  },
  {
    id: "q12",
    question: "Which of these is NOT a basic circuit component?",
    options: ["Cell", "Bulb", "Wire", "Television"],
    correctAnswer: 3,
    topic: "circuit_components",
    difficulty: "easy",
    explanation: "A television is not a basic circuit component. The basic components are cell/battery, bulb, switch, wires, and resistors."
  }
];

function calculateMasteryLevel(score) {
  if (score >= 80) return 'strong';
  if (score >= 60) return 'good';
  return 'weak';
}

function getTopicScore(answers, topic) {
  const topicQuestions = DIAGNOSTIC_QUESTIONS.filter(q => q.topic === topic);
  const topicAnswers = answers.filter(a => topicQuestions.some(q => q.id === a.questionId));

  if (topicAnswers.length === 0) return 0;

  let correct = 0;
  topicAnswers.forEach(answer => {
    const question = DIAGNOSTIC_QUESTIONS.find(q => q.id === answer.questionId);
    if (question && answer.selectedAnswer === question.correctAnswer) {
      correct++;
    }
  });

  return Math.round((correct / topicAnswers.length) * 100);
}

function scoreDiagnosticTest(answers) {
  let totalCorrect = 0;
  const results = {};

  // Score each topic
  ALL_TOPICS.forEach(topic => {
    const topicScore = getTopicScore(answers, topic);
    results[topic] = {
      score: topicScore,
      mastery: calculateMasteryLevel(topicScore)
    };
    // Count correct answers for overall score
    const topicQuestions = DIAGNOSTIC_QUESTIONS.filter(q => q.topic === topic);
    const topicAnswers = answers.filter(a => topicQuestions.some(q => q.id === a.questionId));
    topicAnswers.forEach(answer => {
      const question = DIAGNOSTIC_QUESTIONS.find(q => q.id === answer.questionId);
      if (question && answer.selectedAnswer === question.correctAnswer) {
        totalCorrect++;
      }
    });
  });

  const overallScore = Math.round((totalCorrect / answers.length) * 100);

  return {
    overall_score: overallScore,
    topic_results: results,
    total_questions: answers.length,
    correct_answers: totalCorrect,
    mastery_level: calculateMasteryLevel(overallScore)
  };
}

function startDiagnosticTest() {
  return {
    questions: DIAGNOSTIC_QUESTIONS,
    total_questions: DIAGNOSTIC_QUESTIONS.length,
    instructions: "Answer all questions to help us understand what you already know about electricity and circuits."
  };
}

function submitDiagnosticTest(sessionId, answers) {
  try {
    // Validate answers
    if (!Array.isArray(answers) || answers.length !== 12) {
      throw new Error("Invalid answers format - must submit all 12 answers");
    }

    // Score the test
    const results = scoreDiagnosticTest(answers);

    // Update student knowledge in agent.js
    updateDiagnosticResults(sessionId, results.topic_results);

    console.log(`📊 Diagnostic completed for session ${sessionId}: ${results.overall_score}% overall`);

    return {
      success: true,
      results: results,
      message: `Diagnostic completed! You scored ${results.overall_score}%. ${results.correct_answers}/${results.total_questions} questions correct.`,
      recommendations: generateRecommendations(results.topic_results)
    };

  } catch (error) {
    console.error("❌ Diagnostic submission error:", error.message);
    return {
      success: false,
      error: error.message,
      message: "Failed to process diagnostic test results."
    };
  }
}

function generateRecommendations(topicResults) {
  const weakTopics = Object.entries(topicResults)
    .filter(([_, result]) => result.mastery === 'weak')
    .map(([topic, _]) => topic.replace(/_/g, ' '));

  const goodTopics = Object.entries(topicResults)
    .filter(([_, result]) => result.mastery === 'good' || result.mastery === 'strong')
    .map(([topic, _]) => topic.replace(/_/g, ' '));

  let recommendations = [];

  if (weakTopics.length > 0) {
    recommendations.push(`Focus on improving: ${weakTopics.join(', ')}`);
  }

  if (goodTopics.length > 0) {
    recommendations.push(`You have good understanding of: ${goodTopics.join(', ')}`);
  }

  return recommendations;
}

module.exports = {
  startDiagnosticTest,
  submitDiagnosticTest,
  DIAGNOSTIC_QUESTIONS,
  scoreDiagnosticTest
};








