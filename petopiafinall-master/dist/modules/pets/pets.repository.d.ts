import { Gender } from "../../../generated/prisma";
export declare class PetRepository {
    static findOwnerProfile(userId: string): import("../../../generated/prisma").Prisma.Prisma__PetOwnerProfileClient<{
        id: string;
        phone: string;
        address: string | null;
        userId: string;
    } | null, null, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static createPet(data: {
        ownerId: string;
        petOwnerProfileId: string | null;
        name: string;
        age: number;
        breed?: string | null;
        gender?: Gender | null;
        description?: string | null;
    }): import("../../../generated/prisma").Prisma.Prisma__PetClient<{
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
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static findPetsByOwner(userId: string, limit?: number, offset?: number): import("../../../generated/prisma").Prisma.PrismaPromise<({
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
    })[]>;
    static findPetById(petId: string): import("../../../generated/prisma").Prisma.Prisma__PetClient<({
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
    }) | null, null, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static updatePet(petId: string, data: {
        name?: string;
        age?: number;
        breed?: string | null;
        gender?: Gender | null;
        description?: string | null;
    }): import("../../../generated/prisma").Prisma.Prisma__PetClient<{
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
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static deletePet(petId: string): import("../../../generated/prisma").Prisma.Prisma__PetClient<{
        id: string;
        age: number;
        gender: import("../../../generated/prisma").$Enums.Gender | null;
        name: string;
        description: string | null;
        petOwnerProfileId: string | null;
        ownerId: string;
        breed: string | null;
    }, never, import("../../../generated/prisma/runtime/library").DefaultArgs, {
        log: ("warn" | "error")[];
    }>;
    static upsertPetImage(petId: string, imageUrl: string, storageKey: string): Promise<{
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
    }>;
}
//# sourceMappingURL=pets.repository.d.ts.map