import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
export declare class ChatController {
    static initiate: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static getConversations: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static deleteConversation: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static getMessages: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=chat.controller.d.ts.map