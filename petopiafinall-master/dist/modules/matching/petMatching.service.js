"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetMatchingService = void 0;
const prisma_1 = require("../../../generated/prisma");
const AppError_1 = require("../../common/errors/AppError");
const prisma_2 = __importDefault(require("../../config/prisma"));
const petMatching_repository_1 = require("./petMatching.repository");
class PetMatchingService {
    // CREATE PROFILE
    static async createProfile(userId, dto) {
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: dto.petId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Pet not found or unauthorized", AppError_1.HttpCode.NOT_FOUND);
        }
        const existing = await petMatching_repository_1.PetMatchingRepository.findProfileByPetId(dto.petId);
        if (existing) {
            throw new AppError_1.AppError("Matching profile already exists", AppError_1.HttpCode.BAD_REQUEST);
        }
        return petMatching_repository_1.PetMatchingRepository.createProfile({
            petId: dto.petId,
            ...(dto.description !== undefined && { description: dto.description }),
            ...(dto.address !== undefined && { address: dto.address }),
            ...(dto.preferredBreed !== undefined && { preferredBreed: dto.preferredBreed }),
        });
    }
    // UPDATE PROFILE
    static async updateProfile(userId, petId, dto) {
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: petId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
        }
        const updateData = {
            ...(dto.description !== undefined && {
                description: dto.description,
            }),
            ...(dto.address !== undefined && {
                address: dto.address,
            }),
            ...(dto.preferredBreed !== undefined && {
                preferredBreed: dto.preferredBreed,
            }),
        };
        return petMatching_repository_1.PetMatchingRepository.updateProfile(petId, updateData);
    }
    // FIND MATCHES
    static async findMatches(userId, petId, page = 1, limit = 10) {
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: petId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
        }
        const skip = (page - 1) * limit;
        return petMatching_repository_1.PetMatchingRepository.findAvailablePets(petId, pet.breed ?? undefined, skip, limit);
    }
    // SEND REQUEST
    static async sendMatchRequest(userId, dto) {
        if (dto.fromPetId === dto.toPetId) {
            throw new AppError_1.AppError("Cannot match same pet", AppError_1.HttpCode.BAD_REQUEST);
        }
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: dto.fromPetId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
        }
        const target = await prisma_2.default.petMatchProfile.findUnique({
            where: {
                petId: dto.toPetId,
            },
        });
        if (!target || !target.isavailable) {
            throw new AppError_1.AppError("Target pet unavailable", AppError_1.HttpCode.BAD_REQUEST);
        }
        const existing = await petMatching_repository_1.PetMatchingRepository.findExistingRequest(dto.fromPetId, dto.toPetId);
        if (existing) {
            throw new AppError_1.AppError("Request already exists", AppError_1.HttpCode.BAD_REQUEST);
        }
        return petMatching_repository_1.PetMatchingRepository.createRequest(dto);
    }
    // INCOMING REQUESTS
    static async getIncomingRequests(userId, petId) {
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: petId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
        }
        return petMatching_repository_1.PetMatchingRepository.getIncomingRequests(petId);
    }
    // ACCEPT REQUEST
    static async acceptRequest(userId, requestId) {
        await prisma_2.default.$transaction(async (tx) => {
            const request = await tx.petMatchRequest.findUnique({
                where: {
                    id: requestId,
                },
                include: {
                    fromPet: true,
                    toPet: true,
                },
            });
            if (!request) {
                throw new AppError_1.AppError("Request not found", AppError_1.HttpCode.NOT_FOUND);
            }
            if (request.toPet.ownerId !== userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
            }
            if (request.status !== prisma_1.MatchRequestStatus.PENDING) {
                throw new AppError_1.AppError("Request already processed", AppError_1.HttpCode.BAD_REQUEST);
            }
            await tx.petMatchRequest.update({
                where: {
                    id: requestId,
                },
                data: {
                    status: prisma_1.MatchRequestStatus.ACCEPTED,
                },
            });
            await petMatching_repository_1.PetMatchingRepository.createConversationIfMissing(request.fromPet.ownerId, request.toPet.ownerId, tx);
        });
        return {
            success: true,
        };
    }
    // REJECT REQUEST
    static async rejectRequest(userId, requestId) {
        const request = await petMatching_repository_1.PetMatchingRepository.getRequestById(requestId);
        if (!request) {
            throw new AppError_1.AppError("Request not found", AppError_1.HttpCode.NOT_FOUND);
        }
        const pet = await prisma_2.default.pet.findUnique({
            where: {
                id: request.toPetId,
            },
        });
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.FORBIDDEN);
        }
        return petMatching_repository_1.PetMatchingRepository.updateRequestStatus(requestId, prisma_1.MatchRequestStatus.REJECTED);
    }
}
exports.PetMatchingService = PetMatchingService;
//# sourceMappingURL=petMatching.service.js.map