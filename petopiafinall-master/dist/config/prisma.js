"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const prisma_1 = require("../../generated/prisma");
const prisma = new prisma_1.PrismaClient({
    log: ['error', 'warn'],
});
exports.default = prisma;
//# sourceMappingURL=prisma.js.map