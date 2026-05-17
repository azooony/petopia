import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { ChatService } from "./chat.service";
import { ConversationType } from "../../../generated/prisma";
import {
  InitiateConversationSchema,
  GetMessagesQuerySchema,
} from "./chat.dto";

export class ChatController {

  // POST /chat/initiate
  static initiate = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const result = InitiateConversationSchema.safeParse(req.body);
      if (!result.success) {
        return next(new AppError(result.error.issues[0]?.message ?? "Invalid input", HttpCode.BAD_REQUEST));
      }

      const { targetUserId, context } = result.data;

      const conversation = await ChatService.initiateConversation(
        req.user!.userId,
        targetUserId,
        context as ConversationType,
      );

      res.status(200).json({
        success: true,
        message: "Conversation ready.",
        data: conversation,
        error: null,
      });
    } catch (err) {
      next(err);
    }
  };

  // GET /chat/conversations
  static getConversations = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const conversations = await ChatService.getMyConversations(req.user!.userId);

      res.status(200).json({
        success: true,
        message: "Conversations retrieved.",
        data: conversations,
        error: null,
      });
    } catch (err) {
      next(err);
    }
  };

  // GET /chat/conversations/:conversationId/messages
  static getMessages = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const rawId = req.params['conversationId'];
      const conversationId = typeof rawId === 'string' ? rawId : '';
      if (!conversationId) {
        return next(new AppError("conversationId is required.", HttpCode.BAD_REQUEST));
      }

      const query = GetMessagesQuerySchema.safeParse(req.query);
      if (!query.success) {
        return next(new AppError(query.error.issues[0]?.message ?? "Invalid query", HttpCode.BAD_REQUEST));
      }

      const messages = await ChatService.getMessages(
        req.user!.userId,
        conversationId,
        query.data.page,
        query.data.limit,
      );

      res.status(200).json({
        success: true,
        message: "Messages retrieved.",
        data: messages,
        error: null,
      });
    } catch (err) {
      next(err);
    }
  };
}
