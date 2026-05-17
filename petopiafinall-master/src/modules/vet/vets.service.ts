// src/modules/vets/vets.service.ts

import { AppError, HttpCode } from '../../common/errors/AppError';
import { VerificationStatus } from '../../../generated/prisma';
import { VetRepository } from './vets.repository';
import {
  RegisterVetDto,
  UpdateVetProfileDto,
  AddAvailabilitySlotDto,
  UpdateAvailabilitySlotDto,
} from './vets.dto';

export class VetService {
  private static parseYearsOfExperience(value: number | string) {
    const yearsOfExperience = Number(value);
    if (!Number.isInteger(yearsOfExperience) || yearsOfExperience < 0) {
      throw new AppError('yearsOfExperience must be a non-negative integer', HttpCode.BAD_REQUEST);
    }

    return yearsOfExperience;
  }

  private static parseAppointmentPrice(value: number | string | undefined) {
    if (value === undefined) return 0;

    const price = Number(value);
    if (!Number.isFinite(price) || price < 0) {
      throw new AppError('appointmentPrice must be a non-negative number', HttpCode.BAD_REQUEST);
    }

    return price;
  }

  private static validateTime(value: string | undefined, fieldName: string, fallback: string) {
    const time = value ?? fallback;
    if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(time)) {
      throw new AppError(`${fieldName} must use HH:mm format`, HttpCode.BAD_REQUEST);
    }

    return time;
  }

  private static toMinutes(time: string) {
    const [hour, minute] = time.split(':').map(Number) as [number, number];
    return hour * 60 + minute;
  }

  private static validateProfileHours(startTime: string | undefined, endTime: string | undefined) {
    const start = this.validateTime(startTime, 'startTime', '09:00');
    const end = this.validateTime(endTime, 'endTime', '17:00');
    const startMinutes = this.toMinutes(start);
    const endMinutes = this.toMinutes(end);

    if (endMinutes <= startMinutes) {
      throw new AppError('endTime must be after startTime', HttpCode.BAD_REQUEST);
    }

    return { startTime: start, endTime: end };
  }

  private static validateAvailabilityWithinProfileHours(
    slotStart: Date,
    slotEnd: Date,
    profileStartTime: string,
    profileEndTime: string,
  ) {
    const slotStartMinutes = slotStart.getUTCHours() * 60 + slotStart.getUTCMinutes();
    const slotEndMinutes = slotEnd.getUTCHours() * 60 + slotEnd.getUTCMinutes();
    const startMinutes = this.toMinutes(profileStartTime);
    const endMinutes = this.toMinutes(profileEndTime);

    if (slotStartMinutes < startMinutes || slotEndMinutes > endMinutes) {
      throw new AppError('Availability slot must be within vet profile hours', HttpCode.BAD_REQUEST);
    }
  }

  // ── 1. Registration ─────────────────────────────────────────

  static async registerVet(userId: string, dto: RegisterVetDto) {
    // Prevent duplicate profiles
    const existing = await VetRepository.findProfileByUserId(userId);
    if (existing) {
      throw new AppError('Vet profile already exists for this user', HttpCode.BAD_REQUEST);
    }

    // Validate certificate URL
    if (!dto.certificateUrl || !dto.certificateUrl.startsWith('http')) {
      throw new AppError('A valid certificate URL is required', HttpCode.BAD_REQUEST);
    }

    // Validate clinic exists
    const clinic = await VetRepository.findClinicById(dto.clinicId);
    if (!clinic) {
      throw new AppError('The selected clinic does not exist', HttpCode.BAD_REQUEST);
    }

    const profileHours = this.validateProfileHours(dto.startTime, dto.endTime);

    const profile = await VetRepository.createVetProfile({
      userId,
      phone: dto.phone,
      certificateImage: dto.certificateUrl,
      yearsOfExperience: this.parseYearsOfExperience(dto.yearsOfExperience),
      appointmentPrice: this.parseAppointmentPrice(dto.appointmentPrice),
      startTime: profileHours.startTime,
      endTime: profileHours.endTime,
      clinicId: dto.clinicId,
    });

    return profile;
  }

  // ── 2. Profile Setup / Update ───────────────────────────────

  static async updateProfile(userId: string, dto: UpdateVetProfileDto) {
    const profile = await VetRepository.findProfileByUserId(userId);

    if (!profile) {
      throw new AppError('Vet profile not found', HttpCode.NOT_FOUND);
    }

    if (profile.verificationStatus === VerificationStatus.REJECTED) {
      throw new AppError(
        'Cannot update profile — your account has been rejected',
        HttpCode.FORBIDDEN,
      );
    }

    // Build the update payload (only vet-profile-level fields)
    const updateData: Record<string, any> = {};
    if (dto.phone !== undefined) updateData.phone = dto.phone;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.specialization !== undefined) updateData.specialization = dto.specialization;
    if (dto.photo !== undefined) updateData.photo = dto.photo;
    if (dto.firstName !== undefined) updateData.firstName = dto.firstName;
    if (dto.surname !== undefined) updateData.surname = dto.surname;
    if (dto.yearsOfExperience !== undefined) {
      updateData.yearsOfExperience = this.parseYearsOfExperience(dto.yearsOfExperience);
    }
    if (dto.appointmentPrice !== undefined) {
      updateData.appointmentPrice = this.parseAppointmentPrice(dto.appointmentPrice);
    }
    if (dto.startTime !== undefined || dto.endTime !== undefined) {
      const profileHours = this.validateProfileHours(
        dto.startTime ?? profile.startTime,
        dto.endTime ?? profile.endTime,
      );
      updateData.startTime = profileHours.startTime;
      updateData.endTime = profileHours.endTime;
    }

    const updatedProfile = await VetRepository.updateVetProfile(userId, updateData);

    // Handle clinic address separately (lives on the Clinic model)
    if (dto.clinicAddress) {
      await VetRepository.updateClinicAddress(profile.clinicId, dto.clinicAddress);
    }

    return updatedProfile;
  }

  // ── 3. Get Own Profile ──────────────────────────────────────

  static async getProfile(userId: string) {
    const profile = await VetRepository.findProfileByUserId(userId);

    if (!profile) {
      throw new AppError('Vet profile not found', HttpCode.NOT_FOUND);
    }

    return profile;
  }

  // ── 4. Verification (admin) ─────────────────────────────────

  static async verifyVet(profileId: string, status: VerificationStatus) {
    const profile = await VetRepository.findProfileById(profileId);

    if (!profile) {
      throw new AppError('Vet profile not found', HttpCode.NOT_FOUND);
    }

    if (!['PENDING', 'VERIFIED', 'REJECTED'].includes(status)) {
      throw new AppError('Invalid verification status', HttpCode.BAD_REQUEST);
    }

    return VetRepository.updateVerificationStatus(profileId, status);
  }

  // ── 5. Availability Slots ──────────────────────────────────

  static async addAvailabilitySlot(userId: string, dto: AddAvailabilitySlotDto) {
    const profile = await VetRepository.findProfileByUserId(userId);

    if (!profile) {
      throw new AppError('Vet profile not found', HttpCode.NOT_FOUND);
    }

    if (profile.verificationStatus !== VerificationStatus.VERIFIED) {
      throw new AppError(
        'Only verified vets can manage availability slots',
        HttpCode.FORBIDDEN,
      );
    }

    const clinicId = dto.clinicId || profile.clinicId;
    const clinic = await VetRepository.findClinicById(clinicId);
    if (!clinic) {
      throw new AppError('The selected clinic does not exist', HttpCode.BAD_REQUEST);
    }

    const startTime = new Date(dto.startTime);
    const endTime = new Date(dto.endTime);

    if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) {
      throw new AppError('Invalid date format for startTime or endTime', HttpCode.BAD_REQUEST);
    }

    if (endTime <= startTime) {
      throw new AppError('endTime must be after startTime', HttpCode.BAD_REQUEST);
    }

    this.validateAvailabilityWithinProfileHours(
      startTime,
      endTime,
      profile.startTime,
      profile.endTime,
    );

    return VetRepository.createAvailabilitySlot({
      vetId: userId,
      clinicId,
      startTime,
      endTime,
    });
  }

  static async getAvailabilitySlots(userId: string) {
    return VetRepository.findSlotsByVetId(userId);
  }

  static async updateAvailabilitySlot(
    userId: string,
    slotId: string,
    dto: UpdateAvailabilitySlotDto,
  ) {
    const slot = await VetRepository.findSlotById(slotId);

    if (!slot) {
      throw new AppError('Availability slot not found', HttpCode.NOT_FOUND);
    }

    const profile = await VetRepository.findProfileByUserId(userId);
    if (!profile || profile.verificationStatus !== VerificationStatus.VERIFIED) {
      throw new AppError('Only verified vets can manage availability slots', HttpCode.FORBIDDEN);
    }

    if (slot.vetId !== userId) {
      throw new AppError('You can only update your own slots', HttpCode.FORBIDDEN);
    }

    const updateData: Record<string, any> = {};
    if (dto.startTime !== undefined) updateData.startTime = new Date(dto.startTime);
    if (dto.endTime !== undefined) updateData.endTime = new Date(dto.endTime);
    if (dto.isActive !== undefined) updateData.isActive = dto.isActive;

    if (
      (updateData.startTime && isNaN(updateData.startTime.getTime())) ||
      (updateData.endTime && isNaN(updateData.endTime.getTime()))
    ) {
      throw new AppError('Invalid date format for startTime or endTime', HttpCode.BAD_REQUEST);
    }

    // Validate times if both are provided or partially updated
    const newStart = updateData.startTime || slot.startTime;
    const newEnd = updateData.endTime || slot.endTime;
    if (newEnd <= newStart) {
      throw new AppError('endTime must be after startTime', HttpCode.BAD_REQUEST);
    }

    this.validateAvailabilityWithinProfileHours(
      newStart,
      newEnd,
      profile.startTime,
      profile.endTime,
    );

    return VetRepository.updateAvailabilitySlot(slotId, updateData);
  }

  static async deleteAvailabilitySlot(userId: string, slotId: string) {
    const slot = await VetRepository.findSlotById(slotId);

    if (!slot) {
      throw new AppError('Availability slot not found', HttpCode.NOT_FOUND);
    }

    const profile = await VetRepository.findProfileByUserId(userId);
    if (!profile || profile.verificationStatus !== VerificationStatus.VERIFIED) {
      throw new AppError('Only verified vets can manage availability slots', HttpCode.FORBIDDEN);
    }

    if (slot.vetId !== userId) {
      throw new AppError('You can only delete your own slots', HttpCode.FORBIDDEN);
    }

    return VetRepository.deleteAvailabilitySlot(slotId);
  }

  // ── 6. Appointment Dashboard ───────────────────────────────

  static async getUpcomingAppointments(userId: string) {
    const profile = await VetRepository.findProfileByUserId(userId);

    if (!profile) {
      throw new AppError('Vet profile not found', HttpCode.NOT_FOUND);
    }

    return VetRepository.findUpcomingAppointments(userId);
  }

  static async completeAppointment(
    userId: string,
    appointmentId: string,
    notes: { diagnosis?: string; treatment?: string; notes?: string },
  ) {
    const result = await VetRepository.markAppointmentComplete(appointmentId, userId, notes);
    if (!result) {
      throw new AppError('Appointment not found or does not belong to you', HttpCode.NOT_FOUND);
    }
    return result;
  }
}
