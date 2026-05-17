import { UserRole } from "../../../generated/prisma";
export interface JwtPayload {
    userId: string;
    role: UserRole;
}
export declare const generateToken: (payload: JwtPayload) => string;
export declare const verifyToken: (token: string) => JwtPayload;
//# sourceMappingURL=jwt.d.ts.map