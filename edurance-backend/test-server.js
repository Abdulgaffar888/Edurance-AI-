const http = require("http");

const server = http.createServer((req, res) => {
  res.end("OK");
});

server.listen(3000, "0.0.0.0", () => {
  console.log("🔥 RAW SERVER LISTENING ON 3000");
});
