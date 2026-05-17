"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SittingController = void 0;
const AppError_1 = require("../../common/errors/AppError");
const sitting_service_1 = require("./sitting.service");
const sitting_dto_1 = require("./sitting.dto");
class SittingController {
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Profile Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async createSitterProfile(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.CreateSitterProfileSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const profile = await sitting_service_1.SittingService.createSitterProfile(req.user.userId, parsed.data);
            return res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Sitter profile created successfully",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getSitterProfileMe(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const profile = await sitting_service_1.SittingService.getSitterProfileMe(req.user.userId);
            return res.json({
                success: true,
                message: "Sitter profile retrieved successfully",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getSitterProfile(req, res, next) {
        try {
            const sitterId = req.params.sitterId;
            if (!sitterId) {
                throw new AppError_1.AppError("Sitter ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const profile = await sitting_service_1.SittingService.getSitterProfile(sitterId);
            return res.json({
                success: true,
                message: "Sitter profile retrieved successfully",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async updateSitterProfile(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.UpdateSitterProfileSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const profile = await sitting_service_1.SittingService.updateSitterProfile(req.user.userId, parsed.data);
            return res.json({
                success: true,
                message: "Sitter profile updated successfully",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitter Images Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async uploadSitterImage(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            if (!req.file) {
                throw new AppError_1.AppError("No file provided", AppError_1.HttpCode.BAD_REQUEST);
            }
            const parsed = sitting_dto_1.UploadSitterImageSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const image = await sitting_service_1.SittingService.uploadSitterImage(req.user.userId, req.file, parsed.data);
            return res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Image uploaded successfully",
                data: image,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getSitterImages(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const images = await sitting_service_1.SittingService.getSitterImages(req.user.userId);
            return res.json({
                success: true,
                message: "Images retrieved successfully",
                data: images,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async deleteSitterImage(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const imageId = req.params.imageId;
            if (!imageId) {
                throw new AppError_1.AppError("Image ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const result = await sitting_service_1.SittingService.deleteSitterImage(req.user.userId, imageId);
            return res.json({
                success: true,
                message: result.message,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Availability Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async addAvailability(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.AddAvailabilitySchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const availability = await sitting_service_1.SittingService.addAvailability(req.user.userId, parsed.data);
            return res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Availability added successfully",
                data: availability,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getMyAvailability(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const availability = await sitting_service_1.SittingService.getMyAvailability(req.user.userId);
            return res.json({
                success: true,
                message: "Availability retrieved successfully",
                data: availability,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async deleteAvailability(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const availabilityId = req.params.availabilityId;
            if (!availabilityId) {
                throw new AppError_1.AppError("Availability ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const result = await sitting_service_1.SittingService.deleteAvailability(req.user.userId, availabilityId);
            return res.json({
                success: true,
                message: result.message,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Sitting Booking Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async createBooking(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.CreateSittingBookingSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const booking = await sitting_service_1.SittingService.createBooking(req.user.userId, parsed.data);
            return res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Booking created successfully",
                data: booking,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getMyBookingsAsSitter(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.PaginationSchema.safeParse(req.query);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const { bookings, total } = await sitting_service_1.SittingService.getMyBookingsAsSitter(req.user.userId, parsed.data.page, parsed.data.limit);
            const totalPages = Math.ceil(total / parsed.data.limit);
            return res.json({
                success: true,
                message: "Bookings retrieved successfully",
                data: bookings,
                meta: {
                    page: parsed.data.page,
                    limit: parsed.data.limit,
                    total,
                    totalPages,
                },
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getIncomingBookings(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.PaginationSchema.safeParse(req.query);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const { bookings, total } = await sitting_service_1.SittingService.getIncomingBookingsAsSitter(req.user.userId, parsed.data.page, parsed.data.limit);
            const totalPages = Math.ceil(total / parsed.data.limit);
            return res.json({
                success: true,
                message: "Incoming bookings retrieved successfully",
                data: bookings,
                meta: {
                    page: parsed.data.page,
                    limit: parsed.data.limit,
                    total,
                    totalPages,
                },
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getMyBookingsAsOwner(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.PaginationSchema.safeParse(req.query);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const { bookings, total } = await sitting_service_1.SittingService.getMyBookingsAsOwner(req.user.userId, parsed.data.page, parsed.data.limit);
            const totalPages = Math.ceil(total / parsed.data.limit);
            return res.json({
                success: true,
                message: "Your bookings retrieved successfully",
                data: bookings,
                meta: {
                    page: parsed.data.page,
                    limit: parsed.data.limit,
                    total,
                    totalPages,
                },
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async acceptBooking(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const bookingId = req.params.bookingId;
            if (!bookingId) {
                throw new AppError_1.AppError("Booking ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const booking = await sitting_service_1.SittingService.acceptBooking(req.user.userId, bookingId);
            return res.json({
                success: true,
                message: "Booking accepted successfully",
                data: booking,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async rejectBooking(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const bookingId = req.params.bookingId;
            if (!bookingId) {
                throw new AppError_1.AppError("Booking ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const booking = await sitting_service_1.SittingService.rejectBooking(req.user.userId, bookingId);
            return res.json({
                success: true,
                message: "Booking rejected successfully",
                data: booking,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async cancelBooking(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const bookingId = req.params.bookingId;
            if (!bookingId) {
                throw new AppError_1.AppError("Booking ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const booking = await sitting_service_1.SittingService.cancelBooking(req.user.userId, bookingId);
            return res.json({
                success: true,
                message: "Booking cancelled successfully",
                data: booking,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Review Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async createReview(req, res, next) {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED);
            }
            const parsed = sitting_dto_1.CreateSitterReviewSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const review = await sitting_service_1.SittingService.createReview(req.user.userId, parsed.data);
            return res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Review created successfully",
                data: review,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async getSitterReviews(req, res, next) {
        try {
            const sitterId = req.params.sitterId;
            if (!sitterId) {
                throw new AppError_1.AppError("Sitter ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const reviews = await sitting_service_1.SittingService.getSitterReviews(sitterId);
            return res.json({
                success: true,
                message: "Reviews retrieved successfully",
                data: reviews,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Search Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async searchSitters(req, res, next) {
        try {
            const parsed = sitting_dto_1.SearchSittersSchema.safeParse(req.query);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const { sitters, total } = await sitting_service_1.SittingService.searchSitters(parsed.data);
            const totalPages = Math.ceil(total / parsed.data.limit);
            return res.json({
                success: true,
                message: "Sitters found",
                data: sitters,
                meta: {
                    page: parsed.data.page,
                    limit: parsed.data.limit,
                    total,
                    totalPages,
                },
            });
        }
        catch (err) {
            return next(err);
        }
    }
    // ─────────────────────────────────────────────────────────────────────────────
    // Admin Endpoints
    // ─────────────────────────────────────────────────────────────────────────────
    static async getPendingSitters(req, res, next) {
        try {
            const parsed = sitting_dto_1.PaginationSchema.safeParse(req.query);
            if (!parsed.success) {
                return res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const { sitters, total } = await sitting_service_1.SittingService.getPendingSitters(parsed.data.page, parsed.data.limit);
            const totalPages = Math.ceil(total / parsed.data.limit);
            return res.json({
                success: true,
                message: "Pending sitters retrieved",
                data: sitters,
                meta: {
                    page: parsed.data.page,
                    limit: parsed.data.limit,
                    total,
                    totalPages,
                },
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async approveSitter(req, res, next) {
        try {
            const sitterId = req.params.sitterId;
            if (!sitterId) {
                throw new AppError_1.AppError("Sitter ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const profile = await sitting_service_1.SittingService.approveSitter(sitterId);
            return res.json({
                success: true,
                message: "Sitter profile approved successfully",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
    static async rejectSitter(req, res, next) {
        try {
            const sitterId = req.params.sitterId;
            if (!sitterId) {
                throw new AppError_1.AppError("Sitter ID is required", AppError_1.HttpCode.BAD_REQUEST);
            }
            const profile = await sitting_service_1.SittingService.rejectSitter(sitterId);
            return res.json({
                success: true,
                message: "Sitter profile rejected",
                data: profile,
            });
        }
        catch (err) {
            return next(err);
        }
    }
}
exports.SittingController = SittingController;
//# sourceMappingURL=sitting.controller.js.map