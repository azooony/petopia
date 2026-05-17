"use strict";
// src/modules/vets/vets.service.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.VetService = void 0;
const AppError_1 = require("../../common/errors/AppError");
const prisma_1 = require("../../../generated/prisma");
const vets_repository_1 = require("./vets.repository");
class VetService {
    static parseYearsOfExperience(value) {
        const yearsOfExperience = Number(value);
        if (!Number.isInteger(yearsOfExperience) || yearsOfExperience < 0) {
            throw new AppError_1.AppError('yearsOfExperience must be a non-negative integer', AppError_1.HttpCode.BAD_REQUEST);
        }
        return yearsOfExperience;
    }
    static parseAppointmentPrice(value) {
        if (value === undefined)
            return 0;
        const price = Number(value);
        if (!Number.isFinite(price) || price < 0) {
            throw new AppError_1.AppError('appointmentPrice must be a non-negative number', AppError_1.HttpCode.BAD_REQUEST);
        }
        return price;
    }
    static validateTime(value, fieldName, fallback) {
        const time = value ?? fallback;
        if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(time)) {
            throw new AppError_1.AppError(`${fieldName} must use HH:mm format`, AppError_1.HttpCode.BAD_REQUEST);
        }
        return time;
    }
    static toMinutes(time) {
        const [hour, minute] = time.split(':').map(Number);
        return hour * 60 + minute;
    }
    static validateProfileHours(startTime, endTime) {
        const start = this.validateTime(startTime, 'startTime', '09:00');
        const end = this.validateTime(endTime, 'endTime', '17:00');
        const startMinutes = this.toMinutes(start);
        const endMinutes = this.toMinutes(end);
        if (endMinutes <= startMinutes) {
            throw new AppError_1.AppError('endTime must be after startTime', AppError_1.HttpCode.BAD_REQUEST);
        }
        return { startTime: start, endTime: end };
    }
    static validateAvailabilityWithinProfileHours(slotStart, slotEnd, profileStartTime, profileEndTime) {
        const slotStartMinutes = slotStart.getUTCHours() * 60 + slotStart.getUTCMinutes();
        const slotEndMinutes = slotEnd.getUTCHours() * 60 + slotEnd.getUTCMinutes();
        const startMinutes = this.toMinutes(profileStartTime);
        const endMinutes = this.toMinutes(profileEndTime);
        if (slotStartMinutes < startMinutes || slotEndMinutes > endMinutes) {
            throw new AppError_1.AppError('Availability slot must be within vet profile hours', AppError_1.HttpCode.BAD_REQUEST);
        }
    }
    // ── 1. Registration ─────────────────────────────────────────
    static async registerVet(userId, dto) {
        // Prevent duplicate profiles
        const existing = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (existing) {
            throw new AppError_1.AppError('Vet profile already exists for this user', AppError_1.HttpCode.BAD_REQUEST);
        }
        // Validate certificate URL
        if (!dto.certificateUrl || !dto.certificateUrl.startsWith('http')) {
            throw new AppError_1.AppError('A valid certificate URL is required', AppError_1.HttpCode.BAD_REQUEST);
        }
        // Validate clinic exists
        const clinic = await vets_repository_1.VetRepository.findClinicById(dto.clinicId);
        if (!clinic) {
            throw new AppError_1.AppError('The selected clinic does not exist', AppError_1.HttpCode.BAD_REQUEST);
        }
        const profileHours = this.validateProfileHours(dto.startTime, dto.endTime);
        const profile = await vets_repository_1.VetRepository.createVetProfile({
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
    static async updateProfile(userId, dto) {
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile) {
            throw new AppError_1.AppError('Vet profile not found', AppError_1.HttpCode.NOT_FOUND);
        }
        if (profile.verificationStatus === prisma_1.VerificationStatus.REJECTED) {
            throw new AppError_1.AppError('Cannot update profile — your account has been rejected', AppError_1.HttpCode.FORBIDDEN);
        }
        // Build the update payload (only vet-profile-level fields)
        const updateData = {};
        if (dto.phone !== undefined)
            updateData.phone = dto.phone;
        if (dto.description !== undefined)
            updateData.description = dto.description;
        if (dto.specialization !== undefined)
            updateData.specialization = dto.specialization;
        if (dto.photo !== undefined)
            updateData.photo = dto.photo;
        if (dto.firstName !== undefined)
            updateData.firstName = dto.firstName;
        if (dto.surname !== undefined)
            updateData.surname = dto.surname;
        if (dto.yearsOfExperience !== undefined) {
            updateData.yearsOfExperience = this.parseYearsOfExperience(dto.yearsOfExperience);
        }
        if (dto.appointmentPrice !== undefined) {
            updateData.appointmentPrice = this.parseAppointmentPrice(dto.appointmentPrice);
        }
        if (dto.startTime !== undefined || dto.endTime !== undefined) {
            const profileHours = this.validateProfileHours(dto.startTime ?? profile.startTime, dto.endTime ?? profile.endTime);
            updateData.startTime = profileHours.startTime;
            updateData.endTime = profileHours.endTime;
        }
        const updatedProfile = await vets_repository_1.VetRepository.updateVetProfile(userId, updateData);
        // Handle clinic address separately (lives on the Clinic model)
        if (dto.clinicAddress) {
            await vets_repository_1.VetRepository.updateClinicAddress(profile.clinicId, dto.clinicAddress);
        }
        return updatedProfile;
    }
    // ── 3. Get Own Profile ──────────────────────────────────────
    static async getProfile(userId) {
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile) {
            throw new AppError_1.AppError('Vet profile not found', AppError_1.HttpCode.NOT_FOUND);
        }
        return profile;
    }
    // ── 4. Verification (admin) ─────────────────────────────────
    static async verifyVet(profileId, status) {
        const profile = await vets_repository_1.VetRepository.findProfileById(profileId);
        if (!profile) {
            throw new AppError_1.AppError('Vet profile not found', AppError_1.HttpCode.NOT_FOUND);
        }
        if (!['PENDING', 'VERIFIED', 'REJECTED'].includes(status)) {
            throw new AppError_1.AppError('Invalid verification status', AppError_1.HttpCode.BAD_REQUEST);
        }
        return vets_repository_1.VetRepository.updateVerificationStatus(profileId, status);
    }
    // ── 5. Availability Slots ──────────────────────────────────
    static async addAvailabilitySlot(userId, dto) {
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile) {
            throw new AppError_1.AppError('Vet profile not found', AppError_1.HttpCode.NOT_FOUND);
        }
        if (profile.verificationStatus !== prisma_1.VerificationStatus.VERIFIED) {
            throw new AppError_1.AppError('Only verified vets can manage availability slots', AppError_1.HttpCode.FORBIDDEN);
        }
        const clinicId = dto.clinicId || profile.clinicId;
        const clinic = await vets_repository_1.VetRepository.findClinicById(clinicId);
        if (!clinic) {
            throw new AppError_1.AppError('The selected clinic does not exist', AppError_1.HttpCode.BAD_REQUEST);
        }
        const startTime = new Date(dto.startTime);
        const endTime = new Date(dto.endTime);
        if (isNaN(startTime.getTime()) || isNaN(endTime.getTime())) {
            throw new AppError_1.AppError('Invalid date format for startTime or endTime', AppError_1.HttpCode.BAD_REQUEST);
        }
        if (endTime <= startTime) {
            throw new AppError_1.AppError('endTime must be after startTime', AppError_1.HttpCode.BAD_REQUEST);
        }
        this.validateAvailabilityWithinProfileHours(startTime, endTime, profile.startTime, profile.endTime);
        return vets_repository_1.VetRepository.createAvailabilitySlot({
            vetId: userId,
            clinicId,
            startTime,
            endTime,
        });
    }
    static async getAvailabilitySlots(userId) {
        return vets_repository_1.VetRepository.findSlotsByVetId(userId);
    }
    static async updateAvailabilitySlot(userId, slotId, dto) {
        const slot = await vets_repository_1.VetRepository.findSlotById(slotId);
        if (!slot) {
            throw new AppError_1.AppError('Availability slot not found', AppError_1.HttpCode.NOT_FOUND);
        }
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile || profile.verificationStatus !== prisma_1.VerificationStatus.VERIFIED) {
            throw new AppError_1.AppError('Only verified vets can manage availability slots', AppError_1.HttpCode.FORBIDDEN);
        }
        if (slot.vetId !== userId) {
            throw new AppError_1.AppError('You can only update your own slots', AppError_1.HttpCode.FORBIDDEN);
        }
        const updateData = {};
        if (dto.startTime !== undefined)
            updateData.startTime = new Date(dto.startTime);
        if (dto.endTime !== undefined)
            updateData.endTime = new Date(dto.endTime);
        if (dto.isActive !== undefined)
            updateData.isActive = dto.isActive;
        if ((updateData.startTime && isNaN(updateData.startTime.getTime())) ||
            (updateData.endTime && isNaN(updateData.endTime.getTime()))) {
            throw new AppError_1.AppError('Invalid date format for startTime or endTime', AppError_1.HttpCode.BAD_REQUEST);
        }
        // Validate times if both are provided or partially updated
        const newStart = updateData.startTime || slot.startTime;
        const newEnd = updateData.endTime || slot.endTime;
        if (newEnd <= newStart) {
            throw new AppError_1.AppError('endTime must be after startTime', AppError_1.HttpCode.BAD_REQUEST);
        }
        this.validateAvailabilityWithinProfileHours(newStart, newEnd, profile.startTime, profile.endTime);
        return vets_repository_1.VetRepository.updateAvailabilitySlot(slotId, updateData);
    }
    static async deleteAvailabilitySlot(userId, slotId) {
        const slot = await vets_repository_1.VetRepository.findSlotById(slotId);
        if (!slot) {
            throw new AppError_1.AppError('Availability slot not found', AppError_1.HttpCode.NOT_FOUND);
        }
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile || profile.verificationStatus !== prisma_1.VerificationStatus.VERIFIED) {
            throw new AppError_1.AppError('Only verified vets can manage availability slots', AppError_1.HttpCode.FORBIDDEN);
        }
        if (slot.vetId !== userId) {
            throw new AppError_1.AppError('You can only delete your own slots', AppError_1.HttpCode.FORBIDDEN);
        }
        return vets_repository_1.VetRepository.deleteAvailabilitySlot(slotId);
    }
    // ── 6. Appointment Dashboard ───────────────────────────────
    static async getUpcomingAppointments(userId) {
        const profile = await vets_repository_1.VetRepository.findProfileByUserId(userId);
        if (!profile) {
            throw new AppError_1.AppError('Vet profile not found', AppError_1.HttpCode.NOT_FOUND);
        }
        return vets_repository_1.VetRepository.findUpcomingAppointments(userId);
    }
}
exports.VetService = VetService;
//# sourceMappingURL=vets.service.js.map