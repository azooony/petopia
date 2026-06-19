import { z } from "zod";
export declare const CreatePetSchema: z.ZodObject<{
    name: z.ZodString;
    age: z.ZodNumber;
    breed: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    gender: z.ZodNullable<z.ZodOptional<z.ZodEnum<{
        MALE: "MALE";
        FEMALE: "FEMALE";
    }>>>;
    description: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    photo: z.ZodNullable<z.ZodOptional<z.ZodString>>;
    petType: z.ZodOptional<z.ZodEnum<{
        DOG: "DOG";
        CAT: "CAT";
    }>>;
}, z.core.$strip>;
export declare const UpdatePetSchema: z.ZodObject<{
    name: z.ZodOptional<z.ZodString>;
    age: z.ZodOptional<z.ZodNumber>;
    breed: z.ZodOptional<z.ZodNullable<z.ZodOptional<z.ZodString>>>;
    gender: z.ZodOptional<z.ZodNullable<z.ZodOptional<z.ZodEnum<{
        MALE: "MALE";
        FEMALE: "FEMALE";
    }>>>>;
    description: z.ZodOptional<z.ZodNullable<z.ZodOptional<z.ZodString>>>;
    photo: z.ZodOptional<z.ZodNullable<z.ZodOptional<z.ZodString>>>;
    petType: z.ZodOptional<z.ZodOptional<z.ZodEnum<{
        DOG: "DOG";
        CAT: "CAT";
    }>>>;
}, z.core.$strip>;
export type CreatePetDto = z.infer<typeof CreatePetSchema>;
export type UpdatePetDto = z.infer<typeof UpdatePetSchema>;
//# sourceMappingURL=pets.dto.d.ts.map