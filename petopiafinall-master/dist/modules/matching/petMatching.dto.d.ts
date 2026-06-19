import { z } from "zod";
export declare const CreateMatchProfileSchema: z.ZodObject<{
    petId: z.ZodString;
    description: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    address: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    preferredBreed: z.ZodNullable<z.ZodOptional<z.ZodString>>;
}, z.core.$strip>;
export type CreateMatchProfileDto = z.infer<typeof CreateMatchProfileSchema>;
export declare const UpdateMatchProfileSchema: z.ZodObject<{
    description: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    address: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    preferredBreed: z.ZodNullable<z.ZodOptional<z.ZodString>>;
}, z.core.$strip>;
export type UpdateMatchProfileDto = z.infer<typeof UpdateMatchProfileSchema>;
export declare const SendMatchRequestSchema: z.ZodObject<{
    fromPetId: z.ZodString;
    toPetId: z.ZodString;
}, z.core.$strip>;
export type SendMatchRequestDto = z.infer<typeof SendMatchRequestSchema>;
export declare const FindMatchesQuerySchema: z.ZodObject<{
    page: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    limit: z.ZodDefault<z.ZodCoercedNumber<unknown>>;
    gender: z.ZodOptional<z.ZodEnum<{
        MALE: "MALE";
        FEMALE: "FEMALE";
    }>>;
    type: z.ZodOptional<z.ZodEnum<{
        DOG: "DOG";
        CAT: "CAT";
    }>>;
}, z.core.$strip>;
export type FindMatchesQueryDto = z.infer<typeof FindMatchesQuerySchema>;
//# sourceMappingURL=petMatching.dto.d.ts.map