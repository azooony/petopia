import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/jwt";
import { UserRole } from "../../../generated/prisma";
import { AppError, HttpCode } from "../errors/AppError";
import { JwtPayload } from "../utils/jwt";

// Convenience type alias used by controllers that need the authenticated user.
export interface AuthRequest extends Request {
  user?: JwtPayload;
}

// Verifies the Bearer token and attaches the decoded payload to req.user.
export const protect = (req: Request, _res: Response, next: NextFunction): void => {
  const header = req.headers.authorization;

  if (!header || !header.startsWith("Bearer ")) {
    return next(new AppError("Unauthorized", HttpCode.UNAUTHORIZED));
  }

  const token = header.split(" ")[1];

  if (!token) {
    return next(new AppError("Unauthorized", HttpCode.UNAUTHORIZED));
  }

  try {
    req.user = verifyToken(token);
    next();
  } catch {
    return next(new AppError("Invalid or expired token", HttpCode.UNAUTHORIZED));
  }
};

// Guards a route to one or more roles. Must be used after `protect`.
export const restrictTo = (...roles: UserRole[]) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role as UserRole)) {
      return next(
        new AppError("You do not have permission to perform this action", HttpCode.FORBIDDEN)
      );
    }
    next();
  };
};

export default { protect, restrictTo };