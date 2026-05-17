// src/modules/vets/vets.repository.ts

import prisma from '../../config/prisma';
import { VerificationStatus } from '../../../generated/prisma';

export class VetRepository {

  // ── Registration ──────────────────────────────────────────────

  static async createVetProfile(data: {
    userId: string;
    phone: string;
    certificateImage: string;
    yearsOfExperience: number;
    appointmentPrice: number;
    startTime: string;
    endTime: string;
    clinicId: string;
  }) {
    return prisma.vetProfile.create({
      data: {
        userId: data.userId,
        phone: data.phone,
        certificateImage: data.certificateImage,
        yearsOfExperience: data.yearsOfExperience,
        appointmentPrice: data.appointmentPrice,
        startTime: data.startTime,
        endTime: data.endTime,
        clinicId: data.clinicId,
        verificationStatus: VerificationStatus.PENDING,
      },
      include: { clinic: true },
    });
  }

  // ── Profile Queries ───────────────────────────────────────────

  static async findProfileByUserId(userId: string) {
    return prisma.vetProfile.findUnique({
      where: { userId },
      include: { clinic: true, user: true },
    });
  }

  static async findProfileById(profileId: string) {
    return prisma.vetProfile.findUnique({
      where: { id: profileId },
      include: { clinic: true, user: true },
    });
  }

  static async updateVetProfile(userId: string, data: {
    phone?: string;
    description?: string;
    specialization?: string;
    photo?: string;
    firstName?: string;
    surname?: string;
    yearsOfExperience?: number;
    appointmentPrice?: number;
    startTime?: string;
    endTime?: string;
  }) {
    return prisma.vetProfile.update({
      where: { userId },
      data,
      include: { clinic: true, user: true },
    });
  }

  static async updateClinicAddress(clinicId: string, address: string) {
    return prisma.clinic.update({
      where: { id: clinicId },
      data: { address },
    });
  }

  // ── Clinic ────────────────────────────────────────────────────

  static async findClinicById(clinicId: string) {
    return prisma.clinic.findUnique({ where: { id: clinicId } });
  }

  // ── Verification ──────────────────────────────────────────────

  static async updateVerificationStatus(profileId: string, status: VerificationStatus) {
    return prisma.vetProfile.update({
      where: { id: profileId },
      data: { verificationStatus: status },
      include: { clinic: true, user: true },
    });
  }

  // ── Availability Slots ────────────────────────────────────────

  static async createAvailabilitySlot(data: {
    vetId: string;
    clinicId?: string;
    startTime: Date;
    endTime: Date;
  }) {
    return prisma.vetAvailabilitySlot.create({
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

  static async findSlotById(slotId: string) {
    return prisma.vetAvailabilitySlot.findUnique({
      where: { id: slotId },
    });
  }

  static async findSlotsByVetId(vetId: string) {
    return prisma.vetAvailabilitySlot.findMany({
      where: { vetId },
      orderBy: { startTime: 'asc' },
      include: { clinic: true },
    });
  }

  static async updateAvailabilitySlot(slotId: string, data: {
    startTime?: Date;
    endTime?: Date;
    isActive?: boolean;
  }) {
    return prisma.vetAvailabilitySlot.update({
      where: { id: slotId },
      data,
      include: { clinic: true },
    });
  }

  static async deleteAvailabilitySlot(slotId: string) {
    return prisma.vetAvailabilitySlot.delete({
      where: { id: slotId },
    });
  }

  // ── Appointments Dashboard ────────────────────────────────────

  static async findUpcomingAppointments(vetId: string) {
    return prisma.appointment.findMany({
      where: {
        vetId,
        startTime: { gte: new Date() },
        status: { in: ['PENDING', 'CONFIRMED'] },
      },
      orderBy: { startTime: 'asc' },
      include: {
        pet: {
          select: {
            name: true,
            breed: true,
            photo: true,
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

  static async markAppointmentComplete(
    appointmentId: string,
    vetId: string,
    notes: { diagnosis?: string; treatment?: string; notes?: string },
  ) {
    return prisma.$transaction(async (tx) => {
      const appointment = await tx.appointment.update({
        where: { id: appointmentId, vetId },
        data: { status: 'COMPLETED' },
      });

      await tx.medicalRecord.create({
        data: {
          petId:         appointment.petId,
          vetId,
          appointmentId: appointment.id,
          diagnosis:     notes.diagnosis  ?? null,
          treatment:     notes.treatment  ?? null,
          notes:         notes.notes      ?? null,
        },
      });

      return appointment;
    });
  }
}
