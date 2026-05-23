import { PetRepository } from "./pets.repository";
import { PetPolicy } from "./pet.policy";
import { CreatePetDto, UpdatePetDto } from "./pets.dto";
import { AppError, HttpCode } from "@/common/errors/AppError";

export class PetService {
  private static parsePagination(query: Record<string, unknown>) {
    const limitRaw = query.limit;
    const offsetRaw = query.offset;

    const limit = Number(limitRaw ?? 10);
    const offset = Number(offsetRaw ?? 0);

    if (!Number.isInteger(limit) || limit < 1) {
      throw new AppError("Limit must be a positive integer", HttpCode.BAD_REQUEST);
    }

    if (limit > 50) {
      throw new AppError("Limit cannot exceed 50", HttpCode.BAD_REQUEST);
    }

    if (!Number.isInteger(offset) || offset < 0) {
      throw new AppError("Offset must be a non-negative integer", HttpCode.BAD_REQUEST);
    }

    return { limit, offset };
  }

  // ───────────────────────── CREATE ─────────────────────────
  static async createPet(userId: string, dto: CreatePetDto) {
    const profile = await PetRepository.findOwnerProfile(userId);

    return PetRepository.createPet({
      ownerId: userId,
      petOwnerProfileId: profile?.id ?? null,
      name: dto.name,
      age: dto.age,
      breed: dto.breed ?? null,
      gender: dto.gender ?? null,
      description: dto.description ?? null,
      ...(dto.petType !== undefined && { petType: dto.petType }),
    });
  }

  // ───────────────────────── GET ALL ─────────────────────────
  static async getMyPets(userId: string, query: Record<string, unknown>) {
    const { limit, offset } = this.parsePagination(query);

    return PetRepository.findPetsByOwner(userId, limit, offset);
  }

  // ───────────────────────── GET ONE ─────────────────────────
  static async getPetById(userId: string, petId: string) {
    if (!petId) {
      throw new AppError("Pet ID is required", HttpCode.BAD_REQUEST);
    }

    const pet = await PetRepository.findPetById(petId);

    PetPolicy.ensureOwner(pet, userId);

    return pet;
  }

  // ───────────────────────── UPDATE ─────────────────────────
  static async updatePet(userId: string, petId: string, dto: UpdatePetDto) {
    if (!petId) {
      throw new AppError("Pet ID is required", HttpCode.BAD_REQUEST);
    }

    const pet = await PetRepository.findPetById(petId);

    PetPolicy.ensureOwner(pet, userId);

    if (dto.age !== undefined && dto.age < 0) {
      throw new AppError("Invalid age", HttpCode.BAD_REQUEST);
    }

    return PetRepository.updatePet(petId, {
      ...(dto.name !== undefined && { name: dto.name }),
      ...(dto.age !== undefined && { age: dto.age }),
      ...(dto.breed !== undefined && { breed: dto.breed }),
      ...(dto.gender !== undefined && { gender: dto.gender }),
      ...(dto.description !== undefined && { description: dto.description }),
      ...(dto.petType !== undefined && { petType: dto.petType }),
    });
  }

  // ───────────────────────── DELETE ─────────────────────────
  static async deletePet(userId: string, petId: string) {
    if (!petId) {
      throw new AppError("Pet ID is required", HttpCode.BAD_REQUEST);
    }

    const pet = await PetRepository.findPetById(petId);

    PetPolicy.ensureOwner(pet, userId);

    await PetRepository.deletePet(petId);

    return {
      success: true,
      message: "Pet deleted successfully",
    };
  }

  // ───────────────────────── UPLOAD PHOTO ─────────────────────────
  static async uploadPetPhoto(userId: string, petId: string, photoUrl: string) {
    if (!petId) throw new AppError('Pet ID is required', HttpCode.BAD_REQUEST);
    const pet = await PetRepository.findPetById(petId);
    PetPolicy.ensureOwner(pet, userId);
    return PetRepository.updatePetPhoto(petId, photoUrl);
  }

  // ───────────────────────── UPLOAD IMAGE ─────────────────────────
  static async uploadPetImage(
    userId: string,
    petId: string,
    imageUrl: string,
    storageKey: string,
  ) {
    if (!petId) {
      throw new AppError("Pet ID is required", HttpCode.BAD_REQUEST);
    }

    const pet = await PetRepository.findPetById(petId);
    PetPolicy.ensureOwner(pet, userId);

    return PetRepository.upsertPetImage(petId, imageUrl, storageKey);
  }
}
