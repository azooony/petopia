import { z } from 'zod';

export const GetNotificationsSchema = z.object({
  page: z.coerce.number().min(1).default(1),

  limit: z.coerce.number().min(1).max(50).default(20),
});

export type GetNotificationsInput =
  z.infer<typeof GetNotificationsSchema>;

export const NotificationIdSchema = z.object({
  id: z.string().cuid(),
});

export type NotificationIdInput =
  z.infer<typeof NotificationIdSchema>;