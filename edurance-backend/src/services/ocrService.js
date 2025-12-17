const axios = require('axios');
module.exports = {
async extractFromImage(filePath) {
// Mathpix expects base64 image + keys
const base64 = require('fs').readFileSync(filePath, { encoding: 'base64' });
const resp = await axios.post('https://api.mathpix.com/v3/latex', { src: `data:image/png;base64,${base64}` }, { headers: { 'app_id': 'edurance', 'app_key': process.env.MATHPIX_API_KEY } });
// This is a simplified example — adapt to Mathpix v3 response
return { text: resp.data.text || '', latex: resp.data.latex || '', confidence: resp.data.confidence || 'unknown' };
}
};