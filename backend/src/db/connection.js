const fs = require("fs");
const path = require("path");
const Database = require("better-sqlite3");

const root = path.join(__dirname, "..", "..");
const dataDir = path.join(root, "data");
const uploadsDir = path.join(root, "uploads");

fs.mkdirSync(dataDir, { recursive: true });
fs.mkdirSync(uploadsDir, { recursive: true });

const db = new Database(path.join(dataDir, "editverse.sqlite"));
db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

module.exports = { db, uploadsDir, dataDir };
