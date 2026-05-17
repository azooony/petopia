import 'dotenv/config';
import prisma from './src/config/prisma';

const KEEP_NAMES = ['azouny', 'sama']; // case-insensitive partial match

async function main() {
  // ── 1. Find users to keep ────────────────────────────────────────────────
  const keepUsers = await prisma.user.findMany({
    where: {
      OR: [
        { role: 'ADMIN' },
        ...KEEP_NAMES.map(n => ({
          fullName: { contains: n, mode: 'insensitive' as const },
        })),
      ],
    },
    select: { id: true, fullName: true, email: true, role: true },
  });

  console.log('\n✅ Keeping:');
  keepUsers.forEach(u => console.log(`   ${u.fullName} <${u.email}> [${u.role}]`));

  const keepIds = keepUsers.map(u => u.id);

  // ── 2. Find users to delete ──────────────────────────────────────────────
  const toDelete = await prisma.user.findMany({
    where: { id: { notIn: keepIds } },
    select: { id: true, fullName: true, email: true },
  });

  if (toDelete.length === 0) {
    console.log('\nNothing to delete — DB already clean.\n');
    return;
  }

  console.log(`\n🗑  Deleting ${toDelete.length} user(s):`);
  toDelete.forEach(u => console.log(`   ${u.fullName} <${u.email}>`));

  const delIds = toDelete.map(u => u.id);

  // Pre-collect pet IDs for those users (needed for cascades)
  const pets = await prisma.pet.findMany({
    where: { ownerId: { in: delIds } },
    select: { id: true },
  });
  const petIds = pets.map(p => p.id);

  console.log('\n⏳ Deleting related records in dependency order…');

  // Step A: MedicalRecord
  // — where the vet is being deleted  (vetId → User, no cascade)
  // — where the pet is being deleted  (petId → Pet, no cascade)
  const mrDel = await prisma.medicalRecord.deleteMany({
    where: {
      OR: [
        { vetId: { in: delIds } },
        ...(petIds.length ? [{ petId: { in: petIds } }] : []),
      ],
    },
  });
  console.log(`   MedicalRecord       deleted: ${mrDel.count}`);

  // Step B: Payment (payerId → User, no cascade)
  const payDel = await prisma.payment.deleteMany({
    where: { payerId: { in: delIds } },
  });
  console.log(`   Payment             deleted: ${payDel.count}`);

  // Step C: Appointment (ownerId/vetId → User, petId → Pet — none cascade)
  // Cascades: linked Payment (onDelete: Cascade on Payment.appointmentId)
  const apptDel = await prisma.appointment.deleteMany({
    where: {
      OR: [
        { ownerId: { in: delIds } },
        { vetId:   { in: delIds } },
        ...(petIds.length ? [{ petId: { in: petIds } }] : []),
      ],
    },
  });
  console.log(`   Appointment         deleted: ${apptDel.count}`);

  // Step D: PetRecognitionLog (userId → User, no cascade)
  const prlDel = await prisma.petRecognitionLog.deleteMany({
    where: { userId: { in: delIds } },
  });
  console.log(`   PetRecognitionLog   deleted: ${prlDel.count}`);

  // Step E: PetImage (petId → Pet, no cascade)
  if (petIds.length) {
    const piDel = await prisma.petImage.deleteMany({
      where: { petId: { in: petIds } },
    });
    console.log(`   PetImage            deleted: ${piDel.count}`);
  }

  // Step F: Pet  →  cascades PetMatchProfile, PetMatchRequest,
  //                          SittingBooking (petId), SitterReview (via booking)
  const petDel = await prisma.pet.deleteMany({
    where: { ownerId: { in: delIds } },
  });
  console.log(`   Pet                 deleted: ${petDel.count}`);

  // Step G: PetOwnerProfile (userId → User, no cascade)
  const popDel = await prisma.petOwnerProfile.deleteMany({
    where: { userId: { in: delIds } },
  });
  console.log(`   PetOwnerProfile     deleted: ${popDel.count}`);

  // Step H: VetProfile (userId → User, no cascade)
  const vpDel = await prisma.vetProfile.deleteMany({
    where: { userId: { in: delIds } },
  });
  console.log(`   VetProfile          deleted: ${vpDel.count}`);

  // Step I: Nullify Asset.uploadedById (nullable — avoids FK error)
  const assetUpd = await prisma.asset.updateMany({
    where: { uploadedById: { in: delIds } },
    data:  { uploadedById: null },
  });
  console.log(`   Asset.uploadedById  nulled:  ${assetUpd.count}`);

  // Step J: Delete the users
  // Cascades automatically: VetAvailabilitySlot, ConversationParticipant,
  //   ChatMessage, SitterProfile → SitterImage / SitterAvailability /
  //   remaining SittingBookings / SitterReview (reviewer), AdminActionLog
  const userDel = await prisma.user.deleteMany({
    where: { id: { in: delIds } },
  });
  console.log(`   User                deleted: ${userDel.count}`);

  // Step K: Clean up orphaned Conversations (participants all gone)
  const orphans = await prisma.conversation.findMany({
    where: { participants: { none: {} } },
    select: { id: true },
  });
  if (orphans.length) {
    await prisma.conversation.deleteMany({
      where: { id: { in: orphans.map(c => c.id) } },
    });
    console.log(`   Conversation        cleaned: ${orphans.length} orphan(s)`);
  }

  console.log('\n✅ Done.\n');
}

main()
  .catch(e => { console.error('\n❌ Error:', e.message); process.exit(1); })
  .finally(() => prisma.$disconnect());
