import { VerificationStatus } from '../../../generated/prisma';
import { RegisterVetDto, UpdateVetProfileDto, AddAvailabilitySlotDto, UpdateAvailabilitySlotDto } from './vets.dto';
export declare class VetService {
    private static parseYearsOfExperience;
    private static parseAppointmentPrice;
    private static validateTime;
    private static toMinutes;
    private static validateProfileHours;
    private static validateAvailabilityWithinProfileHours;
    static registerVet(userId: string, dto: RegisterVetDto): Promise<{
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        };
    } & {
        id: string;
        phone: string;
        userId: string;
        description: string | null;
        yearsOfExperience: number;
        appointmentPrice: number;
        startTime: string;
        endTime: string;
        certificateImage: string;
        photo: string | null;
        firstName: string | null;
        surname: string | null;
        specialization: string | null;
        verificationStatus: import("../../../generated/prisma").$Enums.VerificationStatus;
        clinicId: string;
    }>;
    static updateProfile(userId: string, dto: UpdateVetProfileDto): Promise<{
        user: {
            id: string;
            email: string;
            passwordHash: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
        };
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        };
    } & {
        id: string;
        phone: string;
        userId: string;
        description: string | null;
        yearsOfExperience: number;
        appointmentPrice: number;
        startTime: string;
        endTime: string;
        certificateImage: string;
        photo: string | null;
        firstName: string | null;
        surname: string | null;
        specialization: string | null;
        verificationStatus: import("../../../generated/prisma").$Enums.VerificationStatus;
        clinicId: string;
    }>;
    static getProfile(userId: string): Promise<{
        user: {
            id: string;
            email: string;
            passwordHash: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
        };
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        };
    } & {
        id: string;
        phone: string;
        userId: string;
        description: string | null;
        yearsOfExperience: number;
        appointmentPrice: number;
        startTime: string;
        endTime: string;
        certificateImage: string;
        photo: string | null;
        firstName: string | null;
        surname: string | null;
        specialization: string | null;
        verificationStatus: import("../../../generated/prisma").$Enums.VerificationStatus;
        clinicId: string;
    }>;
    static verifyVet(profileId: string, status: VerificationStatus): Promise<{
        user: {
            id: string;
            email: string;
            passwordHash: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
        };
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        };
    } & {
        id: string;
        phone: string;
        userId: string;
        description: string | null;
        yearsOfExperience: number;
        appointmentPrice: number;
        startTime: string;
        endTime: string;
        certificateImage: string;
        photo: string | null;
        firstName: string | null;
        surname: string | null;
        specialization: string | null;
        verificationStatus: import("../../../generated/prisma").$Enums.VerificationStatus;
        clinicId: string;
    }>;
    static addAvailabilitySlot(userId: string, dto: AddAvailabilitySlotDto): Promise<{
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        } | null;
    } & {
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    }>;
    static getAvailabilitySlots(userId: string): Promise<({
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        } | null;
    } & {
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    })[]>;
    static updateAvailabilitySlot(userId: string, slotId: string, dto: UpdateAvailabilitySlotDto): Promise<{
        clinic: {
            id: string;
            createdAt: Date;
            name: string;
            phone: string;
            address: string;
            updatedAt: Date;
        } | null;
    } & {
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    }>;
    static deleteAvailabilitySlot(userId: string, slotId: string): Promise<{
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    }>;
    static getUpcomingAppointments(userId: string): Promise<({
        pet: {
            images: ({
                asset: {
                    id: string;
                    createdAt: Date;
                    url: string;
                    mimeType: string | null;
                    sizeBytes: number | null;
                    storageKey: string | null;
                    uploadedById: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                petId: string;
                assetId: string;
                isPrimary: boolean;
            })[];
        } & {
            id: string;
            petOwnerProfileId: string | null;
            ownerId: string;
        };
        owner: {
            id: string;
            email: string;
            fullName: string;
        };
    } & {
        id: string;
        createdAt: Date;
        startTime: Date;
        status: import("../../../generated/prisma").$Enums.AppointmentStatus;
        petOwnerProfileId: string | null;
        ownerId: string;
        vetId: string;
        petId: string;
        clinicName: string | null;
        clinicAddress: string | null;
        reason: string | null;
        price: number;
    })[]>;
}
//# sourceMappingURL=vets.service.d.ts.map