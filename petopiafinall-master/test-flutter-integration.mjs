/**
 * Flutter → Backend Integration Test
 * Mirrors exactly what the Flutter ChatService / ChatScreen code does.
 * Run: node test-flutter-integration.mjs
 */

import { io } from "socket.io-client";

const BASE = "http://localhost:3000";
let passed = 0, failed = 0;

// ── Helpers ───────────────────────────────────────────────────────────────────

async function api(method, path, body, token) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    },
    ...(body && { body: JSON.stringify(body) }),
  });
  const json = await res.json();
  return { status: res.status, body: json };
}

function assert(label, condition, detail = "") {
  if (condition) {
    console.log(`  ✅ ${label}`);
    passed++;
  } else {
    console.error(`  ❌ ${label}${detail ? ` — ${detail}` : ""}`);
    failed++;
  }
}

function connectSocket(token) {
  return new Promise((resolve) => {
    const s = io(BASE, { auth: { token }, transports: ["websocket"] });
    s.on("connect", () => resolve(s));
    s.on("connect_error", () => resolve(null));
  });
}

function waitFor(socket, event, ms = 3000) {
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => reject(new Error(`Timeout: ${event}`)), ms);
    socket.once(event, (d) => { clearTimeout(t); resolve(d); });
  });
}

// ── Setup ─────────────────────────────────────────────────────────────────────

console.log("\n══════════════════════════════════════════════════════");
console.log("  FLUTTER ↔ BACKEND INTEGRATION TEST");
console.log("══════════════════════════════════════════════════════\n");

const ts = Date.now();
const emailA = `flutter_a_${ts}@test.com`;
const emailB = `flutter_b_${ts}@test.com`;

// ── PHASE 1: Auth (mirrors AuthService.login → AuthStorage.saveSession) ───────
console.log("─── PHASE 1: Auth ───");

await api("POST", "/auth/register-owner", { email: emailA, password: "Test1234", fullName: "Flutter Alpha", age: 25, gender: "MALE",   phone: "01011110001" });
await api("POST", "/auth/register-owner", { email: emailB, password: "Test1234", fullName: "Flutter Beta",  age: 26, gender: "FEMALE", phone: "01022220002" });

const lA = (await api("POST", "/auth/login", { email: emailA, password: "Test1234" })).body;
const lB = (await api("POST", "/auth/login", { email: emailB, password: "Test1234" })).body;

const tokenA = lA.data?.token;
const tokenB = lB.data?.token;
const idA    = lA.data?.user?.id;
const idB    = lB.data?.user?.id;

assert("Both users registered and JWT tokens received", tokenA && tokenB);
console.log(`  UserA: ${idA}  UserB: ${idB}`);

// ── PHASE 2: Set up an accepted MATCHING conversation ─────────────────────────
console.log("\n─── PHASE 2: MATCHING Setup ───");

const petA = await api("POST", "/pets", { name: "FlutterDog", age: 2, gender: "MALE"   }, tokenA);
const petB = await api("POST", "/pets", { name: "FlutterCat", age: 3, gender: "FEMALE" }, tokenB);
assert("Pets created", petA.status === 201 && petB.status === 201);

const petIdA = petA.body.data?.id;
const petIdB = petB.body.data?.id;

await api("POST", "/matching/profile", { petId: petIdA, description: "Test", address: "Cairo" }, tokenA);
await api("POST", "/matching/profile", { petId: petIdB, description: "Test", address: "Giza"  }, tokenB);

const req    = await api("POST", "/matching/request", { fromPetId: petIdA, toPetId: petIdB }, tokenA);
const reqId  = req.body.data?.id;
const accept = await api("PATCH", `/matching/requests/${reqId}/accept`, {}, tokenB);
assert("Match accepted (conversation auto-created)", accept.status === 200);

// ── PHASE 3: ChatService.initiateConversation (MATCHING) ──────────────────────
console.log("\n─── PHASE 3: ChatService.initiateConversation ───");

// Mirrors: ChatService.initiateConversation(targetUserId: idB, context: 'MATCHING')
const initA = await api("POST", "/chat/initiate", { targetUserId: idB, context: "MATCHING" }, tokenA);
assert("POST /chat/initiate → 200", initA.status === 200, initA.body.message);
assert("Response has conversation id",   !!initA.body.data?.id);
assert("Response has type MATCHING",     initA.body.data?.type === "MATCHING");
assert("Response has 2 participants",    initA.body.data?.participants?.length === 2);
assert("Participant has user.fullName",  !!initA.body.data?.participants?.[0]?.user?.fullName);

const convId = initA.body.data?.id;
console.log(`  conversationId: ${convId}`);

// Idempotent from B side (Flutter calls this when the other user also clicks Message Owner)
const initB = await api("POST", "/chat/initiate", { targetUserId: idA, context: "MATCHING" }, tokenB);
assert("Idempotent — same conv returned for B",  initB.body.data?.id === convId);

// ── PHASE 4: ChatService.getConversations (chat list screen) ──────────────────
console.log("\n─── PHASE 4: ChatService.getConversations ───");

// Mirrors: ChatService.getConversations() called in ChatListScreen.initState
const convListA = await api("GET", "/chat/conversations", null, tokenA);
assert("GET /chat/conversations → 200",                convListA.status === 200);
assert("Array returned",                               Array.isArray(convListA.body.data));
const conv = convListA.body.data.find(c => c.id === convId);
assert("Our conversation is in the list",              !!conv);
assert("Conversation has participants array",           Array.isArray(conv?.participants));
assert("Participant has user.fullName for name display",
  conv?.participants?.every(p => p?.user?.fullName));
assert("messages array present (for last-message snippet)", Array.isArray(conv?.messages));
assert("updatedAt present",                            !!conv?.updatedAt);

// otherParticipantName logic mirrors Dart: filter out myUserId, take the other
const otherParticipant = conv?.participants?.find(p => p.userId !== idA);
assert("Other participant identified correctly",
  otherParticipant?.user?.fullName === "Flutter Beta");

// ── PHASE 5: ChatService.getMessages (ChatScreen history load) ────────────────
console.log("\n─── PHASE 5: ChatService.getMessages ───");

// Mirrors: ChatService.getMessages(conversationId, page:1, limit:50)
const msgs0 = await api("GET", `/chat/conversations/${convId}/messages?page=1&limit=50`, null, tokenA);
assert("GET /messages → 200",          msgs0.status === 200);
assert("Empty before any socket send", Array.isArray(msgs0.body.data) && msgs0.body.data.length === 0);

// Non-participant blocked (Flutter shows 403 as snackbar)
const msgsUnauth = await api("GET", `/chat/conversations/${convId}/messages`, null, null);
assert("No token → 401 (would show session-expired snackbar)", msgsUnauth.status === 401);

// ── PHASE 6: ChatService.connect + joinRoom + sendMessage (real-time) ─────────
console.log("\n─── PHASE 6: Socket — connect / join / send / receive ───");

// Mirrors: ChatService.connect() → socket.io with auth.token
const sockA = await connectSocket(tokenA);
const sockB = await connectSocket(tokenB);
assert("UserA socket connects (JWT valid)",  sockA?.connected);
assert("UserB socket connects (JWT valid)",  sockB?.connected);

// Mirrors: ChatService.joinRoom(conversationId)
sockA.emit("join_room", { conversationId: convId });
const joinA = await waitFor(sockA, "joined").catch(() => null);
assert("UserA received 'joined' ack",  joinA?.conversationId === convId);

sockB.emit("join_room", { conversationId: convId });
const joinB = await waitFor(sockB, "joined").catch(() => null);
assert("UserB received 'joined' ack",  joinB?.conversationId === convId);

// Mirrors: ChatService.sendMessage(conversationId, content)
// B listens; A sends → B's messageStream fires
const bPromise = waitFor(sockB, "receive_message").catch(() => null);
sockA.emit("send_message", { conversationId: convId, content: "Hello from Flutter Alpha!" });
const bReceived = await bPromise;
assert("B receives 'receive_message'",       bReceived !== null);
assert("content matches",                    bReceived?.content === "Hello from Flutter Alpha!");
assert("senderId is A",                      bReceived?.senderId === idA);
assert("createdAt present (timestamps work)", !!bReceived?.createdAt);

// Sender also receives own message (broadcast to room)
// In Flutter: the stream filter is .where((m) => m.conversationId == widget.conversationId)
const aOwnPromise = waitFor(sockA, "receive_message").catch(() => null);
sockA.emit("send_message", { conversationId: convId, content: "Second message from A" });
const aOwn = await aOwnPromise;
assert("Sender (A) also receives own message via room broadcast", aOwn?.content === "Second message from A");
assert("isSentByMe logic: senderId == myId", aOwn?.senderId === idA);

// B replies → A sees it
const aPromise = waitFor(sockA, "receive_message").catch(() => null);
sockB.emit("send_message", { conversationId: convId, content: "Reply from Flutter Beta!" });
const aReceived = await aPromise;
assert("A receives B's reply",       aReceived?.content === "Reply from Flutter Beta!");
assert("senderId is B (isSentByMe=false for A)", aReceived?.senderId === idB);

// Empty content rejected (connection banner stays active because socket stays connected)
sockA.emit("send_message", { conversationId: convId, content: "" });
const emptyErr = await waitFor(sockA, "error").catch(() => null);
assert("Empty message → server error event (Flutter: send button checks !isEmpty)", emptyErr?.message?.includes("required"));

// ── PHASE 7: DB persistence (ChatScreen reload after messages) ────────────────
console.log("\n─── PHASE 7: DB Persistence (ChatScreen history reload) ───");

await new Promise(r => setTimeout(r, 500));

const finalMsgs = await api("GET", `/chat/conversations/${convId}/messages?page=1&limit=50`, null, tokenA);
assert("GET /messages after socket sends → 200",  finalMsgs.status === 200);
const count = finalMsgs.body.data?.length ?? 0;
assert(`${count} messages persisted (≥ 3)`,       count >= 3);
assert("Messages ordered ASC (oldest first)",
  count >= 2 && new Date(finalMsgs.body.data[0].createdAt) <= new Date(finalMsgs.body.data[count - 1].createdAt));

// sender.fullName is present (Flutter uses this to populate message bubbles)
const firstMsg = finalMsgs.body.data[0];
assert("Message has sender.id",       !!firstMsg?.sender?.id);
assert("Message has sender.fullName", !!firstMsg?.sender?.fullName);
assert("Message has conversationId",  firstMsg?.conversationId === convId);
assert("Message has content",         typeof firstMsg?.content === "string");
assert("Message has createdAt",       !!firstMsg?.createdAt);

// Verify the conversation list now shows the last message (snippet in chat list)
const convListAfter = await api("GET", "/chat/conversations", null, tokenA);
const convAfter = convListAfter.body.data?.find(c => c.id === convId);
assert("Conversation in list has last message (snippet source)",
  Array.isArray(convAfter?.messages) && convAfter.messages.length > 0);
assert("Last message content present",
  typeof convAfter?.messages?.[0]?.content === "string");

// ── PHASE 8: Permission gates (what the Flutter snackbar shows) ───────────────
console.log("\n─── PHASE 8: Error Handling — Flutter SnackBar Scenarios ───");

// MATCHING without accepted match (user clicks Message Owner without a match)
const tmpReg = await api("POST", "/auth/register-owner", {
  email: `tmp_${ts}@test.com`, password: "Test1234",
  fullName: "No Match User", age: 22, gender: "MALE", phone: "01099991111",
});
const tmpLogin = await api("POST", "/auth/login", { email: `tmp_${ts}@test.com`, password: "Test1234" });
const tmpToken = tmpLogin.body.data?.token;

const noMatchErr = await api("POST", "/chat/initiate", { targetUserId: idB, context: "MATCHING" }, tmpToken);
assert("MATCHING without match → 403 (Flutter shows: 'No accepted match found' toast)",
  noMatchErr.status === 403, noMatchErr.body.message);

// SITTING without approved sitter
const noSitterErr = await api("POST", "/chat/initiate", { targetUserId: idA, context: "SITTING" }, tmpToken);
assert("SITTING not-approved → 403 (Flutter shows: 'Only approved pet sitters can initiate' toast)",
  noSitterErr.status === 403, noSitterErr.body.message);

// ── Cleanup ───────────────────────────────────────────────────────────────────
sockA.disconnect();
sockB.disconnect();

// ── Summary ───────────────────────────────────────────────────────────────────
console.log("\n══════════════════════════════════════════════════════");
console.log(`  RESULTS: ${passed} passed, ${failed} failed`);
console.log("══════════════════════════════════════════════════════\n");

if (failed > 0) process.exit(1);
