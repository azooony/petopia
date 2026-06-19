import { ConversationType } from "../../../generated/prisma";
export declare class ChatService {
    static initiateConversation(initiatorId: string, targetUserId: string, context: ConversationType): Promise<{
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
    static getMyConversations(userId: string): import("../../../generated/prisma").Prisma.PrismaPromise<({
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
    static deleteConversation(userId: string, conversationId: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }>;
    static getMessages(userId: string, conversationId: string, page: number, limit: number): Promise<({
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
}
//# sourceMappingURL=chat.service.d.ts.map