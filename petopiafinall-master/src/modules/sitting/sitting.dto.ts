import { z } from "zod";

// ─────────────────────────────────────────────
// Pagination
// ─────────────────────────────────────────────
export const PaginationSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(50).default(10),
});

export type PaginationInput = z.infer<typeof PaginationSchema>;

// ─────────────────────────────────────────────
// Sitter Profile
// ─────────────────────────────────────────────
export const CreateSitterProfileSchema = z.object({
  bio: z.string().max(1000).optional().nullable(),
  supportedPetTypes: z.array(z.string()).min(1),
  maxPets: z.number().int().min(1).max(20).default(3),
  city: z.string().min(1),
  address: z.string().min(5),
  emergencyContact: z.string().min(10),
});

export type CreateSitterProfileInput = z.infer<typeof CreateSitterProfileSchema>;

export const UpdateSitterProfileSchema = z.object({
  bio: z.string().max(1000).optional().nullable(),
  supportedPetTypes: z.array(z.string()).optional(),
  maxPets: z.number().int().min(1).max(20).optional(),
  city: z.string().optional(),
  address: z.string().optional(),
  emergencyContact: z.string().optional(),
  isAvailable: z.boolean().optional(),
});

export type UpdateSitterProfileInput = z.infer<typeof UpdateSitterProfileSchema>;

// ─────────────────────────────────────────────
// Image
// ─────────────────────────────────────────────
export const UploadSitterImageSchema = z.object({
  isPrimary: z.boolean().optional().default(false),
});

export type UploadSitterImageInput = z.infer<typeof UploadSitterImageSchema>;

// ─────────────────────────────────────────────
// Availability
// ─────────────────────────────────────────────
export const AddAvailabilitySchema = z.object({
  startDate: z.coerce.date().refine(d => d > new Date(), "Must be future"),
  endDate: z.coerce.date(),
}).refine(d => d.endDate > d.startDate, {
  message: "End date must be after start date",
});

export type AddAvailabilityInput = z.infer<typeof AddAvailabilitySchema>;

export const DeleteAvailabilitySchema = z.object({
  availabilityId: z.string().cuid(),
});

// ─────────────────────────────────────────────
// Booking
// ─────────────────────────────────────────────
export const CreateSittingBookingSchema = z.object({
  sitterId: z.string().cuid(),
  petId: z.string().cuid(),
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
  ownerNotes: z.string().optional().nullable(),
  emergencyPhone: z.string().min(10),
}).refine(d => d.endDate > d.startDate, {
  message: "End date must be after start date",
});

export type CreateSittingBookingInput = z.infer<typeof CreateSittingBookingSchema>;

// ─────────────────────────────────────────────
// Review
// ─────────────────────────────────────────────
export const CreateSitterReviewSchema = z.object({
  bookingId: z.string().cuid(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().optional().nullable(),
});

export type CreateSitterReviewInput = z.infer<typeof CreateSitterReviewSchema>;

// ─────────────────────────────────────────────
// Search
// ─────────────────────────────────────────────
export const SearchSittersSchema = z.object({
  city: z.string().optional(),
  petType: z.string().optional(),
  minRating: z.coerce.number().min(0).max(5).optional(),
  maxRating: z.coerce.number().min(0).max(5).optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  sortBy: z.enum(["rating", "newest", "booked"]).optional().default("rating"),
});

export type SearchSittersInput = z.infer<typeof SearchSittersSchema>;

// ─────────────────────────────────────────────
// Pet Listing for Sitting
// ─────────────────────────────────────────────
export const ListPetForSittingSchema = z.object({
  petName: z.string().min(1),
  breed: z.string().optional().nullable(),
  age: z.coerce.number().int().min(0).max(100),
  gender: z.enum(["MALE", "FEMALE"]).optional().nullable(),
  petType: z.enum(["DOG", "CAT"]).default("DOG"),
  payRatePerDay: z.coerce.number().min(1).max(1000),
  sittingNotes: z.string().max(500).optional().nullable(),
});

export type ListPetForSittingInput = z.infer<typeof ListPetForSittingSchema>;