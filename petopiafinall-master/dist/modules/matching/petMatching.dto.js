"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FindMatchesQuerySchema = exports.SendMatchRequestSchema = exports.UpdateMatchProfileSchema = exports.CreateMatchProfileSchema = void 0;
const zod_1 = require("zod");
exports.CreateMatchProfileSchema = zod_1.z.object({
    petId: zod_1.z.string().cuid(),
    description: zod_1.z.string().max(500).optional().nullable(),
    address: zod_1.z.string().max(255).optional().nullable(),
    preferredBreed: zod_1.z.string().max(100).optional().nullable(),
});
exports.UpdateMatchProfileSchema = zod_1.z.object({
    description: zod_1.z.string().max(500).optional().nullable(),
    address: zod_1.z.string().max(255).optional().nullable(),
    preferredBreed: zod_1.z.string().max(100).optional().nullable(),
});
exports.SendMatchRequestSchema = zod_1.z.object({
    fromPetId: zod_1.z.string().cuid(),
    toPetId: zod_1.z.string().cuid(),
});
exports.FindMatchesQuerySchema = zod_1.z.object({
    page: zod_1.z.coerce.number().int().min(1).default(1),
    limit: zod_1.z.coerce.number().int().min(1).max(50).default(10),
});
//# sourceMappingURL=petMatching.dto.js.map