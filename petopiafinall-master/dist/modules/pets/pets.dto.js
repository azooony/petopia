"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdatePetSchema = exports.CreatePetSchema = void 0;
const prisma_1 = require("../../../generated/prisma");
const zod_1 = require("zod");
exports.CreatePetSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(50).trim(),
    age: zod_1.z.number().int().min(0).max(50),
    breed: zod_1.z.string().max(100).optional().nullable(),
    gender: zod_1.z.enum([prisma_1.Gender.MALE, prisma_1.Gender.FEMALE]).optional().nullable(),
    description: zod_1.z.string().max(1000).optional().nullable(),
    photo: zod_1.z.string().optional().nullable(),
    petType: zod_1.z.enum([prisma_1.PetType.DOG, prisma_1.PetType.CAT]).optional(),
});
exports.UpdatePetSchema = exports.CreatePetSchema.partial();
//# sourceMappingURL=pets.dto.js.map