import { Request, Response, NextFunction } from 'express';
import prisma from '../../config/prisma';

export const search = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const q = (req.query.q as string | undefined)?.trim() ?? '';

    if (!q) {
      res.json({ success: true, data: { pets: [], vets: [] } });
      return;
    }

    const like = { contains: q, mode: 'insensitive' as const };

    const [pets, vets] = await Promise.all([
      // Pets: search by name, breed, or match-profile address
      prisma.pet.findMany({
        where: {
          OR: [
            { name: like },
            { breed: like },
            { matchProfile: { address: like } },
          ],
        },
        select: {
          id: true,
          name: true,
          breed: true,
          petType: true,
          age: true,
          photo: true,
          matchProfile: { select: { address: true } },
          images: {
            take: 1,
            where: { isPrimary: true },
            include: { asset: { select: { url: true } } },
          },
        },
        take: 20,
      }),

      // Vets: search by first/last name, user full name, specialization, or clinic address/name
      prisma.vetProfile.findMany({
        where: {
          verificationStatus: 'VERIFIED',
          OR: [
            { firstName: like },
            { surname: like },
            { specialization: like },
            { user: { fullName: like } },
            { clinic: { address: like } },
            { clinic: { name: like } },
          ],
        },
        select: {
          id: true,
          firstName: true,
          surname: true,
          specialization: true,
          photo: true,
          appointmentPrice: true,
          user: { select: { id: true, fullName: true } },
          clinic: { select: { id: true, name: true, address: true } },
        },
        take: 20,
      }),
    ]);

    res.json({
      success: true,
      data: {
        pets: pets.map((p) => ({
          id: p.id,
          name: p.name,
          breed: p.breed ?? null,
          petType: p.petType,
          age: p.age,
          photo: p.photo ?? p.images[0]?.asset.url ?? null,
          address: p.matchProfile?.address ?? null,
        })),
        vets: vets.map((v) => ({
          id: v.user.id,
          vetProfileId: v.id,
          name: v.firstName && v.surname
            ? `Dr. ${v.firstName} ${v.surname}`
            : `Dr. ${v.user.fullName}`,
          specialization: v.specialization ?? null,
          photo: v.photo ?? null,
          appointmentPrice: v.appointmentPrice,
          clinicName: v.clinic.name,
          clinicAddress: v.clinic.address,
        })),
      },
    });
  } catch (err) {
    next(err);
  }
};
