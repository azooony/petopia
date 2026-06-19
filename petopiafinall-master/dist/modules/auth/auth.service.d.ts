export declare class AuthService {
    static registerPetOwner(data: {
        email: string;
        password: string;
        fullName: string;
        age: number;
        gender: "MALE" | "FEMALE";
        phone: string;
    }): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
            profilePicture: string | null;
        };
        token: string;
    }>;
    static registerVet(data: {
        email: string;
        password: string;
        fullName: string;
        age: number | string;
        gender: "MALE" | "FEMALE";
        phone: string;
        clinicId?: string;
        clinicName?: string;
        clinicAddress?: string;
        clinicPhone?: string;
        yearsOfExperience: number | string;
        appointmentPrice?: number | string;
        startTime?: string;
        endTime?: string;
    }, certificateFile: Express.Multer.File, photoFile: Express.Multer.File): Promise<{
        message: string;
        user: {
            vetProfile: {
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
            } | null;
            id: string;
            email: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
            profilePicture: string | null;
        };
    }>;
    static login(email: string, password: string): Promise<{
        user: {
            vetProfile: {
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
            } | null;
            id: string;
            email: string;
            fullName: string;
            age: number;
            role: import("../../../generated/prisma").$Enums.UserRole;
            createdAt: Date;
            gender: import("../../../generated/prisma").$Enums.Gender;
            profilePicture: string | null;
        };
        token: string;
    }>;
}
//# sourceMappingURL=auth.service.d.ts.map