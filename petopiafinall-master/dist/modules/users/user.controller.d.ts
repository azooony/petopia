import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
export declare class UserController {
    static getMe: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static updateProfile: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static updatePassword: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static deleteProfile: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=user.controller.d.ts.map