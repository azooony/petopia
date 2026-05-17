"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetService = void 0;
const pets_repository_1 = require("./pets.repository");
const pet_policy_1 = require("./pet.policy");
const AppError_1 = require("@/common/errors/AppError");
class PetService {
    static parsePagination(query) {
        const limitRaw = query.limit;
        const offsetRaw = query.offset;
        const limit = Number(limitRaw ?? 10);
        const offset = Number(offsetRaw ?? 0);
        if (!Number.isInteger(limit) || limit < 1) {
            throw new AppError_1.AppError("Limit must be a positive integer", AppError_1.HttpCode.BAD_REQUEST);
        }
        if (limit > 50) {
            throw new AppError_1.AppError("Limit cannot exceed 50", AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!Number.isInteger(offset) || offset < 0) {
            throw new AppError_1.AppError("Offset must be a non-negative integer", AppError_1.HttpCode.BAD_REQUEST);
        }
        return { limit, offset };
    }
    // ───────────────────────── CREATE ─────────────────────────
    static async createPet(userId, dto) {
        const profile = await pets_repository_1.PetRepository.findOwnerProfile(userId);
        return pets_repository_1.PetRepository.createPet({
            ownerId: userId,
            petOwnerProfileId: profile?.id ?? null,
            name: dto.name,
            age: dto.age,
            breed: dto.breed ?? null,
            gender: dto.gender ?? null,
            description: dto.description ?? null,
        });
    }
    // ───────────────────────── GET ALL ─────────────────────────
    static async getMyPets(userId, query) {
        const { limit, offset } = this.parsePagination(query);
        return pets_repository_1.PetRepository.findPetsByOwner(userId, limit, offset);
    }
    // ───────────────────────── GET ONE ─────────────────────────
    static async getPetById(userId, petId) {
        if (!petId) {
            throw new AppError_1.AppError("Pet ID is required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const pet = await pets_repository_1.PetRepository.findPetById(petId);
        pet_policy_1.PetPolicy.ensureOwner(pet, userId);
        return pet;
    }
    // ───────────────────────── UPDATE ─────────────────────────
    static async updatePet(userId, petId, dto) {
        if (!petId) {
            throw new AppError_1.AppError("Pet ID is required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const pet = await pets_repository_1.PetRepository.findPetById(petId);
        pet_policy_1.PetPolicy.ensureOwner(pet, userId);
        if (dto.age !== undefined && dto.age < 0) {
            throw new AppError_1.AppError("Invalid age", AppError_1.HttpCode.BAD_REQUEST);
        }
        return pets_repository_1.PetRepository.updatePet(petId, {
            ...(dto.name !== undefined && { name: dto.name }),
            ...(dto.age !== undefined && { age: dto.age }),
            ...(dto.breed !== undefined && { breed: dto.breed }),
            ...(dto.gender !== undefined && { gender: dto.gender }),
            ...(dto.description !== undefined && { description: dto.description }),
        });
    }
    // ───────────────────────── DELETE ─────────────────────────
    static async deletePet(userId, petId) {
        if (!petId) {
            throw new AppError_1.AppError("Pet ID is required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const pet = await pets_repository_1.PetRepository.findPetById(petId);
        pet_policy_1.PetPolicy.ensureOwner(pet, userId);
        await pets_repository_1.PetRepository.deletePet(petId);
        return {
            success: true,
            message: "Pet deleted successfully",
        };
    }
    // ───────────────────────── UPLOAD IMAGE ─────────────────────────
    static async uploadPetImage(userId, petId, imageUrl, storageKey) {
        if (!petId) {
            throw new AppError_1.AppError("Pet ID is required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const pet = await pets_repository_1.PetRepository.findPetById(petId);
        pet_policy_1.PetPolicy.ensureOwner(pet, userId);
        return pets_repository_1.PetRepository.upsertPetImage(petId, imageUrl, storageKey);
    }
}
exports.PetService = PetService;
//# sourceMappingURL=pets.service.js.map