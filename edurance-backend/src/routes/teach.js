// ============================================================================
// Edurance Backend - Teach Route Handler (ULTRA SAFE VERSION)
// File: src/routes/teach.js
// ============================================================================

import express from 'express';
import OpenAI from 'openai'; // ⭐ Changed from { OpenAI }

const router = express.Router();

// ============================================================================
// POST /api/teach
// ============================================================================

router.post('/', async (req, res) => {
  try {
    console.log('━'.repeat(70));
    console.log('🎓 TEACH ENDPOINT CALLED');
    console.log('━'.repeat(70));
    console.log('📥 Request Body:', JSON.stringify(req.body, null, 2));

    // Check if OpenAI API key exists
    if (!process.env.OPENAI_API_KEY) {
      console.error('❌ OPENAI_API_KEY is not set in environment variables!');
      return res.status(500).json({ 
        success: false,
        error: 'Server configuration error',
        reply: 'Sorry, the AI service is not properly configured. Please contact support.',
        details: 'OPENAI_API_KEY missing'
      });
    }

    console.log('✓ OpenAI API Key found:', process.env.OPENAI_API_KEY.substring(0, 10) + '...');

    // Initialize OpenAI client
    let openai;
    try {
      openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY
      });
      console.log('✓ OpenAI client initialized');
    } catch (initError) {
      console.error('❌ Failed to initialize OpenAI client:', initError);
      return res.status(500).json({
        success: false,
        error: 'Failed to initialize AI service',
        reply: 'Sorry, I cannot connect to the AI service right now.',
        details: initError.message
      });
    }

    // Extract data from request
    const { subject, topic, message } = req.body;

    // Validate input
    if (!subject || !topic) {
      console.log('⚠️ Missing subject or topic');
      return res.status(400).json({ 
        success: false,
        error: 'Missing required fields: subject and topic',
        reply: 'Please provide both subject and topic to start learning.'
      });
    }

    console.log(`📚 Subject: ${subject}`);
    console.log(`📖 Topic: ${topic}`);
    console.log(`💬 Message: ${message || '(starting conversation)'}`);

    // Build the teaching prompt
    const systemPrompt = `You are an expert ${subject} teacher specializing in ${topic}. 

Your teaching style:
- Explain concepts step-by-step like a patient human teacher
- Use simple, relatable examples from everyday life
- Ask ONE question at the end to check understanding
- Adapt explanations based on student responses
- Be encouraging and supportive
- Keep responses concise (2-3 short paragraphs max)
- Never overwhelm with too much information at once

Topic focus: ${topic}

Remember: You're teaching a student who wants to learn. Be conversational and friendly.`;

    const userMessage = message || `I want to learn about ${topic}. Please start teaching me from the basics.`;

    console.log('🤖 Calling OpenAI API...');

    // Call OpenAI API with error handling
    let completion;
    try {
      completion = await openai.chat.completions.create({
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
      
      console.log('✓ OpenAI API call successful');
      
    } catch (apiError) {
      console.error('❌ OpenAI API Error:', apiError);
      console.error('Error details:', {
        status: apiError.status,
        message: apiError.message,
        type: apiError.type
      });

      // Handle specific OpenAI errors
      if (apiError.status === 401) {
        return res.status(500).json({ 
          success: false,
          error: 'OpenAI authentication failed',
          reply: 'Sorry, there is an authentication issue with the AI service. Please contact support.',
          details: 'Invalid API key'
        });
      }

      if (apiError.status === 429) {
        return res.status(429).json({ 
          success: false,
          error: 'Rate limit exceeded',
          reply: 'Too many requests right now. Please wait a moment and try again.'
        });
      }

      if (apiError.status === 400) {
        return res.status(500).json({
          success: false,
          error: 'Invalid request to OpenAI',
          reply: 'Sorry, something went wrong with the request. Please try again.',
          details: apiError.message
        });
      }

      // Generic OpenAI error
      return res.status(500).json({
        success: false,
        error: 'AI service error',
        reply: 'Sorry, I encountered an error. Please try again in a moment.',
        details: apiError.message
      });
    }

    // Extract the AI response
    const teacherReply = completion.choices[0].message.content;

    console.log('✓ Generated reply:', teacherReply.substring(0, 100) + '...');
    console.log('━'.repeat(70));

    // Return in Flutter's expected format
    res.json({
      success: true,
      reply: teacherReply,
      subject: subject,
      topic: topic,
      timestamp: new Date().toISOString(),
      model: 'gpt-3.5-turbo'
    });

  } catch (error) {
    // Catch-all error handler
    console.error('❌ UNEXPECTED ERROR in /api/teach:', error);
    console.error('Stack:', error.stack);

    res.status(500).json({ 
      success: false,
      error: 'Unexpected server error',
      reply: 'Sorry, something went wrong. Please try again.',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ============================================================================
// Export router
// ============================================================================

export default router;