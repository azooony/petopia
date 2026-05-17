"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const bcrypt_1 = __importDefault(require("bcrypt"));
const jwt_1 = require("../../common/utils/jwt");
const prisma_2 = require("../../../generated/prisma");
const AppError_1 = require("../../common/errors/AppError");
const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || "12");
class AuthService {
    // REGISTER PET OWNER
    static async registerPetOwner(data) {
        // Check if email already exists
        const existing = await prisma_1.default.user.findUnique({
            where: { email: data.email },
        });
        if (existing) {
            throw new AppError_1.AppError("Email already exists", AppError_1.HttpCode.BAD_REQUEST);
        }
        // Hash password with configurable salt rounds
        const passwordHash = await bcrypt_1.default.hash(data.password, SALT_ROUNDS);
        // Create user with pet owner profile
        const user = await prisma_1.default.user.create({
            data: {
                email: data.email,
                passwordHash,
                fullName: data.fullName,
                age: data.age,
                gender: data.gender,
                role: prisma_2.UserRole.PET_OWNER,
                ownerProfile: {
                    create: {
                        phone: data.phone,
                    },
                },
            },
        });
        // Generate JWT token for immediate access
        const token = (0, jwt_1.generateToken)({
            userId: user.id,
            role: user.role,
        });
        const { passwordHash: _passwordHash, ...safeUser } = user;
        return { user: safeUser, token };
    }
    // REGISTER VET (PENDING - requires admin approval)
    static async registerVet(data, certificateFile) {
        const existing = await prisma_1.default.user.findUnique({ where: { email: data.email } });
        if (existing)
            throw new AppError_1.AppError("Email already exists", AppError_1.HttpCode.BAD_REQUEST);
        // Resolve clinic — use existing or create a new one
        let resolvedClinicId;
        if (data.clinicId) {
            const clinic = await prisma_1.default.clinic.findUnique({ where: { id: data.clinicId } });
            if (!clinic)
                throw new AppError_1.AppError("Clinic not found", AppError_1.HttpCode.NOT_FOUND);
            resolvedClinicId = data.clinicId;
        }
        else {
            if (!data.clinicName || !data.clinicAddress || !data.clinicPhone) {
                throw new AppError_1.AppError("clinicName, clinicAddress, and clinicPhone are required when not providing a clinicId", AppError_1.HttpCode.BAD_REQUEST);
            }
            const newClinic = await prisma_1.default.clinic.create({
                data: {
                    name: data.clinicName,
                    address: data.clinicAddress,
                    phone: data.clinicPhone,
                },
            });
            resolvedClinicId = newClinic.id;
        }
        const passwordHash = await bcrypt_1.default.hash(data.password, SALT_ROUNDS);
        const appointmentPrice = Number(data.appointmentPrice ?? 0);
        const yearsOfExperience = Number(data.yearsOfExperience);
        const age = Number(data.age);
        if (!Number.isFinite(appointmentPrice) || appointmentPrice < 0)
            throw new AppError_1.AppError("appointmentPrice must be a non-negative number", AppError_1.HttpCode.BAD_REQUEST);
        const startTime = (data.startTime ?? "09:00").trim();
        const endTime = (data.endTime ?? "17:00").trim();
        if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(startTime))
            throw new AppError_1.AppError("startTime must use HH:mm format", AppError_1.HttpCode.BAD_REQUEST);
        if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(endTime))
            throw new AppError_1.AppError("endTime must use HH:mm format", AppError_1.HttpCode.BAD_REQUEST);
        const [sh, sm] = startTime.split(":").map(Number);
        const [eh, em] = endTime.split(":").map(Number);
        if (eh * 60 + em <= sh * 60 + sm)
            throw new AppError_1.AppError("endTime must be after startTime", AppError_1.HttpCode.BAD_REQUEST);
        const certificateImage = `/uploads/certificates/${certificateFile.filename}`;
        const user = await prisma_1.default.user.create({
            data: {
                email: data.email,
                passwordHash,
                fullName: data.fullName,
                age,
                gender: data.gender,
                role: prisma_2.UserRole.VET,
                vetProfile: {
                    create: {
                        phone: data.phone,
                        certificateImage,
                        clinicId: resolvedClinicId,
                        yearsOfExperience,
                        appointmentPrice,
                        startTime,
                        endTime,
                        verificationStatus: prisma_2.VerificationStatus.PENDING,
                    },
                },
            },
            include: { vetProfile: true },
        });
        const { passwordHash: _passwordHash, ...safeUser } = user;
        return {
            message: "Vet registered successfully. Waiting for admin approval.",
            user: safeUser,
        };
    }
    // LOGIN
    static async login(email, password) {
        // Find user with vet profile if applicable
        const user = await prisma_1.default.user.findUnique({
            where: { email },
            include: {
                vetProfile: true,
            },
        });
        if (!user) {
            throw new AppError_1.AppError("Invalid email or password", 401);
        }
        // Verify password
        const valid = await bcrypt_1.default.compare(password, user.passwordHash);
        if (!valid) {
            throw new AppError_1.AppError("Invalid email or password", 401);
        }
        // IMPORTANT: Vet must be VERIFIED to login
        if (user.role === prisma_2.UserRole.VET) {
            if (!user.vetProfile) {
                throw new AppError_1.AppError("Vet profile not found", 403);
            }
            if (user.vetProfile.verificationStatus === prisma_2.VerificationStatus.PENDING) {
                throw new AppError_1.AppError("Your account is pending admin approval", 403);
            }
            if (user.vetProfile.verificationStatus === prisma_2.VerificationStatus.REJECTED) {
                throw new AppError_1.AppError("Your account was rejected by admin", 403);
            }
        }
        // Generate JWT token for authenticated user
        const token = (0, jwt_1.generateToken)({
            userId: user.id,
            role: user.role,
        });
        const { passwordHash: _passwordHash, ...safeUser } = user;
        return { user: safeUser, token };
    }
}
exports.AuthService = AuthService;
//# sourceMappingURL=auth.service.js.map