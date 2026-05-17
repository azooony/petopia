import { z } from "zod";

export const BookAppointmentSchema = z.object({
  vetId: z.string().min(1, "vetId is required"),
  petId: z.string().min(1, "petId is required"),
  startTime: z
    .string()
    .min(1, "startTime is required")
    .refine((val) => !isNaN(Date.parse(val)), {
      message: "startTime must be a valid ISO 8601 datetime string",
    }),
  reason: z.string().max(500).optional(),
});

export type BookAppointmentDto = z.infer<typeof BookAppointmentSchema>;
