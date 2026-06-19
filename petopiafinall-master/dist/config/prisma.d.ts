import 'dotenv/config';
import { PrismaClient } from '../../generated/prisma';
import { PrismaPg } from '@prisma/adapter-pg';
declare const prisma: PrismaClient<{
    log: ("warn" | "error")[];
    adapter: PrismaPg;
}, "warn" | "error", import("../../generated/prisma/runtime/client").DefaultArgs>;
export default prisma;
//# sourceMappingURL=prisma.d.ts.map