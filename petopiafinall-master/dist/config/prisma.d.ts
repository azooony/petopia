import 'dotenv/config';
import { PrismaClient } from '../../generated/prisma';
declare const prisma: PrismaClient<{
    log: ("warn" | "error")[];
}, "warn" | "error", import("../../generated/prisma/runtime/library").DefaultArgs>;
export default prisma;
//# sourceMappingURL=prisma.d.ts.map