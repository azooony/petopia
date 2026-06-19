import { CreateMatchProfileDto, UpdateMatchProfileDto, SendMatchRequestDto } from "./petMatching.dto";
export declare class PetMatchingService {
    static createProfile(userId: string, dto: CreateMatchProfileDto): Promise<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }>;
    static updateProfile(userId: string, petId: string, dto: UpdateMatchProfileDto): Promise<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }>;
    static getProfile(userId: string, petId: string): Promise<{
        pet: {
            owner: {
                id: string;
                fullName: string;
            };
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
        profile: ({
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
        }) | null;
    }>;
    static findMatches(userId: string, petId: string, page?: number, limit?: number, gender?: string): Promise<({
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
    static deleteProfile(userId: string, petId: string): Promise<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }>;
    static findAllMatches(page?: number, limit?: number, gender?: string, petType?: string): Promise<({
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
    static sendMatchRequest(userId: string, dto: SendMatchRequestDto): Promise<{
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
    }>;
    static getIncomingRequests(userId: string, petId: string): Promise<({
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
    static acceptRequest(userId: string, requestId: string): Promise<{
        success: boolean;
    }>;
    static rejectRequest(userId: string, requestId: string): Promise<{
        id: string;
        createdAt: Date;
        status: import("../../../generated/prisma").$Enums.MatchRequestStatus;
        fromPetId: string;
        toPetId: string;
    }>;
}
//# sourceMappingURL=petMatching.service.d.ts.map