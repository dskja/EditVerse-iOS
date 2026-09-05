const express = require("express");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");
const multer = require("multer");
const { db, uploadsDir } = require("../db/connection");
const { requireAuth, optionalAuth } = require("../middleware/auth");
const { CATEGORIES, mapEdit, mapComment } = require("../utils/mappers");

const router = express.Router();

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || "").toLowerCase() || ".mp4";
    cb(null, `${crypto.randomUUID()}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: (Number(process.env.UPLOAD_MAX_MB) || 200) * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith("video/")) return cb(new Error("video_required"));
    cb(null, true);
  }
});

router.post("/", requireAuth, (req, res) => {
  upload.single("video")(req, res, (err) => {
    if (err) return res.status(400).json({ error: err.message || "upload_failed" });
    if (!req.file) return res.status(400).json({ error: "video_required" });

    const title = String(req.body.title || "").trim();
    const caption = String(req.body.caption || "").trim();
    const category = String(req.body.category || "").trim();
    const songTitle = String(req.body.songTitle || "").trim();
    const durationMs = Math.max(0, Number(req.body.durationMs) || 0);
    const thumbnailUrl = String(req.body.thumbnailUrl || "").trim();

    if (!title) {
      fs.unlink(req.file.path, () => {});
      return res.status(400).json({ error: "title_required" });
    }
    if (!CATEGORIES.includes(category)) {
      fs.unlink(req.file.path, () => {});
      return res.status(400).json({ error: "invalid_category", categories: CATEGORIES });
    }

    const id = crypto.randomUUID();
    const videoPath = `/uploads/${req.file.filename}`;

    db.prepare(
      `INSERT INTO edits (
        id, author_id, title, caption, category, video_path, thumbnail_url, duration_ms, song_title
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    ).run(id, req.user.id, title, caption, category, videoPath, thumbnailUrl, durationMs, songTitle);

    const row = db
      .prepare(
        `SELECT e.*, u.username, u.display_name, u.avatar_url,
                0 AS is_liked, 0 AS is_saved, 0 AS is_following_author
         FROM edits e JOIN users u ON u.id = e.author_id WHERE e.id = ?`
      )
      .get(id);

    return res.status(201).json({ item: mapEdit(row, req) });
  });
});

router.delete("/:id", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT * FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  if (edit.author_id !== req.user.id) return res.status(403).json({ error: "forbidden" });

  const filePath = path.join(uploadsDir, path.basename(edit.video_path));
  db.prepare("DELETE FROM edits WHERE id = ?").run(edit.id);
  fs.unlink(filePath, () => {});
  res.json({ ok: true });
});

router.get("/:id/comments", optionalAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  const rows = db
    .prepare(
      `SELECT c.*, u.username, u.display_name, u.avatar_url
       FROM comments c JOIN users u ON u.id = c.author_id
       WHERE c.edit_id = ? ORDER BY c.created_at ASC`
    )
    .all(edit.id);
  res.json({ items: rows.map((row) => mapComment(row, req)) });
});

router.post("/:id/comments", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  const body = String(req.body.body || "").trim();
  if (!body) return res.status(400).json({ error: "body_required" });
  if (body.length > 500) return res.status(400).json({ error: "body_too_long" });

  const id = crypto.randomUUID();
  db.transaction(() => {
    db.prepare("INSERT INTO comments (id, edit_id, author_id, body) VALUES (?, ?, ?, ?)").run(
      id,
      edit.id,
      req.user.id,
      body
    );
    db.prepare("UPDATE edits SET comments_count = comments_count + 1 WHERE id = ?").run(edit.id);
  })();

  const row = db
    .prepare(
      `SELECT c.*, u.username, u.display_name, u.avatar_url
       FROM comments c JOIN users u ON u.id = c.author_id WHERE c.id = ?`
    )
    .get(id);
  res.status(201).json({ item: mapComment(row, req) });
});

module.exports = router;
