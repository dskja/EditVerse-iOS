const express = require("express");
const { db } = require("../db/connection");
const { optionalAuth, requireAuth } = require("../middleware/auth");
const { mapUser, mapEdit } = require("../utils/mappers");

const router = express.Router();

function countsFor(userId) {
  return {
    followersCount: db.prepare("SELECT COUNT(*) AS c FROM follows WHERE following_id = ?").get(userId).c,
    followingCount: db.prepare("SELECT COUNT(*) AS c FROM follows WHERE follower_id = ?").get(userId).c,
    editsCount: db.prepare("SELECT COUNT(*) AS c FROM edits WHERE author_id = ?").get(userId).c
  };
}

const EDIT_SELECT = `
  SELECT e.*, u.username, u.display_name, u.avatar_url,
         CASE WHEN l.user_id IS NULL THEN 0 ELSE 1 END AS is_liked,
         CASE WHEN s.user_id IS NULL THEN 0 ELSE 1 END AS is_saved,
         CASE WHEN f.follower_id IS NULL THEN 0 ELSE 1 END AS is_following_author
  FROM edits e
  JOIN users u ON u.id = e.author_id
  LEFT JOIN likes l ON l.edit_id = e.id AND l.user_id = ?
  LEFT JOIN saves s ON s.edit_id = e.id AND s.user_id = ?
  LEFT JOIN follows f ON f.following_id = e.author_id AND f.follower_id = ?
`;

router.get("/me/saved", requireAuth, (req, res) => {
  const rows = db
    .prepare(
      `SELECT e.*, u.username, u.display_name, u.avatar_url,
              CASE WHEN l.user_id IS NULL THEN 0 ELSE 1 END AS is_liked,
              1 AS is_saved,
              CASE WHEN f.follower_id IS NULL THEN 0 ELSE 1 END AS is_following_author
       FROM saves sv
       JOIN edits e ON e.id = sv.edit_id
       JOIN users u ON u.id = e.author_id
       LEFT JOIN likes l ON l.edit_id = e.id AND l.user_id = ?
       LEFT JOIN follows f ON f.following_id = e.author_id AND f.follower_id = ?
       WHERE sv.user_id = ?
       ORDER BY sv.created_at DESC`
    )
    .all(req.user.id, req.user.id, req.user.id);
  res.json({ items: rows.map((row) => mapEdit(row, req)) });
});

router.get("/me/liked", requireAuth, (req, res) => {
  const rows = db
    .prepare(
      `SELECT e.*, u.username, u.display_name, u.avatar_url,
              1 AS is_liked,
              CASE WHEN s.user_id IS NULL THEN 0 ELSE 1 END AS is_saved,
              CASE WHEN f.follower_id IS NULL THEN 0 ELSE 1 END AS is_following_author
       FROM likes lk
       JOIN edits e ON e.id = lk.edit_id
       JOIN users u ON u.id = e.author_id
       LEFT JOIN saves s ON s.edit_id = e.id AND s.user_id = ?
       LEFT JOIN follows f ON f.following_id = e.author_id AND f.follower_id = ?
       WHERE lk.user_id = ?
       ORDER BY lk.created_at DESC`
    )
    .all(req.user.id, req.user.id, req.user.id);
  res.json({ items: rows.map((row) => mapEdit(row, req)) });
});

router.get("/:username", optionalAuth, (req, res) => {
  const user = db
    .prepare("SELECT * FROM users WHERE username = ? COLLATE NOCASE")
    .get(String(req.params.username));
  if (!user) return res.status(404).json({ error: "user_not_found" });

  const isFollowing = req.user
    ? Boolean(
        db
          .prepare("SELECT 1 FROM follows WHERE follower_id = ? AND following_id = ?")
          .get(req.user.id, user.id)
      )
    : false;

  res.json({
    user: mapUser(user, req, {
      ...countsFor(user.id),
      isFollowing,
      isSelf: req.user?.id === user.id,
      includeEmail: req.user?.id === user.id
    })
  });
});

router.get("/:username/edits", optionalAuth, (req, res) => {
  const user = db
    .prepare("SELECT * FROM users WHERE username = ? COLLATE NOCASE")
    .get(String(req.params.username));
  if (!user) return res.status(404).json({ error: "user_not_found" });

  const viewerId = req.user?.id || "";
  const rows = db
    .prepare(`${EDIT_SELECT} WHERE e.author_id = ? ORDER BY e.created_at DESC`)
    .all(viewerId, viewerId, viewerId, user.id);
  res.json({ items: rows.map((row) => mapEdit(row, req)) });
});

router.post("/:username/follow", requireAuth, (req, res) => {
  const user = db
    .prepare("SELECT * FROM users WHERE username = ? COLLATE NOCASE")
    .get(String(req.params.username));
  if (!user) return res.status(404).json({ error: "user_not_found" });
  if (user.id === req.user.id) return res.status(400).json({ error: "cannot_follow_self" });

  const existing = db
    .prepare("SELECT 1 FROM follows WHERE follower_id = ? AND following_id = ?")
    .get(req.user.id, user.id);
  if (!existing) {
    db.prepare("INSERT INTO follows (follower_id, following_id) VALUES (?, ?)").run(
      req.user.id,
      user.id
    );
  }
  res.json({ following: true, ...countsFor(user.id) });
});

router.delete("/:username/follow", requireAuth, (req, res) => {
  const user = db
    .prepare("SELECT * FROM users WHERE username = ? COLLATE NOCASE")
    .get(String(req.params.username));
  if (!user) return res.status(404).json({ error: "user_not_found" });
  db.prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?").run(
    req.user.id,
    user.id
  );
  res.json({ following: false, ...countsFor(user.id) });
});

module.exports = router;
