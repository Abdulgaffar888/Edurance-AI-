import dotenv from "dotenv";
dotenv.config(); // 👈 MUST BE FIRST

import express from "express";
import teachRouter from "./routes/teach.js";

console.log("OPENAI KEY PRESENT:", !!process.env.OPENAI_API_KEY);

const app = express();
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Edurance backend is running");
});

app.use("/api/teach", teachRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
