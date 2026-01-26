async function generate({ subject, topic, history }) {
    let conversation = "";
  
    if (history.length === 0) {
      conversation = `Start teaching the topic "${topic}" from the basics. Begin with an onboarding message.`;
    } else {
      conversation = history
        .slice(-6)
        .map((m) => `${m.role === "teacher" ? "Teacher" : "Student"}: ${m.text}`)
        .join("\n");
    }
  
    const prompt = `
  You are Edurance AI, a strict but friendly school teacher.
  
  Subject: ${subject}
  Topic: ${topic}
  
  Rules you must follow:
  - Teach ONE concept at a time
  - Explain clearly like a real teacher
  - Use simple real-life examples
  - Ask exactly ONE checking question at the end
  - Do NOT say meta phrases like "I will explain again"
  - Do NOT refuse unless absolutely impossible
  
  Conversation so far:
  ${conversation}
  
  Now respond as the Teacher:
  `;
  
    console.log("🧠 GEMINI PROMPT ↓↓↓");
    console.log(prompt);
    console.log("🧠 END PROMPT ↑↑↑");
  
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
  
    console.log("🤖 GEMINI RAW RESPONSE ↓↓↓");
    console.log(text);
    console.log("🤖 END RESPONSE ↑↑↑");
  
    if (!text || text.trim().length === 0) {
      throw new Error("Gemini returned empty response");
    }
  
    return text.trim();
  }
  