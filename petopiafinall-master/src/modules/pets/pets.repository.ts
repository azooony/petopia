import prisma from "../../config/prisma";
import { Gender } from "../../../generated/prisma";

export class PetRepository {

  static findOwnerProfile(userId: string) {
    return prisma.petOwnerProfile.findUnique({
      where: { userId },
    });
  }

  static createPet(data: {
    ownerId: string;
    petOwnerProfileId: string | null;
    name: string;
    age: number;
    breed?: string | null;
    gender?: Gender | null;
    description?: string | null;
  }) {
    return prisma.pet.create({
      data: {
        name: data.name,
        age: data.age,
        breed: data.breed ?? null,
        gender: data.gender ?? null,
        description: data.description ?? null,
        owner: { connect: { id: data.ownerId } },
        ...(data.petOwnerProfileId
          ? { petOwnerProfile: { connect: { id: data.petOwnerProfileId } } }
          : {}),
      },
      include: {
        images: { include: { asset: true } },
      },
    });
  }

  static findPetsByOwner(userId: string, limit = 10, offset = 0) {
    return prisma.pet.findMany({
      where: { ownerId: userId },
      take: limit,
      skip: offset,
      orderBy: { id: "desc" as const },
      include: {
        images: { include: { asset: true } },
      },
    });
  }

  static findPetById(petId: string) {
    return prisma.pet.findUnique({
      where: { id: petId },
      include: {
        images: { include: { asset: true } },
      },
    });
  }

  static updatePet(
    petId: string,
    data: {
      name?: string;
      age?: number;
      breed?: string | null;
      gender?: Gender | null;
      description?: string | null;
      photo?: string | null;
    }
  ) {
    return prisma.pet.update({
      where: { id: petId },
      data,
      include: {
        images: { include: { asset: true } },
      },
    });
  }

  static updatePetPhoto(petId: string, photoUrl: string) {
    return prisma.pet.update({
      where: { id: petId },
      data: { photo: photoUrl },
    });
  }

  static deletePet(petId: string) {
    return prisma.pet.delete({
      where: { id: petId },
    });
  }

  static async upsertPetImage(petId: string, imageUrl: string, storageKey: string) {
    // Remove any existing primary image for this pet
    const existing = await prisma.petImage.findFirst({
      where: { petId, isPrimary: true },
      include: { asset: true },
    });

    if (existing) {
      await prisma.petImage.delete({ where: { id: existing.id } });
      await prisma.asset.delete({ where: { id: existing.assetId } });
    }

    const asset = await prisma.asset.create({
      data: { url: imageUrl, storageKey },
    });

    return prisma.petImage.create({
      data: { petId, assetId: asset.id, isPrimary: true },
      include: { asset: true },
    });
  }
}
