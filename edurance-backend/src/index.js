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

// ✅ LEARN - Flashcard Format
app.post("/api/learn", async (req, res) => {
  const { topic, grade } = req.body;

  if (!topic || !grade) {
    return res.status(400).json({ error: "Topic and grade required" });
  }

  try {
    // Define explicit content depth requirements by grade
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
      contentStyle = "comprehensive how/why explanations, cause-effect, detailed examples";
    } else if (grade === 10) {
      contentLines = "12-14 lines";
      contentStyle = "mechanisms, processes, keywords, step-by-step explanations, exam-relevant details";
      examOrientation = "Focus on exam-relevant mechanisms, precise terminology, and comprehensive understanding.";
    } else {
      contentLines = "14-16 lines";
      contentStyle = "exam-oriented, precise terminology, comprehensive explanations, formulas, reasoning, detailed analysis";
      examOrientation = "Focus on exam-relevant details, precise definitions, comprehensive understanding, academic terminology, and exam-ready depth.";
    }

    const prompt = `
You are a teacher creating a flashcard-style lesson about "${topic}" for Grade ${grade}.

Create 5-7 flashcards (exactly 5-7, no more, no less). Each flashcard must have:
- emoji: A symbolic emoji representing the concept (one emoji only). Use conceptual emojis:
  * History: ⏰ (time), 🏛️ (empire/civilization), ⚔️ (war/conflict), 📜 (document/event), 🌍 (geography)
  * Science: 🔬 (experiment), ⚛️ (atoms/chemistry), 🌊 (nature/process), 🔋 (energy), 🧬 (biology)
  * Math: ➕ (operations), 📐 (geometry), 📊 (data), ∞ (concepts)
  * General: 💡 (idea), 🔑 (key concept), 📖 (learning), 🎯 (focus)
- title: A short, catchy title (3-6 words)
- hook: An engaging opening sentence that grabs attention (one sentence)
- content: The main explanation - MUST be exactly ${contentLines} of content. ${contentStyle}
${examOrientation ? `\n${examOrientation}` : ''}

CRITICAL CONTENT REQUIREMENTS:
- Grade 4: EXACTLY 6-7 lines per flashcard (short sentences, daily examples)
- Grade 5: EXACTLY 7-8 lines per flashcard (clear explanations, daily examples)
- Grade 6: EXACTLY 8-9 lines per flashcard (clear definitions, structured explanations)
- Grade 7: EXACTLY 9-10 lines per flashcard (how/why explanations, cause-effect)
- Grade 8-9: EXACTLY 10-12 lines per flashcard (comprehensive how/why, detailed examples)
- Grade 10: EXACTLY 12-14 lines per flashcard (mechanisms, processes, keywords, exam-relevant)
- Grade 11-12: EXACTLY 14-16 lines per flashcard (exam-oriented, precise terminology, comprehensive depth)

IMPORTANT:
- Flashcards are NOT summaries - each flashcard represents ONE exam-relevant concept
- Each flashcard must be comprehensive and detailed enough to stand alone
- Content must be substantial and educational, not brief overviews
- Higher grades require exam-oriented precision and depth

Language rules:
- Grade 4: very simple language, short sentences, daily examples
- Grade 5: simple language, clear explanations, daily examples
- Grade 6: clear definitions, structured explanations, key terms
- Grade 7: how/why explanations, cause-effect relationships, examples
- Grade 8-9: comprehensive how/why explanations, cause-effect, detailed examples
- Grade 10: exam-oriented, mechanisms, processes, precise terminology, formulas
- Grade 11-12: exam-ready, precise terminology, comprehensive reasoning, formulas, detailed analysis

Return ONLY valid JSON in this exact format (no markdown, no extra text):
{
  "flashcards": [
    {
      "emoji": "🌱",
      "title": "What is Photosynthesis?",
      "hook": "Plants are like nature's solar panels!",
      "content": "Photosynthesis is how plants make food using sunlight, water, and carbon dioxide."
    },
    {
      "emoji": "☀️",
      "title": "The Sun's Role",
      "hook": "Without the sun, plants couldn't survive!",
      "content": "Sunlight provides energy that plants need to convert water and CO2 into glucose."
    }
  ]
}
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a teacher. Always return valid JSON only, no markdown formatting." },
        { role: "user", content: prompt }
      ],
      temperature: 0.6,
      response_format: { type: "json_object" }
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

    console.log("Parsing JSON content (length:", text.length, ")");
    
    // Parse JSON response
    let parsed;
    try {
      parsed = JSON.parse(text);
    } catch (parseError) {
      console.error("JSON parse error:", parseError);
      // Fallback: create a single flashcard from the text
      parsed = {
        flashcards: [{
          emoji: "📚",
          title: topic,
          hook: `Let's learn about ${topic}!`,
          content: text.trim()
        }]
      };
    }

    // Validate flashcards structure
    if (!parsed.flashcards || !Array.isArray(parsed.flashcards) || parsed.flashcards.length === 0) {
      console.error("Invalid flashcards structure:", parsed);
      // Fallback: create a single flashcard
      parsed = {
        flashcards: [{
          emoji: "📚",
          title: topic,
          hook: `Let's learn about ${topic}!`,
          content: text.trim()
        }]
      };
    }

    // Ensure 5-7 flashcards (pad or trim if needed)
    const flashcards = parsed.flashcards.slice(0, 7);
    while (flashcards.length < 5 && flashcards.length > 0) {
      // Duplicate last card if we have less than 5
      flashcards.push({ ...flashcards[flashcards.length - 1] });
    }

    // Ensure each flashcard has required fields
    const validFlashcards = flashcards.map((card, index) => ({
      emoji: card.emoji || "📚",
      title: card.title || `${topic} - Part ${index + 1}`,
      hook: card.hook || `Let's explore this concept!`,
      content: card.content || "Content coming soon..."
    })).filter(card => card.content && card.content.trim().length > 0);

    if (validFlashcards.length === 0) {
      console.error("All flashcards are empty, using fallback");
      return res.status(500).json({ error: "Failed to generate valid flashcards" });
    }

    console.log("Successfully generated", validFlashcards.length, "flashcards");

    res.json({
      title: topic,
      grade: grade,
      flashcards: validFlashcards
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
