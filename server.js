const express = require("express");
const http = require("http");
const { WebSocketServer } = require("ws");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const { createClient } = require("@supabase/supabase-js");

const PORT = process.env.PORT || 3000;
const app = express();
app.use(express.static("public"));

app.get("/healthz", (_req, res) => {
    res.status(200).json({
        ok: true,
        uptimeSec: Math.round(process.uptime()),
        sessions: sessions.size,
        storage: supabase ? "supabase" : "file",
    });
});

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

const sessions = new Map();
const clients = new Map();
const HOST_RECONNECT_GRACE_MS = 20 * 1000;
const SESSION_MAX_AGE_MS = 48 * 60 * 60 * 1000;
const ACTIVITY_MAX_ITEMS = 60;
const HOST_TOKEN_SECRET =
    process.env.HOST_TOKEN_SECRET || crypto.randomBytes(32).toString("hex");
if (process.env.NODE_ENV === "production" && !process.env.HOST_TOKEN_SECRET) {
    console.warn("[warn] HOST_TOKEN_SECRET is not set. Host reclaim tokens will rotate on restart.");
}

const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "";
const SUPABASE_TABLE = process.env.SUPABASE_TABLE || "pomodoro_dual_state";
const SUPABASE_ROW_KEY = "sessions";
const hasSupabaseConfig = Boolean(SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY);
const supabase = hasSupabaseConfig
    ? createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, { auth: { persistSession: false } })
    : null;

const dataDir = path.join(__dirname, "data");
const sessionsFile = path.join(dataDir, "sessions.json");
let saveTimer = null;

function randomCode(length = 6) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    return Array.from({ length }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
}

function makeUniqueSessionCode() {
    let code = randomCode();
    while (sessions.has(code)) {
        code = randomCode();
    }
    return code;
}

function makeDefaultState() {
    const defaultTaskId = crypto.randomUUID();
    return {
        tasks: [
            {
                id: defaultTaskId,
                title: "Deep work",
                done: false,
                pomodorosDone: 0,
            },
        ],
        activeTaskId: defaultTaskId,
        focusDurationSec: 25 * 60,
        shortBreakDurationSec: 5 * 60,
        longBreakDurationSec: 15 * 60,
        longBreakEvery: 4,
        targetPomodoros: 4,
        completedPomodoros: 0,
        mode: "focus",
        remainingSec: 25 * 60,
        isRunning: false,
        lastTickAt: null,
    };
}

function hashPasscode(input) {
    return crypto.createHash("sha256").update(input).digest("hex");
}

function normalizePasscode(input) {
    return (input || "").toString().trim();
}

function toBase64Url(input) {
    return Buffer.from(input)
        .toString("base64")
        .replace(/\+/g, "-")
        .replace(/\//g, "_")
        .replace(/=+$/g, "");
}

function fromBase64Url(input) {
    const padded = input.replace(/-/g, "+").replace(/_/g, "/") + "===".slice((input.length + 3) % 4);
    return Buffer.from(padded, "base64").toString("utf8");
}

function signHostTokenPayload(payload) {
    return crypto.createHmac("sha256", HOST_TOKEN_SECRET).update(payload).digest("base64url");
}

function createSignedHostToken(sessionCode) {
    const payload = JSON.stringify({
        sid: sessionCode,
        nonce: crypto.randomBytes(10).toString("hex"),
        iat: Date.now(),
    });
    const payloadEncoded = toBase64Url(payload);
    const sig = signHostTokenPayload(payloadEncoded);
    return `${payloadEncoded}.${sig}`;
}

function parseAndValidateSignedHostToken(token, expectedSessionCode) {
    if (!token || typeof token !== "string") return false;
    const [payloadEncoded, sig] = token.split(".");
    if (!payloadEncoded || !sig) return false;

    const expectedSig = signHostTokenPayload(payloadEncoded);
    const givenSigBuffer = Buffer.from(sig);
    const expectedSigBuffer = Buffer.from(expectedSig);
    if (givenSigBuffer.length !== expectedSigBuffer.length) {
        return false;
    }
    if (!crypto.timingSafeEqual(givenSigBuffer, expectedSigBuffer)) {
        return false;
    }

    try {
        const payload = JSON.parse(fromBase64Url(payloadEncoded));
        return payload?.sid === expectedSessionCode;
    } catch {
        return false;
    }
}

function sanitizeActivity(items) {
    if (!Array.isArray(items)) return [];
    return items
        .filter((entry) => entry && typeof entry.message === "string")
        .map((entry) => ({
            at: Number(entry.at) || Date.now(),
            type: entry.type === "warning" ? "warning" : "info",
            message: entry.message.slice(0, 220),
        }))
        .slice(0, ACTIVITY_MAX_ITEMS);
}

function getParticipantLabel(session, userKey, fallback = "Someone") {
    const participant = session.participants.get(userKey);
    return participant?.name || fallback;
}

function logSessionActivity(session, message, type = "info") {
    session.activity.unshift({
        at: Date.now(),
        type: type === "warning" ? "warning" : "info",
        message: message.slice(0, 220),
    });
    if (session.activity.length > ACTIVITY_MAX_ITEMS) {
        session.activity = session.activity.slice(0, ACTIVITY_MAX_ITEMS);
    }
}

function ensureDataDir() {
    if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
    }
}

function buildPersistencePayload() {
    return {
        savedAt: Date.now(),
        sessions: Array.from(sessions.values()).map(toPersistableSession),
    };
}

async function readPersistencePayload() {
    if (supabase) {
        const { data, error } = await supabase
            .from(SUPABASE_TABLE)
            .select("data")
            .eq("key", SUPABASE_ROW_KEY)
            .maybeSingle();

        if (error) {
            console.error("[persistence] Supabase read failed:", error.message);
            return null;
        }
        return data?.data || null;
    }

    if (!fs.existsSync(sessionsFile)) return null;
    try {
        return JSON.parse(fs.readFileSync(sessionsFile, "utf8"));
    } catch {
        return null;
    }
}

async function writePersistencePayload(payload) {
    if (supabase) {
        const { error } = await supabase.from(SUPABASE_TABLE).upsert(
            {
                key: SUPABASE_ROW_KEY,
                data: payload,
                updated_at: new Date().toISOString(),
            },
            { onConflict: "key" }
        );

        if (error) {
            console.error("[persistence] Supabase write failed:", error.message);
        }
        return;
    }

    ensureDataDir();
    fs.writeFileSync(sessionsFile, JSON.stringify(payload, null, 2));
}

async function persistSessionsNow() {
    const payload = buildPersistencePayload();
    await writePersistencePayload(payload);
}

function toPersistableSession(session) {
    return {
        code: session.code,
        hostKey: session.hostKey,
        joinPasscodeHash: session.joinPasscodeHash || null,
        hostClaimTokenHash: session.hostClaimTokenHash || null,
        activity: session.activity,
        participants: Array.from(session.participants.entries()).map(([key, participant]) => [
            key,
            {
                name: participant.name,
                role: participant.role,
                connected: false,
            },
        ]),
        state: session.state,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
    };
}

function schedulePersistSessions() {
    if (saveTimer) {
        clearTimeout(saveTimer);
    }

    saveTimer = setTimeout(async () => {
        try {
            await persistSessionsNow();
        } catch (err) {
            console.error("[persistence] Unexpected persist error:", err?.message || err);
        }
        saveTimer = null;
    }, 120);
}

function hydrateSession(raw) {
    const session = {
        code: raw.code,
        hostKey: raw.hostKey,
        joinPasscodeHash: raw.joinPasscodeHash || null,
        hostClaimTokenHash: raw.hostClaimTokenHash || null,
        activity: sanitizeActivity(raw.activity),
        participants: new Map(),
        connections: new Map(),
        state: {
            ...makeDefaultState(),
            ...raw.state,
            isRunning: false,
            lastTickAt: null,
        },
        hostDisconnectedAt: null,
        hostDisconnectTimer: null,
        createdAt: Number(raw.createdAt) || Date.now(),
        updatedAt: Number(raw.updatedAt) || Date.now(),
    };

    normalizeState(session.state);

    if (Array.isArray(raw.participants)) {
        for (const item of raw.participants) {
            if (!Array.isArray(item) || item.length !== 2) continue;
            const [key, p] = item;
            if (!key || !p) continue;
            session.participants.set(key, {
                name: (p.name || "Guest").toString().slice(0, 40),
                role: p.role === "editor" || p.role === "host" ? p.role : "viewer",
                connected: false,
            });
        }
    }

    if (!session.participants.has(session.hostKey)) {
        session.participants.set(session.hostKey, {
            name: "Host",
            role: "host",
            connected: false,
        });
    }

    return session;
}

async function loadPersistedSessions() {
    const raw = await readPersistencePayload();
    const persisted = Array.isArray(raw?.sessions) ? raw.sessions : [];
    const now = Date.now();

    for (const item of persisted) {
        const session = hydrateSession(item);
        if (now - session.updatedAt > SESSION_MAX_AGE_MS) {
            continue;
        }
        sessions.set(session.code, session);
    }
}

function touchSession(session) {
    session.updatedAt = Date.now();
    schedulePersistSessions();
}

function issueHostClaimToken(session) {
    const token = createSignedHostToken(session.code);
    session.hostClaimTokenHash = hashPasscode(token);
    return token;
}

function sendHostClaimToken(session, userKey) {
    const ws = session.connections.get(userKey);
    if (!ws) return;

    const token = issueHostClaimToken(session);
    send(ws, {
        type: "session:host-token-issued",
        code: session.code,
        token,
    });
}

function verifyHostClaimToken(session, token) {
    if (!session.hostClaimTokenHash) return false;
    const isSignedTokenValid = parseAndValidateSignedHostToken(token, session.code);
    if (!isSignedTokenValid) return false;
    return hashPasscode(token) === session.hostClaimTokenHash;
}

function send(ws, payload) {
    if (ws.readyState === ws.OPEN) {
        ws.send(JSON.stringify(payload));
    }
}

function getRoleInSession(session, userKey) {
    if (session.hostKey === userKey) {
        return "host";
    }
    const participant = session.participants.get(userKey);
    return participant ? participant.role : "viewer";
}

function canEditSession(session, userKey) {
    return getRoleInSession(session, userKey) === "host" || getRoleInSession(session, userKey) === "editor";
}

function serializeSessionFor(session, userKey) {
    normalizeState(session.state);
    const role = getRoleInSession(session, userKey);
    const remainingPomodoros = Math.max(session.state.targetPomodoros - session.state.completedPomodoros, 0);
    const activeTask = getActiveTask(session.state);

    return {
        code: session.code,
        hostKey: session.hostKey,
        joinProtected: Boolean(session.joinPasscodeHash),
        activity: session.activity,
        you: {
            id: userKey,
            role,
            canEdit: role === "host" || role === "editor",
            isHost: role === "host",
        },
        participants: Array.from(session.participants.entries()).map(([id, p]) => ({
            id,
            name: p.name,
            role: id === session.hostKey ? "host" : p.role,
            connected: Boolean(p.connected),
        })),
        state: {
            ...session.state,
            activeTaskTitle: activeTask ? activeTask.title : "-",
            remainingPomodoros,
        },
    };
}

function broadcastSession(session) {
    for (const [userKey, ws] of session.connections.entries()) {
        send(ws, { type: "session:update", session: serializeSessionFor(session, userKey) });
    }
}

function removeClientFromSession(userKey, sessionCode) {
    const session = sessions.get(sessionCode);
    if (!session) return;

    session.connections.delete(userKey);
    const participant = session.participants.get(userKey);
    if (participant) {
        participant.connected = false;
    }

    if (userKey === session.hostKey) {
        session.hostDisconnectedAt = Date.now();
        if (session.hostDisconnectTimer) {
            clearTimeout(session.hostDisconnectTimer);
        }

        session.hostDisconnectTimer = setTimeout(() => {
            const live = sessions.get(sessionCode);
            if (!live) return;
            const hostOnline = live.connections.has(live.hostKey);
            if (hostOnline) return;

            for (const [, peerWs] of live.connections.entries()) {
                send(peerWs, {
                    type: "session:ended",
                    reason: "The host left and did not reconnect in time. Session ended.",
                });
            }
            sessions.delete(sessionCode);
            schedulePersistSessions();
        }, HOST_RECONNECT_GRACE_MS);
    }

    if (session.connections.size === 0 && !session.hostDisconnectTimer) {
        sessions.delete(sessionCode);
        schedulePersistSessions();
        return;
    }

    touchSession(session);
    broadcastSession(session);
}

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function normalizeState(state) {
    if (!Array.isArray(state.tasks) || state.tasks.length === 0) {
        const id = crypto.randomUUID();
        state.tasks = [
            {
                id,
                title: (state.task || "Deep work").toString().slice(0, 120),
                done: false,
                pomodorosDone: 0,
            },
        ];
        state.activeTaskId = id;
    }

    state.tasks = state.tasks
        .filter((t) => t && typeof t.id === "string")
        .map((t) => ({
            id: t.id,
            title: (t.title || "Untitled task").toString().slice(0, 120),
            done: Boolean(t.done),
            pomodorosDone: clamp(Number(t.pomodorosDone) || 0, 0, 1000),
        }));

    if (state.tasks.length === 0) {
        const id = crypto.randomUUID();
        state.tasks = [{ id, title: "Deep work", done: false, pomodorosDone: 0 }];
        state.activeTaskId = id;
    }

    if (!state.tasks.some((t) => t.id === state.activeTaskId)) {
        state.activeTaskId = state.tasks[0].id;
    }

    if (!Number.isInteger(state.shortBreakDurationSec) && Number.isInteger(state.breakDurationSec)) {
        state.shortBreakDurationSec = state.breakDurationSec;
    }

    state.shortBreakDurationSec = clamp(Number(state.shortBreakDurationSec) || 5 * 60, 60, 60 * 60);
    state.longBreakDurationSec = clamp(Number(state.longBreakDurationSec) || 15 * 60, 60, 90 * 60);
    state.longBreakEvery = clamp(Number(state.longBreakEvery) || 4, 2, 12);

    if (!["focus", "shortBreak", "longBreak"].includes(state.mode)) {
        state.mode = "focus";
    }

    state.targetPomodoros = clamp(Number(state.targetPomodoros) || 4, 1, 24);
    state.completedPomodoros = clamp(Number(state.completedPomodoros) || 0, 0, 1000);
}

function getDurationForMode(state, mode) {
    if (mode === "shortBreak") return state.shortBreakDurationSec;
    if (mode === "longBreak") return state.longBreakDurationSec;
    return state.focusDurationSec;
}

function getActiveTask(state) {
    return state.tasks.find((t) => t.id === state.activeTaskId) || null;
}

function applyStatePatch(session, patch) {
    const s = session.state;
    normalizeState(s);

    if (typeof patch.task === "string") {
        const active = getActiveTask(s);
        if (active) {
            active.title = patch.task.slice(0, 120);
        }
    }

    if (Number.isInteger(patch.focusDurationSec)) {
        s.focusDurationSec = clamp(patch.focusDurationSec, 60, 120 * 60);
        if (!s.isRunning && s.mode === "focus") {
            s.remainingSec = s.focusDurationSec;
        }
    }

    if (Number.isInteger(patch.shortBreakDurationSec) || Number.isInteger(patch.breakDurationSec)) {
        const value = Number.isInteger(patch.shortBreakDurationSec) ? patch.shortBreakDurationSec : patch.breakDurationSec;
        s.shortBreakDurationSec = clamp(value, 60, 60 * 60);
        if (!s.isRunning && s.mode === "shortBreak") {
            s.remainingSec = s.shortBreakDurationSec;
        }
    }

    if (Number.isInteger(patch.longBreakDurationSec)) {
        s.longBreakDurationSec = clamp(patch.longBreakDurationSec, 60, 90 * 60);
        if (!s.isRunning && s.mode === "longBreak") {
            s.remainingSec = s.longBreakDurationSec;
        }
    }

    if (Number.isInteger(patch.longBreakEvery)) {
        s.longBreakEvery = clamp(patch.longBreakEvery, 2, 12);
    }

    if (Number.isInteger(patch.targetPomodoros)) {
        s.targetPomodoros = clamp(patch.targetPomodoros, 1, 24);
    }

    if (Number.isInteger(patch.completedPomodoros)) {
        s.completedPomodoros = clamp(patch.completedPomodoros, 0, 1000);
    }

    if (patch.mode === "focus" || patch.mode === "shortBreak" || patch.mode === "longBreak") {
        s.mode = patch.mode;
        if (!s.isRunning) {
            s.remainingSec = getDurationForMode(s, s.mode);
        }
    }

    if (typeof patch.activeTaskId === "string" && s.tasks.some((t) => t.id === patch.activeTaskId)) {
        s.activeTaskId = patch.activeTaskId;
    }
}

setInterval(() => {
    const now = Date.now();

    for (const session of sessions.values()) {
        const state = session.state;
        if (!state.isRunning || !state.lastTickAt) continue;

        const elapsedSec = Math.floor((now - state.lastTickAt) / 1000);
        if (elapsedSec <= 0) continue;

        state.lastTickAt += elapsedSec * 1000;
        state.remainingSec -= elapsedSec;

        if (state.remainingSec <= 0) {
            if (state.mode === "focus") {
                state.completedPomodoros += 1;
                const activeTask = getActiveTask(state);
                if (activeTask) {
                    activeTask.pomodorosDone += 1;
                }
                const shouldLongBreak = state.completedPomodoros % state.longBreakEvery === 0;
                state.mode = shouldLongBreak ? "longBreak" : "shortBreak";
                state.remainingSec = getDurationForMode(state, state.mode);
                logSessionActivity(session, `Focus complete. ${shouldLongBreak ? "Long" : "Short"} break started.`);
            } else {
                state.mode = "focus";
                state.remainingSec = state.focusDurationSec;
                logSessionActivity(session, "Break complete. Focus started.");
            }
        }

        touchSession(session);
        broadcastSession(session);
    }
}, 250);

setInterval(() => {
    const now = Date.now();
    let removed = false;

    for (const [code, session] of sessions.entries()) {
        const hasConnections = session.connections.size > 0;
        const tooOld = now - session.updatedAt > SESSION_MAX_AGE_MS;
        if (!hasConnections && tooOld) {
            sessions.delete(code);
            removed = true;
        }
    }

    if (removed) {
        schedulePersistSessions();
    }
}, 5 * 60 * 1000);

wss.on("connection", (ws) => {
    const clientId = crypto.randomUUID();
    clients.set(clientId, { ws, sessionCode: null, name: "Guest", userKey: null });

    send(ws, { type: "connected", clientId });

    ws.on("message", (raw) => {
        let msg;
        try {
            msg = JSON.parse(raw.toString());
        } catch {
            send(ws, { type: "error", message: "Invalid JSON payload." });
            return;
        }

        const client = clients.get(clientId);
        if (!client) return;

        if (msg.type === "host:create") {
            const name = (msg.name || "Host").toString().slice(0, 40);
            const userKey = (msg.userKey || "").toString().trim();
            if (!userKey) {
                send(ws, { type: "error", message: "Missing user identity." });
                return;
            }

            const code = makeUniqueSessionCode();
            const session = {
                code,
                hostKey: userKey,
                joinPasscodeHash: null,
                hostClaimTokenHash: null,
                activity: [],
                participants: new Map(),
                connections: new Map(),
                state: makeDefaultState(),
                hostDisconnectedAt: null,
                hostDisconnectTimer: null,
                createdAt: Date.now(),
                updatedAt: Date.now(),
            };

            session.participants.set(userKey, { name, role: "host", connected: true });
            session.connections.set(userKey, ws);
            sessions.set(code, session);

            client.name = name;
            client.sessionCode = code;
            client.userKey = userKey;
            logSessionActivity(session, `${name} created the session.`);
            sendHostClaimToken(session, userKey);
            schedulePersistSessions();
            broadcastSession(session);
            return;
        }

        if (msg.type === "session:join") {
            const code = (msg.code || "").toString().trim().toUpperCase();
            const name = (msg.name || "Guest").toString().slice(0, 40);
            const userKey = (msg.userKey || "").toString().trim();
            const passcode = normalizePasscode(msg.passcode);
            const hostClaimToken = normalizePasscode(msg.hostClaimToken);
            if (!userKey) {
                send(ws, { type: "error", message: "Missing user identity." });
                return;
            }

            const session = sessions.get(code);

            if (!session) {
                send(ws, { type: "error", message: "Session code not found." });
                return;
            }

            const isHostRejoin = userKey === session.hostKey;
            const hasClaimToken = hostClaimToken.length > 0;
            const existing = session.participants.get(userKey);

            if (hasClaimToken && !verifyHostClaimToken(session, hostClaimToken)) {
                send(ws, { type: "error", message: "Invalid host reclaim token." });
                return;
            }

            if (hasClaimToken && !isHostRejoin) {
                const previousHostKey = session.hostKey;
                const previousHost = session.participants.get(previousHostKey);
                if (previousHost) {
                    previousHost.role = "editor";
                }
                session.hostKey = userKey;
                logSessionActivity(
                    session,
                    `${name} reclaimed host ownership with a secure token.`
                );
            }

            if (session.joinPasscodeHash && !isHostRejoin && !hasClaimToken) {
                const passcodeIsValid = hashPasscode(passcode) === session.joinPasscodeHash;
                if (!passcodeIsValid) {
                    send(ws, { type: "error", message: "Incorrect session passcode." });
                    return;
                }
            }

            if (existing) {
                existing.name = name;
                if (session.hostKey === userKey) {
                    existing.role = "host";
                }
                existing.connected = true;
                logSessionActivity(session, `${name} reconnected.`);
            } else {
                session.participants.set(userKey, {
                    name,
                    role: session.hostKey === userKey ? "host" : "viewer",
                    connected: true,
                });
                logSessionActivity(
                    session,
                    `${name} joined as ${session.hostKey === userKey ? "host" : "viewer"}.`
                );
            }

            session.connections.set(userKey, ws);
            if (session.hostKey === userKey) {
                session.hostDisconnectedAt = null;
                if (session.hostDisconnectTimer) {
                    clearTimeout(session.hostDisconnectTimer);
                    session.hostDisconnectTimer = null;
                }
            }

            client.name = name;
            client.sessionCode = code;
            client.userKey = userKey;
            if (session.hostKey === userKey) {
                sendHostClaimToken(session, userKey);
            }
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (!client.sessionCode) {
            send(ws, { type: "error", message: "Join or create a session first." });
            return;
        }

        const session = sessions.get(client.sessionCode);
        if (!session) {
            send(ws, { type: "error", message: "Session no longer exists." });
            return;
        }

        if (msg.type === "session:set-role") {
            if (session.hostKey !== client.userKey) {
                send(ws, { type: "error", message: "Only host can change roles." });
                return;
            }

            const targetId = msg.targetClientId;
            const newRole = msg.role;

            if (targetId === session.hostKey) {
                send(ws, { type: "error", message: "Host role cannot be changed." });
                return;
            }

            if (newRole !== "viewer" && newRole !== "editor") {
                send(ws, { type: "error", message: "Role must be viewer or editor." });
                return;
            }

            const target = session.participants.get(targetId);
            if (!target) {
                send(ws, { type: "error", message: "Participant not found." });
                return;
            }

            target.role = newRole;
            logSessionActivity(
                session,
                `${getParticipantLabel(session, client.userKey, "Host")} changed ${target.name} to ${newRole}.`
            );
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "session:transfer-host") {
            if (session.hostKey !== client.userKey) {
                send(ws, { type: "error", message: "Only host can transfer ownership." });
                return;
            }

            const targetId = (msg.targetClientId || "").toString().trim();
            if (!targetId) {
                send(ws, { type: "error", message: "Missing transfer target." });
                return;
            }

            if (targetId === session.hostKey) {
                send(ws, { type: "error", message: "Target is already host." });
                return;
            }

            const target = session.participants.get(targetId);
            if (!target) {
                send(ws, { type: "error", message: "Participant not found." });
                return;
            }

            const oldHostKey = session.hostKey;
            const oldHost = session.participants.get(oldHostKey);
            if (oldHost) {
                oldHost.role = "editor";
            }

            target.role = "host";
            session.hostKey = targetId;
            logSessionActivity(
                session,
                `${getParticipantLabel(session, oldHostKey, "Host")} transferred host ownership to ${target.name}.`
            );
            sendHostClaimToken(session, targetId);

            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "session:set-passcode") {
            if (session.hostKey !== client.userKey) {
                send(ws, { type: "error", message: "Only host can manage passcode." });
                return;
            }

            const passcode = normalizePasscode(msg.passcode);
            if (passcode.length === 0) {
                session.joinPasscodeHash = null;
                logSessionActivity(session, `${getParticipantLabel(session, client.userKey, "Host")} cleared join passcode.`);
                touchSession(session);
                broadcastSession(session);
                return;
            }

            if (passcode.length < 4 || passcode.length > 32) {
                send(ws, { type: "error", message: "Passcode must be 4 to 32 characters." });
                return;
            }

            session.joinPasscodeHash = hashPasscode(passcode);
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey, "Host")} updated join passcode.`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "task:add") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }

            normalizeState(session.state);
            const title = (msg.title || "New task").toString().trim().slice(0, 120);
            const task = {
                id: crypto.randomUUID(),
                title: title || "New task",
                done: false,
                pomodorosDone: 0,
            };
            session.state.tasks.push(task);
            session.state.activeTaskId = task.id;
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} added task "${task.title}".`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "task:select") {
            normalizeState(session.state);
            const taskId = (msg.taskId || "").toString();
            const exists = session.state.tasks.some((t) => t.id === taskId);
            if (!exists) {
                send(ws, { type: "error", message: "Task not found." });
                return;
            }
            session.state.activeTaskId = taskId;
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "task:update") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }
            normalizeState(session.state);
            const taskId = (msg.taskId || "").toString();
            const task = session.state.tasks.find((t) => t.id === taskId);
            if (!task) {
                send(ws, { type: "error", message: "Task not found." });
                return;
            }
            if (typeof msg.title === "string") {
                task.title = msg.title.trim().slice(0, 120) || "Untitled task";
            }
            if (typeof msg.done === "boolean") {
                task.done = msg.done;
            }
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} updated task "${task.title}".`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "task:remove") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }
            normalizeState(session.state);
            if (session.state.tasks.length === 1) {
                send(ws, { type: "error", message: "At least one task must remain." });
                return;
            }
            const taskId = (msg.taskId || "").toString();
            const index = session.state.tasks.findIndex((t) => t.id === taskId);
            if (index === -1) {
                send(ws, { type: "error", message: "Task not found." });
                return;
            }
            const [removed] = session.state.tasks.splice(index, 1);
            if (session.state.activeTaskId === taskId) {
                session.state.activeTaskId = session.state.tasks[0].id;
            }
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} removed task "${removed.title}".`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "state:update") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }

            applyStatePatch(session, msg.patch || {});
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} updated session settings.`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "timer:start") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }

            if (!session.state.isRunning) {
                session.state.isRunning = true;
                session.state.lastTickAt = Date.now();
                logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} started the timer.`);
            }
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "timer:stop") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }

            session.state.isRunning = false;
            session.state.lastTickAt = null;
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} stopped the timer.`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        if (msg.type === "timer:reset") {
            if (!canEditSession(session, client.userKey)) {
                send(ws, { type: "error", message: "You have viewer access only." });
                return;
            }

            session.state.isRunning = false;
            session.state.lastTickAt = null;
            normalizeState(session.state);
            session.state.remainingSec = getDurationForMode(session.state, session.state.mode);
            logSessionActivity(session, `${getParticipantLabel(session, client.userKey)} reset the timer.`);
            touchSession(session);
            broadcastSession(session);
            return;
        }

        send(ws, { type: "error", message: "Unknown action type." });
    });

    ws.on("close", () => {
        const client = clients.get(clientId);
        if (client && client.sessionCode && client.userKey) {
            const session = sessions.get(client.sessionCode);
            if (session) {
                const leftName = getParticipantLabel(session, client.userKey, client.name || "Someone");
                logSessionActivity(session, `${leftName} disconnected.`, "warning");
            }
            removeClientFromSession(client.userKey, client.sessionCode);
        }
        clients.delete(clientId);
    });
});

loadPersistedSessions()
    .then(() => {
        console.log(`[persistence] backend: ${supabase ? "supabase" : "file"}`);
        server.listen(PORT, () => {
            console.log(`PomodoroDual server running at http://localhost:${PORT}`);
        });
    })
    .catch((err) => {
        console.error("[startup] Failed to load persisted sessions:", err?.message || err);
        server.listen(PORT, () => {
            console.log(`PomodoroDual server running at http://localhost:${PORT}`);
        });
    });
