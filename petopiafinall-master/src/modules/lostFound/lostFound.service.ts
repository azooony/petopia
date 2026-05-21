import prisma from "../../config/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { VisionClient } from "../../integrations/vision/VisionClient";
import { LostFoundRepository } from "./lostFound.repository";
import { ReportLostPetInput, ReportFoundPetInput } from "./lostFound.dto";
import { PetType, Gender } from "../../../generated/prisma";

export class LostFoundService {
  // ── Lost ───────────────────────────────────────────────────────────────────

  static async reportLostPet(
    userId: string,
    input: ReportLostPetInput,
    imageBuffers: { buffer: Buffer; filename: string }[],
    baseUrl: string,
  ) {
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

    return LostFoundRepository.createLostReport({
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
}
