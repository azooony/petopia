import { PrismaClient } from "../../../generated/prisma";
export declare class ConflictError extends Error {
    constructor();
}
export declare class AppointmentsRepository {
    private readonly db;
    constructor(db: PrismaClient);
    listVerifiedVets(): Promise<{
        id: string;
        email: string;
        fullName: string;
        availabilitySlots: {
            id: string;
            startTime: Date;
            endTime: Date;
        }[];
        vetProfile: {
            id: string;
            phone: string;
            clinic: {
                id: string;
                name: string;
                phone: string;
                address: string;
            };
            description: string | null;
            yearsOfExperience: number;
            appointmentPrice: number;
            startTime: string;
            endTime: string;
            photo: string | null;
            specialization: string | null;
            verificationStatus: import("../../../generated/prisma").$Enums.VerificationStatus;
        } | null;
    }[]>;
    findVetWithProfile(vetId: string): Promise<({
        vetProfile: ({
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
        }) | null;
    } & {
        id: string;
        email: string;
        passwordHash: string;
        fullName: string;
        age: number;
        role: import("../../../generated/prisma").$Enums.UserRole;
        createdAt: Date;
        gender: import("../../../generated/prisma").$Enums.Gender;
    }) | null>;
    findMyAppointments(ownerId: string): Promise<({
        pet: {
            id: string;
            name: string;
        };
        vet: {
            id: string;
            fullName: string;
            vetProfile: {
                photo: string | null;
                specialization: string | null;
            } | null;
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
    findPetForOwner(petId: string, ownerId: string): Promise<{
        id: string;
        petOwnerProfileId: string | null;
    } | null>;
    bookAtomically(data: {
        ownerId: string;
        vetId: string;
        petId: string;
        startTime: Date;
        price: number;
        clinicName: string;
        clinicAddress: string;
        reason?: string;
        petOwnerProfileId?: string;
        invoiceUrl: string;
        invoiceStorageKey: string;
        invoiceMimeType: string;
        invoiceSizeBytes: number;
    }): Promise<{
        appointment: {
            pet: {
                id: string;
                name: string;
                breed: string | null;
            };
            owner: {
                id: string;
                email: string;
                fullName: string;
            };
            vet: {
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
        };
        payment: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            appointmentId: string | null;
            payerId: string;
            method: import("../../../generated/prisma").$Enums.PaymentMethod;
            status: import("../../../generated/prisma").$Enums.PaymentStatus;
            amount: number;
            currency: string;
            proofAssetId: string | null;
            petOwnerProfileId: string | null;
        };
        asset: {
            id: string;
            createdAt: Date;
            storageKey: string | null;
            url: string;
            mimeType: string | null;
            sizeBytes: number | null;
            uploadedById: string | null;
        };
    }>;
}
export declare const appointmentsRepository: AppointmentsRepository;
//# sourceMappingURL=appointments.repository.d.ts.map