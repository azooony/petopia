import { z } from "zod";
export declare const AdminLoginSchema: z.ZodObject<{
    email: z.ZodEmail;
    password: z.ZodString;
}, z.core.$strip>;
export type AdminLoginDto = z.infer<typeof AdminLoginSchema>;
//# sourceMappingURL=admin.dto.d.ts.map