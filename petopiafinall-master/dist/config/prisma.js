"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const prisma_1 = require("../../generated/prisma");
const adapter_pg_1 = require("@prisma/adapter-pg");
if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL is not set. Add it to your .env file.');
}
const adapter = new adapter_pg_1.PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new prisma_1.PrismaClient({
    log: ['error', 'warn'],
    adapter,
});
exports.default = prisma;
//# sourceMappingURL=prisma.js.map