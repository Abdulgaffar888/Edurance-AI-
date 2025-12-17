module.exports = function learnPrompt(topic, grade, style) {
return `Create a JSON slides payload for Edurance.ai. Topic: ${topic}. Grade: ${grade}. Style: ${style}. Output EXACT JSON with \n{ \n \"slides\": [ {\"title\": \"...\", \"content_markdown\": \"...\", \"image_query\": \"...\" } ] \n}`;
};