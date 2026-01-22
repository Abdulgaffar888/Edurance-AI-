require('dotenv').config();
const express = require('express');
const cors = require('cors');
const OpenAI = require("openai");
const admin = require('firebase-admin');
const tutorRoutes = require('../ai/tutor/routes'); // ONLY ONCE

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Tutor API
app.use('/api/tutor', tutorRoutes);

// const openai = new OpenAI({
//   apiKey: process.env.OPENAI_API_KEY,
// });

// Initialize Firebase Admin
try {
  const serviceAccount = require('./firebase-service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized');
} catch (e) {
  console.log('⚠️ Firebase Admin not initialized (no service account)');
}

app.get('/', (req, res) => {
  res.send('Edurance Backend Running');
});

/* =========================
   LEARN
========================= */
app.post("/api/learn", async (req, res) => {
  const { topic, grade } = req.body;

  if (!topic || !grade) {
    return res.status(400).json({ error: "Topic and grade required" });
  }

  try {
    let linesPerCard;
    let languageRule;
    let examRule = "";

    if (grade === 4) {
      linesPerCard = "6–7 complete lines";
      languageRule = "very simple sentences, daily life examples, no jargon";
    } else if (grade === 5) {
      linesPerCard = "7–8 complete lines";
      languageRule = "simple explanations, clear structure, daily examples";
    } else if (grade === 6) {
      linesPerCard = "8–9 complete lines";
      languageRule = "clear definitions, structured explanation, key terms";
    } else if (grade === 7) {
      linesPerCard = "9–10 complete lines";
      languageRule = "how and why explanations, cause-effect relationships";
    } else if (grade <= 9) {
      linesPerCard = "10–12 complete lines";
      languageRule = "detailed explanations, examples, reasoning";
    } else if (grade === 10) {
      linesPerCard = "12–14 complete lines";
      languageRule = "exam-oriented, mechanisms, processes, precise terms";
      examRule = "Write answers suitable for board exam preparation.";
    } else {
      linesPerCard = "14–16 complete lines";
      languageRule = "exam-ready depth, formal reasoning, precise terminology";
      examRule = "Answers must be sufficient for full exam marks.";
    }

    const prompt = `
You are a STRICT school teacher preparing EXAM-READY flashcards.

Topic: "${topic}"
Grade: ${grade}

CREATE EXACTLY 5 FLASHCARDS.

⚠️ CRITICAL RULE (VERY IMPORTANT):
- EVERY flashcard must have THE SAME DEPTH AND DETAIL.
- Do NOT make the first flashcard longer than others.
- If ONE flashcard is shallow, the answer is INVALID.

Each flashcard MUST contain:
- emoji: exactly ONE relevant emoji
- title: 3–6 words
- hook: exactly ONE engaging sentence
- content: EXACTLY ${linesPerCard}

Content rules for EVERY flashcard:
- ${languageRule}
- Each line must be a FULL sentence.
- No summaries.
- Each flashcard represents ONE exam-relevant concept.
${examRule}

ABSOLUTE RULES:
- Depth must be CONSISTENT across ALL flashcards.
- Do NOT reduce detail in later flashcards.
- Do NOT use markdown.
- Do NOT use LaTeX or symbols.
- Output ONLY valid JSON.

Return ONLY this format:
{
  "flashcards": [
    {
      "emoji": "📘",
      "title": "Concept title",
      "hook": "Engaging opening sentence.",
      "content": "Line 1. Line 2. Line 3. Line 4. Line 5. Line 6."
    }
  ]
}
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "You are a strict teacher. Reject shallow answers. Return JSON only."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.4,
      response_format: { type: "json_object" }
    });

    const parsed = JSON.parse(completion.choices[0].message.content);

    res.json({
      title: topic,
      grade,
      flashcards: parsed.flashcards
    });

  } catch (e) {
    console.error("Learn failed:", e);
    res.status(500).json({ error: "Learn failed" });
  }
});

/* =========================
   DOUBT
========================= */
app.post("/api/doubt", async (req, res) => {
  const { doubt, topic, grade } = req.body;

  if (!doubt) return res.status(400).json({ error: "Doubt required" });

  try {
    const prompt = `
Student (Grade ${grade || 8}) asks:
"${doubt}"

Explain clearly and concisely.
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a helpful teacher." },
        { role: "user", content: prompt }
      ],
      temperature: 0.5,
    });

    res.json({ answer: completion.choices[0].message.content });

  } catch (e) {
    res.status(500).json({ error: "Doubt failed" });
  }
});

/* =========================
   SOLVE
========================= */
app.post("/api/solve", async (req, res) => {
  const { question, grade } = req.body;

  if (!question || !grade) {
    return res.status(400).json({ error: "Question and grade required" });
  }

  try {
    const prompt = `
You are an EXAM-CHECKING teacher solving a Grade ${grade} question.

Question:
"${question}"

MANDATORY RULES:

1. Solve step-by-step with numbered steps.
2. Show all formulas, substitutions, and reasoning.
3. NEVER guess or assume missing information.
4. After solving, perform a FINAL SELF-CHECK:
   - Are all steps logically valid?
   - Are calculations correct?
   - Is this solution exam-safe?

5. IF THERE IS ANY DOUBT AT ALL:
   - DO NOT give the solution
   - Return:
     {
       "steps": [],
       "finalAnswer": "Insufficient information to solve accurately. Please provide more details."
     }

Return ONLY valid JSON:
{
  "steps": ["Step 1: ...", "Step 2: ..."],
  "finalAnswer": "..."
}

IMPORTANT OUTPUT RULES:
- Do NOT use LaTeX, TeX, or math symbols like $, \, ^, or subscripts
- Write all math in plain text
  Example:
  Use "angle A" instead of "\angle A"
  Use "180 degrees" instead of "180°"
- Ensure all text is valid JSON-safe plain text

Accuracy > completeness. Refusal is better than a wrong answer.
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "Accuracy is critical. Never guess. Return JSON only." },
        { role: "user", content: prompt }
      ],
      temperature: 0.2,
      response_format: { type: "json_object" }
    });

    let parsed;

    try {
      parsed = JSON.parse(completion.choices[0].message.content);
    } catch (err) {
      console.error(
        "❌ JSON parse failed in /api/solve. Raw AI output:\n",
        completion.choices[0].message.content
      );
    
      return res.json({
        steps: [],
        finalAnswer:
          "The question was understood, but the response format failed. Please retry or rephrase the question."
      });
    }
    
    res.json({
      steps: Array.isArray(parsed.steps) ? parsed.steps : [],
      finalAnswer:
        typeof parsed.finalAnswer === "string"
          ? parsed.finalAnswer
          : "Unable to solve accurately."
    });
    

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Solve failed" });
  }
});

/* =========================
   PROFILE APIs
========================= */
app.post('/api/profile/save', async (req, res) => {
  try {
    const { userId, grade, school, prevExamPercentage, parentPhone } = req.body;
    
    if (!userId || !grade || !parentPhone) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Save to Firestore if admin is initialized
    if (admin.apps.length > 0) {
      try {
        await admin.firestore().collection('students').doc(userId).set({
          userId,
          grade: parseInt(grade),
          school: school || '',
          prevExamPercentage: prevExamPercentage ? parseFloat(prevExamPercentage) : null,
          parentPhone,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (firestoreError) {
        console.log('Firestore save failed, continuing:', firestoreError);
      }
    }
    
    res.json({
      success: true,
      message: 'Profile saved successfully',
      data: {
        userId,
        grade,
        school,
        prevExamPercentage,
        parentPhone
      }
    });
  } catch (error) {
    console.error('Profile save error:', error);
    res.status(500).json({ error: 'Failed to save profile' });
  }
});

app.get('/api/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (admin.apps.length > 0) {
      try {
        const doc = await admin.firestore().collection('students').doc(userId).get();
        if (doc.exists) {
          return res.json({
            success: true,
            data: doc.data()
          });
        }
      } catch (firestoreError) {
        console.log('Firestore fetch failed:', firestoreError);
      }
    }
    
    // Fallback if Firestore not available
    res.json({
      success: true,
      data: {
        userId,
        grade: 8,
        school: 'Sample School',
        prevExamPercentage: 75,
        parentPhone: '+1234567890'
      }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

/* =========================
   DIAGNOSTIC APIs
========================= */
app.post('/api/diagnostic/start', async (req, res) => {
  try {
    const { userId, grade } = req.body;
    
    if (!userId || !grade) {
      return res.status(400).json({ error: 'Missing userId or grade' });
    }
    
    const questions = getSampleQuestions(grade);
    
    const testSession = {
      userId,
      grade,
      questions,
      startedAt: new Date().toISOString(),
      sessionId: `test_${Date.now()}_${userId.substring(0, 8)}`
    };
    
    // Save session to Firestore if available
    if (admin.apps.length > 0) {
      try {
        await admin.firestore().collection('diagnostics').doc(testSession.sessionId).set(testSession);
      } catch (e) {
        console.log('Firestore save failed for session:', e);
      }
    }
    
    res.json({
      success: true,
      sessionId: testSession.sessionId,
      questions: testSession.questions,
      totalQuestions: testSession.questions.length,
      timeLimit: 1800,
    });
  } catch (error) {
    console.error('Start diagnostic error:', error);
    res.status(500).json({ error: 'Failed to start diagnostic test' });
  }
});

app.post('/api/diagnostic/submit', async (req, res) => {
  try {
    const { userId, sessionId, answers } = req.body;
    
    if (!userId || !sessionId || !answers) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const questions = getSampleQuestions(8);
    
    let score = 0;
    const results = [];
    const weaknesses = [];
    
    answers.forEach((answer, index) => {
      if (index < questions.length) {
        const question = questions[index];
        const isCorrect = answer.selectedOption === question.correctAnswer;
        
        if (isCorrect) {
          score++;
        } else {
          weaknesses.push(question.topic);
        }
        
        results.push({
          question: question.question,
          selectedOption: answer.selectedOption,
          correctAnswer: question.correctAnswer,
          isCorrect,
          explanation: question.explanation
        });
      }
    });
    
    const percentage = (score / questions.length) * 100;
    
    const prescription = {
      overallScore: percentage,
      strengthAreas: weaknesses.length === 0 ? ['Good foundation'] : [],
      weakAreas: [...new Set(weaknesses)],
      recommendation: getRecommendation(percentage),
      testDate: new Date().toISOString()
    };
    
    // Save results to Firestore if available
    if (admin.apps.length > 0) {
      try {
        await admin.firestore().collection('diagnostic_results').doc(sessionId).set({
          userId,
          sessionId,
          score: percentage,
          correct: score,
          total: questions.length,
          prescription,
          results,
          submittedAt: new Date().toISOString()
        });
      } catch (e) {
        console.log('Firestore save failed for results:', e);
      }
    }
    
    res.json({
      success: true,
      score: percentage.toFixed(1),
      correct: score,
      total: questions.length,
      prescription,
      results
    });
  } catch (error) {
    console.error('Submit diagnostic error:', error);
    res.status(500).json({ error: 'Failed to submit diagnostic test' });
  }
});

/* =========================
   CURRICULUM GENERATION
========================= */
app.post('/api/curriculum/generate', async (req, res) => {
  try {
    const { userId, weakAreas, strengthAreas, overallScore, grade } = req.body;
    
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }
    
    const curriculum = await generateCurriculumPlan({
      weakAreas,
      strengthAreas,
      overallScore,
      grade,
      userId
    });
    
    // Save to Firestore if available
    if (admin.apps.length > 0) {
      try {
        await admin.firestore().collection('curriculum').doc(userId).set({
          userId,
          ...curriculum,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (e) {
        console.log('Firestore save failed for curriculum:', e);
      }
    }
    
    res.json({
      success: true,
      curriculum,
      message: '1-month curriculum generated successfully'
    });
  } catch (error) {
    console.error('Curriculum generation error:', error);
    res.status(500).json({ error: 'Failed to generate curriculum' });
  }
});

/* =========================
   PROGRESS TRACKING
========================= */
app.post('/api/progress/record', async (req, res) => {
  try {
    const { userId, date, timeSpent, topicsCompleted, dayRating } = req.body;
    
    if (!userId || !date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const progressData = {
      userId,
      date,
      timeSpent: timeSpent || 0,
      topicsCompleted: topicsCompleted || [],
      dayRating: dayRating || 3,
      recordedAt: new Date().toISOString()
    };
    
    // Save to Firestore if available
    if (admin.apps.length > 0) {
      try {
        await admin.firestore().collection('progress').add(progressData);
      } catch (e) {
        console.log('Firestore save failed for progress:', e);
      }
    }
    
    res.json({
      success: true,
      message: 'Progress recorded successfully',
      data: progressData
    });
  } catch (error) {
    console.error('Progress recording error:', error);
    res.status(500).json({ error: 'Failed to record progress' });
  }
});

app.get('/api/progress/summary/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const days = parseInt(req.query.days) || 7;
    
    let summary = getDefaultSummary(userId, days);
    
    // Try to fetch from Firestore if available
    if (admin.apps.length > 0) {
      try {
        const snapshot = await admin.firestore()
          .collection('progress')
          .where('userId', '==', userId)
          .orderBy('date', 'desc')
          .limit(days)
          .get();
        
        if (!snapshot.empty) {
          const progressEntries = [];
          let totalTime = 0;
          let totalTopics = 0;
          let totalRating = 0;
          
          snapshot.forEach(doc => {
            const data = doc.data();
            progressEntries.push(data);
            totalTime += data.timeSpent || 0;
            totalTopics += data.topicsCompleted?.length || 0;
            totalRating += data.dayRating || 3;
          });
          
          const count = progressEntries.length;
          summary = {
            userId,
            period: `${days} days`,
            totalTimeSpent: totalTime,
            topicsCompleted: totalTopics,
            averageRating: count > 0 ? (totalRating / count).toFixed(1) : 0,
            consistency: count >= 5 ? '85%' : `${(count/days*100).toFixed(0)}%`,
            dailyAverages: {
              timeSpent: count > 0 ? Math.round(totalTime / count) : 0,
              topics: count > 0 ? (totalTopics / count).toFixed(1) : 0,
              rating: count > 0 ? (totalRating / count).toFixed(1) : 0
            },
            recentEntries: progressEntries.slice(0, 5)
          };
        }
      } catch (e) {
        console.log('Firestore fetch failed for progress:', e);
      }
    }
    
    res.json({
      success: true,
      summary
    });
  } catch (error) {
    console.error('Progress summary error:', error);
    res.status(500).json({ error: 'Failed to fetch progress summary' });
  }
});

/* =========================
   HELPER FUNCTIONS
========================= */
function getSampleQuestions(grade) {
  return [
    {
      id: 1,
      question: "What is the value of 3 × (4 + 5)?",
      options: ["12", "27", "17", "21"],
      correctAnswer: 1,
      explanation: "First solve bracket: 4 + 5 = 9, then multiply: 3 × 9 = 27",
      topic: "Basic Arithmetic",
      difficulty: "easy"
    },
    {
      id: 2,
      question: "If a triangle has angles of 60° and 70°, what is the third angle?",
      options: ["40°", "50°", "60°", "70°"],
      correctAnswer: 1,
      explanation: "Sum of angles in triangle = 180°. 180 - (60 + 70) = 50°",
      topic: "Geometry",
      difficulty: "medium"
    },
    {
      id: 3,
      question: "Simplify: 2x + 3x - x",
      options: ["4x", "5x", "6x", "3x"],
      correctAnswer: 0,
      explanation: "Combine like terms: 2x + 3x = 5x, 5x - x = 4x",
      topic: "Algebra",
      difficulty: "easy"
    },
    {
      id: 4,
      question: "What is 15% of 200?",
      options: ["15", "30", "25", "20"],
      correctAnswer: 1,
      explanation: "15% of 200 = (15/100) × 200 = 0.15 × 200 = 30",
      topic: "Percentage",
      difficulty: "easy"
    },
    {
      id: 5,
      question: "Solve for x: 2x - 5 = 11",
      options: ["x = 3", "x = 8", "x = 6", "x = 7"],
      correctAnswer: 1,
      explanation: "2x - 5 = 11 → 2x = 16 → x = 8",
      topic: "Linear Equations",
      difficulty: "medium"
    }
  ];
}

function getRecommendation(percentage) {
  if (percentage >= 80) {
    return "Excellent foundation! You can proceed to advanced topics.";
  } else if (percentage >= 60) {
    return "Good understanding. Focus on weak areas before advancing.";
  } else if (percentage >= 40) {
    return "Needs improvement. Start with basic concepts reinforcement.";
  } else {
    return "Requires significant support. Begin with foundational topics.";
  }
}

async function generateCurriculumPlan(params) {
  const { weakAreas, strengthAreas, overallScore, grade, userId } = params;
  
  let studyIntensity = 'moderate';
  let dailyStudyTime = 60;
  
  if (overallScore >= 80) {
    studyIntensity = 'light';
    dailyStudyTime = 45;
  } else if (overallScore >= 60) {
    studyIntensity = 'moderate';
    dailyStudyTime = 60;
  } else if (overallScore >= 40) {
    studyIntensity = 'intensive';
    dailyStudyTime = 90;
  } else {
    studyIntensity = 'remedial';
    dailyStudyTime = 120;
  }
  
  const weeklyPlans = [];
  
  for (let week = 1; week <= 4; week++) {
    const weekPlan = {
      weekNumber: week,
      focus: week === 1 ? 'Foundation Building' : 
             week === 2 ? 'Core Concepts' :
             week === 3 ? 'Advanced Topics' : 'Revision & Practice',
      dailySchedule: []
    };
    
    for (let day = 1; day <= 7; day++) {
      const dayPlan = {
        day: day,
        date: new Date(Date.now() + (week-1)*7*24*60*60*1000 + (day-1)*24*60*60*1000).toISOString().split('T')[0],
        topics: [],
        timeAllocated: dailyStudyTime,
        status: 'pending'
      };
      
      if (weakAreas.length > 0) {
        const topicIndex = (week * 7 + day) % weakAreas.length;
        dayPlan.topics.push({
          name: weakAreas[topicIndex],
          type: 'weak_area',
          time: Math.floor(dailyStudyTime * 0.7)
        });
      }
      
      if (strengthAreas.length > 0 && day % 3 === 0) {
        const strengthIndex = day % strengthAreas.length;
        dayPlan.topics.push({
          name: strengthAreas[strengthIndex],
          type: 'strength_reinforcement',
          time: Math.floor(dailyStudyTime * 0.3)
        });
      }
      
      weekPlan.dailySchedule.push(dayPlan);
    }
    
    weeklyPlans.push(weekPlan);
  }
  
  const firstWeek = weeklyPlans[0].dailySchedule.map(day => ({
    day: `Day ${day.day}`,
    topic: day.topics[0]?.name || 'Mixed Review',
    time: day.timeAllocated
  }));
  
  return {
    userId,
    generatedAt: new Date().toISOString(),
    duration: '1_month',
    studyIntensity,
    dailyStudyTime,
    weakAreaCoverage: `${Math.min(weakAreas.length * 20, 100)}%`,
    weeklyPlans,
    firstWeek,
    dailyFocus: weakAreas.length > 0 ? weakAreas[0] : 'General Studies'
  };
}

function getDefaultSummary(userId, days) {
  return {
    userId,
    period: `${days} days`,
    totalTimeSpent: 420,
    topicsCompleted: 15,
    averageRating: 3.8,
    consistency: '85%',
    weakAreasImproved: ['Algebra', 'Geometry'],
    dailyAverages: {
      timeSpent: 60,
      topics: 2.1,
      rating: 3.8
    }
  };
}

app.listen(3000, "0.0.0.0", () => {
  console.log("Server running on all interfaces on port 3000");
});
