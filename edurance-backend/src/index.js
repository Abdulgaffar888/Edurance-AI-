import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import teachRouter from "./routes/teach.js";

const app = express();

/**
 * ✅ SINGLE, CORRECT CORS CONFIG
 * This fixes Flutter Web + Vercel + Render
 */
app.use(
  cors({
    origin: "*", // MVP: allow all (safe for now)
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// ✅ IMPORTANT: handle preflight BEFORE routes
app.options("*", cors());

app.use(express.json());

// Health check
app.get("/", (req, res) => {
  res.send("Edurance backend running");
});

// API routes
app.use("/api/teach", teachRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 Backend running on port", PORT);
});
