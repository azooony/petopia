// src/modules/vets/vet.routes.ts

import { Router } from 'express';
import * as vetController from './vet.controller';
import { protect, restrictTo } from '../../common/middlewares/auth.middleware';
import { isAdmin } from '../../common/middlewares/admin.middleware';
import { upload, uploadVet } from '../../common/middlewares/upload.middleware';

const router = Router();

router.post('/certificate', upload.single('certificate'), vetController.uploadCertificate);

// ── Registration ────────────────────────────────────────────────
// POST /vets/register  —  Logged-in VET creates their vet profile
router.post(
  '/register',
  protect,
  restrictTo('VET'),
  vetController.registerVetProfile,
);

// ── Profile ─────────────────────────────────────────────────────
// GET  /vets/profile              —  Get own profile
// PATCH /vets/profile             —  Update profile (name, phone, specialization, clinic address)
// POST  /vets/profile/photo       —  Upload/replace profile photo
router.get('/profile', protect, restrictTo('VET'), vetController.getMyProfile);
router.patch('/profile', protect, restrictTo('VET'), vetController.updateProfile);
router.post('/profile/photo', protect, restrictTo('VET'), uploadVet.single('photo'), vetController.uploadProfilePhoto);

// ── Admin Verification ──────────────────────────────────────────
// PATCH /vets/:id/verify     —  Admin approves/rejects a vet
router.patch('/:id/verify', protect, isAdmin, vetController.verifyVet);

// ── Availability Slots ──────────────────────────────────────────
// POST   /vets/availability             —  Add a new slot
// GET    /vets/availability             —  List all own slots
// PATCH  /vets/availability/:slotId     —  Update a slot
// DELETE /vets/availability/:slotId     —  Delete a slot
router.post('/availability', protect, restrictTo('VET'), vetController.addAvailabilitySlot);
router.get('/availability', protect, restrictTo('VET'), vetController.getAvailabilitySlots);
router.patch('/availability/:slotId', protect, restrictTo('VET'), vetController.updateAvailabilitySlot);
router.delete('/availability/:slotId', protect, restrictTo('VET'), vetController.deleteAvailabilitySlot);

// ── Appointment Dashboard ───────────────────────────────────────
// GET   /vets/appointments        —  Upcoming appointments with pet details
// PATCH /vets/appointments/:id/complete  —  Mark appointment as completed
router.get('/appointments', protect, restrictTo('VET'), vetController.getUpcomingAppointments);
router.patch('/appointments/:id/complete', protect, restrictTo('VET'), vetController.completeAppointment);

export default router;
