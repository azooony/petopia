import prisma from "../../config/prisma";
import bcrypt from "bcrypt";
import { UserRole } from "../../../generated/prisma";
import { AppError } from "../../common/errors/AppError";

const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS || "12");

export class UserService {


  // GET CURRENT USER

  static async getMe(userId: string) {
    const baseUser = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (!baseUser) {
      throw new AppError("User not found", 404);
    }

    let user;

    if (baseUser.role === "PET_OWNER") {
      user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          ownerProfile: true,
          pets: {
            include: {
              images: { include: { asset: true } },
            },
          },
        },
      });
    } else if (baseUser.role === "VET") {
      user = await prisma.user.findUnique({
        where: { id: userId },
        include: { vetProfile: true },
      });
    } else {
      user = await prisma.user.findUnique({
        where: { id: userId },
      });
    }

    if (!user) {
      throw new AppError("User not found", 404);
    }

    const { passwordHash, ...safeUser } = user;

    const ownerProfile = (safeUser as any).ownerProfile ?? null;

    return {
      id: safeUser.id,
      email: safeUser.email,
      fullName: safeUser.fullName,
      role: safeUser.role,
      createdAt: safeUser.createdAt,
      age: safeUser.age,
      gender: safeUser.gender,
      profilePicture: (safeUser as any).profilePicture ?? null,
      address: ownerProfile?.address ?? '',
      pets: safeUser.role === "PET_OWNER" ? (safeUser as any).pets ?? null : null,
      profile:
        safeUser.role === "PET_OWNER"
          ? ownerProfile
          : safeUser.role === "VET"
          ? (safeUser as any).vetProfile ?? null
          : null,
    };
  }

  // UPDATE PROFILE

  static async updateProfile(
    userId: string,
    role: UserRole,
    updateData: any
  ) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    if (Object.keys(updateData).length === 0) {
      throw new AppError("No data provided", 400);
    }

    // Shared validations
    if (updateData.fullName && updateData.fullName.trim() === "") {
      throw new AppError("Full name cannot be empty", 400);
    }

    if (updateData.age && (updateData.age < 13 || updateData.age > 120)) {
      throw new AppError("Age must be between 13 and 120", 400);
    }

    if (updateData.phone && updateData.phone.length < 10) {
      throw new AppError("Phone must be at least 10 digits", 400);
    }

    // Email validation
    if (updateData.email) {
      const email = updateData.email.toLowerCase();

      const existing = await prisma.user.findUnique({
        where: { email },
      });

      if (existing && existing.id !== userId) {
        throw new AppError("Email already in use", 400);
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

    throw new AppError("Invalid role", 400);
  }


  // PET OWNER UPDATE

  static async updatePetOwnerProfile(userId: string, data: any) {

    // BLOCK VET FIELDS
    if (data.certificateUrl || data.clinicId || data.yearsOfExperience) {
      throw new AppError("Forbidden fields for pet owner", 403);
    }

    const userData: any = {};
    const profileData: any = {};

    if (data.fullName) userData.fullName = data.fullName;
    if (data.email) userData.email = data.email;
    if (data.age) userData.age = data.age;
    if (data.gender) userData.gender = data.gender;

    if (data.phone) profileData.phone = data.phone;
    if (data.address !== undefined) profileData.address = data.address;

    await prisma.$transaction(async (tx) => {

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
  static async updateVetProfile(userId: string, data: any) {

    const userData: any = {};
    const profileData: any = {};

    if (data.fullName) userData.fullName = data.fullName;
    if (data.email) userData.email = data.email;
    if (data.age) userData.age = data.age;
    if (data.gender) userData.gender = data.gender;

    if (data.phone) profileData.phone = data.phone;
    if (data.address !== undefined) profileData.address = data.address;

    if (data.yearsOfExperience !== undefined) {
      if (data.yearsOfExperience < 0) {
        throw new AppError("Invalid years of experience", 400);
      }
      profileData.yearsOfExperience = data.yearsOfExperience;
    }

    if (data.description) profileData.description = data.description;
    if (data.certificateUrl) profileData.certificateUrl = data.certificateUrl;

    if (data.clinicId) {
      const clinic = await prisma.clinic.findUnique({
        where: { id: data.clinicId },
      });

      if (!clinic) {
        throw new AppError("Clinic not found", 404);
      }

      profileData.clinicId = data.clinicId;
    }

    await prisma.$transaction(async (tx) => {

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

  static async updatePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    const isValid = await bcrypt.compare(currentPassword, user.passwordHash);

    if (!isValid) {
      throw new AppError("Current password is incorrect", 401);
    }

    if (newPassword.length < 6) {
      throw new AppError("New password must be at least 6 characters", 400);
    }

    const newPasswordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);

    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newPasswordHash },
    });

    return { success: true, message: "Password updated successfully" };
  }


  // DELETE PROFILE

  static async deleteProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    await prisma.user.delete({
      where: { id: userId },
    });

    return {
      success: true,
      message: "Profile deleted successfully",
      userId,
    };
  }

  // UPLOAD AVATAR

  static async uploadAvatar(userId: string, avatarUrl: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppError("User not found", 404);

    await prisma.user.update({
      where: { id: userId },
      data: { profilePicture: avatarUrl },
    });

    return this.getMe(userId);
  }

  // BLOCK USER

  static async blockUser(blockerId: string, blockedId: string) {
    if (blockerId === blockedId) {
      throw new AppError("You cannot block yourself.", 400);
    }
    const target = await prisma.user.findUnique({ where: { id: blockedId } });
    if (!target) throw new AppError("User not found.", 404);

    await prisma.userBlock.upsert({
      where: { blockerId_blockedId: { blockerId, blockedId } },
      create: { blockerId, blockedId },
      update: {},
    });
  }
}