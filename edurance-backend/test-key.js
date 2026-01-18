// test-key.js
require("dotenv").config();
const OpenAI = require("openai");

async function test() {
  const apiKey = process.env.OPENAI_API_KEY;
  console.log("🔑 Key present:", !!apiKey);
  console.log("Key starts with:", apiKey ? apiKey.substring(0, 10) + "..." : "None");

  if (!apiKey) {
    console.log("❌ No API key found in .env");
    return;
  }

  const openai = new OpenAI({ apiKey });

  try {
    console.log("\n📋 Testing API connection...");
    const models = await openai.models.list();
    const gptModels = models.data.filter(m => m.id.includes("gpt"));
    
    console.log("✅ API key works!");
    console.log(`Available GPT models: ${gptModels.slice(0, 5).map(m => m.id).join(", ")}`);
    
    // Test a cheap completion
    console.log("\n💬 Testing completion...");
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: "Say hello" }],
      max_tokens: 5
    });
    
    console.log("✅ Completion works:", completion.choices[0].message.content);
    console.log("Tokens used:", completion.usage?.total_tokens);
    
  } catch (error) {
    console.log("\n❌ API Error:", error.message);
    console.log("Error code:", error.code);
    console.log("Error type:", error.type);
    
    if (error.message.includes("insufficient_quota")) {
      console.log("\n💡 SOLUTION: Your new key also has no credits.");
      console.log("1. Go to https://platform.openai.com/account/billing");
      console.log("2. Add payment method");
      console.log("3. Or use a different email for new account");
    }
  }
}

test();