import prisma from "../../config/prisma";
import bcrypt from "bcrypt";
import { generateToken } from "../../common/utils/jwt";
import { UserRole, VerificationStatus } from "../../../generated/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";

const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || "12");

export class AuthService {
  // REGISTER PET OWNER
  static async registerPetOwner(data: {
    email: string;
    password: string;
    fullName: string;
    age: number;
    gender: "MALE" | "FEMALE";
    phone: string;
  }) {
    // Check if email already exists
    const existing = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existing) {
      throw new AppError("Email already exists", HttpCode.BAD_REQUEST);
    }

    // Hash password with configurable salt rounds
    const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);

    // Create user with pet owner profile
    const user = await prisma.user.create({
      data: {
        email: data.email,
        passwordHash,
        fullName: data.fullName,
        age: data.age,
        gender: data.gender,
        role: UserRole.PET_OWNER,

        ownerProfile: {
          create: {
            phone: data.phone,
          },
        },
      },
    });

    // Generate JWT token for immediate access
    const token = generateToken({
      userId: user.id,
      role: user.role,
    });

    const { passwordHash: _passwordHash, ...safeUser } = user;
    return { user: safeUser, token };
  }

  // REGISTER VET (PENDING - requires admin approval)
  static async registerVet(
    data: {
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
    },
    certificateFile: Express.Multer.File
  ) {
    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) throw new AppError("Email already exists", HttpCode.BAD_REQUEST);

    // Resolve clinic — use existing or create a new one
    let resolvedClinicId: string;
    if (data.clinicId) {
      const clinic = await prisma.clinic.findUnique({ where: { id: data.clinicId } });
      if (!clinic) throw new AppError("Clinic not found", HttpCode.NOT_FOUND);
      resolvedClinicId = data.clinicId;
    } else {
      if (!data.clinicName || !data.clinicAddress || !data.clinicPhone) {
        throw new AppError(
          "clinicName, clinicAddress, and clinicPhone are required when not providing a clinicId",
          HttpCode.BAD_REQUEST
        );
      }
      const newClinic = await prisma.clinic.create({
        data: {
          name: data.clinicName,
          address: data.clinicAddress,
          phone: data.clinicPhone,
        },
      });
      resolvedClinicId = newClinic.id;
    }

    const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);
    const appointmentPrice = Number(data.appointmentPrice ?? 0);
    const yearsOfExperience = Number(data.yearsOfExperience);
    const age = Number(data.age);

    if (!Number.isFinite(appointmentPrice) || appointmentPrice < 0)
      throw new AppError("appointmentPrice must be a non-negative number", HttpCode.BAD_REQUEST);

    const startTime = (data.startTime ?? "09:00").trim();
    const endTime = (data.endTime ?? "17:00").trim();

    if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(startTime))
      throw new AppError("startTime must use HH:mm format", HttpCode.BAD_REQUEST);
    if (!/^([01]\d|2[0-3]):([0-5]\d)$/.test(endTime))
      throw new AppError("endTime must use HH:mm format", HttpCode.BAD_REQUEST);

    const [sh, sm] = startTime.split(":").map(Number) as [number, number];
    const [eh, em] = endTime.split(":").map(Number) as [number, number];
    if (eh * 60 + em <= sh * 60 + sm)
      throw new AppError("endTime must be after startTime", HttpCode.BAD_REQUEST);

    const certificateImage = `/uploads/certificates/${certificateFile.filename}`;

    const user = await prisma.user.create({
      data: {
        email: data.email,
        passwordHash,
        fullName: data.fullName,
        age,
        gender: data.gender,
        role: UserRole.VET,
        vetProfile: {
          create: {
            phone: data.phone,
            certificateImage,
            clinicId: resolvedClinicId,
            yearsOfExperience,
            appointmentPrice,
            startTime,
            endTime,
            verificationStatus: VerificationStatus.PENDING,
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
  static async login(email: string, password: string) {
    // Find user with vet profile if applicable
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        vetProfile: true,
      },
    });

    if (!user) {
      throw new AppError("Invalid email or password", 401);
    }

    // Verify password
    const valid = await bcrypt.compare(password, user.passwordHash);

    if (!valid) {
      throw new AppError("Invalid email or password", 401);
    }

    // IMPORTANT: Vet must be VERIFIED to login
    if (user.role === UserRole.VET) {
      if (!user.vetProfile) {
        throw new AppError("Vet profile not found", 403);
      }

      if (user.vetProfile.verificationStatus === VerificationStatus.PENDING) {
        throw new AppError("Your account is pending admin approval", 403);
      }

      if (user.vetProfile.verificationStatus === VerificationStatus.REJECTED) {
        throw new AppError("Your account was rejected by admin", 403);
      }
    }

    // Generate JWT token for authenticated user
    const token = generateToken({
      userId: user.id,
      role: user.role,
    });

    const { passwordHash: _passwordHash, ...safeUser } = user;
    return { user: safeUser, token };
  }
}
