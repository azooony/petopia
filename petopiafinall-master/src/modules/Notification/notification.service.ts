import { NotificationRepository } from './notification.repository';
import { NotificationGateway } from './notification.socket';
import type {
  CreateNotificationInput,
  NotificationListResult,
} from './notification.types';
import { AppError, HttpCode } from '../../common/errors/AppError';

export class NotificationService {

  static async send(input: CreateNotificationInput) {
    const notification = await NotificationRepository.create({
      userId: input.userId,
      title: input.title,
      body: input.body,
      type: input.type,
      entityId: input.entityId ?? null,
      entityType: input.entityType ?? null,
    });

    NotificationGateway.emitToUser(
      input.userId,
      'notification:new',
      notification,
    );

    return notification;
  }

  static async getMyNotifications(
    userId: string,
    page = 1,
    limit = 20,
  ): Promise<NotificationListResult> {
    const [{ items, total }, unreadCount] = await Promise.all([
      NotificationRepository.findByUser(userId, page, limit),
      NotificationRepository.countUnread(userId),
    ]);

    return {
      notifications: items,
      unreadCount,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 0,
      },
    };
  }

  static async markAsRead(userId: string, id: string) {
    const result = await NotificationRepository.markAsRead(id, userId);

    if (result.count === 0) {
      throw new AppError('Notification not found', HttpCode.NOT_FOUND);
    }
  }

  static async markAllAsRead(userId: string) {
    await NotificationRepository.markAllAsRead(userId);
  }

  static async deleteNotification(userId: string, id: string) {
    const result = await NotificationRepository.delete(id, userId);

    if (result.count === 0) {
      throw new AppError('Notification not found', HttpCode.NOT_FOUND);
    }
  }
}
