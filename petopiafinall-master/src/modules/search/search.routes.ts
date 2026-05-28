import { Router } from 'express';
import { protect } from '../../common/middlewares/auth.middleware';
import { search } from './search.controller';

const router = Router();

// GET /search?q=<query>
router.get('/', protect, search);

export default router;
