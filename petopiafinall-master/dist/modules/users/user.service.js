"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const bcrypt_1 = __importDefault(require("bcrypt"));
const AppError_1 = require("../../common/errors/AppError");
const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || "12");
class UserService {
    // GET CURRENT USER
    static async getMe(userId) {
        const baseUser = await prisma_1.default.user.findUnique({
            where: { id: userId },
            select: { role: true },
        });
        if (!baseUser) {
            throw new AppError_1.AppError("User not found", 404);
        }
        let user;
        if (baseUser.role === "PET_OWNER") {
            user = await prisma_1.default.user.findUnique({
                where: { id: userId },
                include: { ownerProfile: true },
            });
        }
        else if (baseUser.role === "VET") {
            user = await prisma_1.default.user.findUnique({
                where: { id: userId },
                include: { vetProfile: true },
            });
        }
        else {
            user = await prisma_1.default.user.findUnique({
                where: { id: userId },
            });
        }
        if (!user) {
            throw new AppError_1.AppError("User not found", 404);
        }
        const { passwordHash, ...safeUser } = user;
        return {
            id: safeUser.id,
            email: safeUser.email,
            fullName: safeUser.fullName,
            role: safeUser.role,
            createdAt: safeUser.createdAt,
            age: safeUser.age,
            gender: safeUser.gender,
            profile: safeUser.role === "PET_OWNER"
                ? safeUser.ownerProfile ?? null
                : safeUser.role === "VET"
                    ? safeUser.vetProfile ?? null
                    : null,
        };
    }
    // UPDATE PROFILE
    static async updateProfile(userId, role, updateData) {
        const user = await prisma_1.default.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new AppError_1.AppError("User not found", 404);
        }
        if (Object.keys(updateData).length === 0) {
            throw new AppError_1.AppError("No data provided", 400);
        }
        // Shared validations
        if (updateData.fullName && updateData.fullName.trim() === "") {
            throw new AppError_1.AppError("Full name cannot be empty", 400);
        }
        if (updateData.age && (updateData.age < 13 || updateData.age > 120)) {
            throw new AppError_1.AppError("Age must be between 13 and 120", 400);
        }
        if (updateData.phone && updateData.phone.length < 10) {
            throw new AppError_1.AppError("Phone must be at least 10 digits", 400);
        }
        // Email validation
        if (updateData.email) {
            const email = updateData.email.toLowerCase();
            const existing = await prisma_1.default.user.findUnique({
                where: { email },
            });
            if (existing && existing.id !== userId) {
                throw new AppError_1.AppError("Email already in use", 400);
            }
            updateData.email = email;
        }
        //  ROLE-BASED LOGIC
        if (role === "PET_OWNER") {
            return this.updatePetOwnerProfile(userId, updateData);
        }
        if (role === "VET") {
            return this.updateVetProfile(userId, updateData);
        }
        throw new AppError_1.AppError("Invalid role", 400);
    }
    // PET OWNER UPDATE
    static async updatePetOwnerProfile(userId, data) {
        // BLOCK VET FIELDS
        if (data.certificateUrl || data.clinicId || data.yearsOfExperience) {
            throw new AppError_1.AppError("Forbidden fields for pet owner", 403);
        }
        const userData = {};
        const profileData = {};
        if (data.fullName)
            userData.fullName = data.fullName;
        if (data.email)
            userData.email = data.email;
        if (data.age)
            userData.age = data.age;
        if (data.gender)
            userData.gender = data.gender;
        if (data.phone)
            profileData.phone = data.phone;
        if (data.address !== undefined)
            profileData.address = data.address;
        await prisma_1.default.$transaction(async (tx) => {
            if (Object.keys(userData).length > 0) {
                await tx.user.update({
                    where: { id: userId },
                    data: userData,
                });
            }
            if (Object.keys(profileData).length > 0) {
                await tx.petOwnerProfile.update({
                    where: { userId },
                    data: profileData,
                });
            }
        });
        return this.getMe(userId);
    }
    // VET UPDATE
    static async updateVetProfile(userId, data) {
        const userData = {};
        const profileData = {};
        if (data.fullName)
            userData.fullName = data.fullName;
        if (data.email)
            userData.email = data.email;
        if (data.age)
            userData.age = data.age;
        if (data.gender)
            userData.gender = data.gender;
        if (data.phone)
            profileData.phone = data.phone;
        if (data.address !== undefined)
            profileData.address = data.address;
        if (data.yearsOfExperience !== undefined) {
            if (data.yearsOfExperience < 0) {
                throw new AppError_1.AppError("Invalid years of experience", 400);
            }
            profileData.yearsOfExperience = data.yearsOfExperience;
        }
        if (data.description)
            profileData.description = data.description;
        if (data.certificateUrl)
            profileData.certificateUrl = data.certificateUrl;
        if (data.clinicId) {
            const clinic = await prisma_1.default.clinic.findUnique({
                where: { id: data.clinicId },
            });
            if (!clinic) {
                throw new AppError_1.AppError("Clinic not found", 404);
            }
            profileData.clinicId = data.clinicId;
        }
        await prisma_1.default.$transaction(async (tx) => {
            if (Object.keys(userData).length > 0) {
                await tx.user.update({
                    where: { id: userId },
                    data: userData,
                });
            }
            if (Object.keys(profileData).length > 0) {
                await tx.vetProfile.update({
                    where: { userId },
                    data: profileData,
                });
            }
        });
        return this.getMe(userId);
    }
    // UPDATE PASSWORD
    static async updatePassword(userId, currentPassword, newPassword) {
        const user = await prisma_1.default.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new AppError_1.AppError("User not found", 404);
        }
        const isValid = await bcrypt_1.default.compare(currentPassword, user.passwordHash);
        if (!isValid) {
            throw new AppError_1.AppError("Current password is incorrect", 401);
        }
        if (newPassword.length < 6) {
            throw new AppError_1.AppError("New password must be at least 6 characters", 400);
        }
        const newPasswordHash = await bcrypt_1.default.hash(newPassword, SALT_ROUNDS);
        await prisma_1.default.user.update({
            where: { id: userId },
            data: { passwordHash: newPasswordHash },
        });
        return { success: true, message: "Password updated successfully" };
    }
    // DELETE PROFILE
    static async deleteProfile(userId) {
        const user = await prisma_1.default.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new AppError_1.AppError("User not found", 404);
        }
        await prisma_1.default.user.delete({
            where: { id: userId },
        });
        return {
            success: true,
            message: "Profile deleted successfully",
            userId,
        };
    }
}
exports.UserService = UserService;
//# sourceMappingURL=user.service.js.map