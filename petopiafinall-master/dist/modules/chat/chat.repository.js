"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatRepository = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class ChatRepository {
    // ── Conversation lookup ────────────────────────────────────────────────────
    static findConversationBetween(userA, userB, type) {
        return prisma_1.default.conversation.findFirst({
            where: {
                ...(type && { type }),
                AND: [
                    { participants: { some: { userId: userA } } },
                    { participants: { some: { userId: userB } } },
                ],
            },
            include: {
                participants: {
                    include: { user: { select: { id: true, fullName: true, profilePicture: true } } },
                },
                messages: { orderBy: { createdAt: "desc" }, take: 1 },
            },
        });
    }
    // ── Conversation creation ──────────────────────────────────────────────────
    static createConversation(userA, userB, type, db = prisma_1.default) {
        return db.conversation.create({
            data: {
                type,
                participants: {
                    create: [{ userId: userA }, { userId: userB }],
                },
            },
            include: {
                participants: {
                    include: { user: { select: { id: true, fullName: true, profilePicture: true } } },
                },
            },
        });
    }
    // Creates a conversation only if one does not already exist between the two users (for the given type).
    static async findOrCreateConversation(userA, userB, type, db = prisma_1.default) {
        const existing = await db.conversation.findFirst({
            where: {
                type,
                AND: [
                    { participants: { some: { userId: userA } } },
                    { participants: { some: { userId: userB } } },
                ],
            },
            include: {
                participants: {
                    include: { user: { select: { id: true, fullName: true, profilePicture: true } } },
                },
            },
        });
        if (existing)
            return existing;
        return db.conversation.create({
            data: {
                type,
                participants: {
                    create: [{ userId: userA }, { userId: userB }],
                },
            },
            include: {
                participants: {
                    include: { user: { select: { id: true, fullName: true, profilePicture: true } } },
                },
            },
        });
    }
    // ── User's conversation list ───────────────────────────────────────────────
    static getConversations(userId) {
        return prisma_1.default.conversation.findMany({
            where: { participants: { some: { userId } } },
            include: {
                participants: {
                    include: { user: { select: { id: true, fullName: true, profilePicture: true } } },
                },
                messages: { orderBy: { createdAt: "desc" }, take: 1 },
            },
            orderBy: { updatedAt: "desc" },
        });
    }
    // ── Messages ───────────────────────────────────────────────────────────────
    static getMessages(conversationId, page = 1, limit = 50) {
        return prisma_1.default.chatMessage.findMany({
            where: { conversationId },
            include: { sender: { select: { id: true, fullName: true, profilePicture: true } } },
            orderBy: { createdAt: "asc" },
            skip: (page - 1) * limit,
            take: limit,
        });
    }
    // ── Membership check ───────────────────────────────────────────────────────
    static async isParticipant(conversationId, userId) {
        const row = await prisma_1.default.conversationParticipant.findUnique({
            where: { conversationId_userId: { conversationId, userId } },
        });
        return row !== null;
    }
    static async getParticipantIds(conversationId) {
        const rows = await prisma_1.default.conversationParticipant.findMany({
            where: { conversationId },
            select: { userId: true },
        });
        return rows.map((r) => r.userId);
    }
    // ── Delete a conversation (cascade removes participants + messages) ─────────
    static deleteConversation(conversationId) {
        return prisma_1.default.conversation.delete({ where: { id: conversationId } });
    }
    // ── Persist a message and bump conversation.updatedAt ─────────────────────
    static async saveMessage(data) {
        return prisma_1.default.$transaction(async (tx) => {
            const message = await tx.chatMessage.create({
                data,
                include: { sender: { select: { id: true, fullName: true, profilePicture: true } } },
            });
            await tx.conversation.update({
                where: { id: data.conversationId },
                data: { updatedAt: new Date() },
            });
            return message;
        });
    }
}
exports.ChatRepository = ChatRepository;
//# sourceMappingURL=chat.repository.js.map