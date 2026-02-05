import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import teachRouter from "./routes/teach.js";

const app = express();

/**
 * ✅ CORS – allow everything for now (MVP)
 */
app.use(cors());
app.use(express.json());

// Health check
app.get("/", (req, res) => {
  res.send("Edurance backend running");
});

// 🔑 THIS IS THE MOST IMPORTANT LINE
app.use("/api/teach", teachRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 Server running on port", PORT);
});
