const express = require('express');
const router = express.Router();
const formidable = require('formidable');
const ocr = require('../services/ocrService');
const llm = require('../services/llmService');
const render = require('../services/renderService');
const storage = require('../services/storageService');


// POST /api/solve-image
// multipart: image file, grade
router.post('/', (req, res) => {
const form = new formidable.IncomingForm();
form.parse(req, async (err, fields, files) => {
try {
if (err) return res.status(400).json({ error: 'invalid upload' });
const grade = parseInt(fields.grade || '8', 10);
const image = files.image;
if (!image) return res.status(400).json({ error: 'image required' });


// 1) call Mathpix or OCR
const ocrResult = await ocr.extractFromImage(image.path);


// 2) respond with OCR result and a hint (LLM)
const hint = await llm.generateHint(ocrResult.text, grade);


// we return OCR + hint; client will request full solution explicitly
res.json({ ocr_text: ocrResult.text, ocr_latex: ocrResult.latex, ocr_confidence: ocrResult.confidence, hint });
} catch (e) {
console.error(e);
res.status(500).json({ error: 'internal' });
}
});
});


module.exports = router;