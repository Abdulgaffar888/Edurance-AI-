console.log("🔥 RUNNING SRC/INDEX.JS");
require("dotenv").config();
const express = require("express");
const cors = require("cors");

const teachRoute = require("./routes/teach");

const app = express();
const PORT = process.env.PORT || 3000;

// CORS
app.use(cors({
  origin: "*",
  methods: ["GET", "POST"],
  allowedHeaders: ["Content-Type"],
}));

// JSON parser
app.use(express.json({
  limit: "1mb",
  strict: true,
}));

// Handle invalid JSON
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    console.error("❌ Invalid JSON received");
    return res.status(400).json({ error: "Invalid JSON format" });
  }
  next();
});

// Teaching route
app.use("/api/teach", teachRoute);

// Health check
app.get("/", (req, res) => {
  res.send("Edurance Backend Running");
});

// 🔥 CRITICAL FIX: bind to all interfaces
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Backend running on http://0.0.0.0:${PORT}`);
});

setInterval(() => {
  // keep process alive for debugging
}, 10000);
