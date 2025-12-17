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

Return your response in EXACTLY this format (use these exact headings):

Explanation
[Your explanation here]

Real Life Example
[Your real-life example here]

Quick Summary
[Your quick summary here]
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.4,
    });

    // Log raw OpenAI response
    console.log("Raw OpenAI response:", JSON.stringify(completion, null, 2));

    // Safely access response content
    if (!completion || !completion.choices || !completion.choices[0] || !completion.choices[0].message) {
      console.error("Invalid OpenAI response structure:", completion);
      return res.status(500).json({ error: "Invalid response from AI service" });
    }

    const text = completion.choices[0].message.content;

    if (!text || typeof text !== 'string' || text.trim().length === 0) {
      console.error("Empty or invalid text from OpenAI:", text);
      return res.status(500).json({ error: "AI returned empty content" });
    }

    console.log("Parsing text content (length:", text.length, ")");
    
    // Parse the response into sections
    const sections = [];
    const lines = text.split('\n');
    let currentHeading = null;
    let currentContent = [];
    
    for (const line of lines) {
      const trimmed = line.trim();
      if (trimmed === 'Explanation' || trimmed === 'Real Life Example' || trimmed === 'Quick Summary') {
        if (currentHeading && currentContent.length > 0) {
          sections.push({
            heading: currentHeading,
            content: currentContent.join('\n').trim()
          });
        }
        currentHeading = trimmed;
        currentContent = [];
      } else if (currentHeading && trimmed.length > 0) {
        currentContent.push(trimmed);
      }
    }
    
    // Add the last section
    if (currentHeading && currentContent.length > 0) {
      sections.push({
        heading: currentHeading,
        content: currentContent.join('\n').trim()
      });
    }
    
    // Fallback if parsing failed - return full text as Explanation
    if (sections.length === 0) {
      console.log("Parsing failed, using fallback - returning full text as Explanation");
      sections.push({
        heading: "Explanation",
        content: text.trim()
      });
    }

    // Ensure we have at least one section with content
    if (sections.length === 0 || sections.every(s => !s.content || s.content.trim().length === 0)) {
      console.error("All sections are empty, using full text fallback");
      return res.status(500).json({ error: "Failed to parse AI response into sections" });
    }

    console.log("Successfully parsed", sections.length, "sections");

    res.json({
      title: topic,
      grade: grade,
      sections: sections
    });

  } catch (e) {
    console.error("Error in /api/learn:", e);
    res.status(500).json({ error: `AI request failed: ${e.message || 'Unknown error'}` });
  }
});

// ✅ DOUBT
app.post("/api/doubt", async (req, res) => {
  const { doubt, topic, grade } = req.body;

  if (!doubt) return res.status(400).json({ error: "Doubt required" });

  try {
    const contextPrompt = topic && grade 
      ? `The student is learning about "${topic}" in Grade ${grade}. `
      : '';
    
    const prompt = `${contextPrompt}The student asks: "${doubt}". 
    
Provide a clear, helpful answer appropriate for Grade ${grade || 8}. 
Keep it concise and easy to understand.`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a helpful teacher who explains concepts clearly and simply." },
        { role: "user", content: prompt }
      ],
      temperature: 0.5,
    });

    res.json({
      answer: completion.choices[0].message.content
    });

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "Doubt failed" });
  }
});

app.listen(port, () => {
  console.log(`✅ Backend running on http://localhost:${port}`);
});
