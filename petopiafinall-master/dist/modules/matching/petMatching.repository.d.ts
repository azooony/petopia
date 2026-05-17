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
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
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
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
    } & {
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }) | null, null, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
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
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static findAvailablePets(currentPetId: string, breed?: string, skip?: number, take?: number): Prisma.PrismaPromise<({
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
            owner: {
                id: string;
                fullName: string;
            };
        } & {
            id: string;
            age: number;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
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
    } | null, null, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static createRequest(data: {
        fromPetId: string;
        toPetId: string;
    }): Prisma.Prisma__PetMatchRequestClient<{
        fromPet: {
            id: string;
            age: number;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
        toPet: {
            id: string;
            age: number;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static getIncomingRequests(petId: string): Prisma.PrismaPromise<({
        fromPet: {
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
            owner: {
                id: string;
                fullName: string;
            };
        } & {
            id: string;
            age: number;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
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
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
        toPet: {
            id: string;
            age: number;
            gender: import("../../../generated/prisma").$Enums.Gender | null;
            name: string;
            description: string | null;
            petOwnerProfileId: string | null;
            ownerId: string;
            breed: string | null;
        };
    } & {
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }) | null, null, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static updateRequestStatus(requestId: string, status: MatchRequestStatus): Prisma.Prisma__PetMatchRequestClient<{
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static createConversationIfMissing(userA: string, userB: string, db?: Prisma.TransactionClient | typeof prisma): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
    }>;
}
//# sourceMappingURL=petMatching.repository.d.ts.map