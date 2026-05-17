import { z } from "zod";
export declare const BookAppointmentSchema: z.ZodObject<{
    vetId: z.ZodString;
    petId: z.ZodString;
    startTime: z.ZodString;
    reason: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
export type BookAppointmentDto = z.infer<typeof BookAppointmentSchema>;
//# sourceMappingURL=appointments.dto.d.ts.map