import { z } from "zod";

export const CreateMatchProfileSchema = z.object({
  petId: z.string().cuid(),
  description: z.string().max(500).optional().nullable(),
  address: z.string().max(255).optional().nullable(),
  preferredBreed: z.string().max(100).optional().nullable(),
});

export type CreateMatchProfileDto = z.infer<
  typeof CreateMatchProfileSchema
>;

export const UpdateMatchProfileSchema =
  z.object({
    description: z.string().max(500).optional().nullable(),
    address: z.string().max(255).optional().nullable(),
    preferredBreed: z.string().max(100).optional().nullable(),
  });

export type UpdateMatchProfileDto = z.infer<
  typeof UpdateMatchProfileSchema
>;

export const SendMatchRequestSchema = z.object({
  fromPetId: z.string().cuid(),
  toPetId: z.string().cuid(),
});

export type SendMatchRequestDto = z.infer<
  typeof SendMatchRequestSchema
>;

export const FindMatchesQuerySchema = z.object({
  page:   z.coerce.number().int().min(1).default(1),
  limit:  z.coerce.number().int().min(1).max(50).default(10),
  gender: z.enum(['MALE', 'FEMALE']).optional(),
  type:   z.enum(['DOG', 'CAT']).optional(),
});

export type FindMatchesQueryDto = z.infer<
  typeof FindMatchesQuerySchema
>;