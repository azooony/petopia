"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetMatchingRepository = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const prisma_2 = require("../../../generated/prisma");
class PetMatchingRepository {
    // PROFILE
    static createProfile(data) {
        return prisma_1.default.petMatchProfile.create({
            data,
            include: {
                pet: {
                    include: {
                        images: {
                            include: {
                                asset: true,
                            },
                        },
                    },
                },
            },
        });
    }
    static findProfileByPetId(petId) {
        return prisma_1.default.petMatchProfile.findUnique({
            where: { petId },
            include: {
                pet: {
                    include: {
                        images: {
                            include: {
                                asset: true,
                            },
                        },
                    },
                },
            },
        });
    }
    static updateProfile(petId, data) {
        return prisma_1.default.petMatchProfile.update({
            where: { petId },
            data,
        });
    }
    // FIND MATCHES
    static findAvailablePets(currentPetId, breed, gender, skip = 0, take = 10) {
        return prisma_1.default.petMatchProfile.findMany({
            where: {
                petId: {
                    not: currentPetId,
                },
                isavailable: true,
                ...(gender && { pet: { gender: gender } }),
                ...(breed && {
                    OR: [
                        {
                            preferredBreed: breed,
                        },
                        {
                            preferredBreed: null,
                        },
                    ],
                }),
            },
            include: {
                pet: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                fullName: true,
                            },
                        },
                        images: {
                            include: {
                                asset: true,
                            },
                        },
                    },
                },
            },
            skip,
            take,
            orderBy: {
                pet: {
                    age: "asc",
                },
            },
        });
    }
    static deleteProfile(petId) {
        return prisma_1.default.petMatchProfile.delete({ where: { petId } });
    }
    static findAllAvailablePets(gender, skip = 0, take = 50, petType) {
        return prisma_1.default.petMatchProfile.findMany({
            where: {
                isavailable: true,
                ...((gender || petType) && {
                    pet: {
                        ...(gender && { gender: gender }),
                        ...(petType && { petType: petType }),
                    },
                }),
            },
            include: {
                pet: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                fullName: true,
                            },
                        },
                        images: {
                            include: {
                                asset: true,
                            },
                        },
                    },
                },
            },
            skip,
            take,
            orderBy: {
                pet: {
                    age: "asc",
                },
            },
        });
    }
    // REQUESTS
    static findExistingRequest(fromPetId, toPetId) {
        return prisma_1.default.petMatchRequest.findFirst({
            where: {
                OR: [
                    {
                        fromPetId,
                        toPetId,
                    },
                    {
                        fromPetId: toPetId,
                        toPetId: fromPetId,
                    },
                ],
            },
        });
    }
    static createRequest(data) {
        return prisma_1.default.petMatchRequest.create({
            data,
            include: {
                fromPet: true,
                toPet: true,
            },
        });
    }
    static getIncomingRequests(petId) {
        return prisma_1.default.petMatchRequest.findMany({
            where: {
                toPetId: petId,
                status: prisma_2.MatchRequestStatus.PENDING,
            },
            include: {
                fromPet: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                fullName: true,
                            },
                        },
                        images: {
                            include: {
                                asset: true,
                            },
                        },
                    },
                },
            },
            orderBy: {
                createdAt: "desc",
            },
        });
    }
    static getRequestById(requestId) {
        return prisma_1.default.petMatchRequest.findUnique({
            where: {
                id: requestId,
            },
            include: {
                fromPet: true,
                toPet: true,
            },
        });
    }
    static updateRequestStatus(requestId, status) {
        return prisma_1.default.petMatchRequest.update({
            where: {
                id: requestId,
            },
            data: {
                status,
            },
        });
    }
    // CHAT CREATION
    static async createConversationIfMissing(userA, userB, db = prisma_1.default) {
        const existingConversation = await db.conversation.findFirst({
            where: {
                AND: [
                    {
                        participants: {
                            some: {
                                userId: userA,
                            },
                        },
                    },
                    {
                        participants: {
                            some: {
                                userId: userB,
                            },
                        },
                    },
                ],
            },
        });
        if (existingConversation) {
            return existingConversation;
        }
        return db.conversation.create({
            data: {
                type: prisma_2.ConversationType.MATCHING,
                participants: {
                    create: [{ userId: userA }, { userId: userB }],
                },
            },
            include: {
                participants: true,
            },
        });
    }
}
exports.PetMatchingRepository = PetMatchingRepository;
//# sourceMappingURL=petMatching.repository.js.map