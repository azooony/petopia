"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatController = void 0;
const AppError_1 = require("../../common/errors/AppError");
const chat_service_1 = require("./chat.service");
const chat_dto_1 = require("./chat.dto");
class ChatController {
    // POST /chat/initiate
    static initiate = async (req, res, next) => {
        try {
            const result = chat_dto_1.InitiateConversationSchema.safeParse(req.body);
            if (!result.success) {
                return next(new AppError_1.AppError(result.error.issues[0]?.message ?? "Invalid input", AppError_1.HttpCode.BAD_REQUEST));
            }
            const { targetUserId, context } = result.data;
            const conversation = await chat_service_1.ChatService.initiateConversation(req.user.userId, targetUserId, context);
            res.status(200).json({
                success: true,
                message: "Conversation ready.",
                data: conversation,
                error: null,
            });
        }
        catch (err) {
            next(err);
        }
    };
    // GET /chat/conversations
    static getConversations = async (req, res, next) => {
        try {
            const conversations = await chat_service_1.ChatService.getMyConversations(req.user.userId);
            res.status(200).json({
                success: true,
                message: "Conversations retrieved.",
                data: conversations,
                error: null,
            });
        }
        catch (err) {
            next(err);
        }
    };
    // DELETE /chat/conversations/:conversationId
    static deleteConversation = async (req, res, next) => {
        try {
            const conversationId = req.params['conversationId'];
            if (!conversationId) {
                return next(new AppError_1.AppError("conversationId is required.", AppError_1.HttpCode.BAD_REQUEST));
            }
            await chat_service_1.ChatService.deleteConversation(req.user.userId, conversationId);
            res.status(200).json({ success: true, message: "Conversation deleted.", data: null, error: null });
        }
        catch (err) {
            next(err);
        }
    };
    // GET /chat/conversations/:conversationId/messages
    static getMessages = async (req, res, next) => {
        try {
            const rawId = req.params['conversationId'];
            const conversationId = typeof rawId === 'string' ? rawId : '';
            if (!conversationId) {
                return next(new AppError_1.AppError("conversationId is required.", AppError_1.HttpCode.BAD_REQUEST));
            }
            const query = chat_dto_1.GetMessagesQuerySchema.safeParse(req.query);
            if (!query.success) {
                return next(new AppError_1.AppError(query.error.issues[0]?.message ?? "Invalid query", AppError_1.HttpCode.BAD_REQUEST));
            }
            const messages = await chat_service_1.ChatService.getMessages(req.user.userId, conversationId, query.data.page, query.data.limit);
            res.status(200).json({
                success: true,
                message: "Messages retrieved.",
                data: messages,
                error: null,
            });
        }
        catch (err) {
            next(err);
        }
    };
}
exports.ChatController = ChatController;
//# sourceMappingURL=chat.controller.js.map