import prisma from "../../config/prisma";
import {
  ConversationType,
  Gender,
  MatchRequestStatus,
  Prisma,
} from "../../../generated/prisma";

export class PetMatchingRepository {

  // PROFILE

  static createProfile(data: {
    petId: string;
    description?: string | null;
    address?: string | null;
    preferredBreed?: string | null;
  }) {
    return prisma.petMatchProfile.create({
      data,
      include: {
        pet: {
          include: {
            images: {
              include: {
                asset: true,
              },
            },
          },
        },
      },
    });
  }

  static findProfileByPetId(petId: string) {
    return prisma.petMatchProfile.findUnique({
      where: { petId },
      include: {
        pet: {
          include: {
            images: {
              include: {
                asset: true,
              },
            },
          },
        },
      },
    });
  }

  static updateProfile(
    petId: string,
    data: {
      description?: string | null;
      address?: string | null;
      preferredBreed?: string | null;
      isavailable?: boolean;
    }
  ) {
    return prisma.petMatchProfile.update({
      where: { petId },
      data,
    });
  }

  // FIND MATCHES

  static findAvailablePets(
    currentPetId: string,
    breed?: string,
    gender?: string,
    skip = 0,
    take = 10
  ) {
    return prisma.petMatchProfile.findMany({
      where: {
        petId: {
          not: currentPetId,
        },
        isavailable: true,
        ...(gender && { pet: { gender: gender as Gender } }),
        ...(breed && {
          OR: [
            {
              preferredBreed: breed,
            },
            {
              preferredBreed: null,
            },
          ],
        }),
      },
      include: {
        pet: {
          include: {
            owner: {
              select: {
                id: true,
                fullName: true,
              },
            },
            images: {
              include: {
                asset: true,
              },
            },
          },
        },
      },
      skip,
      take,
      orderBy: {
        pet: {
          age: "asc",
        },
      },
    });
  }

  static deleteProfile(petId: string) {
    return prisma.petMatchProfile.delete({ where: { petId } });
  }

  static findAllAvailablePets(
    gender?: string,
    skip = 0,
    take = 50,
    petType?: string
  ) {
    return prisma.petMatchProfile.findMany({
      where: {
        isavailable: true,
        ...((gender || petType) && {
          pet: {
            ...(gender && { gender: gender as Gender }),
            ...(petType && { petType: petType as any }),
          },
        }),
      },
      include: {
        pet: {
          include: {
            owner: {
              select: {
                id: true,
                fullName: true,
              },
            },
            images: {
              include: {
                asset: true,
              },
            },
          },
        },
      },
      skip,
      take,
      orderBy: {
        pet: {
          age: "asc",
        },
      },
    });
  }

  // REQUESTS

  static findExistingRequest(fromPetId: string, toPetId: string) {
    return prisma.petMatchRequest.findFirst({
      where: {
        OR: [
          {
            fromPetId,
            toPetId,
          },
          {
            fromPetId: toPetId,
            toPetId: fromPetId,
          },
        ],
      },
    });
  }

  static createRequest(data: {
    fromPetId: string;
    toPetId: string;
  }) {
    return prisma.petMatchRequest.create({
      data,
      include: {
        fromPet: true,
        toPet: true,
      },
    });
  }

  static getIncomingRequests(petId: string) {
    return prisma.petMatchRequest.findMany({
      where: {
        toPetId: petId,
        status: MatchRequestStatus.PENDING,
      },
      include: {
        fromPet: {
          include: {
            owner: {
              select: {
                id: true,
                fullName: true,
              },
            },
            images: {
              include: {
                asset: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });
  }

  static getRequestById(requestId: string) {
    return prisma.petMatchRequest.findUnique({
      where: {
        id: requestId,
      },
      include: {
        fromPet: true,
        toPet: true,
      },
    });
  }

  static updateRequestStatus(
    requestId: string,
    status: MatchRequestStatus
  ) {
    return prisma.petMatchRequest.update({
      where: {
        id: requestId,
      },
      data: {
        status,
      },
    });
  }

  // CHAT CREATION

  static async createConversationIfMissing(
    userA: string,
    userB: string,
    db: Prisma.TransactionClient | typeof prisma = prisma
  ) {
    const existingConversation =
      await db.conversation.findFirst({
        where: {
          AND: [
            {
              participants: {
                some: {
                  userId: userA,
                },
              },
            },
            {
              participants: {
                some: {
                  userId: userB,
                },
              },
            },
          ],
        },
      });

    if (existingConversation) {
      return existingConversation;
    }

    return db.conversation.create({
      data: {
        type: ConversationType.MATCHING,
        participants: {
          create: [{ userId: userA }, { userId: userB }],
        },
      },
      include: {
        participants: true,
      },
    });
  }
}