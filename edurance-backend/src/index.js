require("dotenv").config();
const express = require("express");
const cors = require("cors");

const teachRoute = require("./routes/teach");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use("/api/teach", teachRoute);

app.get("/", (req, res) => {
  res.send("Edurance Backend Running");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Backend running on http://0.0.0.0:${PORT}`);
});
