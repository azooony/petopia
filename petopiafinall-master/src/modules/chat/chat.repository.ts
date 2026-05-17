import prisma from "../../config/prisma";
import { ConversationType, Prisma } from "../../../generated/prisma";

export class ChatRepository {

  // ── Conversation lookup ────────────────────────────────────────────────────

  static findConversationBetween(
    userA: string,
    userB: string,
    type?: ConversationType,
  ) {
    return prisma.conversation.findFirst({
      where: {
        ...(type && { type }),
        AND: [
          { participants: { some: { userId: userA } } },
          { participants: { some: { userId: userB } } },
        ],
      },
      include: {
        participants: {
          include: { user: { select: { id: true, fullName: true } } },
        },
        messages: { orderBy: { createdAt: "desc" }, take: 1 },
      },
    });
  }

  // ── Conversation creation ──────────────────────────────────────────────────

  static createConversation(
    userA: string,
    userB: string,
    type: ConversationType,
    db: Prisma.TransactionClient | typeof prisma = prisma,
  ) {
    return db.conversation.create({
      data: {
        type,
        participants: {
          create: [{ userId: userA }, { userId: userB }],
        },
      },
      include: {
        participants: {
          include: { user: { select: { id: true, fullName: true } } },
        },
      },
    });
  }

  // Creates a conversation only if one does not already exist between the two users (for the given type).
  static async findOrCreateConversation(
    userA: string,
    userB: string,
    type: ConversationType,
    db: Prisma.TransactionClient | typeof prisma = prisma,
  ) {
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
          include: { user: { select: { id: true, fullName: true } } },
        },
      },
    });

    if (existing) return existing;

    return db.conversation.create({
      data: {
        type,
        participants: {
          create: [{ userId: userA }, { userId: userB }],
        },
      },
      include: {
        participants: {
          include: { user: { select: { id: true, fullName: true } } },
        },
      },
    });
  }

  // ── User's conversation list ───────────────────────────────────────────────

  static getConversations(userId: string) {
    return prisma.conversation.findMany({
      where: { participants: { some: { userId } } },
      include: {
        participants: {
          include: { user: { select: { id: true, fullName: true } } },
        },
        messages: { orderBy: { createdAt: "desc" }, take: 1 },
      },
      orderBy: { updatedAt: "desc" },
    });
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  static getMessages(conversationId: string, page = 1, limit = 50) {
    return prisma.chatMessage.findMany({
      where: { conversationId },
      include: { sender: { select: { id: true, fullName: true } } },
      orderBy: { createdAt: "asc" },
      skip: (page - 1) * limit,
      take: limit,
    });
  }

  // ── Membership check ───────────────────────────────────────────────────────

  static async isParticipant(conversationId: string, userId: string) {
    const row = await prisma.conversationParticipant.findUnique({
      where: { conversationId_userId: { conversationId, userId } },
    });
    return row !== null;
  }

  static async getParticipantIds(conversationId: string): Promise<string[]> {
    const rows = await prisma.conversationParticipant.findMany({
      where: { conversationId },
      select: { userId: true },
    });
    return rows.map((r) => r.userId);
  }

  // ── Persist a message and bump conversation.updatedAt ─────────────────────

  static async saveMessage(data: {
    conversationId: string;
    senderId: string;
    content: string;
  }) {
    return prisma.$transaction(async (tx) => {
      const message = await tx.chatMessage.create({
        data,
        include: { sender: { select: { id: true, fullName: true } } },
      });
      await tx.conversation.update({
        where: { id: data.conversationId },
        data: { updatedAt: new Date() },
      });
      return message;
    });
  }
}
