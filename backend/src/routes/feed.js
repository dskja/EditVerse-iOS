const express = require("express");
const { db } = require("../db/connection");
const { optionalAuth, requireAuth } = require("../middleware/auth");
const { CATEGORIES, mapEdit } = require("../utils/mappers");

const router = express.Router();

const SELECT = `
  SELECT
    e.*,
    u.username,
    u.display_name,
    u.avatar_url,
    CASE WHEN l.user_id IS NULL THEN 0 ELSE 1 END AS is_liked,
    CASE WHEN s.user_id IS NULL THEN 0 ELSE 1 END AS is_saved,
    CASE WHEN f.follower_id IS NULL THEN 0 ELSE 1 END AS is_following_author
  FROM edits e
  JOIN users u ON u.id = e.author_id
  LEFT JOIN likes l ON l.edit_id = e.id AND l.user_id = ?
  LEFT JOIN saves s ON s.edit_id = e.id AND s.user_id = ?
  LEFT JOIN follows f ON f.following_id = e.author_id AND f.follower_id = ?
`;

router.get("/categories", (_req, res) => {
  res.json({ categories: CATEGORIES });
});

router.get("/", optionalAuth, (req, res) => {
  const viewerId = req.user?.id || "";
  const limit = Math.min(Math.max(Number(req.query.limit) || 20, 1), 50);
  const cursor = req.query.cursor ? String(req.query.cursor) : null;
  const category = req.query.category ? String(req.query.category) : null;
  const q = req.query.q ? String(req.query.q).trim() : "";

  const params = [viewerId, viewerId, viewerId];
  let where = "WHERE 1=1";

  if (category && CATEGORIES.includes(category)) {
    where += " AND e.category = ?";
    params.push(category);
  }
  if (q) {
    where +=
      " AND (e.title LIKE ? OR e.caption LIKE ? OR u.username LIKE ? OR u.display_name LIKE ?)";
    const like = `%${q}%`;
    params.push(like, like, like, like);
  }
  if (cursor) {
    where += " AND e.created_at < ?";
    params.push(cursor);
  }

  params.push(limit);
  const rows = db
    .prepare(`${SELECT} ${where} ORDER BY e.created_at DESC LIMIT ?`)
    .all(...params);

  res.json({
    items: rows.map((row) => mapEdit(row, req)),
    nextCursor: rows.length === limit ? rows[rows.length - 1].created_at : null
  });
});

router.get("/:id", optionalAuth, (req, res) => {
  const viewerId = req.user?.id || "";
  const row = db
    .prepare(`${SELECT} WHERE e.id = ?`)
    .get(viewerId, viewerId, viewerId, req.params.id);
  if (!row) return res.status(404).json({ error: "edit_not_found" });
  db.prepare("UPDATE edits SET views_count = views_count + 1 WHERE id = ?").run(row.id);
  row.views_count += 1;
  res.json({ item: mapEdit(row, req) });
});

router.post("/:id/like", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });

  const liked = db
    .prepare("SELECT 1 FROM likes WHERE user_id = ? AND edit_id = ?")
    .get(req.user.id, edit.id);
  if (!liked) {
    db.transaction(() => {
      db.prepare("INSERT INTO likes (user_id, edit_id) VALUES (?, ?)").run(req.user.id, edit.id);
      db.prepare("UPDATE edits SET likes_count = likes_count + 1 WHERE id = ?").run(edit.id);
    })();
  }
  const likes = db.prepare("SELECT likes_count FROM edits WHERE id = ?").get(edit.id).likes_count;
  res.json({ liked: true, likes });
});

router.delete("/:id/like", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  const liked = db
    .prepare("SELECT 1 FROM likes WHERE user_id = ? AND edit_id = ?")
    .get(req.user.id, edit.id);
  if (liked) {
    db.transaction(() => {
      db.prepare("DELETE FROM likes WHERE user_id = ? AND edit_id = ?").run(req.user.id, edit.id);
      db.prepare("UPDATE edits SET likes_count = MAX(likes_count - 1, 0) WHERE id = ?").run(edit.id);
    })();
  }
  const likes = db.prepare("SELECT likes_count FROM edits WHERE id = ?").get(edit.id).likes_count;
  res.json({ liked: false, likes });
});

router.post("/:id/save", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  const saved = db
    .prepare("SELECT 1 FROM saves WHERE user_id = ? AND edit_id = ?")
    .get(req.user.id, edit.id);
  if (!saved) {
    db.transaction(() => {
      db.prepare("INSERT INTO saves (user_id, edit_id) VALUES (?, ?)").run(req.user.id, edit.id);
      db.prepare("UPDATE edits SET saves_count = saves_count + 1 WHERE id = ?").run(edit.id);
    })();
  }
  res.json({ saved: true });
});

router.delete("/:id/save", requireAuth, (req, res) => {
  const edit = db.prepare("SELECT id FROM edits WHERE id = ?").get(req.params.id);
  if (!edit) return res.status(404).json({ error: "edit_not_found" });
  const saved = db
    .prepare("SELECT 1 FROM saves WHERE user_id = ? AND edit_id = ?")
    .get(req.user.id, edit.id);
  if (saved) {
    db.transaction(() => {
      db.prepare("DELETE FROM saves WHERE user_id = ? AND edit_id = ?").run(req.user.id, edit.id);
      db.prepare("UPDATE edits SET saves_count = MAX(saves_count - 1, 0) WHERE id = ?").run(edit.id);
    })();
  }
  res.json({ saved: false });
});

router.post("/:id/share", optionalAuth, (req, res) => {
  const info = db
    .prepare("UPDATE edits SET shares_count = shares_count + 1 WHERE id = ?")
    .run(req.params.id);
  if (info.changes === 0) return res.status(404).json({ error: "edit_not_found" });
  const shares = db.prepare("SELECT shares_count FROM edits WHERE id = ?").get(req.params.id)
    .shares_count;
  res.json({ shares });
});

module.exports = router;
