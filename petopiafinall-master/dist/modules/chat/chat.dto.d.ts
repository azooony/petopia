import { z } from "zod";
export declare const InitiateConversationSchema: z.ZodObject<{
    targetUserId: z.ZodString;
    context: z.ZodEnum<{
        MATCHING: "MATCHING";
        SITTING: "SITTING";
    }>;
}, z.core.$strip>;
export type InitiateConversationDto = z.infer<typeof InitiateConversationSchema>;
export declare const GetMessagesQuerySchema: z.ZodObject<{
    page: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    limit: z.ZodPipe<z.ZodDefault<z.ZodCoercedNumber<unknown>>, z.ZodTransform<number, number>>;
}, z.core.$strip>;
//# sourceMappingURL=chat.dto.d.ts.map