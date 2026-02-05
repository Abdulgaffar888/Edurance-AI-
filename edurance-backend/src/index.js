// ============================================================================
// Edurance Backend - Server Entry Point (ENHANCED)
// File: src/index.js
// ============================================================================

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import teachRouter from './routes/teach.js';

// Load environment variables from .env file
dotenv.config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================================
// MIDDLEWARE
// ============================================================================

// Enhanced CORS configuration - CRITICAL FOR BROWSER REQUESTS
const corsOptions = {
  origin: '*', // Allow all origins (tighten in production)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: false,
  optionsSuccessStatus: 200,
  preflightContinue: false
};

// Apply CORS middleware
app.use(cors(corsOptions));

// Explicitly handle preflight OPTIONS requests
app.options('*', cors(corsOptions));

// Parse JSON request bodies (MUST come after CORS)
app.use(express.json());

// Detailed request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log('━'.repeat(70));
  console.log(`📥 ${timestamp} - ${req.method} ${req.path}`);
  console.log(`   Origin: ${req.get('origin') || 'none'}`);
  console.log(`   Content-Type: ${req.get('content-type') || 'none'}`);
  console.log(`   User-Agent: ${req.get('user-agent')?.substring(0, 50) || 'none'}`);
  
  if (req.method === 'POST' && req.body && Object.keys(req.body).length > 0) {
    console.log(`   Body:`, JSON.stringify(req.body, null, 2));
  }
  
  console.log('━'.repeat(70));
  next();
});

// ============================================================================
// ROUTES
// ============================================================================

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Edurance AI Backend is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    endpoints: {
      health: '/',
      teach: '/api/teach (POST)'
    }
  });
});

// Mount the teach router at /api/teach
app.use('/api/teach', teachRouter);

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler - must come AFTER all routes
app.use((req, res) => {
  console.log(`❌ 404 - Route not found: ${req.method} ${req.path}`);
  res.status(404).json({ 
    success: false,
    error: 'Not Found',
    path: req.path,
    message: `Route ${req.method} ${req.path} does not exist`,
    availableRoutes: ['GET /', 'POST /api/teach']
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Unhandled Error:', err);
  console.error('Stack:', err.stack);
  
  res.status(err.status || 500).json({ 
    success: false,
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { 
      stack: err.stack,
      details: err
    })
  });
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, '0.0.0.0', () => {
  console.log('='.repeat(70));
  console.log('✅ Edurance AI Backend Server Started Successfully');
  console.log('='.repeat(70));
  console.log(`🚀 Port: ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔑 OpenAI API Key: ${process.env.OPENAI_API_KEY ? '✓ Configured' : '✗ MISSING'}`);
  console.log(`📍 Health check: http://localhost:${PORT}/`);
  console.log(`🎓 Teach endpoint: http://localhost:${PORT}/api/teach (POST)`);
  console.log(`🌐 Public URL: https://edurance-ai-v2.onrender.com`);
  console.log('='.repeat(70));
  console.log('📝 Waiting for requests...');
  console.log('='.repeat(70));
});