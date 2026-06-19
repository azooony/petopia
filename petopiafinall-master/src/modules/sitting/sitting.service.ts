import prisma from "../../config/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { SittingRepository } from "./sitting.repository";
import { storageClient } from "../../integrations/storage/index";
import { ChatRepository } from "../chat/chat.repository";
import { ConversationType } from "../../../generated/prisma";
import {
  CreateSitterProfileInput,
  UpdateSitterProfileInput,
  UploadSitterImageInput,
  AddAvailabilityInput,
  CreateSittingBookingInput,
  CreateSitterReviewInput,
  SearchSittersInput,
  ListPetForSittingInput,
} from "./sitting.dto";
import { fireNotification } from "../Notification/notification.helpers";
import {
  notifySittingBookingRequested,
  notifySittingBookingAccepted,
  notifySittingBookingRejected,
  notifySittingBookingCancelled,
} from "../Notification/notification.templates";

export class SittingService {
  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Profile Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createSitterProfile(
    userId: string,
    input: CreateSitterProfileInput
  ) {
    // Verify user exists
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError("User not found", HttpCode.NOT_FOUND);
    }

    const profile = await SittingRepository.createSitterProfile({
      userId,
      supportedPetTypes: input.supportedPetTypes,
      maxPets: input.maxPets,
      city: input.city,
      address: input.address,
      emergencyContact: input.emergencyContact,
      ...(input.bio ? { bio: input.bio } : {}),
      isAvailable: true,
    });

    return profile;
  }

  static async getSitterProfileMe(userId: string) {
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found. Please create one first.",
        HttpCode.NOT_FOUND
      );
    }

    return profile;
  }

  static async getSitterProfile(sitterId: string) {
    const profile = await SittingRepository.getSitterProfileById(sitterId);

    if (!profile) {
      throw new AppError("Sitter profile not found", HttpCode.NOT_FOUND);
    }

    return profile;
  }

  static async updateSitterProfile(
    userId: string,
    input: UpdateSitterProfileInput
  ) {
    // Verify profile exists
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found. Please create one first.",
        HttpCode.NOT_FOUND
      );
    }

    const updated = await SittingRepository.updateSitterProfile(userId, {
      ...input,
    } as any);

    return updated;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Image Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async uploadSitterImage(
    userId: string,
    file: Express.Multer.File,
    input: UploadSitterImageInput
  ) {
    if (!file) {
      throw new AppError("No file provided", HttpCode.BAD_REQUEST);
    }

    // Verify profile exists
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found. Please create one first.",
        HttpCode.NOT_FOUND
      );
    }

    // Validate file is an image
    if (!file.mimetype.startsWith("image/")) {
      throw new AppError(
        "Only image files are allowed",
        HttpCode.BAD_REQUEST
      );
    }

    // Upload file using storage client
    const uploadResult = await storageClient.upload(
      file.buffer,
      file.originalname,
      `sitter-images/${profile.id}`,
      { mimeType: file.mimetype }
    );

    // Save image metadata to database
    const image = await SittingRepository.createSitterImage({
      sitterProfileId: profile.id,
      imageUrl: uploadResult.url,
      storageKey: uploadResult.storageKey,
      uploadedById: userId,
      isPrimary: input.isPrimary,
    });

    return image;
  }

  static async getSitterImages(userId: string) {
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found",
        HttpCode.NOT_FOUND
      );
    }

    return SittingRepository.getSitterImages(profile.id);
  }

  static async deleteSitterImage(userId: string, imageId: string) {
    // Verify profile exists
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found",
        HttpCode.NOT_FOUND
      );
    }

    // Verify image belongs to this sitter
    const image = await prisma.sitterImage.findUnique({
      where: { id: imageId },
    });

    if (!image || image.sitterProfileId !== profile.id) {
      throw new AppError(
        "Image not found or does not belong to your profile",
        HttpCode.NOT_FOUND
      );
    }

    // Delete file from storage
    await storageClient.delete(image.storageKey);

    // Delete image record from database
    await SittingRepository.deleteSitterImage(imageId);

    return { message: "Image deleted successfully" };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Availability Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async addAvailability(userId: string, input: AddAvailabilityInput) {
    // Verify profile exists
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found. Please create one first.",
        HttpCode.NOT_FOUND
      );
    }

    const availability = await SittingRepository.addAvailability({
      sitterProfileId: profile.id,
      userId,
      startDate: input.startDate,
      endDate: input.endDate,
    });

    return availability;
  }

  static async getMyAvailability(userId: string) {
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found",
        HttpCode.NOT_FOUND
      );
    }

    return SittingRepository.getSitterAvailability(profile.id);
  }

  static async deleteAvailability(userId: string, availabilityId: string) {
    // Verify profile exists
    const profile = await SittingRepository.getSitterProfileByUserId(userId);

    if (!profile) {
      throw new AppError(
        "Sitter profile not found",
        HttpCode.NOT_FOUND
      );
    }

    // Verify availability belongs to this sitter
    const availability = await prisma.sitterAvailability.findUnique({
      where: { id: availabilityId },
    });

    if (!availability || availability.sitterProfileId !== profile.id) {
      throw new AppError(
        "Availability not found or does not belong to your profile",
        HttpCode.NOT_FOUND
      );
    }

    await SittingRepository.deleteAvailability(availabilityId);

    return { message: "Availability deleted successfully" };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitting Booking Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createBooking(userId: string, input: CreateSittingBookingInput) {
    // Verify pet ownership
    const pet = await prisma.pet.findUnique({
      where: { id: input.petId },
      select: { ownerId: true, name: true },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Pet not found or does not belong to you",
        HttpCode.NOT_FOUND
      );
    }

    // Verify sitter exists and is approved
    const sitterProfile = await SittingRepository.getSitterProfileById(
      input.sitterId
    );

    if (!sitterProfile) {
      throw new AppError("Sitter not found", HttpCode.NOT_FOUND);
    }

    // Cannot book own profile
    if (sitterProfile.userId === userId) {
      throw new AppError(
        "You cannot book your own sitter profile",
        HttpCode.BAD_REQUEST
      );
    }

    // Check if sitter is available
    const isAvailable = await SittingRepository.checkAvailability(
      sitterProfile.id,
      input.startDate,
      input.endDate
    );

    if (!isAvailable) {
      throw new AppError(
        "Sitter is not available for the requested dates",
        HttpCode.BAD_REQUEST
      );
    }

    // Create booking
    const totalDays = Math.ceil(
      (input.endDate.getTime() - input.startDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    const booking = await SittingRepository.createSittingBooking({
      sitterProfileId: sitterProfile.id,
      sitterId: sitterProfile.userId,
      petOwnerId: userId,
      petId: input.petId,
      startDate: input.startDate,
      endDate: input.endDate,
      totalDays,
      ...(input.ownerNotes ? { ownerNotes: input.ownerNotes } : {}),
      emergencyPhone: input.emergencyPhone,
    });

    fireNotification(
      notifySittingBookingRequested(
        sitterProfile.userId,
        booking.id,
        pet.name ?? undefined,
      ),
    );

    return booking;
  }

  static async getMyBookingsAsSitter(
    userId: string,
    page: number = 1,
    limit: number = 10
  ) {
    return SittingRepository.getSitterBookings(userId, undefined, page, limit);
  }

  static async getIncomingBookingsAsSitter(
    userId: string,
    page: number = 1,
    limit: number = 10
  ) {
    const { bookings, total } = await SittingRepository.getSitterBookings(
      userId,
      "PENDING",
      page,
      limit
    );

    return { bookings, total };
  }

  static async getMyBookingsAsOwner(
    userId: string,
    page: number = 1,
    limit: number = 10
  ) {
    return SittingRepository.getOwnerBookings(userId, undefined, page, limit);
  }

  static async acceptBooking(userId: string, bookingId: string) {
    // Get booking
    const booking = await SittingRepository.getSittingBookingById(bookingId);

    if (!booking) {
      throw new AppError("Booking not found", HttpCode.NOT_FOUND);
    }

    // Verify ownership
    if (booking.sitterId !== userId) {
      throw new AppError(
        "Only the sitter can accept this booking",
        HttpCode.FORBIDDEN
      );
    }

    // Can only accept pending bookings
    if (booking.status !== "PENDING") {
      throw new AppError(
        "Only pending bookings can be accepted",
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await SittingRepository.updateBookingStatus(
      bookingId,
      "ACCEPTED"
    );

    // Open a SITTING conversation between sitter and pet owner if one doesn't exist yet.
    await ChatRepository.findOrCreateConversation(
      booking.sitterId,
      booking.petOwnerId,
      ConversationType.SITTING,
    );

    fireNotification(
      notifySittingBookingAccepted(booking.petOwnerId, bookingId),
    );

    return updated;
  }

  static async rejectBooking(userId: string, bookingId: string) {
    // Get booking
    const booking = await SittingRepository.getSittingBookingById(bookingId);

    if (!booking) {
      throw new AppError("Booking not found", HttpCode.NOT_FOUND);
    }

    // Verify ownership
    if (booking.sitterId !== userId) {
      throw new AppError(
        "Only the sitter can reject this booking",
        HttpCode.FORBIDDEN
      );
    }

    // Can only reject pending bookings
    if (booking.status !== "PENDING") {
      throw new AppError(
        "Only pending bookings can be rejected",
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await SittingRepository.updateBookingStatus(
      bookingId,
      "REJECTED"
    );

    fireNotification(
      notifySittingBookingRejected(booking.petOwnerId, bookingId),
    );

    return updated;
  }

  static async cancelBooking(userId: string, bookingId: string) {
    // Get booking
    const booking = await SittingRepository.getSittingBookingById(bookingId);

    if (!booking) {
      throw new AppError("Booking not found", HttpCode.NOT_FOUND);
    }

    // Verify ownership - only owner can cancel
    if (booking.petOwnerId !== userId) {
      throw new AppError(
        "Only the booking owner can cancel",
        HttpCode.FORBIDDEN
      );
    }

    // Can only cancel pending or accepted bookings
    if (!["PENDING", "ACCEPTED"].includes(booking.status)) {
      throw new AppError(
        "Only pending or accepted bookings can be cancelled",
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await SittingRepository.updateBookingStatus(
      bookingId,
      "CANCELLED"
    );

    fireNotification(
      notifySittingBookingCancelled(
        booking.sitterId,
        bookingId,
        "The pet owner cancelled the sitting booking.",
      ),
    );

    return updated;
  }

  static async completeBooking(bookingId: string) {
    // Get booking
    const booking = await SittingRepository.getSittingBookingById(bookingId);

    if (!booking) {
      throw new AppError("Booking not found", HttpCode.NOT_FOUND);
    }

    // Can only complete accepted bookings
    if (booking.status !== "ACCEPTED") {
      throw new AppError(
        "Only accepted bookings can be completed",
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await SittingRepository.updateBookingStatus(
      bookingId,
      "COMPLETED"
    );

    return updated;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sitter Review Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async createReview(
    userId: string,
    input: CreateSitterReviewInput
  ) {
    // Get booking
    const booking = await SittingRepository.getSittingBookingById(
      input.bookingId
    );

    if (!booking) {
      throw new AppError("Booking not found", HttpCode.NOT_FOUND);
    }

    // Verify booking is completed
    if (booking.status !== "COMPLETED") {
      throw new AppError(
        "Only completed bookings can be reviewed",
        HttpCode.BAD_REQUEST
      );
    }

    // Verify ownership - only owner can review
    if (booking.petOwnerId !== userId) {
      throw new AppError(
        "Only the booking owner can review",
        HttpCode.FORBIDDEN
      );
    }

    const review = await SittingRepository.createSitterReview({
      bookingId: input.bookingId,
      sitterProfileId: booking.sitterProfileId,
      reviewerUserId: userId,
      rating: input.rating,
      ...(input.comment ? { comment: input.comment } : {}),
    });

    return review;
  }

  static async getSitterReviews(sitterId: string) {
    const profile = await SittingRepository.getSitterProfileById(sitterId);

    if (!profile) {
      throw new AppError("Sitter not found", HttpCode.NOT_FOUND);
    }

    return SittingRepository.getSitterReviews(profile.id);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Search Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async searchSitters(filters: SearchSittersInput) {
    return SittingRepository.searchSitters(filters as any);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Admin Operations
  // ─────────────────────────────────────────────────────────────────────────────

  static async getPendingSitters(page: number = 1, limit: number = 10) {
    return SittingRepository.getPendingSitters(page, limit);
  }

  static async approveSitter(sitterId: string) {
    const profile = await SittingRepository.getSitterProfileById(sitterId);

    if (!profile) {
      throw new AppError("Sitter not found", HttpCode.NOT_FOUND);
    }

    return SittingRepository.approveSitterProfile(sitterId);
  }

  static async rejectSitter(sitterId: string) {
    const profile = await SittingRepository.getSitterProfileById(sitterId);

    if (!profile) {
      throw new AppError("Sitter not found", HttpCode.NOT_FOUND);
    }

    return SittingRepository.rejectSitterProfile(sitterId);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Pet Listing for Sitting
  // ─────────────────────────────────────────────────────────────────────────────

  static async listPetForSitting(
    userId: string,
    input: ListPetForSittingInput,
    photoFile?: Express.Multer.File
  ) {
    let photoUrl: string | undefined;

    if (photoFile) {
      if (!photoFile.mimetype.startsWith("image/")) {
        throw new AppError("Only image files are allowed", HttpCode.BAD_REQUEST);
      }
      const uploadResult = await storageClient.upload(
        photoFile.buffer,
        photoFile.originalname,
        `pet-sitting-photos/${userId}`,
        { mimeType: photoFile.mimetype }
      );
      photoUrl = uploadResult.url;
    }

    return SittingRepository.upsertPetForSitting(userId, {
      name: input.petName,
      breed: input.breed ?? null,
      age: input.age,
      gender: input.gender ?? null,
      petType: input.petType,
      payRatePerDay: input.payRatePerDay,
      sittingNotes: input.sittingNotes ?? null,
      ...(photoUrl !== undefined ? { photo: photoUrl } : {}),
    });
  }

  static async unlistPet(userId: string) {
    const result = await SittingRepository.unlistPetFromSitting(userId);
    if (!result) {
      throw new AppError("No pet found for this user", HttpCode.NOT_FOUND);
    }
    return result;
  }

  static async getAvailablePets(userId: string, petType?: string) {
    return SittingRepository.getAvailablePets(userId, petType);
  }

  static async getSitterStatus(userId: string) {
    const status = await SittingRepository.getSitterStatus(userId);
    return { status };
  }

  static async registerSitter(
    userId: string,
    nationalIdFile: Express.Multer.File,
    venuePhotoFile: Express.Multer.File
  ) {
    if (!nationalIdFile.mimetype.startsWith("image/")) {
      throw new AppError("National ID must be an image", HttpCode.BAD_REQUEST);
    }
    if (!venuePhotoFile.mimetype.startsWith("image/")) {
      throw new AppError("Venue photo must be an image", HttpCode.BAD_REQUEST);
    }

    const [nationalIdResult, venueResult] = await Promise.all([
      storageClient.upload(
        nationalIdFile.buffer,
        nationalIdFile.originalname,
        `sitter-registration/${userId}/national-id`,
        { mimeType: nationalIdFile.mimetype }
      ),
      storageClient.upload(
        venuePhotoFile.buffer,
        venuePhotoFile.originalname,
        `sitter-registration/${userId}/venue`,
        { mimeType: venuePhotoFile.mimetype }
      ),
    ]);

    return SittingRepository.createOrUpdateSitterRegistration(
      userId,
      nationalIdResult.url,
      venueResult.url
    );
  }
}
