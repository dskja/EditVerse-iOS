const CATEGORIES = ["Gaming", "Anime", "Sports", "Cinema", "Music", "Cars"];

function publicBaseUrl(req) {
  const env = (process.env.PUBLIC_BASE_URL || "").replace(/\/$/, "");
  if (env) return env;
  const proto = req.headers["x-forwarded-proto"] || req.protocol;
  const host = req.headers["x-forwarded-host"] || req.get("host");
  return `${proto}://${host}`;
}

function absoluteUrl(req, relativePath) {
  if (!relativePath) return "";
  if (/^https?:\/\//i.test(relativePath)) return relativePath;
  const part = relativePath.startsWith("/") ? relativePath : `/${relativePath}`;
  return `${publicBaseUrl(req)}${part}`;
}

function formatDuration(ms) {
  const total = Math.max(0, Math.round(Number(ms || 0) / 1000));
  const m = Math.floor(total / 60);
  const s = total % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}

function mapUser(row, req, extras = {}) {
  if (!row) return null;
  return {
    id: row.id,
    email: extras.includeEmail ? row.email : undefined,
    username: row.username,
    displayName: row.display_name,
    bio: row.bio || "",
    avatarUrl: absoluteUrl(req, row.avatar_url),
    createdAt: row.created_at,
    followersCount: extras.followersCount ?? 0,
    followingCount: extras.followingCount ?? 0,
    editsCount: extras.editsCount ?? 0,
    isFollowing: Boolean(extras.isFollowing),
    isSelf: Boolean(extras.isSelf)
  };
}

function mapEdit(row, req) {
  return {
    id: row.id,
    title: row.title,
    caption: row.caption || "",
    category: row.category,
    videoUrl: absoluteUrl(req, row.video_path),
    thumbnailUrl: absoluteUrl(req, row.thumbnail_url),
    durationMs: row.duration_ms || 0,
    durationLabel: formatDuration(row.duration_ms || 0),
    songTitle: row.song_title || "",
    likes: row.likes_count || 0,
    comments: row.comments_count || 0,
    shares: row.shares_count || 0,
    saves: row.saves_count || 0,
    views: row.views_count || 0,
    isLiked: Boolean(row.is_liked),
    isSaved: Boolean(row.is_saved),
    isFollowingAuthor: Boolean(row.is_following_author),
    createdAt: row.created_at,
    author: {
      id: row.author_id,
      username: row.username,
      displayName: row.display_name,
      avatarUrl: absoluteUrl(req, row.avatar_url)
    }
  };
}

function mapComment(row, req) {
  return {
    id: row.id,
    body: row.body,
    createdAt: row.created_at,
    author: {
      id: row.author_id,
      username: row.username,
      displayName: row.display_name,
      avatarUrl: absoluteUrl(req, row.avatar_url)
    }
  };
}

module.exports = {
  CATEGORIES,
  mapUser,
  mapEdit,
  mapComment,
  absoluteUrl,
  publicBaseUrl
};
