import { AdminRepository } from "./admin.repository";
import type { AdminLoginDto } from "./admin.dto";
export declare class AdminService {
    private readonly repo;
    constructor(repo: AdminRepository);
    login(dto: AdminLoginDto): Promise<{
        token: string;
        admin: {
            id: string;
            email: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
        };
    }>;
    getPendingVets(): Promise<({
        user: {
            id: string;
            email: string;
            fullName: string;
            createdAt: Date;
        };
        clinic: {
            id: string;
            name: string;
            address: string;
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
    })[]>;
    approveVet(vetProfileId: string, adminId: string): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
        };
        clinic: {
            id: string;
            name: string;
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
    rejectVet(vetProfileId: string, adminId: string): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
        };
        clinic: {
            id: string;
            name: string;
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
    getPendingSitters(): Promise<({
        user: {
            id: string;
            email: string;
            fullName: string;
        };
        images: {
            id: string;
            createdAt: Date;
            imageUrl: string;
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
    })[]>;
    approveSitter(serviceId: string, adminId: string): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
        };
        images: {
            id: string;
            imageUrl: string;
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
    }>;
    rejectSitter(serviceId: string, adminId: string): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
        };
        images: {
            id: string;
            imageUrl: string;
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
    }>;
    getPendingPayments(): Promise<({
        appointment: ({
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
        }) | null;
        payer: {
            id: string;
            email: string;
            fullName: string;
        };
        proofAsset: {
            id: string;
            url: string;
        } | null;
    } & {
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
    })[]>;
    approvePayment(paymentId: string, adminId: string): Promise<{
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
        appointment: {
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
    }>;
    rejectPayment(paymentId: string, adminId: string): Promise<{
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
        appointment: {
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
    }>;
}
export declare const adminService: AdminService;
//# sourceMappingURL=admin.service.d.ts.map