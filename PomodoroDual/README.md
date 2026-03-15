# Pomodoro Dual

[![Node](https://img.shields.io/badge/node-%3E%3D20-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=YOUR_PUBLIC_GITHUB_REPO_URL)

A collaborative Pomodoro web app where a host creates a unique session code and participants join from their own browser.

## Features

- Unique session code for each host session
- Shareable invite link for each session
- Optional host-managed join passcode for private sessions
- Real-time synchronized timer, task, and pomodoro stats
- Live session activity timeline (join/leave, roles, timer and settings actions)
- Classic Pomodoro cycle support: Focus, Short Break, Long Break
- Editable cycle settings: focus, short break, long break, and long break interval
- Multiple collaborative tasks with active-task selection and per-task pomodoro count
- Host ownership transfer to another participant
- Signed host reclaim link/token for recovering host access from another device/browser
- Host can assign each participant role
- Viewer: can only watch
- Editor: can start/stop/reset and update settings
- Host always has full control
- Host reconnect grace period (20s) before session ends
- URL join prefill via query parameter (for example: /?code=ABC123)
- Session persistence to disk (survives server restarts)
- Automatic cleanup for inactive sessions older than 48 hours
- Keyboard shortcuts for faster control (Space, R, 1, 2, 3)

## Run locally

```bash
npm install
npm start
```

Then open:

- `http://localhost:3000`

## Free publish (Render)

### 1) Push to GitHub

```bash
git init
git add .
git commit -m "Prepare Pomodoro Dual for deployment"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

### 2) Deploy on Render

1. Open Render and choose **New +** -> **Blueprint**.
2. Select this repository.
3. Render auto-detects `render.yaml` and provisions the web service.
4. Wait for deploy to finish, then open your app URL.

Tip: replace `YOUR_PUBLIC_GITHUB_REPO_URL` in the badge link above with your repo URL for a one-click deploy button.

### 3) Validate deployment

1. Open `/healthz` on your deployed URL and confirm JSON response.
2. Open app in two browsers/devices.
3. Create and join a session by code.
4. Verify live sync (timer, tasks, roles).

## Pre-publish checklist

- `HOST_TOKEN_SECRET` is set in production (Render handles this via `render.yaml`).
- `node_modules/` and `data/` are ignored in Git (`.gitignore`).
- Health endpoint is available at `/healthz`.
- App starts with `npm start`.

## Durable free persistence (Supabase)

Render free instances can restart and wipe local disk state, so enable Supabase persistence for reliable sessions.

### 1) Create Supabase project

1. Create a free project at Supabase.
2. Open SQL editor and run [supabase/schema.sql](supabase/schema.sql).

### 2) Add environment variables in Render

Set these in your Render web service:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_TABLE` (optional, default `pomodoro_dual_state`)

Keep `HOST_TOKEN_SECRET` enabled too.

### 3) Redeploy and verify

1. Trigger redeploy.
2. Open `/healthz` and confirm `"storage":"supabase"`.
3. Create a session, restart service, and verify session restores.

## Persistence details

- Sessions are stored in `data/sessions.json`.
- On restart, sessions are restored and participants can rejoin with their existing browser identity.
- Running timers are paused after restart for safety and resume when an editor or host starts them again.
- Activity timeline is also persisted and restored with each session.
- Host reclaim token hash is persisted; plaintext token is only shown to active host client.

## How to use

1. Host enters name and clicks **Create Session**.
2. Share the generated code with your friend.
3. Optionally copy and share the invite link shown in the session header.
4. Host can optionally set a join passcode to lock the session.
5. Friend enters name, code, and passcode (only if lock is enabled), then clicks Join By Code.
6. Use task panel to add multiple tasks, choose active task, rename tasks, and mark tasks done.
7. Configure Pomodoro settings (focus/short break/long break durations, long-break interval, target, completed count).
8. Host can change participant roles and transfer host ownership in the participants panel.
9. Editors and host can control timer/settings; viewers can only observe.
10. Host can copy a host reclaim link and use it on another device to reclaim host role when needed.

## Keyboard shortcuts

- `Space`: start/stop timer
- `R`: reset timer
- `1`: switch to focus mode
- `2`: switch to short break mode
- `3`: switch to long break mode
