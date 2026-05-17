import 'dotenv/config';
import bcrypt from 'bcrypt';
import { PrismaClient } from '../generated/prisma';

const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash('admin123', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@petopia.com' },
    update: {},
    create: {
      email: 'admin@petopia.com',
      fullName: 'Admin',
      passwordHash: hash,
      role: 'ADMIN',
      age: 30,
      gender: 'MALE',
    },
  });

  console.log(`Admin ready: ${admin.email}`);
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
