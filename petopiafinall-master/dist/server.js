"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
process.env.TZ = process.env.TZ ?? "Africa/Cairo";
const http_1 = require("http");
const child_process_1 = require("child_process");
const net_1 = __importDefault(require("net"));
const path_1 = __importDefault(require("path"));
const app_1 = __importDefault(require("./app"));
const socket_1 = require("./socket");
// ── AI service auto-spawn ─────────────────────────────────────────────────────
function isPortOpen(port) {
    return new Promise(resolve => {
        const s = net_1.default.createServer();
        s.once("error", () => resolve(true));
        s.once("listening", () => { s.close(); resolve(false); });
        s.listen(port, "127.0.0.1");
    });
}
let _aiProc = null;
async function startAIService() {
    if (await isPortOpen(5001)) {
        console.log("[AI] service already running on :5001, skipping spawn");
        return;
    }
    const aiDir = path_1.default.resolve(process.cwd(), "ai-service");
    const script = path_1.default.join(aiDir, "app.py");
    const cmd = process.env.PYTHON_CMD ?? (process.platform === "win32" ? "python" : "python3");
    _aiProc = (0, child_process_1.spawn)(cmd, [script], {
        cwd: aiDir,
        stdio: ["ignore", "pipe", "pipe"],
    });
    _aiProc.stdout?.on("data", d => process.stdout.write(`[AI] ${d}`));
    _aiProc.stderr?.on("data", d => process.stderr.write(`[AI] ${d}`));
    _aiProc.on("error", err => console.error(`[AI] could not start — is Python in PATH? (${err.message})`));
    _aiProc.on("exit", code => {
        console.log(`[AI] process exited (code ${code})`);
        _aiProc = null;
    });
}
startAIService();
const PORT = process.env.PORT || 3000;
const httpServer = (0, http_1.createServer)(app_1.default);
(0, socket_1.initSocket)(httpServer);
// Graceful shutdown: release the port before ts-node-dev spawns the next
// process on hot-reload (prevents EADDRINUSE on file-change restarts).
const shutdown = () => {
    _aiProc?.kill();
    httpServer.close(() => process.exit(0));
};
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
// Retry binding in case the previous process hasn't released the port yet
// (race condition on Windows during ts-node-dev hot-reload).
function listen(attemptsLeft = 8) {
    httpServer.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
    httpServer.once("error", (err) => {
        if (err.code === "EADDRINUSE" && attemptsLeft > 0) {
            console.log(`Port ${PORT} busy, retrying in 400 ms… (${attemptsLeft} left)`);
            setTimeout(() => listen(attemptsLeft - 1), 400);
        }
        else {
            throw err;
        }
    });
}
listen();
//# sourceMappingURL=server.js.map