import prisma from "../../config/prisma";
import { MatchRequestStatus, Prisma } from "../../../generated/prisma";
export declare class PetMatchingRepository {
    static createProfile(data: {
        petId: string;
        description?: string | null;
        address?: string | null;
        preferredBreed?: string | null;
    }): Prisma.Prisma__PetMatchProfileClient<{
        pet: {
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    storageKey: string | null;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                isPrimary: boolean;
                petId: string;
                assetId: string;
            })[];
        } & {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static findProfileByPetId(petId: string): Prisma.Prisma__PetMatchProfileClient<({
        pet: {
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    storageKey: string | null;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                isPrimary: boolean;
                petId: string;
                assetId: string;
            })[];
        } & {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }) | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static updateProfile(petId: string, data: {
        description?: string | null;
        address?: string | null;
        preferredBreed?: string | null;
        isavailable?: boolean;
    }): Prisma.Prisma__PetMatchProfileClient<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static findAvailablePets(currentPetId: string, breed?: string, gender?: string, skip?: number, take?: number): Prisma.PrismaPromise<({
        pet: {
            owner: {
                id: string;
                fullName: string;
            };
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    storageKey: string | null;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                isPrimary: boolean;
                petId: string;
                assetId: string;
            })[];
        } & {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    })[]>;
    static deleteProfile(petId: string): Prisma.Prisma__PetMatchProfileClient<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static findAllAvailablePets(gender?: string, skip?: number, take?: number, petType?: string): Prisma.PrismaPromise<({
        pet: {
            owner: {
                id: string;
                fullName: string;
            };
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    storageKey: string | null;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                isPrimary: boolean;
                petId: string;
                assetId: string;
            })[];
        } & {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    })[]>;
    static findExistingRequest(fromPetId: string, toPetId: string): Prisma.Prisma__PetMatchRequestClient<{
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    } | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static createRequest(data: {
        fromPetId: string;
        toPetId: string;
    }): Prisma.Prisma__PetMatchRequestClient<{
        fromPet: {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
        toPet: {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static getIncomingRequests(petId: string): Prisma.PrismaPromise<({
        fromPet: {
            owner: {
                id: string;
                fullName: string;
            };
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    storageKey: string | null;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                isPrimary: boolean;
                petId: string;
                assetId: string;
            })[];
        } & {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    })[]>;
    static getRequestById(requestId: string): Prisma.Prisma__PetMatchRequestClient<({
        fromPet: {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
        toPet: {
            id: string;
            age: number;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            photo: string | null;
            ownerId: string;
            petOwnerProfileId: string | null;
            breed: string | null;
            petType: import("../../../generated/prisma").$Enums.PetType;
            isAvailableForSitting: boolean;
            payRatePerDay: number | null;
            sittingNotes: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }) | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static updateRequestStatus(requestId: string, status: MatchRequestStatus): Prisma.Prisma__PetMatchRequestClient<{
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static createConversationIfMissing(userA: string, userB: string, db?: Prisma.TransactionClient | typeof prisma): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        type: import("../../../generated/prisma").$Enums.ConversationType;
    }>;
}
//# sourceMappingURL=petMatching.repository.d.ts.map