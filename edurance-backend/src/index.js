import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import teachRouter from "./routes/teach.js"; // ✅ FIXED PATH

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Edurance backend running");
});

app.use("/api/teach", teachRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 Backend running on port", PORT);
});
