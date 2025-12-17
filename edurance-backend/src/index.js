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

// ✅ LEARN
app.post("/api/learn", async (req, res) => {
  const { topic, grade } = req.body;

  if (!topic || !grade) {
    return res.status(400).json({ error: "Topic and grade required" });
  }

  try {
    const prompt = `
You are a teacher.

Explain ONLY "${topic}" for Grade ${grade}.

Rules:
- Grade 4–6: very simple, short sentences, daily examples
- Grade 7–9: clear explanation, light formulas
- Grade 10–12: deep explanation, formulas, reasoning

Return plain text for each section.

Sections:
Explanation
Real Life Example
Quick Summary
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.4,
    });

    const text = completion.choices[0].message.content;

    res.json({
      title: topic,
      sections: [
        { heading: "Explanation", content: text },
      ]
    });

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "AI failed" });
  }
});

// ✅ DOUBT (TEXT for now)
app.post("/api/doubt", async (req, res) => {
  const { doubt } = req.body;

  if (!doubt) return res.status(400).json({ error: "Doubt required" });

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a helpful teacher." },
        { role: "user", content: doubt }
      ],
      temperature: 0.5,
    });

    res.json({
      answer: completion.choices[0].message.content
    });

  } catch (e) {
    res.status(500).json({ error: "Doubt failed" });
  }
});

app.listen(port, () => {
  console.log(`✅ Backend running on http://localhost:${port}`);
});
