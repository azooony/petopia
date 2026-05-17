import { z } from "zod";

export const AdminLoginSchema = z.object({
  email: z.email("Invalid email address"),
  password: z.string().min(1, "Password is required"),
});

export type AdminLoginDto = z.infer<typeof AdminLoginSchema>;