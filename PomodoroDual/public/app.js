const $ = (id) => document.getElementById(id);

const dom = {
    lobby: $("lobby"),
    sessionPanel: $("sessionPanel"),
    statusLine: $("statusLine"),
    hostForm: $("hostForm"),
    joinForm: $("joinForm"),
    hostName: $("hostName"),
    joinName: $("joinName"),
    joinCode: $("joinCode"),
    joinPasscode: $("joinPasscode"),
    joinHostToken: $("joinHostToken"),
    sessionCode: $("sessionCode"),
    roleBadge: $("roleBadge"),
    lockState: $("lockState"),
    modePill: $("modePill"),
    countdown: $("countdown"),
    pomodoroProgressBar: $("pomodoroProgressBar"),
    focusModeBtn: $("focusModeBtn"),
    shortBreakModeBtn: $("shortBreakModeBtn"),
    longBreakModeBtn: $("longBreakModeBtn"),
    taskLabel: $("taskLabel"),
    completedLabel: $("completedLabel"),
    remainingLabel: $("remainingLabel"),
    startBtn: $("startBtn"),
    stopBtn: $("stopBtn"),
    resetBtn: $("resetBtn"),
    newTaskInput: $("newTaskInput"),
    addTaskBtn: $("addTaskBtn"),
    tasksList: $("tasksList"),
    focusMinutesInput: $("focusMinutesInput"),
    shortBreakMinutesInput: $("shortBreakMinutesInput"),
    longBreakMinutesInput: $("longBreakMinutesInput"),
    longBreakEveryInput: $("longBreakEveryInput"),
    targetPomodorosInput: $("targetPomodorosInput"),
    completedPomodorosInput: $("completedPomodorosInput"),
    saveSettingsBtn: $("saveSettingsBtn"),
    participantsList: $("participantsList"),
    inviteLink: $("inviteLink"),
    copyInviteBtn: $("copyInviteBtn"),
    hostClaimLink: $("hostClaimLink"),
    copyHostClaimBtn: $("copyHostClaimBtn"),
    hostPasscodeInput: $("hostPasscodeInput"),
    setPasscodeBtn: $("setPasscodeBtn"),
    clearPasscodeBtn: $("clearPasscodeBtn"),
    activityList: $("activityList"),
};

const socketProtocol = location.protocol === "https:" ? "wss" : "ws";
let ws = null;
let reconnectTimer = null;
let reconnectAttempt = 0;
const HEARTBEAT_MS = 20 * 1000;
let heartbeatTimer = null;
let currentUserName = "Guest";
let lastJoinCode = "";
let lastJoinPasscode = "";
let lastJoinHostToken = "";

let currentSession = null;
let previousMode = null;
const USER_KEY_STORAGE = "pomodoroDualUserKey";
const HOST_TOKEN_STORAGE = "pomodoroDualHostTokens";
const LAST_SESSION_STORAGE = "pomodoroDualLastSession";

function getOrCreateUserKey() {
    const existing = localStorage.getItem(USER_KEY_STORAGE);
    if (existing) return existing;
    const created = crypto.randomUUID();
    localStorage.setItem(USER_KEY_STORAGE, created);
    return created;
}

const userKey = getOrCreateUserKey();

function getStoredHostTokens() {
    try {
        return JSON.parse(localStorage.getItem(HOST_TOKEN_STORAGE) || "{}");
    } catch {
        return {};
    }
}

function setStoredHostToken(code, token) {
    const all = getStoredHostTokens();
    all[code] = token;
    localStorage.setItem(HOST_TOKEN_STORAGE, JSON.stringify(all));
}

function getStoredHostToken(code) {
    return getStoredHostTokens()[code] || "";
}

function saveLastSessionContext() {
    if (!lastJoinCode) return;
    localStorage.setItem(
        LAST_SESSION_STORAGE,
        JSON.stringify({
            code: lastJoinCode,
            name: currentUserName || "Guest",
            passcode: lastJoinPasscode || "",
            hostToken: lastJoinHostToken || "",
            updatedAt: Date.now(),
        })
    );
}

function clearLastSessionContext() {
    localStorage.removeItem(LAST_SESSION_STORAGE);
}

function restoreLastSessionContext() {
    try {
        const raw = localStorage.getItem(LAST_SESSION_STORAGE);
        if (!raw) return;

        const parsed = JSON.parse(raw);
        if (!parsed?.code) return;

        lastJoinCode = String(parsed.code).trim().toUpperCase();
        currentUserName = (parsed.name || "Guest").toString();
        lastJoinPasscode = (parsed.passcode || "").toString();
        lastJoinHostToken = (parsed.hostToken || "").toString();

        dom.joinCode.value = lastJoinCode;
        if (currentUserName && currentUserName !== "Guest") {
            dom.joinName.value = currentUserName;
        }
        if (lastJoinPasscode) dom.joinPasscode.value = lastJoinPasscode;
        if (lastJoinHostToken) dom.joinHostToken.value = lastJoinHostToken;
    } catch {
        // ignore malformed storage
    }
}

function setStatus(text, kind = "") {
    dom.statusLine.textContent = text;
    dom.statusLine.className = `status ${kind}`.trim();
}

function formatTime(seconds) {
    const s = Math.max(0, Number(seconds) || 0);
    const mm = String(Math.floor(s / 60)).padStart(2, "0");
    const ss = String(s % 60).padStart(2, "0");
    return `${mm}:${ss}`;
}

function resetDocumentTitle() {
    document.title = "Pomodoro Dual";
}

function updateDocumentTitle(state) {
    if (!state) {
        resetDocumentTitle();
        return;
    }

    const modeLabel = state.mode === "shortBreak" ? "Short Break" : state.mode === "longBreak" ? "Long Break" : "Focus";
    const runningDot = state.isRunning ? "●" : "○";
    document.title = `${runningDot} ${formatTime(state.remainingSec)} • ${modeLabel} • Pomodoro Dual`;
}

function formatClock(ms) {
    const d = new Date(ms);
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function requestNotificationPermission() {
    if (!("Notification" in window)) return;
    if (Notification.permission === "default") {
        Notification.requestPermission();
    }
}

function notifyPhaseChange(mode) {
    if (!("Notification" in window)) return;
    if (Notification.permission !== "granted") return;
    const title = mode === "focus" ? "Focus Time" : mode === "longBreak" ? "Long Break" : "Short Break";
    new Notification(`Pomodoro: ${title}`, { body: "Session mode changed." });
}

function emit(type, payload = {}) {
    if (!ws || ws.readyState !== WebSocket.OPEN) return;
    ws.send(JSON.stringify({ type, ...payload }));
}

function getModeDuration(state) {
    if (state.mode === "shortBreak") return state.shortBreakDurationSec;
    if (state.mode === "longBreak") return state.longBreakDurationSec;
    return state.focusDurationSec;
}

function renderParticipants() {
    dom.participantsList.innerHTML = "";
    if (!currentSession) return;

    for (const participant of currentSession.participants) {
        const row = document.createElement("div");
        row.className = "participant";

        const title = document.createElement("div");
        const youTag = participant.id === currentSession.you.id ? " (you)" : "";
        const status = participant.connected ? "online" : "offline";
        title.textContent = `${participant.name}${youTag} • ${status}`;

        if (participant.role === "host") {
            const hostBadge = document.createElement("span");
            hostBadge.textContent = "Host";
            row.append(title, hostBadge);
            dom.participantsList.appendChild(row);
            continue;
        }

        const roleSelect = document.createElement("select");
        roleSelect.innerHTML = `
            <option value="viewer">viewer</option>
            <option value="editor">editor</option>
        `;
        roleSelect.value = participant.role;
        roleSelect.disabled = !currentSession.you.isHost;
        roleSelect.addEventListener("change", () => {
            emit("session:set-role", {
                targetClientId: participant.id,
                role: roleSelect.value,
            });
        });

        const actions = document.createElement("div");
        actions.className = "participant-actions";
        actions.append(roleSelect);

        if (currentSession.you.isHost) {
            const transferBtn = document.createElement("button");
            transferBtn.type = "button";
            transferBtn.className = "ghost";
            transferBtn.textContent = "Make Host";
            transferBtn.addEventListener("click", () => {
                if (!confirm(`Transfer host to ${participant.name}?`)) return;
                emit("session:transfer-host", { targetClientId: participant.id });
            });
            actions.append(transferBtn);
        }

        row.append(title, actions);
        dom.participantsList.appendChild(row);
    }
}

function renderTasks() {
    dom.tasksList.innerHTML = "";
    if (!currentSession) return;

    const { state, you } = currentSession;
    const canEdit = you.canEdit;

    for (const task of state.tasks || []) {
        const row = document.createElement("div");
        row.className = `task-item ${task.id === state.activeTaskId ? "active" : ""}`;

        const left = document.createElement("div");
        left.className = "task-left";

        const selectBtn = document.createElement("button");
        selectBtn.type = "button";
        selectBtn.className = "ghost";
        selectBtn.textContent = task.id === state.activeTaskId ? "Current" : "Select";
        selectBtn.disabled = task.id === state.activeTaskId;
        selectBtn.addEventListener("click", () => emit("task:select", { taskId: task.id }));

        const titleInput = document.createElement("input");
        titleInput.value = task.title;
        titleInput.disabled = !canEdit;
        titleInput.maxLength = 120;
        titleInput.addEventListener("change", () => {
            emit("task:update", {
                taskId: task.id,
                title: titleInput.value,
            });
        });

        left.append(selectBtn, titleInput);

        const right = document.createElement("div");
        right.className = "task-right";

        const doneCheckbox = document.createElement("input");
        doneCheckbox.type = "checkbox";
        doneCheckbox.checked = Boolean(task.done);
        doneCheckbox.disabled = !canEdit;
        doneCheckbox.addEventListener("change", () => {
            emit("task:update", {
                taskId: task.id,
                done: doneCheckbox.checked,
            });
        });

        const doneLabel = document.createElement("span");
        doneLabel.textContent = `Done (${task.pomodorosDone})`;

        const removeBtn = document.createElement("button");
        removeBtn.type = "button";
        removeBtn.className = "ghost";
        removeBtn.textContent = "Remove";
        removeBtn.disabled = !canEdit || (state.tasks || []).length <= 1;
        removeBtn.addEventListener("click", () => emit("task:remove", { taskId: task.id }));

        right.append(doneCheckbox, doneLabel, removeBtn);
        row.append(left, right);
        dom.tasksList.appendChild(row);
    }
}

function renderActivity() {
    dom.activityList.innerHTML = "";
    if (!currentSession || !Array.isArray(currentSession.activity)) return;

    for (const item of currentSession.activity.slice(0, 24)) {
        const row = document.createElement("div");
        row.className = `activity-item ${item.type === "warning" ? "warn" : "info"}`;

        const time = document.createElement("span");
        time.className = "activity-time";
        time.textContent = formatClock(item.at);

        const message = document.createElement("span");
        message.className = "activity-message";
        message.textContent = item.message;

        row.append(time, message);
        dom.activityList.appendChild(row);
    }
}

function renderSession() {
    if (!currentSession) return;

    const { state, code, you } = currentSession;
    const canEdit = you.canEdit;

    dom.lobby.classList.add("hidden");
    dom.sessionPanel.classList.remove("hidden");

    dom.sessionCode.textContent = code;
    lastJoinCode = code;
    saveLastSessionContext();
    dom.inviteLink.value = `${location.origin}/?code=${encodeURIComponent(code)}`;

    const hostToken = getStoredHostToken(code);
    dom.hostClaimLink.value = hostToken
        ? `${location.origin}/?code=${encodeURIComponent(code)}&hostToken=${encodeURIComponent(hostToken)}`
        : "Host reclaim token will appear once issued.";

    dom.roleBadge.textContent = you.role;
    dom.lockState.textContent = `Join lock: ${currentSession.joinProtected ? "On" : "Off"}`;
    dom.modePill.textContent = state.mode === "shortBreak" ? "SHORT BREAK" : state.mode === "longBreak" ? "LONG BREAK" : "FOCUS";
    dom.countdown.textContent = formatTime(state.remainingSec);
    dom.taskLabel.textContent = state.activeTaskTitle || "-";
    dom.completedLabel.textContent = String(state.completedPomodoros);
    dom.remainingLabel.textContent = String(state.remainingPomodoros);

    const modeDuration = getModeDuration(state);
    const progress = modeDuration > 0 ? ((modeDuration - state.remainingSec) / modeDuration) * 100 : 0;
    dom.pomodoroProgressBar.style.width = `${Math.max(0, Math.min(100, progress))}%`;

    dom.focusMinutesInput.value = String(Math.floor(state.focusDurationSec / 60));
    dom.shortBreakMinutesInput.value = String(Math.floor(state.shortBreakDurationSec / 60));
    dom.longBreakMinutesInput.value = String(Math.floor(state.longBreakDurationSec / 60));
    dom.longBreakEveryInput.value = String(state.longBreakEvery);
    dom.targetPomodorosInput.value = String(state.targetPomodoros);
    dom.completedPomodorosInput.value = String(state.completedPomodoros);

    dom.startBtn.disabled = !canEdit || state.isRunning;
    dom.stopBtn.disabled = !canEdit || !state.isRunning;
    dom.resetBtn.disabled = !canEdit;
    dom.addTaskBtn.disabled = !canEdit;
    dom.newTaskInput.disabled = !canEdit;
    dom.focusMinutesInput.disabled = !canEdit;
    dom.shortBreakMinutesInput.disabled = !canEdit;
    dom.longBreakMinutesInput.disabled = !canEdit;
    dom.longBreakEveryInput.disabled = !canEdit;
    dom.targetPomodorosInput.disabled = !canEdit;
    dom.completedPomodorosInput.disabled = !canEdit;
    dom.saveSettingsBtn.disabled = !canEdit;
    dom.focusModeBtn.disabled = !canEdit;
    dom.shortBreakModeBtn.disabled = !canEdit;
    dom.longBreakModeBtn.disabled = !canEdit;
    dom.hostPasscodeInput.disabled = !you.isHost;
    dom.setPasscodeBtn.disabled = !you.isHost;
    dom.clearPasscodeBtn.disabled = !you.isHost;

    renderTasks();
    renderParticipants();
    renderActivity();
    updateDocumentTitle(state);
}

function tryAutoRejoin() {
    if (!lastJoinCode || !currentUserName) return;

    saveLastSessionContext();
    emit("session:join", {
        name: currentUserName,
        code: lastJoinCode,
        passcode: lastJoinPasscode,
        hostClaimToken: lastJoinHostToken || getStoredHostToken(lastJoinCode),
        userKey,
    });
}

function startHeartbeat() {
    if (heartbeatTimer) clearInterval(heartbeatTimer);
    heartbeatTimer = setInterval(() => {
        emit("client:ping", { t: Date.now() });
    }, HEARTBEAT_MS);
}

function connectSocket() {
    ws = new WebSocket(`${socketProtocol}://${location.host}`);

    ws.addEventListener("open", () => {
        if (reconnectTimer) {
            clearTimeout(reconnectTimer);
            reconnectTimer = null;
        }
        reconnectAttempt = 0;
        setStatus("Connected. Session synced live.", "good");
        startHeartbeat();
        if (lastJoinCode) {
            tryAutoRejoin();
        }
    });

    ws.addEventListener("message", (event) => {
        const data = JSON.parse(event.data);

        if (data.type === "session:host-token-issued") {
            if (data.code && data.token) {
                setStoredHostToken(data.code, data.token);
                if (currentSession && currentSession.code === data.code) {
                    renderSession();
                    setStatus("Host reclaim token updated.", "good");
                }
            }
        }

        if (data.type === "session:update") {
            currentSession = data.session;
            const me = currentSession.participants.find((p) => p.id === currentSession.you.id);
            if (me?.name) {
                currentUserName = me.name;
            }
            if (previousMode && previousMode !== currentSession.state.mode) {
                notifyPhaseChange(currentSession.state.mode);
            }
            previousMode = currentSession.state.mode;
            renderSession();
            setStatus("Session synchronized.", "good");
        }

        if (data.type === "error") {
            if (typeof data.message === "string" && data.message.includes("Session code not found")) {
                lastJoinCode = "";
                lastJoinPasscode = "";
                lastJoinHostToken = "";
                clearLastSessionContext();
            }
            setStatus(data.message, "error");
        }

        if (data.type === "session:ended") {
            currentSession = null;
            previousMode = null;
            lastJoinCode = "";
            lastJoinPasscode = "";
            lastJoinHostToken = "";
            clearLastSessionContext();
            dom.sessionPanel.classList.add("hidden");
            dom.lobby.classList.remove("hidden");
            dom.participantsList.innerHTML = "";
            dom.activityList.innerHTML = "";
            dom.tasksList.innerHTML = "";
            resetDocumentTitle();
            setStatus(data.reason, "error");
        }
    });

    ws.addEventListener("close", () => {
        if (heartbeatTimer) clearInterval(heartbeatTimer);
        setStatus("Connection lost. Reconnecting...", "error");
        document.title = "Reconnecting... • Pomodoro Dual";

        const delay = Math.min(10000, 1000 * 2 ** reconnectAttempt);
        reconnectAttempt += 1;
        reconnectTimer = setTimeout(connectSocket, delay);
    });
}

dom.hostForm.addEventListener("submit", (e) => {
    e.preventDefault();
    currentUserName = dom.hostName.value.trim() || "Host";
    lastJoinPasscode = "";
    lastJoinHostToken = "";
    saveLastSessionContext();
    emit("host:create", {
        name: currentUserName,
        userKey,
    });
});

dom.joinForm.addEventListener("submit", (e) => {
    e.preventDefault();
    currentUserName = dom.joinName.value.trim() || "Guest";
    lastJoinCode = dom.joinCode.value.trim().toUpperCase();
    lastJoinPasscode = dom.joinPasscode.value;
    lastJoinHostToken = dom.joinHostToken.value;
    saveLastSessionContext();
    emit("session:join", {
        name: currentUserName,
        code: lastJoinCode,
        passcode: lastJoinPasscode,
        hostClaimToken: lastJoinHostToken,
        userKey,
    });
});

dom.copyInviteBtn.addEventListener("click", async () => {
    if (!dom.inviteLink.value) return;
    try {
        await navigator.clipboard.writeText(dom.inviteLink.value);
        setStatus("Invite link copied.", "good");
    } catch {
        dom.inviteLink.select();
        document.execCommand("copy");
        setStatus("Invite link copied.", "good");
    }
});

dom.copyHostClaimBtn.addEventListener("click", async () => {
    if (!dom.hostClaimLink.value || dom.hostClaimLink.value.includes("will appear")) return;
    try {
        await navigator.clipboard.writeText(dom.hostClaimLink.value);
        setStatus("Host reclaim link copied.", "good");
    } catch {
        dom.hostClaimLink.select();
        document.execCommand("copy");
        setStatus("Host reclaim link copied.", "good");
    }
});

dom.startBtn.addEventListener("click", () => {
    requestNotificationPermission();
    emit("timer:start");
});
dom.stopBtn.addEventListener("click", () => emit("timer:stop"));
dom.resetBtn.addEventListener("click", () => emit("timer:reset"));
dom.focusModeBtn.addEventListener("click", () => emit("state:update", { patch: { mode: "focus" } }));
dom.shortBreakModeBtn.addEventListener("click", () => emit("state:update", { patch: { mode: "shortBreak" } }));
dom.longBreakModeBtn.addEventListener("click", () => emit("state:update", { patch: { mode: "longBreak" } }));

dom.addTaskBtn.addEventListener("click", () => {
    const title = dom.newTaskInput.value.trim();
    emit("task:add", { title });
    dom.newTaskInput.value = "";
});

dom.saveSettingsBtn.addEventListener("click", () => {
    emit("state:update", {
        patch: {
            focusDurationSec: Math.round(Number(dom.focusMinutesInput.value) * 60),
            shortBreakDurationSec: Math.round(Number(dom.shortBreakMinutesInput.value) * 60),
            longBreakDurationSec: Math.round(Number(dom.longBreakMinutesInput.value) * 60),
            longBreakEvery: Math.round(Number(dom.longBreakEveryInput.value)),
            targetPomodoros: Math.round(Number(dom.targetPomodorosInput.value)),
            completedPomodoros: Math.round(Number(dom.completedPomodorosInput.value)),
        },
    });
});

dom.setPasscodeBtn.addEventListener("click", () => {
    const passcode = dom.hostPasscodeInput.value.trim();
    emit("session:set-passcode", { passcode });
    dom.hostPasscodeInput.value = "";
});

dom.clearPasscodeBtn.addEventListener("click", () => {
    emit("session:set-passcode", { passcode: "" });
    dom.hostPasscodeInput.value = "";
});

document.addEventListener("keydown", (event) => {
    const targetTag = event.target && event.target.tagName;
    if (targetTag === "INPUT" || targetTag === "TEXTAREA" || targetTag === "SELECT") return;
    if (!currentSession || !currentSession.you.canEdit) return;

    if (event.code === "Space") {
        event.preventDefault();
        emit(currentSession.state.isRunning ? "timer:stop" : "timer:start");
    }

    if (event.key.toLowerCase() === "r") {
        emit("timer:reset");
    }

    if (event.key === "1") emit("state:update", { patch: { mode: "focus" } });
    if (event.key === "2") emit("state:update", { patch: { mode: "shortBreak" } });
    if (event.key === "3") emit("state:update", { patch: { mode: "longBreak" } });
});

const params = new URLSearchParams(location.search);
const urlCode = params.get("code");
const urlHostToken = params.get("hostToken");

restoreLastSessionContext();

if (urlCode) {
    dom.joinCode.value = urlCode.trim().toUpperCase().slice(0, 6);
    lastJoinCode = dom.joinCode.value;
    const storedToken = getStoredHostToken(dom.joinCode.value);
    if (storedToken) dom.joinHostToken.value = storedToken;
}
if (urlHostToken) {
    dom.joinHostToken.value = urlHostToken;
    lastJoinHostToken = urlHostToken;
}

if (lastJoinCode) {
    saveLastSessionContext();
}

connectSocket();
resetDocumentTitle();
