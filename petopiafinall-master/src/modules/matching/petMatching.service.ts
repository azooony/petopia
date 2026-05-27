import {
  MatchRequestStatus,
} from "../../../generated/prisma";

import { AppError, HttpCode } from "../../common/errors/AppError";

import prisma from "../../config/prisma";

import { PetMatchingRepository } from "./petMatching.repository";

import {
  CreateMatchProfileDto,
  UpdateMatchProfileDto,
  SendMatchRequestDto,
} from "./petMatching.dto";
import { fireNotification } from "../Notification/notification.helpers";
import {
  notifyMatchRequestReceived,
  notifyMatchAccepted,
} from "../Notification/notification.templates";

export class PetMatchingService {

  // CREATE PROFILE

  static async createProfile(
    userId: string,
    dto: CreateMatchProfileDto
  ) {

    const pet = await prisma.pet.findUnique({
      where: {
        id: dto.petId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Pet not found or unauthorized",
        HttpCode.NOT_FOUND
      );
    }

    const existing =
      await PetMatchingRepository.findProfileByPetId(dto.petId);

    if (existing) {
      return PetMatchingRepository.updateProfile(dto.petId, {
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.address     !== undefined && { address:     dto.address     }),
        ...(dto.preferredBreed !== undefined && { preferredBreed: dto.preferredBreed }),
      });
    }

    return PetMatchingRepository.createProfile({
      petId: dto.petId,
      ...(dto.description !== undefined && { description: dto.description }),
      ...(dto.address !== undefined && { address: dto.address }),
      ...(dto.preferredBreed !== undefined && { preferredBreed: dto.preferredBreed }),
    });
  }

  // UPDATE PROFILE

  static async updateProfile(
    userId: string,
    petId: string,
    dto: UpdateMatchProfileDto
  ) {

    const pet = await prisma.pet.findUnique({
      where: {
        id: petId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Unauthorized",
        HttpCode.FORBIDDEN
      );
    }

    const updateData = {
      ...(dto.description !== undefined && {
        description: dto.description,
      }),
      ...(dto.address !== undefined && {
        address: dto.address,
      }),
      ...(dto.preferredBreed !== undefined && {
        preferredBreed: dto.preferredBreed,
      }),
    };

    return PetMatchingRepository.updateProfile(
      petId,
      updateData
    );
  }

  // GET PROFILE (for pre-filling the form)

  static async getProfile(userId: string, petId: string) {
    const pet = await prisma.pet.findUnique({
      where: { id: petId },
      include: {
        owner: { select: { id: true, fullName: true } },
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError("Unauthorized", HttpCode.FORBIDDEN);
    }

    const profile = await PetMatchingRepository.findProfileByPetId(petId);
    return { pet, profile: profile ?? null };
  }

  // FIND MATCHES

  static async findMatches(
    userId: string,
    petId: string,
    page = 1,
    limit = 10,
    gender?: string,
  ) {

    const pet = await prisma.pet.findUnique({
      where: {
        id: petId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Unauthorized",
        HttpCode.FORBIDDEN
      );
    }

    const skip = (page - 1) * limit;

    return PetMatchingRepository.findAvailablePets(
      petId,
      pet.breed ?? undefined,
      gender,
      skip,
      limit
    );
  }

  // DELETE PROFILE

  static async deleteProfile(userId: string, petId: string) {
    const pet = await prisma.pet.findUnique({ where: { id: petId } });
    if (!pet || pet.ownerId !== userId) {
      throw new AppError("Unauthorized", HttpCode.FORBIDDEN);
    }
    return PetMatchingRepository.deleteProfile(petId);
  }

  // FIND ALL MATCHES (no own-pet required — browse mode)

  static async findAllMatches(
    page = 1,
    limit = 50,
    gender?: string,
    petType?: string,
  ) {
    const skip = (page - 1) * limit;
    return PetMatchingRepository.findAllAvailablePets(gender, skip, limit, petType);
  }

  // SEND REQUEST

  static async sendMatchRequest(
    userId: string,
    dto: SendMatchRequestDto
  ) {

    if (dto.fromPetId === dto.toPetId) {
      throw new AppError(
        "Cannot match same pet",
        HttpCode.BAD_REQUEST
      );
    }

    const pet = await prisma.pet.findUnique({
      where: {
        id: dto.fromPetId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Unauthorized",
        HttpCode.FORBIDDEN
      );
    }

    const target =
      await prisma.petMatchProfile.findUnique({
        where: {
          petId: dto.toPetId,
        },
      });

    if (!target || !target.isavailable) {
      throw new AppError(
        "Target pet unavailable",
        HttpCode.BAD_REQUEST
      );
    }

    const existing =
      await PetMatchingRepository.findExistingRequest(
        dto.fromPetId,
        dto.toPetId
      );

    if (existing) {
      throw new AppError(
        "Request already exists",
        HttpCode.BAD_REQUEST
      );
    }

    const request = await PetMatchingRepository.createRequest(dto);

    fireNotification(
      notifyMatchRequestReceived(
        request.toPet.ownerId,
        request.id,
        request.fromPet.name ?? undefined,
      ),
    );

    return request;
  }

  // INCOMING REQUESTS

  static async getIncomingRequests(
    userId: string,
    petId: string
  ) {

    const pet = await prisma.pet.findUnique({
      where: {
        id: petId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Unauthorized",
        HttpCode.FORBIDDEN
      );
    }

    return PetMatchingRepository.getIncomingRequests(
      petId
    );
  }

  // ACCEPT REQUEST

  static async acceptRequest(
    userId: string,
    requestId: string
  ) {
    const accepted = await prisma.$transaction(async (tx) => {
      const request =
        await tx.petMatchRequest.findUnique({
          where: {
            id: requestId,
          },
          include: {
            fromPet: true,
            toPet: true,
          },
        });

      if (!request) {
        throw new AppError(
          "Request not found",
          HttpCode.NOT_FOUND
        );
      }

      if (request.toPet.ownerId !== userId) {
        throw new AppError(
          "Unauthorized",
          HttpCode.FORBIDDEN
        );
      }

      if (request.status !== MatchRequestStatus.PENDING) {
        throw new AppError(
          "Request already processed",
          HttpCode.BAD_REQUEST
        );
      }

      await tx.petMatchRequest.update({
        where: {
          id: requestId,
        },
        data: {
          status: MatchRequestStatus.ACCEPTED,
        },
      });

      await PetMatchingRepository.createConversationIfMissing(
        request.fromPet.ownerId,
        request.toPet.ownerId,
        tx
      );

      return request;
    });

    fireNotification(
      notifyMatchAccepted(
        accepted.fromPet.ownerId,
        requestId,
        accepted.toPet.name ?? undefined,
      ),
    );

    return {
      success: true,
    };
  }

  // REJECT REQUEST

  static async rejectRequest(
    userId: string,
    requestId: string
  ) {

    const request =
      await PetMatchingRepository.getRequestById(
        requestId
      );

    if (!request) {
      throw new AppError(
        "Request not found",
        HttpCode.NOT_FOUND
      );
    }

    const pet = await prisma.pet.findUnique({
      where: {
        id: request.toPetId,
      },
    });

    if (!pet || pet.ownerId !== userId) {
      throw new AppError(
        "Unauthorized",
        HttpCode.FORBIDDEN
      );
    }

    return PetMatchingRepository.updateRequestStatus(
      requestId,
      MatchRequestStatus.REJECTED
    );
  }
}