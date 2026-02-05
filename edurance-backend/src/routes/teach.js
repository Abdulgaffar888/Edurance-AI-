// ============================================================================
// Edurance Backend - Teach Route Handler
// File: src/routes/teach.js
// ============================================================================

import express from 'express';
import { OpenAI } from 'openai';

const router = express.Router();

// ============================================================================
// POST /api/teach
// ============================================================================
// This route receives a user's learning query and returns AI-generated
// educational content using OpenAI's GPT model.
// ============================================================================

router.post('/', async (req, res) => {
  try {
    // Initialize OpenAI client inside the handler (after env vars are loaded)
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });

    // Extract user query from request body
    const { userQuery } = req.body;

    // Validate input
    if (!userQuery || typeof userQuery !== 'string') {
      return res.status(400).json({ 
        success: false,
        error: 'Missing or invalid userQuery in request body',
        message: 'Please provide a valid userQuery string'
      });
    }

    if (userQuery.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'userQuery cannot be empty',
        message: 'Please provide a non-empty query'
      });
    }

    console.log('Processing teach request:', userQuery);

    // Call OpenAI API to generate teaching content
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are an expert AI tutor for the Edurance AI learning platform. Explain concepts clearly, provide examples, and adapt your teaching style to help students understand complex topics. Be encouraging and patient.'
        },
        {
          role: 'user',
          content: userQuery
        }
      ],
      temperature: 0.7,
      max_tokens: 800,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0
    });

    // Extract the AI response
    const teachingContent = completion.choices[0].message.content;

    // Log success
    console.log('✓ Successfully generated teaching content');

    // Return successful response
    res.json({
      success: true,
      query: userQuery,
      response: teachingContent,
      timestamp: new Date().toISOString(),
      model: 'gpt-3.5-turbo'
    });

  } catch (error) {
    console.error('Error in /api/teach:', error);

    // Handle specific OpenAI API errors
    if (error.status === 401) {
      return res.status(500).json({ 
        success: false,
        error: 'OpenAI API authentication failed',
        message: 'Invalid API key. Please check server configuration.'
      });
    }

    if (error.status === 429) {
      return res.status(429).json({ 
        success: false,
        error: 'Rate limit exceeded',
        message: 'Too many requests. Please try again in a moment.'
      });
    }

    if (error.status === 400) {
      return res.status(400).json({
        success: false,
        error: 'Invalid request to OpenAI',
        message: error.message
      });
    }

    // Handle missing API key
    if (error.message && error.message.includes('OPENAI_API_KEY')) {
      return res.status(500).json({
        success: false,
        error: 'Server configuration error',
        message: 'OpenAI API key is not configured. Please contact administrator.'
      });
    }

    // Generic error response
    res.status(500).json({ 
      success: false,
      error: 'Failed to process teaching request',
      message: process.env.NODE_ENV === 'development' ? error.message : 'An unexpected error occurred'
    });
  }
});

// ============================================================================
// Export router (ESM syntax)
// ============================================================================

export default router;