import { Gender } from "../../../generated/prisma";
export declare class PetRepository {
    static findOwnerProfile(userId: string): import("../../../generated/prisma").Prisma.Prisma__PetOwnerProfileClient<{
        id: string;
        phone: string;
        address: string | null;
        userId: string;
    } | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
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
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
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
    }) | null, null, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static updatePet(petId: string, data: {
        name?: string;
        age?: number;
        breed?: string | null;
        gender?: Gender | null;
        description?: string | null;
        photo?: string | null;
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
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static updatePetPhoto(petId: string, photoUrl: string): import("../../../generated/prisma").Prisma.Prisma__PetClient<{
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
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
    }>;
    static deletePet(petId: string): import("../../../generated/prisma").Prisma.Prisma__PetClient<{
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
    }, never, import("../../../generated/prisma/runtime/client").DefaultArgs, {
        log: ("warn" | "error")[];
        adapter: import("@prisma/adapter-pg").PrismaPg;
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