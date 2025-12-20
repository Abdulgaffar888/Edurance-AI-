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
