import { CreateMatchProfileDto, UpdateMatchProfileDto, SendMatchRequestDto } from "./petMatching.dto";
export declare class PetMatchingService {
    static createProfile(userId: string, dto: CreateMatchProfileDto): Promise<{
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
    }>;
    static updateProfile(userId: string, petId: string, dto: UpdateMatchProfileDto): Promise<{
        id: string;
        address: string | null;
        description: string | null;
        petId: string;
        preferredBreed: string | null;
        isavailable: boolean;
    }>;
    static findMatches(userId: string, petId: string, page?: number, limit?: number): Promise<({
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
    static sendMatchRequest(userId: string, dto: SendMatchRequestDto): Promise<{
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
    }>;
    static getIncomingRequests(userId: string, petId: string): Promise<({
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