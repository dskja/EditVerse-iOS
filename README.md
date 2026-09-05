# EditVerse iOS

Cinematic vertical feed for **video edits only**. Native SwiftUI client + Node/Express backend. No demo posts — the reel stays empty until someone uploads.

## Architecture

- `EditVerse/` — iOS app (SwiftUI, iOS 17+)
- `backend/` — REST API (Express, better-sqlite3, JWT, multipart uploads)

## Backend

```bash
cd backend
cp .env.example .env
npm install
npm start
```

API: `http://127.0.0.1:8787`

### Core endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register` | Create account |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/me` | Current user |
| GET | `/api/feed` | Vertical feed (`category`, `q`, `cursor`) |
| GET | `/api/feed/categories` | Categories |
| POST/DELETE | `/api/feed/:id/like` | Like |
| POST/DELETE | `/api/feed/:id/save` | Save |
| POST | `/api/edits` | Upload edit (multipart `video`) |
| GET | `/api/users/:username` | Profile |
| POST/DELETE | `/api/users/:username/follow` | Follow |

## iOS

1. Start the backend
2. Open `EditVerse.xcodeproj` on a Mac
3. Simulator uses `API_BASE_URL` = `http://127.0.0.1:8787` (Info.plist)
4. For a physical device, set `API_BASE_URL` to your machine LAN IP

Feed scrolls **vertically** (paging). Horizontal swiping is not used for the reel.

## Unsigned IPA

GitHub Actions builds an unsigned `EditVerse.ipa` artifact on push to `main` (Actions tab). No GitHub Releases.

## Bundle ID

`com.editverse.app`
