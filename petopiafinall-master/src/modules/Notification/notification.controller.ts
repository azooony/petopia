import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../common/middlewares/auth.middleware';
import { AppError, HttpCode } from '../../common/errors/AppError';
import { NotificationService } from './notification.service';
import {
  GetNotificationsSchema,
  NotificationIdSchema,
} from './notification.dto';

export class NotificationController {

  static getMyNotifications = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      if (!req.user?.userId) {
        throw new AppError('Unauthorized', HttpCode.UNAUTHORIZED);
      }

      const parsed = GetNotificationsSchema.safeParse(req.query);
      if (!parsed.success) {
        res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: 'Validation failed',
          error: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const data = await NotificationService.getMyNotifications(
        req.user.userId,
        parsed.data.page,
        parsed.data.limit,
      );

      res.json({
        success: true,
        message: 'Notifications retrieved successfully',
        data: data.notifications,
        meta: {
          unreadCount: data.unreadCount,
          ...data.meta,
        },
      });
    } catch (err) {
      next(err);
    }
  };

  static markAsRead = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      if (!req.user?.userId) {
        throw new AppError('Unauthorized', HttpCode.UNAUTHORIZED);
      }

      const parsed = NotificationIdSchema.safeParse(req.params);
      if (!parsed.success) {
        res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: 'Validation failed',
          error: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      await NotificationService.markAsRead(
        req.user.userId,
        parsed.data.id,
      );

      res.json({
        success: true,
        message: 'Notification marked as read',
      });
    } catch (err) {
      next(err);
    }
  };

  static markAllAsRead = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      if (!req.user?.userId) {
        throw new AppError('Unauthorized', HttpCode.UNAUTHORIZED);
      }

      await NotificationService.markAllAsRead(req.user.userId);

      res.json({
        success: true,
        message: 'All notifications marked as read',
      });
    } catch (err) {
      next(err);
    }
  };

  static deleteNotification = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    try {
      if (!req.user?.userId) {
        throw new AppError('Unauthorized', HttpCode.UNAUTHORIZED);
      }

      const parsed = NotificationIdSchema.safeParse(req.params);
      if (!parsed.success) {
        res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: 'Validation failed',
          error: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      await NotificationService.deleteNotification(
        req.user.userId,
        parsed.data.id,
      );

      res.json({
        success: true,
        message: 'Notification deleted',
      });
    } catch (err) {
      next(err);
    }
  };
}
