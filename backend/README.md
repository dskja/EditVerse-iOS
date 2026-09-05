# EditVerse API

Real backend for the EditVerse iOS app. No demo/seed posts — the feed is empty until users register and upload edits.

## Run

```bash
cd backend
cp .env.example .env
npm install
npm start
```

API: `http://localhost:8787`

## Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | no | Health check |
| POST | `/api/auth/register` | no | Create account |
| POST | `/api/auth/login` | no | Login |
| GET | `/api/auth/me` | yes | Current user |
| PATCH | `/api/auth/me` | yes | Update profile |
| GET | `/api/feed` | optional | Vertical feed (`category`, `q`, `cursor`) |
| GET | `/api/feed/categories` | no | Category list |
| GET | `/api/feed/:id` | optional | Single edit |
| POST/DELETE | `/api/feed/:id/like` | yes | Like / unlike |
| POST/DELETE | `/api/feed/:id/save` | yes | Save / unsave |
| POST | `/api/feed/:id/share` | optional | Share count |
| POST | `/api/edits` | yes | Upload edit (`multipart`: video, title, category, …) |
| DELETE | `/api/edits/:id` | yes | Delete own edit |
| GET/POST | `/api/edits/:id/comments` | mix | Comments |
| GET | `/api/users/:username` | optional | Profile |
| GET | `/api/users/:username/edits` | optional | User edits |
| POST/DELETE | `/api/users/:username/follow` | yes | Follow |
| GET | `/api/users/me/saved` | yes | Saved edits |
| GET | `/api/users/me/liked` | yes | Liked edits |

## iOS

Set `API_BASE_URL` in the app Info.plist (default `http://127.0.0.1:8787` for Simulator).
