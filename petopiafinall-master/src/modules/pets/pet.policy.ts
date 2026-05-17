import { AppError, HttpCode } from "../../common/errors/AppError";
import type { Pet } from "../../../generated/prisma";

export class PetPolicy {
  static ensureOwner(pet: Pet | null, userId: string) {
    if (!pet || pet.ownerId !== userId) {
      throw new AppError("Pet not found or unauthorized", HttpCode.NOT_FOUND);
    }
  }
}