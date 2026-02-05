// ============================================================================
// Edurance Backend - Teach Route Handler (FIXED)
// File: src/routes/teach.js
// ============================================================================

import express from 'express';
import { OpenAI } from 'openai';

const router = express.Router();

// ============================================================================
// POST /api/teach
// ============================================================================
// Matches Flutter's request format exactly
// ============================================================================

router.post('/', async (req, res) => {
  try {
    console.log('📥 Received teach request:', JSON.stringify(req.body, null, 2));

    // Initialize OpenAI client
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });

    // Extract data from Flutter's request format
    const { subject, topic, message } = req.body;

    // Validate input
    if (!subject || !topic) {
      return res.status(400).json({ 
        success: false,
        error: 'Missing required fields: subject and topic',
        reply: 'Error: Subject and topic are required.'
      });
    }

    console.log(`🎓 Subject: ${subject}, Topic: ${topic}`);
    console.log(`💬 Student message: ${message || '(starting conversation)'}`);

    // Build the teaching prompt
    const systemPrompt = `You are an expert ${subject} teacher specializing in ${topic}. 
Your teaching style:
- Explain concepts step-by-step like a patient human teacher
- Use simple, relatable examples
- Ask questions to check understanding
- Adapt explanations based on student responses
- Be encouraging and supportive
- Never overwhelm with too much information at once

Topic focus: ${topic}`;

    const userMessage = message || `I want to learn about ${topic}. Please start teaching me from the basics.`;

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: userMessage
        }
      ],
      temperature: 0.7,
      max_tokens: 500,
      top_p: 1,
      frequency_penalty: 0.3,
      presence_penalty: 0.3
    });

    // Extract the AI response
    const teacherReply = completion.choices[0].message.content;

    console.log('✅ Generated reply:', teacherReply.substring(0, 100) + '...');

    // Return in Flutter's expected format
    res.json({
      success: true,
      reply: teacherReply,  // ⭐ This is what Flutter expects
      subject: subject,
      topic: topic,
      timestamp: new Date().toISOString(),
      model: 'gpt-3.5-turbo'
    });

  } catch (error) {
    console.error('❌ Error in /api/teach:', error);

    // Handle OpenAI errors
    if (error.status === 401) {
      return res.status(500).json({ 
        success: false,
        error: 'OpenAI API authentication failed',
        reply: 'Sorry, there is a server configuration issue. Please contact support.'
      });
    }

    if (error.status === 429) {
      return res.status(429).json({ 
        success: false,
        error: 'Rate limit exceeded',
        reply: 'Too many requests. Please wait a moment and try again.'
      });
    }

    // Generic error - still return valid JSON with "reply" field
    res.status(500).json({ 
      success: false,
      error: error.message,
      reply: 'Sorry, I encountered an error. Please try again.'
    });
  }
});

// ============================================================================
// Export router
// ============================================================================

export default router;