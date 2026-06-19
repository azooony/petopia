import { BookAppointmentDto } from "./appointments.dto";
import { AppointmentsRepository } from "./appointments.repository";
export declare class AppointmentsService {
    private readonly repo;
    constructor(repo: AppointmentsRepository);
    listDoctors(): Promise<{
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
    getMyAppointments(ownerId: string): Promise<({
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
        ownerId: string;
        petOwnerProfileId: string | null;
        status: import("../../../generated/prisma").$Enums.AppointmentStatus;
        vetId: string;
        petId: string;
        clinicName: string | null;
        clinicAddress: string | null;
        reason: string | null;
        price: number;
    })[]>;
    bookAppointment(ownerId: string, dto: BookAppointmentDto, invoiceFile: Express.Multer.File | undefined): Promise<{
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
            ownerId: string;
            petOwnerProfileId: string | null;
            status: import("../../../generated/prisma").$Enums.AppointmentStatus;
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
            petOwnerProfileId: string | null;
            appointmentId: string | null;
            payerId: string;
            method: import("../../../generated/prisma").$Enums.PaymentMethod;
            status: import("../../../generated/prisma").$Enums.PaymentStatus;
            amount: number;
            currency: string;
            proofAssetId: string | null;
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
    private validateWithinWorkingHours;
}
export declare const appointmentsService: AppointmentsService;
//# sourceMappingURL=appointments.service.d.ts.map