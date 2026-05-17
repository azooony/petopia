import { VerificationStatus } from '../../../generated/prisma';
export declare class VetRepository {
    static createVetProfile(data: {
        userId: string;
        phone: string;
        certificateImage: string;
        yearsOfExperience: number;
        appointmentPrice: number;
        startTime: string;
        endTime: string;
        clinicId: string;
    }): Promise<{
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
    static findProfileByUserId(userId: string): Promise<({
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
    }) | null>;
    static findProfileById(profileId: string): Promise<({
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
    }) | null>;
    static updateVetProfile(userId: string, data: {
        phone?: string;
        description?: string;
        specialization?: string;
        photo?: string;
        firstName?: string;
        surname?: string;
        yearsOfExperience?: number;
        appointmentPrice?: number;
        startTime?: string;
        endTime?: string;
    }): Promise<{
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
    static updateClinicAddress(clinicId: string, address: string): Promise<{
        id: string;
        createdAt: Date;
        name: string;
        phone: string;
        address: string;
        updatedAt: Date;
    }>;
    static findClinicById(clinicId: string): Promise<{
        id: string;
        createdAt: Date;
        name: string;
        phone: string;
        address: string;
        updatedAt: Date;
    } | null>;
    static updateVerificationStatus(profileId: string, status: VerificationStatus): Promise<{
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
    static createAvailabilitySlot(data: {
        vetId: string;
        clinicId?: string;
        startTime: Date;
        endTime: Date;
    }): Promise<{
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
    static findSlotById(slotId: string): Promise<{
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    } | null>;
    static findSlotsByVetId(vetId: string): Promise<({
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
    static updateAvailabilitySlot(slotId: string, data: {
        startTime?: Date;
        endTime?: Date;
        isActive?: boolean;
    }): Promise<{
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
    static deleteAvailabilitySlot(slotId: string): Promise<{
        id: string;
        startTime: Date;
        endTime: Date;
        clinicId: string | null;
        vetId: string;
        isActive: boolean;
    }>;
    static findUpcomingAppointments(vetId: string): Promise<({
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
//# sourceMappingURL=vets.repository.d.ts.map