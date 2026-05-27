import { Server as SocketServer, Socket } from "socket.io";
import { createServer } from "http";
import type { Express } from "express";
import { verifyToken } from "./common/utils/jwt";
import { ChatRepository } from "./modules/chat/chat.repository";
import { NotificationGateway } from "./modules/Notification/notification.socket";
import { fireNotification } from "./modules/Notification/notification.helpers";
import { notifyNewChatMessage } from "./modules/Notification/notification.templates";

console.log("=== socket.ts LOADED — new version with full logging ===");

export type HttpServer = ReturnType<typeof createServer>;

let io: SocketServer;

// ── Safely unwrap payload from socket_io_client (Dart emits may be array-wrapped) ──
function extractPayload(raw: unknown): Record<string, unknown> {
  if (raw == null) return {};
  if (Array.isArray(raw)) return (raw[0] as Record<string, unknown>) ?? {};
  if (typeof raw === "object") return raw as Record<string, unknown>;
  return {};
}

export function initSocket(httpServer: HttpServer): SocketServer {
  io = new SocketServer(httpServer, {
    cors: {
      origin: (origin, callback) => {
        if (!origin || origin.startsWith("http://localhost")) {
          return callback(null, true);
        }
        callback(new Error(`CORS: origin ${origin} not allowed`));
      },
      credentials: true,
    },
  });

  // ── Engine-level connection error (fires before auth middleware) ─────────
  io.engine.on("connection_error", (err: { code: number; message: string; context: unknown }) => {
    console.error(`[socket] ENGINE connection_error  code=${err.code}  msg="${err.message}"`);
  });

  // ── JWT auth middleware ───────────────────────────────────────────────────
  io.use((socket, next) => {
    console.log(`[socket] AUTH attempt  addr=${socket.handshake.address}  hasToken=${!!socket.handshake.auth["token"]}`);
    const token = socket.handshake.auth["token"] as string | undefined;
    if (!token) {
      console.log(`[socket] AUTH rejected — no token`);
      return next(new Error("Unauthorized: no token provided"));
    }
    try {
      socket.data["user"] = verifyToken(token);
      console.log(`[socket] AUTH ok  userId=${(socket.data["user"] as { userId: string }).userId}`);
      next();
    } catch (err) {
      console.error(`[socket] AUTH rejected — invalid token:`, err);
      next(new Error("Unauthorized: invalid or expired token"));
    }
  });

  NotificationGateway.initialize(io);

  // ── Connection handler ────────────────────────────────────────────────────
  io.on("connection", async (socket: Socket) => {
    const userId = (socket.data["user"] as { userId: string }).userId;
    console.log(`[socket] ✅ CONNECTED  userId=${userId}  socketId=${socket.id}`);

    // User-specific room — guarantees delivery even for conversations created
    // after this socket connected (avoids the join_room timing gap).
    socket.join(`user:${userId}`);

    // Also join all existing conversation rooms for backward compat.
    try {
      const convs = await ChatRepository.getConversations(userId);
      for (const conv of convs) {
        socket.join(conv.id);
      }
      console.log(`[socket] auto-joined ${convs.length} existing room(s) for ${userId}`);
    } catch (err) {
      console.error(`[socket] auto-join failed for user ${userId}:`, err);
    }

    // ── join_room ─ client sends { conversationId } ───────────────────────
    socket.on("join_room", async (raw: unknown) => {
      try {
        const payload = extractPayload(raw);
        const conversationId =
          typeof payload["conversationId"] === "string"
            ? payload["conversationId"]
            : "";

        console.log(`[socket] join_room  userId=${userId}  conversationId=${conversationId || "(empty)"}`);

        if (!conversationId) {
          socket.emit("error", { message: "conversationId is required" });
          return;
        }

        const isMember = await ChatRepository.isParticipant(conversationId, userId);
        if (!isMember) {
          console.log(`[socket] join_room REJECTED — not a participant`);
          socket.emit("error", {
            message: "You are not a participant of this conversation",
          });
          return;
        }

        socket.join(conversationId);
        socket.emit("joined", { conversationId });
        console.log(`[socket] join_room OK  conversationId=${conversationId}`);
      } catch (err) {
        console.error(`[socket] join_room error for user ${userId}:`, err);
        socket.emit("error", { message: "Failed to join room" });
      }
    });

    // ── send_message ─ client sends { conversationId, content } ──────────
    // Persists to DB BEFORE broadcasting so history is always consistent.
    socket.on("send_message", async (raw: unknown) => {
      console.log(`[socket] send_message RAW received from userId=${userId}:`, JSON.stringify(raw));
      try {
        const payload = extractPayload(raw);
        const conversationId =
          typeof payload["conversationId"] === "string"
            ? payload["conversationId"]
            : "";
        const content =
          typeof payload["content"] === "string" ? payload["content"] : "";

        console.log(`[socket] send_message  conversationId=${conversationId || "(empty)"}  content="${content || "(empty)"}"`);

        if (!conversationId || !content.trim()) {
          console.log(`[socket] send_message REJECTED — missing fields`);
          socket.emit("error", {
            message: "conversationId and content are required",
          });
          return;
        }

        const isMember = await ChatRepository.isParticipant(conversationId, userId);
        console.log(`[socket] send_message isParticipant=${isMember}`);
        if (!isMember) {
          socket.emit("error", {
            message: "You are not a participant of this conversation",
          });
          return;
        }

        // ── Persist first, then broadcast ─────────────────────────────────
        console.log(`[socket] send_message calling saveMessage...`);
        const message = await ChatRepository.saveMessage({
          conversationId,
          senderId: userId,
          content: content.trim(),
        });
        console.log(`[socket] send_message SAVED  messageId=${message.id}`);

        const msgPayload = {
          id:             message.id,
          conversationId: message.conversationId,
          senderId:       message.senderId,
          sender:         message.sender,
          content:        message.content,
          createdAt:      message.createdAt,
        };

        // ACK to sender: message successfully persisted
        socket.emit("message_sent", msgPayload);

        // Broadcast to conversation room + every participant's user room.
        const participantIds = await ChatRepository.getParticipantIds(conversationId);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let emitter: any = io.to(conversationId);
        for (const pid of participantIds) {
          emitter = emitter.to(`user:${pid}`);
        }
        emitter.emit("receive_message", msgPayload);
        console.log(`[socket] send_message broadcast to ${participantIds.length} participant(s)`);

        const senderName =
          (message.sender as { fullName?: string } | null)?.fullName ?? "Someone";
        for (const pid of participantIds) {
          if (pid !== userId) {
            fireNotification(
              notifyNewChatMessage(pid, conversationId, senderName),
            );
          }
        }
      } catch (err) {
        console.error(`[socket] send_message ERROR for user ${userId}:`, err);
        socket.emit("error", { message: "Failed to send message" });
      }
    });

    socket.on("disconnect", () => {
      // intentionally left empty — socket.io cleans up room membership
    });
  });

  return io;
}

export function getIO(): SocketServer {
  if (!io) throw new Error("Socket.io not initialized");
  return io;
}

// Attach socket.io to an Express app (call before app.listen in tests).
export function createHttpServer(app: Express): HttpServer {
  return createServer(app);
}
