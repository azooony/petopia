import { UserRole } from "../../../generated/prisma";
export declare class UserService {
    static getMe(userId: string): Promise<{
        id: string;
        email: string;
        fullName: string;
        role: import("../../../generated/prisma").$Enums.UserRole;
        createdAt: Date;
        age: number;
        gender: import("../../../generated/prisma").$Enums.Gender;
        profile: any;
    }>;
    static updateProfile(userId: string, role: UserRole, updateData: any): Promise<{
        id: string;
        email: string;
        fullName: string;
        role: import("../../../generated/prisma").$Enums.UserRole;
        createdAt: Date;
        age: number;
        gender: import("../../../generated/prisma").$Enums.Gender;
        profile: any;
    }>;
    static updatePetOwnerProfile(userId: string, data: any): Promise<{
        id: string;
        email: string;
        fullName: string;
        role: import("../../../generated/prisma").$Enums.UserRole;
        createdAt: Date;
        age: number;
        gender: import("../../../generated/prisma").$Enums.Gender;
        profile: any;
    }>;
    static updateVetProfile(userId: string, data: any): Promise<{
        id: string;
        email: string;
        fullName: string;
        role: import("../../../generated/prisma").$Enums.UserRole;
        createdAt: Date;
        age: number;
        gender: import("../../../generated/prisma").$Enums.Gender;
        profile: any;
    }>;
    static updatePassword(userId: string, currentPassword: string, newPassword: string): Promise<{
        success: boolean;
        message: string;
    }>;
    static deleteProfile(userId: string): Promise<{
        success: boolean;
        message: string;
        userId: string;
    }>;
}
//# sourceMappingURL=user.service.d.ts.map