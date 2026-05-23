import prisma from "../../config/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { ChatRepository } from "./chat.repository";
import { ConversationType } from "../../../generated/prisma";

export class ChatService {

  // ── Initiate or retrieve a conversation ───────────────────────────────────
  // Any user can message any other user directly — no prerequisites required.

  static async initiateConversation(
    initiatorId: string,
    targetUserId: string,
    context: ConversationType,
  ) {
    if (initiatorId === targetUserId) {
      throw new AppError("You cannot message yourself.", HttpCode.BAD_REQUEST);
    }

    const target = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!target) throw new AppError("Target user not found.", HttpCode.NOT_FOUND);

    return ChatRepository.findOrCreateConversation(initiatorId, targetUserId, context);
  }

  // ── User's conversation list ───────────────────────────────────────────────

  static getMyConversations(userId: string) {
    return ChatRepository.getConversations(userId);
  }

  // ── Delete conversation (caller must be a participant) ────────────────────

  static async deleteConversation(userId: string, conversationId: string) {
    const isMember = await ChatRepository.isParticipant(conversationId, userId);
    if (!isMember) {
      throw new AppError("You are not a participant of this conversation.", HttpCode.FORBIDDEN);
    }
    return ChatRepository.deleteConversation(conversationId);
  }

  // ── Messages (caller must be a participant) ────────────────────────────────

  static async getMessages(
    userId: string,
    conversationId: string,
    page: number,
    limit: number,
  ) {
    const isMember = await ChatRepository.isParticipant(conversationId, userId);
    if (!isMember) {
      throw new AppError("You are not a participant of this conversation.", HttpCode.FORBIDDEN);
    }
    return ChatRepository.getMessages(conversationId, page, limit);
  }
}
