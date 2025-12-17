const OpenAI = require('openai');
const fs = require('fs');
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const learnPrompt = require('../prompts/learnPrompt');
const solvePrompt = require('../prompts/solvePrompt');


module.exports = {
async generateSlides(topic, grade, style) {
const prompt = learnPrompt(topic, grade, style);
// TODO: pick model & manage tokens
const resp = await client.chat.completions.create({ model: 'gpt-4o-mini', messages: [{ role: 'user', content: prompt }], max_tokens: 1200 });
// Expect JSON from LLM — parse carefully
try {
const text = resp.choices[0].message.content;
const json = JSON.parse(text);
return json;
} catch (err) {
console.error('LLM parse error', err);
throw err;
}
},


async generateHint(ocrText, grade) {
const prompt = solvePrompt(ocrText, grade, { hintOnly: true });
const resp = await client.chat.completions.create({ model: 'gpt-4o-mini', messages: [{ role: 'user', content: prompt }], max_tokens: 400 });
return resp.choices[0].message.content;
}
};