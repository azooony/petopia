import prisma from "../../config/prisma";
import { ConversationType, Prisma } from "../../../generated/prisma";
export declare class ChatRepository {
    static findConversationBetween(userA: string, userB: string, type?: ConversationType): Prisma.Prisma__ConversationClient<({
        messages: {
            id: string;
            createdAt: Date;
            conversationId: string;
            senderId: string;
            assetId: string | null;
            readAt: Date | null;
            content: string | null;
        }[];
        participants: ({
            user: {
                id: string;
                fullName: string;
                profilePicture: string | null;
            };
        } & {
            id: string;
            userId: string;
            conversationId: string;
        })[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }) | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static createConversation(userA: string, userB: string, type: ConversationType, db?: Prisma.TransactionClient | typeof prisma): Prisma.Prisma__ConversationClient<{
        participants: ({
            user: {
                id: string;
                fullName: string;
                profilePicture: string | null;
            };
        } & {
            id: string;
            userId: string;
            conversationId: string;
        })[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, Prisma.PrismaClientOptions>;
    static findOrCreateConversation(userA: string, userB: string, type: ConversationType, db?: Prisma.TransactionClient | typeof prisma): Promise<{
        participants: ({
            user: {
                id: string;
                fullName: string;
                profilePicture: string | null;
            };
        } & {
            id: string;
            userId: string;
            conversationId: string;
        })[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }>;
    static getConversations(userId: string): Prisma.PrismaPromise<({
        messages: {
            id: string;
            createdAt: Date;
            conversationId: string;
            senderId: string;
            assetId: string | null;
            readAt: Date | null;
            content: string | null;
        }[];
        participants: ({
            user: {
                id: string;
                fullName: string;
                profilePicture: string | null;
            };
        } & {
            id: string;
            userId: string;
            conversationId: string;
        })[];
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    })[]>;
    static getMessages(conversationId: string, page?: number, limit?: number): Prisma.PrismaPromise<({
        sender: {
            id: string;
            fullName: string;
            profilePicture: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        conversationId: string;
        senderId: string;
        assetId: string | null;
        readAt: Date | null;
        content: string | null;
    })[]>;
    static isParticipant(conversationId: string, userId: string): Promise<boolean>;
    static getParticipantIds(conversationId: string): Promise<string[]>;
    static deleteConversation(conversationId: string): Prisma.Prisma__ConversationClient<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static saveMessage(data: {
        conversationId: string;
        senderId: string;
        content: string;
    }): Promise<{
        sender: {
            id: string;
            fullName: string;
            profilePicture: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        conversationId: string;
        senderId: string;
        assetId: string | null;
        readAt: Date | null;
        content: string | null;
    }>;
}
//# sourceMappingURL=chat.repository.d.ts.map