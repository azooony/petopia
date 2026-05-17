import 'dotenv/config';
import prisma from './src/config/prisma';

async function main() {
  const users = await prisma.user.findMany({ select: { id: true, fullName: true, role: true } });
  console.log('\n--- USERS ---');
  users.forEach(u => console.log(`  ${u.id}  ${u.fullName}  [${u.role}]`));

  const pets = await prisma.pet.findMany({ select: { id: true, name: true, ownerId: true } });
  console.log('\n--- PETS ---');
  pets.forEach(p => console.log(`  pet:${p.id}  name:${p.name}  owner:${p.ownerId}`));

  const matchProfiles = await prisma.petMatchProfile.findMany({ select: { id: true, petId: true } });
  console.log('\n--- MATCH PROFILES ---');
  matchProfiles.forEach(m => console.log(`  profile:${m.id}  pet:${m.petId}`));

  const reqs = await prisma.petMatchRequest.findMany({
    select: { id: true, status: true, fromPetId: true, toPetId: true },
  });
  console.log('\n--- MATCH REQUESTS ---');
  reqs.forEach(r => console.log(`  req:${r.id}  ${r.status}  ${r.fromPetId} -> ${r.toPetId}`));

  const convs = await prisma.conversation.findMany({
    include: {
      participants: { include: { user: { select: { id: true, fullName: true } } } },
      messages:     { orderBy: { createdAt: 'desc' }, take: 5 },
    },
  });
  console.log('\n--- CONVERSATIONS ---');
  convs.forEach(c => {
    const names = c.participants.map(p => p.user.fullName).join(' <-> ');
    console.log(`  conv:${c.id}  type:${c.type}  participants:[${names}]`);
    c.messages.forEach(m => console.log(`    msg: "${m.content}" by ${m.senderId}`));
  });
}

main().catch(e => console.error('ERR', e.message)).finally(() => prisma.$disconnect());
