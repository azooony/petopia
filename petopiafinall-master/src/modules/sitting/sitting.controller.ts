import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { SittingService } from "./sitting.service";
import {
  CreateSitterProfileSchema,
  UpdateSitterProfileSchema,
  UploadSitterImageSchema,
  AddAvailabilitySchema,
  CreateSittingBookingSchema,
  CreateSitterReviewSchema,
  SearchSittersSchema,
  PaginationSchema,
  ListPetForSittingSchema,
} from "./sitting.dto";

export class SittingController {
  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Profile Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSitterProfile(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = CreateSitterProfileSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const profile = await SittingService.createSitterProfile(
        req.user.userId,
        parsed.data
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Sitter profile created successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getSitterProfileMe(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const profile = await SittingService.getSitterProfileMe(req.user.userId);

      return res.json({
        success: true,
        message: "Sitter profile retrieved successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getSitterProfile(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const sitterId = req.params.sitterId as string;

      if (!sitterId) {
        throw new AppError("Sitter ID is required", HttpCode.BAD_REQUEST);
      }

      const profile = await SittingService.getSitterProfile(sitterId);

      return res.json({
        success: true,
        message: "Sitter profile retrieved successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async updateSitterProfile(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = UpdateSitterProfileSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const profile = await SittingService.updateSitterProfile(
        req.user.userId,
        parsed.data
      );

      return res.json({
        success: true,
        message: "Sitter profile updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Images Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async uploadSitterImage(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      if (!req.file) {
        throw new AppError("No file provided", HttpCode.BAD_REQUEST);
      }

      const parsed = UploadSitterImageSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const image = await SittingService.uploadSitterImage(
        req.user.userId,
        req.file,
        parsed.data
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Image uploaded successfully",
        data: image,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getSitterImages(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const images = await SittingService.getSitterImages(req.user.userId);

      return res.json({
        success: true,
        message: "Images retrieved successfully",
        data: images,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async deleteSitterImage(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const imageId = req.params.imageId as string;

      if (!imageId) {
        throw new AppError("Image ID is required", HttpCode.BAD_REQUEST);
      }

      const result = await SittingService.deleteSitterImage(
        req.user.userId,
        imageId
      );

      return res.json({
        success: true,
        message: result.message,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Availability Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async addAvailability(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = AddAvailabilitySchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const availability = await SittingService.addAvailability(
        req.user.userId,
        parsed.data
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Availability added successfully",
        data: availability,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getMyAvailability(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const availability = await SittingService.getMyAvailability(
        req.user.userId
      );

      return res.json({
        success: true,
        message: "Availability retrieved successfully",
        data: availability,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async deleteAvailability(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const availabilityId = req.params.availabilityId as string;

      if (!availabilityId) {
        throw new AppError("Availability ID is required", HttpCode.BAD_REQUEST);
      }

      const result = await SittingService.deleteAvailability(
        req.user.userId,
        availabilityId
      );

      return res.json({
        success: true,
        message: result.message,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitting Booking Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async createBooking(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = CreateSittingBookingSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const booking = await SittingService.createBooking(
        req.user.userId,
        parsed.data
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Booking created successfully",
        data: booking,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getMyBookingsAsSitter(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = PaginationSchema.safeParse(req.query);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const { bookings, total } = await SittingService.getMyBookingsAsSitter(
        req.user.userId,
        parsed.data.page,
        parsed.data.limit
      );

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
    } catch (err) {
      return next(err);
    }
  }

  static async getIncomingBookings(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = PaginationSchema.safeParse(req.query);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const { bookings, total } = await SittingService.getIncomingBookingsAsSitter(
        req.user.userId,
        parsed.data.page,
        parsed.data.limit
      );

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
    } catch (err) {
      return next(err);
    }
  }

  static async getMyBookingsAsOwner(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = PaginationSchema.safeParse(req.query);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const { bookings, total } = await SittingService.getMyBookingsAsOwner(
        req.user.userId,
        parsed.data.page,
        parsed.data.limit
      );

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
    } catch (err) {
      return next(err);
    }
  }

  static async acceptBooking(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const bookingId = req.params.bookingId as string;

      if (!bookingId) {
        throw new AppError("Booking ID is required", HttpCode.BAD_REQUEST);
      }

      const booking = await SittingService.acceptBooking(
        req.user.userId,
        bookingId
      );

      return res.json({
        success: true,
        message: "Booking accepted successfully",
        data: booking,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async rejectBooking(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const bookingId = req.params.bookingId as string;

      if (!bookingId) {
        throw new AppError("Booking ID is required", HttpCode.BAD_REQUEST);
      }

      const booking = await SittingService.rejectBooking(
        req.user.userId,
        bookingId
      );

      return res.json({
        success: true,
        message: "Booking rejected successfully",
        data: booking,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async cancelBooking(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const bookingId = req.params.bookingId as string;

      if (!bookingId) {
        throw new AppError("Booking ID is required", HttpCode.BAD_REQUEST);
      }

      const booking = await SittingService.cancelBooking(
        req.user.userId,
        bookingId
      );

      return res.json({
        success: true,
        message: "Booking cancelled successfully",
        data: booking,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Review Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async createReview(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = CreateSitterReviewSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const review = await SittingService.createReview(
        req.user.userId,
        parsed.data
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Review created successfully",
        data: review,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getSitterReviews(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const sitterId = req.params.sitterId as string;

      if (!sitterId) {
        throw new AppError("Sitter ID is required", HttpCode.BAD_REQUEST);
      }

      const reviews = await SittingService.getSitterReviews(sitterId);

      return res.json({
        success: true,
        message: "Reviews retrieved successfully",
        data: reviews,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Search Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async searchSitters(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const parsed = SearchSittersSchema.safeParse(req.query);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const { sitters, total } = await SittingService.searchSitters(
        parsed.data
      );

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
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Admin Endpoints
  // ─────────────────────────────────────────────────────────────────────────────

  static async getPendingSitters(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const parsed = PaginationSchema.safeParse(req.query);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const { sitters, total } = await SittingService.getPendingSitters(
        parsed.data.page,
        parsed.data.limit
      );

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
    } catch (err) {
      return next(err);
    }
  }

  static async approveSitter(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const sitterId = req.params.sitterId as string;

      if (!sitterId) {
        throw new AppError("Sitter ID is required", HttpCode.BAD_REQUEST);
      }

      const profile = await SittingService.approveSitter(sitterId);

      return res.json({
        success: true,
        message: "Sitter profile approved successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async rejectSitter(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      const sitterId = req.params.sitterId as string;

      if (!sitterId) {
        throw new AppError("Sitter ID is required", HttpCode.BAD_REQUEST);
      }

      const profile = await SittingService.rejectSitter(sitterId);

      return res.json({
        success: true,
        message: "Sitter profile rejected",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Pet Listing for Sitting
  // ─────────────────────────────────────────────────────────────────────────────

  static async listPetForSitting(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const parsed = ListPetForSittingSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(HttpCode.BAD_REQUEST).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }

      const pet = await SittingService.listPetForSitting(
        req.user.userId,
        parsed.data,
        req.file
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Pet listed for sitting successfully",
        data: pet,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async unlistPet(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      await SittingService.unlistPet(req.user.userId);

      return res.json({
        success: true,
        message: "Pet removed from sitting list",
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getAvailablePets(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const petType = req.query.type as string | undefined;
      const pets = await SittingService.getAvailablePets(req.user.userId, petType);

      return res.json({
        success: true,
        message: "Available pets retrieved",
        data: pets,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async getSitterStatus(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const result = await SittingService.getSitterStatus(req.user.userId);

      return res.json({
        success: true,
        message: "Sitter status retrieved",
        data: result,
      });
    } catch (err) {
      return next(err);
    }
  }

  static async registerSitter(
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) {
    try {
      if (!req.user?.userId) {
        throw new AppError("Unauthorized", HttpCode.UNAUTHORIZED);
      }

      const files = req.files as
        | { [fieldname: string]: Express.Multer.File[] }
        | undefined;

      const nationalIdFile = files?.["nationalIdPhoto"]?.[0];
      const venuePhotoFile = files?.["venuePhoto"]?.[0];

      if (!nationalIdFile) {
        throw new AppError("National ID photo is required", HttpCode.BAD_REQUEST);
      }
      if (!venuePhotoFile) {
        throw new AppError("Venue photo is required", HttpCode.BAD_REQUEST);
      }

      const profile = await SittingService.registerSitter(
        req.user.userId,
        nationalIdFile,
        venuePhotoFile
      );

      return res.status(HttpCode.CREATED).json({
        success: true,
        message: "Registration submitted. Awaiting admin approval.",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  }
}
