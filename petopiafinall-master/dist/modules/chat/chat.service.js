"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const AppError_1 = require("../../common/errors/AppError");
const chat_repository_1 = require("./chat.repository");
class ChatService {
    // ── Initiate or retrieve a conversation ───────────────────────────────────
    // Any user can message any other user directly — no prerequisites required.
    static async initiateConversation(initiatorId, targetUserId, context) {
        if (initiatorId === targetUserId) {
            throw new AppError_1.AppError("You cannot message yourself.", AppError_1.HttpCode.BAD_REQUEST);
        }
        const target = await prisma_1.default.user.findUnique({ where: { id: targetUserId } });
        if (!target)
            throw new AppError_1.AppError("Target user not found.", AppError_1.HttpCode.NOT_FOUND);
        return chat_repository_1.ChatRepository.findOrCreateConversation(initiatorId, targetUserId, context);
    }
    // ── User's conversation list ───────────────────────────────────────────────
    static getMyConversations(userId) {
        return chat_repository_1.ChatRepository.getConversations(userId);
    }
    // ── Delete conversation (caller must be a participant) ────────────────────
    static async deleteConversation(userId, conversationId) {
        const isMember = await chat_repository_1.ChatRepository.isParticipant(conversationId, userId);
        if (!isMember) {
            throw new AppError_1.AppError("You are not a participant of this conversation.", AppError_1.HttpCode.FORBIDDEN);
        }
        return chat_repository_1.ChatRepository.deleteConversation(conversationId);
    }
    // ── Messages (caller must be a participant) ────────────────────────────────
    static async getMessages(userId, conversationId, page, limit) {
        const isMember = await chat_repository_1.ChatRepository.isParticipant(conversationId, userId);
        if (!isMember) {
            throw new AppError_1.AppError("You are not a participant of this conversation.", AppError_1.HttpCode.FORBIDDEN);
        }
        return chat_repository_1.ChatRepository.getMessages(conversationId, page, limit);
    }
}
exports.ChatService = ChatService;
//# sourceMappingURL=chat.service.js.map