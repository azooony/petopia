import { CreateSitterProfileInput, UpdateSitterProfileInput, UploadSitterImageInput, AddAvailabilityInput, CreateSittingBookingInput, CreateSitterReviewInput, SearchSittersInput } from "./sitting.dto";
export declare class SittingService {
    static createSitterProfile(userId: string, input: CreateSitterProfileInput): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
    static getSitterProfileMe(userId: string): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
    static getSitterProfile(sitterId: string): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
    static updateSitterProfile(userId: string, input: UpdateSitterProfileInput): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
    static uploadSitterImage(userId: string, file: Express.Multer.File, input: UploadSitterImageInput): Promise<{
        id: string;
        createdAt: Date;
        sitterProfileId: string;
        imageUrl: string;
        storageKey: string;
        isPrimary: boolean;
    }>;
    static getSitterImages(userId: string): Promise<{
        id: string;
        createdAt: Date;
        sitterProfileId: string;
        imageUrl: string;
        storageKey: string;
        isPrimary: boolean;
    }[]>;
    static deleteSitterImage(userId: string, imageId: string): Promise<{
        message: string;
    }>;
    static addAvailability(userId: string, input: AddAvailabilityInput): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        updatedAt: Date;
        sitterProfileId: string;
        startDate: Date;
        endDate: Date;
    }>;
    static getMyAvailability(userId: string): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        updatedAt: Date;
        sitterProfileId: string;
        startDate: Date;
        endDate: Date;
    }[]>;
    static deleteAvailability(userId: string, availabilityId: string): Promise<{
        message: string;
    }>;
    static createBooking(userId: string, input: CreateSittingBookingInput): Promise<{
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
    }>;
    static getMyBookingsAsSitter(userId: string, page?: number, limit?: number): Promise<{
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
    static getIncomingBookingsAsSitter(userId: string, page?: number, limit?: number): Promise<{
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
    static getMyBookingsAsOwner(userId: string, page?: number, limit?: number): Promise<{
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
    static acceptBooking(userId: string, bookingId: string): Promise<{
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
    }>;
    static rejectBooking(userId: string, bookingId: string): Promise<{
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
    }>;
    static cancelBooking(userId: string, bookingId: string): Promise<{
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
    }>;
    static completeBooking(bookingId: string): Promise<{
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
    }>;
    static createReview(userId: string, input: CreateSitterReviewInput): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sitterProfileId: string;
        bookingId: string;
        reviewerUserId: string;
        rating: number;
        comment: string | null;
    }>;
    static getSitterReviews(sitterId: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sitterProfileId: string;
        bookingId: string;
        reviewerUserId: string;
        rating: number;
        comment: string | null;
    }[]>;
    static searchSitters(filters: SearchSittersInput): Promise<{
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
            ratingAverage: number;
            totalReviews: number;
        })[];
        total: number;
    }>;
    static approveSitter(sitterId: string): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
    static rejectSitter(sitterId: string): Promise<{
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
        ratingAverage: number;
        totalReviews: number;
    }>;
}
//# sourceMappingURL=sitting.service.d.ts.map