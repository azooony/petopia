import { SitterVerificationStatus, SittingBookingStatus } from "../../../generated/prisma";
export interface SitterProfileData {
    userId: string;
    bio?: string;
    idCardImage?: string;
    supportedPetTypes: string[];
    maxPets: number;
    city: string;
    address: string;
    emergencyContact: string;
    isAvailable: boolean;
}
export interface SitterImageData {
    sitterProfileId: string;
    imageUrl: string;
    storageKey: string;
    uploadedById: string;
    isPrimary?: boolean;
}
export interface SitterAvailabilityData {
    sitterProfileId: string;
    userId: string;
    startDate: Date;
    endDate: Date;
}
export interface SittingBookingData {
    sitterProfileId: string;
    sitterId: string;
    petOwnerId: string;
    petId: string;
    startDate: Date;
    endDate: Date;
    totalDays: number;
    ownerNotes?: string;
    emergencyPhone: string;
}
export interface SitterReviewData {
    bookingId: string;
    sitterProfileId: string;
    reviewerUserId: string;
    rating: number;
    comment?: string;
}
export interface SitterProfileResponse {
    id: string;
    userId: string;
    bio?: string;
    supportedPetTypes: string[];
    maxPets: number;
    city: string;
    address: string;
    emergencyContact: string;
    isAvailable: boolean;
    ratingAverage: number;
    totalReviews: number;
    verificationStatus: SitterVerificationStatus;
    createdAt: Date;
    updatedAt: Date;
}
export interface SitterImageResponse {
    id: string;
    sitterProfileId: string;
    imageUrl: string;
    storageKey: string;
    isPrimary: boolean;
    createdAt: Date;
}
export interface SitterAvailabilityResponse {
    id: string;
    sitterProfileId: string;
    startDate: Date;
    endDate: Date;
    createdAt: Date;
    updatedAt: Date;
}
export interface SittingBookingResponse {
    id: string;
    sitterProfileId: string;
    sitterId: string;
    petOwnerId: string;
    petId: string;
    startDate: Date;
    endDate: Date;
    totalDays: number;
    ownerNotes?: string;
    emergencyPhone: string;
    status: SittingBookingStatus;
    createdAt: Date;
    updatedAt: Date;
}
export interface SitterReviewResponse {
    id: string;
    bookingId: string;
    sitterProfileId: string;
    reviewerUserId: string;
    rating: number;
    comment?: string;
    createdAt: Date;
    updatedAt: Date;
}
export interface SearchSittersFilters {
    city?: string;
    petType?: string;
    minRating?: number;
    maxRating?: number;
    startDate?: Date;
    endDate?: Date;
    page: number;
    limit: number;
    sortBy?: "rating" | "newest" | "booked";
}
export interface PaginationMeta {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
}
//# sourceMappingURL=sitting.types.d.ts.map