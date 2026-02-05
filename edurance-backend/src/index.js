import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import teachRouter from "./routes/teach.js";

const app = express();

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Content-Type"],
}));

app.options("*", cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Backend running");
});

app.use("/api/teach", teachRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("🚀 Server on port", PORT);
});
