// Usage: node test-seed-notif.cjs <email>
require('dotenv').config();
const { PrismaClient } = require('./generated/prisma');
const { PrismaPg }     = require('@prisma/adapter-pg');

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma  = new PrismaClient({ adapter });

async function main() {
  const email = process.argv[2];
  if (!email) { console.error('email arg required'); process.exit(1); }

  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) { console.error('user not found: ' + email); process.exit(1); }

  const n1 = await prisma.notification.create({
    data: {
      userId: user.id,
      title:  'Test notification',
      body:   'This is a seeded test notification.',
      type:   'SYSTEM',
      isRead: false,
    }
  });

  const n2 = await prisma.notification.create({
    data: {
      userId: user.id,
      title:  'Second notification',
      body:   'Second seeded notification.',
      type:   'SYSTEM',
      isRead: false,
    }
  });

  process.stdout.write(JSON.stringify({ id1: n1.id, id2: n2.id, userId: user.id }) + '\n');
  await prisma.$disconnect();
}

main().catch(e => { process.stderr.write(e.message + '\n'); process.exit(1); });
