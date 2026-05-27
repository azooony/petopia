import { Router } from 'express';
import { protect } from '../../common/middlewares/auth.middleware';
import { NotificationController } from './notification.controller';

const router = Router();

router.use(protect);

router.get('/', NotificationController.getMyNotifications);

// Must be registered before /:id/read so "read-all" is not captured as an id
router.patch('/read-all', NotificationController.markAllAsRead);

router.patch('/:id/read', NotificationController.markAsRead);

router.delete('/:id', NotificationController.deleteNotification);

export default router;
