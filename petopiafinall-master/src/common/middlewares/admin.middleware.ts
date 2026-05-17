import { Request, Response, NextFunction } from 'express';
import { AppError, HttpCode } from '../errors/AppError';
import { UserRole } from '../../../generated/prisma'; // Use your generated Enum

export const isAdmin = (req: Request, res: Response, next: NextFunction) => {
  // Assuming your auth middleware populates req.user
  if (req.user?.role !== UserRole.ADMIN) {
    throw new AppError('Access denied: Admins only', HttpCode.FORBIDDEN);
  }
  next();
};