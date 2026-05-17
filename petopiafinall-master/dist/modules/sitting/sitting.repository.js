"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SittingRepository = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const prisma_2 = require("../../../generated/prisma");
const AppError_1 = require("../../common/errors/AppError");
class SittingRepository {
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Profile Operations
    // ─────────────────────────────────────────────────────────────────────────────
    static async createSitterProfile(data) {
        const existing = await prisma_1.default.sitterProfile.findUnique({
            where: { userId: data.userId },
        });
        if (existing) {
            throw new AppError_1.AppError("Sitter profile already exists for this user", AppError_1.HttpCode.BAD_REQUEST);
        }
        return prisma_1.default.sitterProfile.create({
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
    static async getSitterProfileByUserId(userId) {
        return prisma_1.default.sitterProfile.findUnique({
            where: { userId },
            include: {
                images: true,
                availabilitySlots: true,
                reviews: true,
            },
        });
    }
    static async getSitterProfileById(id) {
        return prisma_1.default.sitterProfile.findUnique({
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
    static async updateSitterProfile(userId, updates) {
        const data = {};
        if (updates.bio !== undefined)
            data.bio = updates.bio;
        if (updates.supportedPetTypes !== undefined)
            data.supportedPetTypes = updates.supportedPetTypes;
        if (updates.maxPets !== undefined)
            data.maxPets = updates.maxPets;
        if (updates.city !== undefined)
            data.city = updates.city;
        if (updates.address !== undefined)
            data.address = updates.address;
        if (updates.emergencyContact !== undefined)
            data.emergencyContact = updates.emergencyContact;
        if (updates.isAvailable !== undefined)
            data.isAvailable = updates.isAvailable;
        return prisma_1.default.sitterProfile.update({
            where: { userId },
            data,
        });
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Image Operations
    // ─────────────────────────────────────────────────────────────────────────────
    static async createSitterImage(data) {
        // If this is the primary image, unset other primary images
        if (data.isPrimary) {
            await prisma_1.default.sitterImage.updateMany({
                where: { sitterProfileId: data.sitterProfileId },
                data: { isPrimary: false },
            });
        }
        return prisma_1.default.sitterImage.create({
            data: {
                sitterProfileId: data.sitterProfileId,
                imageUrl: data.imageUrl,
                storageKey: data.storageKey,
                isPrimary: data.isPrimary || false,
            },
        });
    }
    static async getSitterImages(sitterProfileId) {
        return prisma_1.default.sitterImage.findMany({
            where: { sitterProfileId },
            orderBy: { isPrimary: "desc" },
        });
    }
    static async deleteSitterImage(id) {
        return prisma_1.default.sitterImage.delete({
            where: { id },
        });
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Availability Operations
    // ─────────────────────────────────────────────────────────────────────────────
    static async addAvailability(data) {
        // Check for overlapping availability
        const overlapping = await prisma_1.default.sitterAvailability.findFirst({
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
            throw new AppError_1.AppError("This availability range overlaps with existing availability", AppError_1.HttpCode.BAD_REQUEST);
        }
        return prisma_1.default.sitterAvailability.create({
            data: {
                sitterProfileId: data.sitterProfileId,
                userId: data.userId,
                startDate: data.startDate,
                endDate: data.endDate,
            },
        });
    }
    static async getSitterAvailability(sitterProfileId) {
        return prisma_1.default.sitterAvailability.findMany({
            where: { sitterProfileId },
            orderBy: { startDate: "asc" },
        });
    }
    static async deleteAvailability(id) {
        return prisma_1.default.sitterAvailability.delete({
            where: { id },
        });
    }
    static async checkAvailability(sitterProfileId, startDate, endDate) {
        const slot = await prisma_1.default.sitterAvailability.findFirst({
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
    static async createSittingBooking(data) {
        // Calculate total days
        const totalDays = Math.ceil((data.endDate.getTime() - data.startDate.getTime()) / (1000 * 60 * 60 * 24));
        // Check for overlapping accepted bookings
        const overlapping = await prisma_1.default.sittingBooking.findFirst({
            where: {
                sitterProfileId: data.sitterProfileId,
                status: prisma_2.SittingBookingStatus.ACCEPTED,
                startDate: { lte: data.endDate },
                endDate: { gte: data.startDate },
            },
        });
        if (overlapping) {
            throw new AppError_1.AppError("Sitter has an accepted booking during this period", AppError_1.HttpCode.BAD_REQUEST);
        }
        return prisma_1.default.sittingBooking.create({
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
                status: prisma_2.SittingBookingStatus.PENDING,
            },
        });
    }
    static async getSittingBookingById(id) {
        return prisma_1.default.sittingBooking.findUnique({
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
    static async getSitterBookings(sitterId, status, page = 1, limit = 10) {
        const skip = (page - 1) * limit;
        const where = {
            sitterId,
            ...(status && { status }),
        };
        const [bookings, total] = await Promise.all([
            prisma_1.default.sittingBooking.findMany({
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
            prisma_1.default.sittingBooking.count({ where }),
        ]);
        return { bookings, total };
    }
    static async getOwnerBookings(ownerId, status, page = 1, limit = 10) {
        const skip = (page - 1) * limit;
        const where = {
            petOwnerId: ownerId,
            ...(status && { status }),
        };
        const [bookings, total] = await Promise.all([
            prisma_1.default.sittingBooking.findMany({
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
            prisma_1.default.sittingBooking.count({ where }),
        ]);
        return { bookings, total };
    }
    static async updateBookingStatus(id, status) {
        return prisma_1.default.sittingBooking.update({
            where: { id },
            data: { status },
        });
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Review Operations
    // ─────────────────────────────────────────────────────────────────────────────
    static async createSitterReview(data) {
        // Check if review already exists for this booking
        const existing = await prisma_1.default.sitterReview.findUnique({
            where: { bookingId: data.bookingId },
        });
        if (existing) {
            throw new AppError_1.AppError("A review already exists for this booking", AppError_1.HttpCode.BAD_REQUEST);
        }
        // Use transaction to create review and update sitter rating
        return prisma_1.default.$transaction(async (tx) => {
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
            const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
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
    static async getSitterReviews(sitterProfileId) {
        return prisma_1.default.sitterReview.findMany({
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
    static async searchSitters(filters) {
        const skip = (filters.page - 1) * filters.limit;
        const where = {
            verificationStatus: prisma_2.SitterVerificationStatus.APPROVED,
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
                where.ratingAverage.lte = filters.maxRating;
            }
            else {
                where.ratingAverage = { lte: filters.maxRating };
            }
        }
        // Determine sort order
        let orderBy = { createdAt: "desc" };
        if (filters.sortBy === "rating") {
            orderBy = { ratingAverage: "desc" };
        }
        else if (filters.sortBy === "newest") {
            orderBy = { createdAt: "desc" };
        }
        else if (filters.sortBy === "booked") {
            orderBy = { totalReviews: "desc" };
        }
        const [sitters, total] = await Promise.all([
            prisma_1.default.sitterProfile.findMany({
                where: where,
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
            prisma_1.default.sitterProfile.count({ where: where }),
        ]);
        return { sitters, total };
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Admin Operations
    // ─────────────────────────────────────────────────────────────────────────────
    static async getPendingSitters(page = 1, limit = 10) {
        const skip = (page - 1) * limit;
        const [sitters, total] = await Promise.all([
            prisma_1.default.sitterProfile.findMany({
                where: { verificationStatus: prisma_2.SitterVerificationStatus.PENDING },
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
            prisma_1.default.sitterProfile.count({
                where: { verificationStatus: prisma_2.SitterVerificationStatus.PENDING },
            }),
        ]);
        return { sitters, total };
    }
    static async approveSitterProfile(id) {
        return prisma_1.default.sitterProfile.update({
            where: { id },
            data: { verificationStatus: prisma_2.SitterVerificationStatus.APPROVED },
        });
    }
    static async rejectSitterProfile(id) {
        return prisma_1.default.sitterProfile.update({
            where: { id },
            data: { verificationStatus: prisma_2.SitterVerificationStatus.REJECTED },
        });
    }
}
exports.SittingRepository = SittingRepository;
//# sourceMappingURL=sitting.repository.js.map