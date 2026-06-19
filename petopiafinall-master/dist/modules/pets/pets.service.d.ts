import { CreatePetDto, UpdatePetDto } from "./pets.dto";
export declare class PetService {
    private static parsePagination;
    static createPet(userId: string, dto: CreatePetDto): Promise<{
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
    }>;
    static getMyPets(userId: string, query: Record<string, unknown>): Promise<({
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
    static getPetById(userId: string, petId: string): Promise<({
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
    }) | null>;
    static updatePet(userId: string, petId: string, dto: UpdatePetDto): Promise<{
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
    }>;
    static deletePet(userId: string, petId: string): Promise<{
        success: boolean;
        message: string;
    }>;
    static uploadPetPhoto(userId: string, petId: string, photoUrl: string): Promise<{
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
    }>;
    static uploadPetImage(userId: string, petId: string, imageUrl: string, storageKey: string): Promise<{
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
//# sourceMappingURL=pets.service.d.ts.map