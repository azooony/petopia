import prisma from "../../config/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { VisionClient } from "../../integrations/vision/VisionClient";
import { LostFoundRepository } from "./lostFound.repository";
import { ReportLostPetInput, ReportFoundPetInput } from "./lostFound.dto";
import {
  PetType,
  Gender,
  LostFoundStatus,
  AppointmentStatus,
  SittingBookingStatus,
  ConversationType,
  MatchRequestStatus,
} from "../../../generated/prisma";
import { fireNotification } from "../Notification/notification.helpers";
import {
  notifyLostPetReported,
  notifySittingBookingCancelled,
  notifyAppointmentCancelled,
} from "../Notification/notification.templates";

export class LostFoundService {
  // ── Lost ───────────────────────────────────────────────────────────────────

  static async reportLostPet(
    userId: string,
    input: ReportLostPetInput,
    imageBuffers: { buffer: Buffer; filename: string }[],
    baseUrl: string,
  ) {
    // One active lost report per user
    const existing = await prisma.lostFoundReport.findFirst({
      where: { ownerId: userId, status: LostFoundStatus.LOST },
    });
    if (existing) {
      throw new AppError(
        "You already have an active lost pet report. You cannot add another one.",
        HttpCode.BAD_REQUEST,
      );
    }

    let name    = input.name;
    let breed   = input.breed;
    let gender  = input.gender as Gender | undefined;

    // Autofill from existing pet when petId is provided
    if (input.petId) {
      const pet = await prisma.pet.findFirst({
        where: { id: input.petId, ownerId: userId },
      });
      if (!pet) throw new AppError("Pet not found or does not belong to you", HttpCode.NOT_FOUND);
      name   = name   ?? pet.name          ?? undefined;
      breed  = breed  ?? pet.breed         ?? undefined;
      gender = gender ?? (pet.gender as Gender | null) ?? undefined;
    }

    // AI breed + species detection from first image
    if (imageBuffers.length > 0 && !breed) {
      try {
        const img = imageBuffers[0]!;
        const ai = await VisionClient.analyzePetImage(img.buffer, img.filename);
        breed = breed ?? ai.breed;
      } catch {
        // AI failure is non-blocking
      }
    }

    const imageUrls = imageBuffers.map(
      ({ filename }) => `${baseUrl}/uploads/lost-found/${filename}`,
    );

    const report = await LostFoundRepository.createLostReport({
      ownerId:          userId,
      species:          input.species as PetType,
      description:      input.description,
      lastSeenLocation: input.lastSeenLocation,
      lastSeenDate:     new Date(input.lastSeenDate),
      ...(name   !== undefined && { name }),
      ...(breed  !== undefined && { breed }),
      ...(gender !== undefined && { gender }),
      ...(input.color !== undefined && { color: input.color }),
      imageUrls,
    });

    fireNotification(
      notifyLostPetReported(userId, report.id, name ?? undefined),
    );

    if (input.petId) {
      try {
        await LostFoundService.cleanupAfterLostReport(userId, input.petId);
      } catch {
        // cleanup failure must not fail the report submission
      }
    }

    return report;
  }

  private static async cleanupAfterLostReport(ownerId: string, petId: string) {
    // 1. Remove from pet matching — delete profile and cancel pending requests
    await prisma.petMatchProfile.deleteMany({ where: { petId } });
    await prisma.petMatchRequest.updateMany({
      where: {
        OR: [{ fromPetId: petId }, { toPetId: petId }],
        status: MatchRequestStatus.PENDING,
      },
      data: { status: MatchRequestStatus.CANCELLED },
    });

    // 2. Remove from sitting availability
    await prisma.pet.update({
      where: { id: petId },
      data: { isAvailableForSitting: false, payRatePerDay: null, sittingNotes: null },
    });

    // 3. Cancel active sitting bookings and notify each sitter
    const sittingBookings = await prisma.sittingBooking.findMany({
      where: {
        petId,
        status: { in: [SittingBookingStatus.PENDING, SittingBookingStatus.ACCEPTED] },
      },
      include: { pet: { select: { name: true } } },
    });
    if (sittingBookings.length > 0) {
      await prisma.sittingBooking.updateMany({
        where: {
          petId,
          status: { in: [SittingBookingStatus.PENDING, SittingBookingStatus.ACCEPTED] },
        },
        data: { status: SittingBookingStatus.CANCELLED },
      });
      for (const booking of sittingBookings) {
        const petName = (booking as { pet?: { name?: string } }).pet?.name ?? "the pet";
        const reason = `The sitting booking for ${petName} was cancelled because the pet was reported as lost.`;
        await LostFoundService.sendSystemMessage(
          ownerId,
          booking.sitterId,
          reason,
        ).catch(() => {});
        fireNotification(
          notifySittingBookingCancelled(booking.sitterId, booking.id, reason),
        );
      }
    }

    // 4. Cancel pending/confirmed appointments and notify each vet
    const appointments = await prisma.appointment.findMany({
      where: {
        petId,
        status: { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
      },
      include: { pet: { select: { name: true } } },
    });
    if (appointments.length > 0) {
      await prisma.appointment.updateMany({
        where: {
          petId,
          status: { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
        },
        data: { status: AppointmentStatus.CANCELLED },
      });
      for (const appt of appointments) {
        const petName = (appt as { pet?: { name?: string } }).pet?.name ?? "the pet";
        const date = appt.startTime.toLocaleDateString("en-GB", {
          day: "2-digit",
          month: "long",
          year: "numeric",
        });
        const reason = `The appointment for ${petName} on ${date} was cancelled because the pet was reported as lost.`;
        await LostFoundService.sendSystemMessage(
          ownerId,
          appt.vetId,
          reason,
        ).catch(() => {});
        fireNotification(
          notifyAppointmentCancelled(appt.vetId, appt.id, reason),
        );
      }
    }
  }

  private static async sendSystemMessage(
    fromUserId: string,
    toUserId: string,
    content: string,
  ) {
    let conversation = await prisma.conversation.findFirst({
      where: {
        AND: [
          { participants: { some: { userId: fromUserId } } },
          { participants: { some: { userId: toUserId } } },
        ],
      },
    });

    if (!conversation) {
      conversation = await prisma.conversation.create({
        data: {
          type: ConversationType.MATCHING,
          participants: {
            create: [{ userId: fromUserId }, { userId: toUserId }],
          },
        },
      });
    }

    await prisma.chatMessage.create({
      data: { conversationId: conversation.id, senderId: fromUserId, content },
    });
  }

  // ── Found ──────────────────────────────────────────────────────────────────

  static async reportFoundPet(
    userId: string,
    input: ReportFoundPetInput,
    imageBuffers: { buffer: Buffer; filename: string }[],
    baseUrl: string,
  ) {
    let breed  = input.breed;

    // AI breed + species detection from first image
    if (imageBuffers.length > 0 && !breed) {
      try {
        const img = imageBuffers[0]!;
        const ai = await VisionClient.analyzePetImage(img.buffer, img.filename);
        breed = breed ?? ai.breed;
      } catch {
        // AI failure is non-blocking
      }
    }

    const imageUrls = imageBuffers.map(
      ({ filename }) => `${baseUrl}/uploads/lost-found/${filename}`,
    );

    const gender = input.gender as Gender | undefined;

    return LostFoundRepository.createFoundReport({
      finderId:             userId,
      species:              input.species as PetType,
      description:          input.description,
      foundLocation:        input.foundLocation,
      isPetStillAtLocation: input.isPetStillAtLocation,
      ...(breed  !== undefined && { breed }),
      ...(gender !== undefined && { gender }),
      ...(input.color !== undefined && { color: input.color }),
      imageUrls,
    });
  }

  // ── Listings ───────────────────────────────────────────────────────────────

  static async getLostReports() {
    return LostFoundRepository.getLostReports();
  }

  static async getFoundReports() {
    return LostFoundRepository.getFoundReports();
  }

  static async deleteFoundReport(userId: string, reportId: string) {
    const result = await LostFoundRepository.deleteFoundReport(reportId, userId);
    if (result.count === 0) {
      throw new AppError(
        "Report not found or you do not have permission to delete it.",
        HttpCode.NOT_FOUND,
      );
    }
  }
}
