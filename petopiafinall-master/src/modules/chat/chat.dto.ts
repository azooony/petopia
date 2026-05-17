import { z } from "zod";

export const InitiateConversationSchema = z.object({
  targetUserId: z.string().min(1, "targetUserId is required"),
  context: z.enum(["MATCHING", "SITTING"]),
});

export type InitiateConversationDto = z.infer<typeof InitiateConversationSchema>;

export const GetMessagesQuerySchema = z.object({
  page:  z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).default(50).transform(v => Math.min(v, 100)),
});
