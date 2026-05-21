import { z } from "zod";

export const ReportLostPetSchema = z.object({
  species:         z.enum(["DOG", "CAT"]),
  description:     z.string().min(10, "Description must be at least 10 characters"),
  lastSeenLocation: z.string().min(1, "Last seen location is required"),
  lastSeenDate:    z.string().refine((v) => !isNaN(Date.parse(v)), "Invalid date"),
  // optional — autofilled when petId is supplied
  name:    z.string().optional(),
  breed:   z.string().optional(),
  gender:  z.enum(["MALE", "FEMALE"]).optional(),
  color:   z.string().optional(),
  // existing pet to autofill from
  petId:   z.string().optional(),
});

export const ReportFoundPetSchema = z.object({
  species:              z.enum(["DOG", "CAT"]),
  description:          z.string().min(10, "Description must be at least 10 characters"),
  foundLocation:        z.string().min(1, "Found location is required"),
  isPetStillAtLocation: z.preprocess((v) => v === "true" || v === true, z.boolean()),
  breed:  z.string().optional(),
  gender: z.enum(["MALE", "FEMALE"]).optional(),
  color:  z.string().optional(),
});

export type ReportLostPetInput  = z.infer<typeof ReportLostPetSchema>;
export type ReportFoundPetInput = z.infer<typeof ReportFoundPetSchema>;
