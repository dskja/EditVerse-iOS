const express = require("express");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const { db } = require("../db/connection");
const { signToken, requireAuth } = require("../middleware/auth");
const { mapUser } = require("../utils/mappers");

const router = express.Router();

function countsFor(userId) {
  return {
    followersCount: db.prepare("SELECT COUNT(*) AS c FROM follows WHERE following_id = ?").get(userId).c,
    followingCount: db.prepare("SELECT COUNT(*) AS c FROM follows WHERE follower_id = ?").get(userId).c,
    editsCount: db.prepare("SELECT COUNT(*) AS c FROM edits WHERE author_id = ?").get(userId).c
  };
}

function getUser(id) {
  return db.prepare("SELECT * FROM users WHERE id = ?").get(id);
}

router.post("/register", (req, res) => {
  const email = String(req.body.email || "").trim().toLowerCase();
  const username = String(req.body.username || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._]/g, "");
  const displayName = String(req.body.displayName || username).trim().slice(0, 48);
  const password = String(req.body.password || "");

  if (!email.includes("@")) return res.status(400).json({ error: "invalid_email" });
  if (username.length < 3 || username.length > 24) {
    return res.status(400).json({ error: "invalid_username" });
  }
  if (password.length < 8) return res.status(400).json({ error: "password_too_short" });

  const exists = db.prepare("SELECT id FROM users WHERE email = ? OR username = ?").get(email, username);
  if (exists) return res.status(409).json({ error: "user_exists" });

  const id = crypto.randomUUID();
  const passwordHash = bcrypt.hashSync(password, 10);
  db.prepare(
    `INSERT INTO users (id, email, username, display_name, password_hash)
     VALUES (?, ?, ?, ?, ?)`
  ).run(id, email, username, displayName || username, passwordHash);

  const user = getUser(id);
  return res.status(201).json({
    token: signToken(user),
    user: mapUser(user, req, { ...countsFor(id), isSelf: true, includeEmail: true })
  });
});

router.post("/login", (req, res) => {
  const login = String(req.body.login || req.body.email || req.body.username || "")
    .trim()
    .toLowerCase();
  const password = String(req.body.password || "");
  if (!login || !password) return res.status(400).json({ error: "missing_credentials" });

  const user = db.prepare("SELECT * FROM users WHERE email = ? OR username = ?").get(login, login);
  if (!user || !bcrypt.compareSync(password, user.password_hash)) {
    return res.status(401).json({ error: "invalid_credentials" });
  }

  return res.json({
    token: signToken(user),
    user: mapUser(user, req, { ...countsFor(user.id), isSelf: true, includeEmail: true })
  });
});

router.get("/me", requireAuth, (req, res) => {
  const user = getUser(req.user.id);
  if (!user) return res.status(401).json({ error: "user_missing" });
  return res.json({
    user: mapUser(user, req, { ...countsFor(user.id), isSelf: true, includeEmail: true })
  });
});

router.patch("/me", requireAuth, (req, res) => {
  const user = getUser(req.user.id);
  if (!user) return res.status(401).json({ error: "user_missing" });

  const displayName =
    req.body.displayName != null ? String(req.body.displayName).trim().slice(0, 48) : user.display_name;
  const bio = req.body.bio != null ? String(req.body.bio).trim().slice(0, 280) : user.bio;
  const avatarUrl = req.body.avatarUrl != null ? String(req.body.avatarUrl).trim() : user.avatar_url;

  db.prepare("UPDATE users SET display_name = ?, bio = ?, avatar_url = ? WHERE id = ?").run(
    displayName,
    bio,
    avatarUrl,
    user.id
  );

  const updated = getUser(user.id);
  return res.json({
    user: mapUser(updated, req, { ...countsFor(user.id), isSelf: true, includeEmail: true })
  });
});

module.exports = router;
