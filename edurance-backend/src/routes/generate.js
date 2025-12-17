const express = require('express');
const router = express.Router();
const llm = require('../services/llmService');
const render = require('../services/renderService');
const path = require('path');
const fs = require('fs');

router.post('/', async (req, res) => {
  try {
    const { topic, grade = 8, style = 'academic' } = req.body;
    if (!topic) return res.status(400).json({ error: 'topic required' });

    const slideJson = await llm.generateSlides(topic, grade, style);
    const pdfPath = await render.renderMarpDeck(slideJson, { topic, grade, style });

    const pdfUrl = `/generated/${path.basename(pdfPath)}`;
    const publicDir = './public/generated';
    if (!fs.existsSync(publicDir)) fs.mkdirSync(publicDir, { recursive: true });
    const publicPath = path.join(publicDir, path.basename(pdfPath));
    fs.copyFileSync(pdfPath, publicPath);

    res.json({ 
      id: Date.now().toString(), 
      download_url: pdfUrl
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'internal' });
  }
});

module.exports = router;
