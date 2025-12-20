require('dotenv').config();
const express = require('express');
const cors = require('cors');
const OpenAI = require("openai");

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

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
    let contentLines;
    let contentStyle;
    let examOrientation = "";

    if (grade === 4) {
      contentLines = "6-7 lines";
      contentStyle = "short sentences, daily examples, simple explanations";
    } else if (grade === 5) {
      contentLines = "7-8 lines";
      contentStyle = "clear explanations, daily examples, structured content";
    } else if (grade === 6) {
      contentLines = "8-9 lines";
      contentStyle = "clear definitions, structured explanations, key terms";
    } else if (grade === 7) {
      contentLines = "9-10 lines";
      contentStyle = "how/why explanations, cause-effect relationships, examples";
    } else if (grade <= 9) {
      contentLines = "10-12 lines";
      contentStyle = "comprehensive how/why explanations, detailed examples";
    } else if (grade === 10) {
      contentLines = "12-14 lines";
      contentStyle = "mechanisms, processes, keywords, exam-relevant details";
      examOrientation = "Focus on exam-relevant mechanisms and precise terminology.";
    } else {
      contentLines = "14-16 lines";
      contentStyle = "exam-oriented, precise terminology, formulas, detailed analysis";
      examOrientation = "Exam-ready depth with formal reasoning and precise definitions.";
    }

    const prompt = `
You are a teacher creating a flashcard-style lesson about "${topic}" for Grade ${grade}.

Create 5–7 flashcards. Each flashcard must include:
- emoji
- title (3–6 words)
- hook (1 engaging sentence)
- content: EXACTLY ${contentLines}. ${contentStyle}
${examOrientation}

Return ONLY valid JSON:
{
  "flashcards": [
    { "emoji": "📘", "title": "...", "hook": "...", "content": "..." }
  ]
}
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "Return valid JSON only." },
        { role: "user", content: prompt }
      ],
      temperature: 0.6,
      response_format: { type: "json_object" }
    });

    const parsed = JSON.parse(completion.choices[0].message.content);

    res.json({
      title: topic,
      grade,
      flashcards: parsed.flashcards
    });

  } catch (e) {
    console.error(e);
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
   SOLVE (FINAL, GUARDED)
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

app.listen(port, () => {
  console.log(`✅ Backend running on http://localhost:${port}`);
});
