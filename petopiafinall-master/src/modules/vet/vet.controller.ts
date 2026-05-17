// src/modules/vets/vet.controller.ts

import { Request, Response, NextFunction } from 'express';
import { VetService } from './vets.service';
import { VerificationStatus } from '../../../generated/prisma';
import { AppError, HttpCode } from '../../common/errors/AppError';

export const uploadCertificate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) {
      throw new AppError('Certificate image is required', HttpCode.BAD_REQUEST);
    }

    const certificateUrl = `${req.protocol}://${req.get('host')}/uploads/certificates/${req.file.filename}`;

    res.status(201).json({
      success: true,
      message: 'Certificate uploaded successfully',
      data: { certificateUrl },
    });
  } catch (error) {
    next(error);
  }
};

// ── 1. Registration ─────────────────────────────────────────────

export const registerVetProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await VetService.registerVet(req.user!.userId, req.body);

    res.status(201).json({
      success: true,
      message: 'Vet profile created successfully. Awaiting admin verification.',
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

// ── 1b. Upload Profile Photo ────────────────────────────────────

export const uploadProfilePhoto = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.file) {
      throw new AppError('Photo file is required', HttpCode.BAD_REQUEST);
    }
    const photoUrl = `${req.protocol}://${req.get('host')}/uploads/vets/${req.file.filename}`;
    await VetService.updateProfile(req.user!.userId, { photo: photoUrl });
    res.status(200).json({ success: true, data: { photoUrl } });
  } catch (error) {
    next(error);
  }
};

// ── 2. Get Own Profile ──────────────────────────────────────────

export const getMyProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await VetService.getProfile(req.user!.userId);

    res.status(200).json({
      success: true,
      message: 'Profile retrieved successfully',
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

// ── 3. Profile Setup / Update ───────────────────────────────────

export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const profile = await VetService.updateProfile(req.user!.userId, req.body);

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

// ── 4. Admin Verification ───────────────────────────────────────

export const verifyVet = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = req.params.id as string;
    const { status } = req.body;

    if (!id) {
      throw new AppError('Vet profile ID is required', HttpCode.BAD_REQUEST);
    }

    if (!status || !['PENDING', 'VERIFIED', 'REJECTED'].includes(status)) {
      throw new AppError('Invalid verification status', HttpCode.BAD_REQUEST);
    }

    const profile = await VetService.verifyVet(id, status as VerificationStatus);

    res.status(200).json({
      success: true,
      message: `Vet verification status updated to ${status}`,
      data: profile,
    });
  } catch (error) {
    next(error);
  }
};

// ── 5. Availability Slots ───────────────────────────────────────

export const addAvailabilitySlot = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const slot = await VetService.addAvailabilitySlot(req.user!.userId, req.body);

    res.status(201).json({
      success: true,
      message: 'Availability slot added successfully',
      data: slot,
    });
  } catch (error) {
    next(error);
  }
};

export const getAvailabilitySlots = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const slots = await VetService.getAvailabilitySlots(req.user!.userId);

    res.status(200).json({
      success: true,
      message: 'Availability slots retrieved successfully',
      data: slots,
    });
  } catch (error) {
    next(error);
  }
};

export const updateAvailabilitySlot = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const slotId = req.params.slotId as string;

    if (!slotId) {
      throw new AppError('Slot ID is required', HttpCode.BAD_REQUEST);
    }

    const slot = await VetService.updateAvailabilitySlot(req.user!.userId, slotId, req.body);

    res.status(200).json({
      success: true,
      message: 'Availability slot updated successfully',
      data: slot,
    });
  } catch (error) {
    next(error);
  }
};

export const deleteAvailabilitySlot = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const slotId = req.params.slotId as string;

    if (!slotId) {
      throw new AppError('Slot ID is required', HttpCode.BAD_REQUEST);
    }

    await VetService.deleteAvailabilitySlot(req.user!.userId, slotId);

    res.status(200).json({
      success: true,
      message: 'Availability slot deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// ── 6. Appointment Dashboard ────────────────────────────────────

export const getUpcomingAppointments = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const appointments = await VetService.getUpcomingAppointments(req.user!.userId);

    res.status(200).json({
      success: true,
      message: 'Upcoming appointments retrieved successfully',
      data: appointments,
    });
  } catch (error) {
    next(error);
  }
};

export const completeAppointment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const appointmentId = req.params.id as string;
    if (!appointmentId) {
      throw new AppError('Appointment ID is required', HttpCode.BAD_REQUEST);
    }
    const { diagnosis, treatment, notes } = req.body as {
      diagnosis?: string;
      treatment?: string;
      notes?: string;
    };
    const result = await VetService.completeAppointment(req.user!.userId, appointmentId, {
      ...(diagnosis  !== undefined && { diagnosis }),
      ...(treatment  !== undefined && { treatment }),
      ...(notes      !== undefined && { notes }),
    });
    res.status(200).json({
      success: true,
      message: 'Appointment marked as completed',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
