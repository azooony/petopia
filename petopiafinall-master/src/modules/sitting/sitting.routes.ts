import { Router } from "express";
import { protect, restrictTo } from "../../common/middlewares/auth.middleware";
import { UserRole } from "../../../generated/prisma";
import { upload } from "../../common/middlewares/upload.middleware";
import { SittingController } from "./sitting.controller";
import multer from "multer";

const router = Router();

// Configure multer for in-memory image uploads
const imageUpload = multer({ storage: multer.memoryStorage() });

// ─────────────────────────────────────────────────────────────────────────────
// Sitter Profile Routes
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/profile - Create sitter profile (authenticated user)
router.post("/profile", protect, SittingController.createSitterProfile);

// GET /sitting/profile/me - Get own sitter profile
router.get("/profile/me", protect, SittingController.getSitterProfileMe);

// GET /sitting/profile/:sitterId - Get sitter profile by ID (public)
router.get("/profile/:sitterId", SittingController.getSitterProfile);

// PATCH /sitting/profile - Update sitter profile
router.patch("/profile", protect, SittingController.updateSitterProfile);

// ─────────────────────────────────────────────────────────────────────────────
// Sitter Images Routes
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/images - Upload sitter images
router.post(
  "/images",
  protect,
  imageUpload.single("image"),
  SittingController.uploadSitterImage
);

// GET /sitting/images - Get own sitter images
router.get("/images", protect, SittingController.getSitterImages);

// DELETE /sitting/images/:imageId - Delete sitter image
router.delete("/images/:imageId", protect, SittingController.deleteSitterImage);

// ─────────────────────────────────────────────────────────────────────────────
// Availability Routes
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/availability - Add availability
router.post("/availability", protect, SittingController.addAvailability);

// GET /sitting/availability - Get own availability
router.get("/availability", protect, SittingController.getMyAvailability);

// DELETE /sitting/availability/:availabilityId - Delete availability
router.delete(
  "/availability/:availabilityId",
  protect,
  SittingController.deleteAvailability
);

// ─────────────────────────────────────────────────────────────────────────────
// Booking Routes (Sitter Side)
// ─────────────────────────────────────────────────────────────────────────────

// GET /sitting/bookings/incoming - Get incoming booking requests (sitter)
router.get("/bookings/incoming", protect, SittingController.getIncomingBookings);

// GET /sitting/bookings/me - Get own bookings (sitter)
router.get("/bookings/me", protect, SittingController.getMyBookingsAsSitter);

// PATCH /sitting/bookings/:bookingId/accept - Accept booking
router.patch(
  "/bookings/:bookingId/accept",
  protect,
  SittingController.acceptBooking
);

// PATCH /sitting/bookings/:bookingId/reject - Reject booking
router.patch(
  "/bookings/:bookingId/reject",
  protect,
  SittingController.rejectBooking
);

// ─────────────────────────────────────────────────────────────────────────────
// Booking Routes (Owner Side)
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/bookings - Create booking request (owner)
router.post("/bookings", protect, SittingController.createBooking);

// GET /sitting/bookings - Get own bookings as owner
router.get("/bookings", protect, SittingController.getMyBookingsAsOwner);

// PATCH /sitting/bookings/:bookingId/cancel - Cancel booking
router.patch(
  "/bookings/:bookingId/cancel",
  protect,
  SittingController.cancelBooking
);

// ─────────────────────────────────────────────────────────────────────────────
// Review Routes
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/reviews - Create review (after completed booking)
router.post("/reviews", protect, SittingController.createReview);

// GET /sitting/reviews/:sitterId - Get reviews for a sitter (public)
router.get("/reviews/:sitterId", SittingController.getSitterReviews);

// ─────────────────────────────────────────────────────────────────────────────
// Search Routes
// ─────────────────────────────────────────────────────────────────────────────

// GET /sitting/search - Search sitters with filters
router.get("/search", SittingController.searchSitters);

// ─────────────────────────────────────────────────────────────────────────────
// Admin Routes
// ─────────────────────────────────────────────────────────────────────────────

// GET /sitting/admin/pending - Get pending sitter profiles (admin only)
router.get(
  "/admin/pending",
  protect,
  restrictTo(UserRole.ADMIN),
  SittingController.getPendingSitters
);

// PATCH /sitting/admin/:sitterId/approve - Approve sitter profile (admin only)
router.patch(
  "/admin/:sitterId/approve",
  protect,
  restrictTo(UserRole.ADMIN),
  SittingController.approveSitter
);

// PATCH /sitting/admin/:sitterId/reject - Reject sitter profile (admin only)
router.patch(
  "/admin/:sitterId/reject",
  protect,
  restrictTo(UserRole.ADMIN),
  SittingController.rejectSitter
);

// ─────────────────────────────────────────────────────────────────────────────
// Pet Listing for Sitting Routes
// ─────────────────────────────────────────────────────────────────────────────

// POST /sitting/pet-listing - List own pet for sitting (with optional photo)
router.post(
  "/pet-listing",
  protect,
  imageUpload.single("petPhoto"),
  SittingController.listPetForSitting
);

// DELETE /sitting/pet-listing - Remove own pet from sitting list
router.delete("/pet-listing", protect, SittingController.unlistPet);

// GET /sitting/available-pets - Get all pets available for sitting
router.get("/available-pets", protect, SittingController.getAvailablePets);

// GET /sitting/sitter-status - Get current user's sitter verification status
router.get("/sitter-status", protect, SittingController.getSitterStatus);

// POST /sitting/register-sitter - Register as sitter (national ID + venue photo)
router.post(
  "/register-sitter",
  protect,
  imageUpload.fields([
    { name: "nationalIdPhoto", maxCount: 1 },
    { name: "venuePhoto", maxCount: 1 },
  ]),
  SittingController.registerSitter
);

export default router;
