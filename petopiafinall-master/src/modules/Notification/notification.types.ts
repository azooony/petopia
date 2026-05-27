import type { Notification } from '../../../generated/prisma';
import {
  NotificationEntityType,
  NotificationType,
} from '../../../generated/prisma';

export interface CreateNotificationInput {
  userId: string;
  title: string;
  body: string;
  type: NotificationType;
  entityId?: string;
  entityType?: NotificationEntityType;
}

export interface NotificationListResult {
  notifications: Notification[];
  unreadCount: number;
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
