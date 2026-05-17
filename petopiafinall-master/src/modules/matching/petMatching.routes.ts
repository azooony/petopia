import { Router } from "express";

import { UserRole } from "../../../generated/prisma";

import {
  protect,
  restrictTo,
} from "../../common/middlewares/auth.middleware";

import { validate } from "../../common/middlewares/validate.middleware";

import {
  CreateMatchProfileSchema,
  UpdateMatchProfileSchema,
  SendMatchRequestSchema,
} from "./petMatching.dto";

import { PetMatchingController } from "./petMatching.controller";

const router = Router();

router.use(
  protect,
  restrictTo(UserRole.PET_OWNER)
);

// PROFILE

router.get(
  "/profile/:petId",
  PetMatchingController.getProfile
);

router.post(
  "/profile",
  validate(CreateMatchProfileSchema),
  PetMatchingController.createProfile
);

router.patch(
  "/profile/:petId",
  validate(UpdateMatchProfileSchema),
  PetMatchingController.updateProfile
);

router.delete(
  "/profile/:petId",
  PetMatchingController.deleteProfile
);

// MATCHES

router.get(
  "/discover",
  PetMatchingController.findAllMatches
);

router.get(
  "/discover/:petId",
  PetMatchingController.findMatches
);

// REQUESTS

router.post(
  "/request",
  validate(SendMatchRequestSchema),
  PetMatchingController.sendRequest
);

router.get(
  "/requests/:petId",
  PetMatchingController.getIncomingRequests
);

router.patch(
  "/requests/:requestId/accept",
  PetMatchingController.acceptRequest
);

router.patch(
  "/requests/:requestId/reject",
  PetMatchingController.rejectRequest
);

export default router;