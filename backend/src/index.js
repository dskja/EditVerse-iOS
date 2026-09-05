require("dotenv").config();

const path = require("path");
const express = require("express");
const cors = require("cors");
const { uploadsDir } = require("./db/connection");
const { migrate } = require("./db/migrate");
const authRoutes = require("./routes/auth");
const feedRoutes = require("./routes/feed");
const editsRoutes = require("./routes/edits");
const usersRoutes = require("./routes/users");

migrate();

const app = express();
const PORT = Number(process.env.PORT) || 8787;
const HOST = process.env.HOST || "0.0.0.0";

app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: "2mb" }));
app.use("/uploads", express.static(uploadsDir));

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "editverse-api", version: "1.0.0" });
});

app.use("/api/auth", authRoutes);
app.use("/api/feed", feedRoutes);
app.use("/api/edits", editsRoutes);
app.use("/api/users", usersRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "internal_error", message: err.message });
});

app.use((_req, res) => {
  res.status(404).json({ error: "not_found" });
});

app.listen(PORT, HOST, () => {
  console.log(`EditVerse API on http://${HOST}:${PORT}`);
  console.log(`Uploads dir: ${path.resolve(uploadsDir)}`);
});
