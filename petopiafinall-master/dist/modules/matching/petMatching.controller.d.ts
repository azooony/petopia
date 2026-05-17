import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
export declare class PetMatchingController {
    static createProfile: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static updateProfile: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static findMatches: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static sendRequest: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static getIncomingRequests: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static acceptRequest: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static rejectRequest: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=petMatching.controller.d.ts.map