// ============================================================================
// Edurance Backend - Server Entry Point
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

// Enable CORS for all origins (adjust for production security if needed)
app.use(cors());

// Parse JSON request bodies
app.use(express.json());

// Request logging middleware (helpful for debugging)
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
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
    timestamp: new Date().toISOString()
  });
});

// Mount the teach router at /api/teach
app.use('/api/teach', teachRouter);

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler - must come AFTER all routes
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    path: req.path,
    message: `Route ${req.method} ${req.path} does not exist`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({ 
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, () => {
  console.log('='.repeat(60));
  console.log('✓ Edurance AI Backend Server Started');
  console.log('='.repeat(60));
  console.log(`✓ Port: ${PORT}`);
  console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`✓ Health check: http://localhost:${PORT}/`);
  console.log(`✓ Teach endpoint: http://localhost:${PORT}/api/teach`);
  console.log('='.repeat(60));
});