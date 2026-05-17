"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const prisma_1 = require("../../../generated/prisma");
const sitting_controller_1 = require("./sitting.controller");
const multer_1 = __importDefault(require("multer"));
const router = (0, express_1.Router)();
// Configure multer for in-memory image uploads
const imageUpload = (0, multer_1.default)({ storage: multer_1.default.memoryStorage() });
// ─────────────────────────────────────────────────────────────────────────────
// Sitter Profile Routes
// ─────────────────────────────────────────────────────────────────────────────
// POST /sitting/profile - Create sitter profile (authenticated user)
router.post("/profile", auth_middleware_1.protect, sitting_controller_1.SittingController.createSitterProfile);
// GET /sitting/profile/me - Get own sitter profile
router.get("/profile/me", auth_middleware_1.protect, sitting_controller_1.SittingController.getSitterProfileMe);
// GET /sitting/profile/:sitterId - Get sitter profile by ID (public)
router.get("/profile/:sitterId", sitting_controller_1.SittingController.getSitterProfile);
// PATCH /sitting/profile - Update sitter profile
router.patch("/profile", auth_middleware_1.protect, sitting_controller_1.SittingController.updateSitterProfile);
// ─────────────────────────────────────────────────────────────────────────────
// Sitter Images Routes
// ─────────────────────────────────────────────────────────────────────────────
// POST /sitting/images - Upload sitter images
router.post("/images", auth_middleware_1.protect, imageUpload.single("image"), sitting_controller_1.SittingController.uploadSitterImage);
// GET /sitting/images - Get own sitter images
router.get("/images", auth_middleware_1.protect, sitting_controller_1.SittingController.getSitterImages);
// DELETE /sitting/images/:imageId - Delete sitter image
router.delete("/images/:imageId", auth_middleware_1.protect, sitting_controller_1.SittingController.deleteSitterImage);
// ─────────────────────────────────────────────────────────────────────────────
// Availability Routes
// ─────────────────────────────────────────────────────────────────────────────
// POST /sitting/availability - Add availability
router.post("/availability", auth_middleware_1.protect, sitting_controller_1.SittingController.addAvailability);
// GET /sitting/availability - Get own availability
router.get("/availability", auth_middleware_1.protect, sitting_controller_1.SittingController.getMyAvailability);
// DELETE /sitting/availability/:availabilityId - Delete availability
router.delete("/availability/:availabilityId", auth_middleware_1.protect, sitting_controller_1.SittingController.deleteAvailability);
// ─────────────────────────────────────────────────────────────────────────────
// Booking Routes (Sitter Side)
// ─────────────────────────────────────────────────────────────────────────────
// GET /sitting/bookings/incoming - Get incoming booking requests (sitter)
router.get("/bookings/incoming", auth_middleware_1.protect, sitting_controller_1.SittingController.getIncomingBookings);
// GET /sitting/bookings/me - Get own bookings (sitter)
router.get("/bookings/me", auth_middleware_1.protect, sitting_controller_1.SittingController.getMyBookingsAsSitter);
// PATCH /sitting/bookings/:bookingId/accept - Accept booking
router.patch("/bookings/:bookingId/accept", auth_middleware_1.protect, sitting_controller_1.SittingController.acceptBooking);
// PATCH /sitting/bookings/:bookingId/reject - Reject booking
router.patch("/bookings/:bookingId/reject", auth_middleware_1.protect, sitting_controller_1.SittingController.rejectBooking);
// ─────────────────────────────────────────────────────────────────────────────
// Booking Routes (Owner Side)
// ─────────────────────────────────────────────────────────────────────────────
// POST /sitting/bookings - Create booking request (owner)
router.post("/bookings", auth_middleware_1.protect, sitting_controller_1.SittingController.createBooking);
// GET /sitting/bookings - Get own bookings as owner
router.get("/bookings", auth_middleware_1.protect, sitting_controller_1.SittingController.getMyBookingsAsOwner);
// PATCH /sitting/bookings/:bookingId/cancel - Cancel booking
router.patch("/bookings/:bookingId/cancel", auth_middleware_1.protect, sitting_controller_1.SittingController.cancelBooking);
// ─────────────────────────────────────────────────────────────────────────────
// Review Routes
// ─────────────────────────────────────────────────────────────────────────────
// POST /sitting/reviews - Create review (after completed booking)
router.post("/reviews", auth_middleware_1.protect, sitting_controller_1.SittingController.createReview);
// GET /sitting/reviews/:sitterId - Get reviews for a sitter (public)
router.get("/reviews/:sitterId", sitting_controller_1.SittingController.getSitterReviews);
// ─────────────────────────────────────────────────────────────────────────────
// Search Routes
// ─────────────────────────────────────────────────────────────────────────────
// GET /sitting/search - Search sitters with filters
router.get("/search", sitting_controller_1.SittingController.searchSitters);
// ─────────────────────────────────────────────────────────────────────────────
// Admin Routes
// ─────────────────────────────────────────────────────────────────────────────
// GET /sitting/admin/pending - Get pending sitter profiles (admin only)
router.get("/admin/pending", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.ADMIN), sitting_controller_1.SittingController.getPendingSitters);
// PATCH /sitting/admin/:sitterId/approve - Approve sitter profile (admin only)
router.patch("/admin/:sitterId/approve", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.ADMIN), sitting_controller_1.SittingController.approveSitter);
// PATCH /sitting/admin/:sitterId/reject - Reject sitter profile (admin only)
router.patch("/admin/:sitterId/reject", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.ADMIN), sitting_controller_1.SittingController.rejectSitter);
exports.default = router;
//# sourceMappingURL=sitting.routes.js.map