import { Gender } from "../../../generated/prisma";
import { z } from "zod";

export const CreatePetSchema = z.object({
  name: z.string().min(1).max(50).trim(),
  age: z.number().int().min(0).max(50),
  breed: z.string().max(100).optional().nullable(),
  gender: z.enum([Gender.MALE, Gender.FEMALE]).optional().nullable(),
  description: z.string().max(1000).optional().nullable(),
  photo: z.string().optional().nullable(),
});

export const UpdatePetSchema = CreatePetSchema.partial();

export type CreatePetDto = z.infer<typeof CreatePetSchema>;
export type UpdatePetDto = z.infer<typeof UpdatePetSchema>;
