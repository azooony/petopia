import prisma from "../../config/prisma";
import {
  SitterProfile,
  SitterImage,
  SitterAvailability,
  SittingBooking,
  SitterReview,
  SitterVerificationStatus,
  SittingBookingStatus,
} from "../../../generated/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import {
  SitterProfileData,
  SitterImageData,
  SitterAvailabilityData,
  SittingBookingData,
  SitterReviewData,
  SearchSittersFilters,
  ListPetForSittingData,
  AvailablePetResult,
} from "./sitting.types";

export class SittingRepository {
  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Profile Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSitterProfile(data: SitterProfileData): Promise<SitterProfile> {
    const existing = await prisma.sitterProfile.findUnique({
      where: { userId: data.userId },
    });

    if (existing) {
      throw new AppError(
        "Sitter profile already exists for this user",
        HttpCode.BAD_REQUEST
      );
    }

    return prisma.sitterProfile.create({
      data: {
        userId: data.userId,
        bio: data.bio || null,
        IdCardImage: data.idCardImage ?? '',
        supportedPetTypes: data.supportedPetTypes,
        maxPets: data.maxPets,
        city: data.city,
        address: data.address,
        emergencyContact: data.emergencyContact,
        isAvailable: data.isAvailable,
      },
    });
  }

  static async getSitterProfileByUserId(userId: string): Promise<SitterProfile | null> {
    return prisma.sitterProfile.findUnique({
      where: { userId },
      include: {
        images: true,
        availabilitySlots: true,
        reviews: true,
      },
    });
  }

  static async getSitterProfileById(id: string): Promise<SitterProfile | null> {
    return prisma.sitterProfile.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            fullName: true,
            createdAt: true,
          },
        },
        images: true,
        availabilitySlots: true,
        reviews: {
          include: {
            reviewer: {
              select: {
                id: true,
                fullName: true,
              },
            },
          },
        },
      },
    });
  }

  static async updateSitterProfile(
    userId: string,
    updates: Partial<SitterProfileData>
  ): Promise<SitterProfile> {
    const data: Record<string, unknown> = {};

    if (updates.bio !== undefined) data.bio = updates.bio;
    if (updates.supportedPetTypes !== undefined) data.supportedPetTypes = updates.supportedPetTypes;
    if (updates.maxPets !== undefined) data.maxPets = updates.maxPets;
    if (updates.city !== undefined) data.city = updates.city;
    if (updates.address !== undefined) data.address = updates.address;
    if (updates.emergencyContact !== undefined) data.emergencyContact = updates.emergencyContact;
    if (updates.isAvailable !== undefined) data.isAvailable = updates.isAvailable;

    return prisma.sitterProfile.update({
      where: { userId },
      data,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Image Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSitterImage(data: SitterImageData): Promise<SitterImage> {
    // If this is the primary image, unset other primary images
    if (data.isPrimary) {
      await prisma.sitterImage.updateMany({
        where: { sitterProfileId: data.sitterProfileId },
        data: { isPrimary: false },
      });
    }

    return prisma.sitterImage.create({
      data: {
        sitterProfileId: data.sitterProfileId,
        imageUrl: data.imageUrl,
        storageKey: data.storageKey,
        isPrimary: data.isPrimary || false,
      },
    });
  }

  static async getSitterImages(sitterProfileId: string): Promise<SitterImage[]> {
    return prisma.sitterImage.findMany({
      where: { sitterProfileId },
      orderBy: { isPrimary: "desc" },
    });
  }

  static async deleteSitterImage(id: string): Promise<SitterImage | null> {
    return prisma.sitterImage.delete({
      where: { id },
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Availability Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async addAvailability(data: SitterAvailabilityData): Promise<SitterAvailability> {
    // Check for overlapping availability
    const overlapping = await prisma.sitterAvailability.findFirst({
      where: {
        sitterProfileId: data.sitterProfileId,
        OR: [
          {
            startDate: { lte: data.endDate },
            endDate: { gte: data.startDate },
          },
        ],
      },
    });

    if (overlapping) {
      throw new AppError(
        "This availability range overlaps with existing availability",
        HttpCode.BAD_REQUEST
      );
    }

    return prisma.sitterAvailability.create({
      data: {
        sitterProfileId: data.sitterProfileId,
        userId: data.userId,
        startDate: data.startDate,
        endDate: data.endDate,
      },
    });
  }

  static async getSitterAvailability(sitterProfileId: string): Promise<SitterAvailability[]> {
    return prisma.sitterAvailability.findMany({
      where: { sitterProfileId },
      orderBy: { startDate: "asc" },
    });
  }

  static async deleteAvailability(id: string): Promise<SitterAvailability | null> {
    return prisma.sitterAvailability.delete({
      where: { id },
    });
  }

  static async checkAvailability(
    sitterProfileId: string,
    startDate: Date,
    endDate: Date
  ): Promise<boolean> {
    const slot = await prisma.sitterAvailability.findFirst({
      where: {
        sitterProfileId,
        startDate: { lte: startDate },
        endDate: { gte: endDate },
      },
    });

    return !!slot;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitting Booking Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSittingBooking(data: SittingBookingData): Promise<SittingBooking> {
    // Calculate total days
    const totalDays = Math.ceil(
      (data.endDate.getTime() - data.startDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    // Check for overlapping accepted bookings
    const overlapping = await prisma.sittingBooking.findFirst({
      where: {
        sitterProfileId: data.sitterProfileId,
        status: SittingBookingStatus.ACCEPTED,
        startDate: { lte: data.endDate },
        endDate: { gte: data.startDate },
      },
    });

    if (overlapping) {
      throw new AppError(
        "Sitter has an accepted booking during this period",
        HttpCode.BAD_REQUEST
      );
    }

    return prisma.sittingBooking.create({
      data: {
        sitterProfileId: data.sitterProfileId,
        sitterId: data.sitterId,
        petOwnerId: data.petOwnerId,
        petId: data.petId,
        startDate: data.startDate,
        endDate: data.endDate,
        totalDays,
        ownerNotes: data.ownerNotes || null,
        emergencyPhone: data.emergencyPhone,
        status: SittingBookingStatus.PENDING,
      },
    });
  }

  static async getSittingBookingById(id: string): Promise<SittingBooking | null> {
    return prisma.sittingBooking.findUnique({
      where: { id },
      include: {
        sitterProfile: true,
        sitter: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
        petOwner: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
        pet: {
          select: {
            id: true,
            name: true,
            breed: true,
            age: true,
          },
        },
        review: true,
      },
    });
  }

  static async getSitterBookings(
    sitterId: string,
    status?: SittingBookingStatus,
    page: number = 1,
    limit: number = 10
  ) {
    const skip = (page - 1) * limit;

    const where = {
      sitterId,
      ...(status && { status }),
    };

    const [bookings, total] = await Promise.all([
      prisma.sittingBooking.findMany({
        where,
        include: {
          petOwner: {
            select: {
              id: true,
              fullName: true,
              email: true,
            },
          },
          pet: {
            select: {
              id: true,
              name: true,
              breed: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.sittingBooking.count({ where }),
    ]);

    return { bookings, total };
  }

  static async getOwnerBookings(
    ownerId: string,
    status?: SittingBookingStatus,
    page: number = 1,
    limit: number = 10
  ) {
    const skip = (page - 1) * limit;

    const where = {
      petOwnerId: ownerId,
      ...(status && { status }),
    };

    const [bookings, total] = await Promise.all([
      prisma.sittingBooking.findMany({
        where,
        include: {
          sitterProfile: {
            include: {
              user: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                },
              },
            },
          },
          pet: {
            select: {
              id: true,
              name: true,
              breed: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
      prisma.sittingBooking.count({ where }),
    ]);

    return { bookings, total };
  }

  static async updateBookingStatus(
    id: string,
    status: SittingBookingStatus
  ): Promise<SittingBooking> {
    return prisma.sittingBooking.update({
      where: { id },
      data: { status },
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Review Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSitterReview(data: SitterReviewData): Promise<SitterReview> {
    // Check if review already exists for this booking
    const existing = await prisma.sitterReview.findUnique({
      where: { bookingId: data.bookingId },
    });

    if (existing) {
      throw new AppError(
        "A review already exists for this booking",
        HttpCode.BAD_REQUEST
      );
    }

    // Use transaction to create review and update sitter rating
    return prisma.$transaction(async (tx) => {
      const review = await tx.sitterReview.create({
        data: {
          bookingId: data.bookingId,
          sitterProfileId: data.sitterProfileId,
          reviewerUserId: data.reviewerUserId,
          rating: data.rating,
          comment: data.comment || null,
        },
      });

      // Get all reviews for the sitter
      const reviews = await tx.sitterReview.findMany({
        where: { sitterProfileId: data.sitterProfileId },
        select: { rating: true },
      });

      // Calculate average rating
      const avgRating =
        reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;

      // Update sitter profile
      await tx.sitterProfile.update({
        where: { id: data.sitterProfileId },
        data: {
          ratingAverage: avgRating,
          totalReviews: reviews.length,
        },
      });

      return review;
    });
  }

  static async getSitterReviews(sitterProfileId: string): Promise<SitterReview[]> {
    return prisma.sitterReview.findMany({
      where: { sitterProfileId },
      include: {
        reviewer: {
          select: {
            id: true,
            fullName: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Search and Filter Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async searchSitters(filters: SearchSittersFilters) {
    const skip = (filters.page - 1) * filters.limit;

    const where: Record<string, unknown> = {
      verificationStatus: SitterVerificationStatus.APPROVED,
      isAvailable: true,
    };

    if (filters.city) {
      where.city = { contains: filters.city, mode: "insensitive" };
    }

    if (filters.minRating !== undefined) {
      where.ratingAverage = { gte: filters.minRating };
    }

    if (filters.maxRating !== undefined) {
      if (where.ratingAverage && typeof where.ratingAverage === "object") {
        (where.ratingAverage as Record<string, number>).lte = filters.maxRating;
      } else {
        where.ratingAverage = { lte: filters.maxRating };
      }
    }

    // Determine sort order
    let orderBy: Record<string, string> = { createdAt: "desc" };
    if (filters.sortBy === "rating") {
      orderBy = { ratingAverage: "desc" };
    } else if (filters.sortBy === "newest") {
      orderBy = { createdAt: "desc" };
    } else if (filters.sortBy === "booked") {
      orderBy = { totalReviews: "desc" };
    }

    const [sitters, total] = await Promise.all([
      prisma.sitterProfile.findMany({
        where: where as any,
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
            },
          },
          images: {
            take: 1,
          },
        },
        orderBy,
        skip,
        take: filters.limit,
      }),
      prisma.sitterProfile.count({ where: where as any }),
    ]);

    return { sitters, total };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Admin Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async getPendingSitters(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const [sitters, total] = await Promise.all([
      prisma.sitterProfile.findMany({
        where: { verificationStatus: SitterVerificationStatus.PENDING },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
            },
          },
          images: true,
        },
        orderBy: { createdAt: "asc" },
        skip,
        take: limit,
      }),
      prisma.sitterProfile.count({
        where: { verificationStatus: SitterVerificationStatus.PENDING },
      }),
    ]);

    return { sitters, total };
  }

  static async approveSitterProfile(id: string): Promise<SitterProfile> {
    return prisma.sitterProfile.update({
      where: { id },
      data: { verificationStatus: SitterVerificationStatus.APPROVED },
    });
  }

  static async rejectSitterProfile(id: string): Promise<SitterProfile> {
    return prisma.sitterProfile.update({
      where: { id },
      data: { verificationStatus: SitterVerificationStatus.REJECTED },
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Pet Listing for Sitting
  // ─────────────────────────────────────────────────────────────────────────────

  static async upsertPetForSitting(
    userId: string,
    data: ListPetForSittingData
  ) {
    return prisma.pet.upsert({
      where: { ownerId: userId },
      update: {
        name: data.name,
        breed: data.breed ?? null,
        age: data.age,
        gender: (data.gender as any) ?? null,
        petType: (data.petType ?? 'DOG') as any,
        isAvailableForSitting: true,
        payRatePerDay: data.payRatePerDay,
        sittingNotes: data.sittingNotes ?? null,
        ...(data.photo !== undefined ? { photo: data.photo } : {}),
      },
      create: {
        ownerId: userId,
        name: data.name,
        breed: data.breed ?? null,
        age: data.age,
        gender: (data.gender as any) ?? null,
        petType: (data.petType ?? 'DOG') as any,
        isAvailableForSitting: true,
        payRatePerDay: data.payRatePerDay,
        sittingNotes: data.sittingNotes ?? null,
        photo: data.photo ?? null,
      },
    });
  }

  static async unlistPetFromSitting(userId: string) {
    const pet = await prisma.pet.findUnique({ where: { ownerId: userId } });
    if (!pet) return null;
    return prisma.pet.update({
      where: { ownerId: userId },
      data: { isAvailableForSitting: false, payRatePerDay: null, sittingNotes: null },
    });
  }

  static async getAvailablePets(
    requesterId: string,
    petType?: string
  ): Promise<AvailablePetResult[]> {
    const pets = await prisma.pet.findMany({
      where: {
        isAvailableForSitting: true,
        ...(petType && { petType: petType as any }),
      },
      include: {
        owner: {
          select: {
            id: true,
            fullName: true,
            ownerProfile: { select: { address: true } },
          },
        },
      },
    });
    return pets.map((pet) => ({
      id: pet.id,
      name: pet.name,
      breed: pet.breed,
      age: pet.age,
      gender: pet.gender,
      petType: (pet as any).petType ?? 'DOG',
      photo: pet.photo,
      payRatePerDay: pet.payRatePerDay,
      sittingNotes: pet.sittingNotes,
      ownerId: pet.owner.id,
      ownerName: pet.owner.fullName,
      ownerAddress: pet.owner.ownerProfile?.address ?? "",
      isOwn: pet.ownerId === requesterId,
    }));
  }

  static async getSitterStatus(userId: string): Promise<string | null> {
    const profile = await prisma.sitterProfile.findUnique({
      where: { userId },
      select: { verificationStatus: true },
    });
    return profile?.verificationStatus ?? null;
  }

  static async createOrUpdateSitterRegistration(
    userId: string,
    idCardImageUrl: string,
    venuePhotoUrl: string
  ): Promise<SitterProfile> {
    return prisma.sitterProfile.upsert({
      where: { userId },
      update: {
        IdCardImage: idCardImageUrl,
        venuePhotoUrl,
        verificationStatus: SitterVerificationStatus.PENDING,
      },
      create: {
        userId,
        IdCardImage: idCardImageUrl,
        venuePhotoUrl,
        supportedPetTypes: [],
        maxPets: 3,
        city: "",
        address: "",
        emergencyContact: "",
        isAvailable: false,
        verificationStatus: SitterVerificationStatus.PENDING,
      },
    });
  }
}
