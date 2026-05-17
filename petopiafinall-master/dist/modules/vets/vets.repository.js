"use strict";
// src/modules/vets/vets.repository.ts
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VetRepository = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const prisma_2 = require("../../../generated/prisma");
class VetRepository {
    // ── Registration ──────────────────────────────────────────────
    static async createVetProfile(data) {
        return prisma_1.default.vetProfile.create({
            data: {
                userId: data.userId,
                phone: data.phone,
                certificateImage: data.certificateImage,
                yearsOfExperience: data.yearsOfExperience,
                appointmentPrice: data.appointmentPrice,
                startTime: data.startTime,
                endTime: data.endTime,
                clinicId: data.clinicId,
                verificationStatus: prisma_2.VerificationStatus.PENDING,
            },
            include: { clinic: true },
        });
    }
    // ── Profile Queries ───────────────────────────────────────────
    static async findProfileByUserId(userId) {
        return prisma_1.default.vetProfile.findUnique({
            where: { userId },
            include: { clinic: true, user: true },
        });
    }
    static async findProfileById(profileId) {
        return prisma_1.default.vetProfile.findUnique({
            where: { id: profileId },
            include: { clinic: true, user: true },
        });
    }
    static async updateVetProfile(userId, data) {
        return prisma_1.default.vetProfile.update({
            where: { userId },
            data,
            include: { clinic: true, user: true },
        });
    }
    static async updateClinicAddress(clinicId, address) {
        return prisma_1.default.clinic.update({
            where: { id: clinicId },
            data: { address },
        });
    }
    // ── Clinic ────────────────────────────────────────────────────
    static async findClinicById(clinicId) {
        return prisma_1.default.clinic.findUnique({ where: { id: clinicId } });
    }
    // ── Verification ──────────────────────────────────────────────
    static async updateVerificationStatus(profileId, status) {
        return prisma_1.default.vetProfile.update({
            where: { id: profileId },
            data: { verificationStatus: status },
            include: { clinic: true, user: true },
        });
    }
    // ── Availability Slots ────────────────────────────────────────
    static async createAvailabilitySlot(data) {
        return prisma_1.default.vetAvailabilitySlot.create({
            data: {
                vetId: data.vetId,
                startTime: data.startTime,
                endTime: data.endTime,
                clinicId: data.clinicId || null,
                isActive: true,
            },
            include: { clinic: true },
        });
    }
    static async findSlotById(slotId) {
        return prisma_1.default.vetAvailabilitySlot.findUnique({
            where: { id: slotId },
        });
    }
    static async findSlotsByVetId(vetId) {
        return prisma_1.default.vetAvailabilitySlot.findMany({
            where: { vetId },
            orderBy: { startTime: 'asc' },
            include: { clinic: true },
        });
    }
    static async updateAvailabilitySlot(slotId, data) {
        return prisma_1.default.vetAvailabilitySlot.update({
            where: { id: slotId },
            data,
            include: { clinic: true },
        });
    }
    static async deleteAvailabilitySlot(slotId) {
        return prisma_1.default.vetAvailabilitySlot.delete({
            where: { id: slotId },
        });
    }
    // ── Appointments Dashboard ────────────────────────────────────
    static async findUpcomingAppointments(vetId) {
        return prisma_1.default.appointment.findMany({
            where: {
                vetId,
                startTime: { gte: new Date() },
                status: { in: ['PENDING', 'CONFIRMED'] },
            },
            orderBy: { startTime: 'asc' },
            include: {
                pet: {
                    include: {
                        images: {
                            where: { isPrimary: true },
                            include: { asset: true },
                            take: 1,
                        },
                    },
                },
                owner: {
                    select: {
                        id: true,
                        fullName: true,
                        email: true,
                    },
                },
            },
        });
    }
}
exports.VetRepository = VetRepository;
//# sourceMappingURL=vets.repository.js.map