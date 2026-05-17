"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BookAppointmentSchema = void 0;
const zod_1 = require("zod");
exports.BookAppointmentSchema = zod_1.z.object({
    vetId: zod_1.z.string().min(1, "vetId is required"),
    petId: zod_1.z.string().min(1, "petId is required"),
    startTime: zod_1.z
        .string()
        .min(1, "startTime is required")
        .refine((val) => !isNaN(Date.parse(val)), {
        message: "startTime must be a valid ISO 8601 datetime string",
    }),
    reason: zod_1.z.string().max(500).optional(),
});
//# sourceMappingURL=appointments.dto.js.map