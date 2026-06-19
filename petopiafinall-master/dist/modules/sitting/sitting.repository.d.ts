import { SitterProfile, SitterImage, SitterAvailability, SittingBooking, SitterReview, SittingBookingStatus } from "../../../generated/prisma";
import { SitterProfileData, SitterImageData, SitterAvailabilityData, SittingBookingData, SitterReviewData, SearchSittersFilters, ListPetForSittingData, AvailablePetResult } from "./sitting.types";
export declare class SittingRepository {
    static createSitterProfile(data: SitterProfileData): Promise<SitterProfile>;
    static getSitterProfileByUserId(userId: string): Promise<SitterProfile | null>;
    static getSitterProfileById(id: string): Promise<SitterProfile | null>;
    static updateSitterProfile(userId: string, updates: Partial<SitterProfileData>): Promise<SitterProfile>;
    static createSitterImage(data: SitterImageData): Promise<SitterImage>;
    static getSitterImages(sitterProfileId: string): Promise<SitterImage[]>;
    static deleteSitterImage(id: string): Promise<SitterImage | null>;
    static addAvailability(data: SitterAvailabilityData): Promise<SitterAvailability>;
    static getSitterAvailability(sitterProfileId: string): Promise<SitterAvailability[]>;
    static deleteAvailability(id: string): Promise<SitterAvailability | null>;
    static checkAvailability(sitterProfileId: string, startDate: Date, endDate: Date): Promise<boolean>;
    static createSittingBooking(data: SittingBookingData): Promise<SittingBooking>;
    static getSittingBookingById(id: string): Promise<SittingBooking | null>;
    static getSitterBookings(sitterId: string, status?: SittingBookingStatus, page?: number, limit?: number): Promise<{
        bookings: ({
            pet: {
                id: string;
                name: string;
                breed: string | null;
            };
            petOwner: {
                id: string;
                email: string;
                fullName: string;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            sitterProfileId: string;
            status: import("../../../generated/prisma").$Enums.SittingBookingStatus;
            petId: string;
            sitterId: string;
            petOwnerId: string;
            startDate: Date;
            endDate: Date;
            totalDays: number;
            ownerNotes: string | null;
            emergencyPhone: string;
        })[];
        total: number;
    }>;
    static getOwnerBookings(ownerId: string, status?: SittingBookingStatus, page?: number, limit?: number): Promise<{
        bookings: ({
            sitterProfile: {
                user: {
                    id: string;
                    email: string;
                    fullName: string;
                };
            } & {
                id: string;
                createdAt: Date;
                address: string;
                userId: string;
                updatedAt: Date;
                verificationStatus: import("../../../generated/prisma").$Enums.SitterVerificationStatus;
                bio: string | null;
                IdCardImage: string;
                supportedPetTypes: string[];
                maxPets: number;
                city: string;
                emergencyContact: string;
                isAvailable: boolean;
                venuePhotoUrl: string | null;
                ratingAverage: number;
                totalReviews: number;
            };
            pet: {
                id: string;
                name: string;
                breed: string | null;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            sitterProfileId: string;
            status: import("../../../generated/prisma").$Enums.SittingBookingStatus;
            petId: string;
            sitterId: string;
            petOwnerId: string;
            startDate: Date;
            endDate: Date;
            totalDays: number;
            ownerNotes: string | null;
            emergencyPhone: string;
        })[];
        total: number;
    }>;
    static updateBookingStatus(id: string, status: SittingBookingStatus): Promise<SittingBooking>;
    static createSitterReview(data: SitterReviewData): Promise<SitterReview>;
    static getSitterReviews(sitterProfileId: string): Promise<SitterReview[]>;
    static searchSitters(filters: SearchSittersFilters): Promise<{
        sitters: ({
            user: {
                id: string;
                email: string;
                fullName: string;
            };
            images: {
                id: string;
                createdAt: Date;
                sitterProfileId: string;
                imageUrl: string;
                storageKey: string;
                isPrimary: boolean;
            }[];
        } & {
            id: string;
            createdAt: Date;
            address: string;
            userId: string;
            updatedAt: Date;
            verificationStatus: import("../../../generated/prisma").$Enums.SitterVerificationStatus;
            bio: string | null;
            IdCardImage: string;
            supportedPetTypes: string[];
            maxPets: number;
            city: string;
            emergencyContact: string;
            isAvailable: boolean;
            venuePhotoUrl: string | null;
            ratingAverage: number;
            totalReviews: number;
        })[];
        total: number;
    }>;
    static getPendingSitters(page?: number, limit?: number): Promise<{
        sitters: ({
            user: {
                id: string;
                email: string;
                fullName: string;
            };
            images: {
                id: string;
                createdAt: Date;
                sitterProfileId: string;
                imageUrl: string;
                storageKey: string;
                isPrimary: boolean;
            }[];
        } & {
            id: string;
            createdAt: Date;
            address: string;
            userId: string;
            updatedAt: Date;
            verificationStatus: import("../../../generated/prisma").$Enums.SitterVerificationStatus;
            bio: string | null;
            IdCardImage: string;
            supportedPetTypes: string[];
            maxPets: number;
            city: string;
            emergencyContact: string;
            isAvailable: boolean;
            venuePhotoUrl: string | null;
            ratingAverage: number;
            totalReviews: number;
        })[];
        total: number;
    }>;
    static approveSitterProfile(id: string): Promise<SitterProfile>;
    static rejectSitterProfile(id: string): Promise<SitterProfile>;
    static upsertPetForSitting(userId: string, data: ListPetForSittingData): Promise<{
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
    static unlistPetFromSitting(userId: string): Promise<{
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
    } | null>;
    static getAvailablePets(requesterId: string, petType?: string): Promise<AvailablePetResult[]>;
    static getSitterStatus(userId: string): Promise<string | null>;
    static createOrUpdateSitterRegistration(userId: string, idCardImageUrl: string, venuePhotoUrl: string): Promise<SitterProfile>;
}
//# sourceMappingURL=sitting.repository.d.ts.map