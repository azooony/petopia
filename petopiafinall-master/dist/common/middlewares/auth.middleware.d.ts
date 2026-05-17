import { Request, Response, NextFunction } from "express";
import { UserRole } from "../../../generated/prisma";
import { JwtPayload } from "../utils/jwt";
export interface AuthRequest extends Request {
    user?: JwtPayload;
}
export declare const protect: (req: Request, _res: Response, next: NextFunction) => void;
export declare const restrictTo: (...roles: UserRole[]) => (req: Request, _res: Response, next: NextFunction) => void;
declare const _default: {
    protect: (req: Request, _res: Response, next: NextFunction) => void;
    restrictTo: (...roles: UserRole[]) => (req: Request, _res: Response, next: NextFunction) => void;
};
export default _default;
//# sourceMappingURL=auth.middleware.d.ts.map