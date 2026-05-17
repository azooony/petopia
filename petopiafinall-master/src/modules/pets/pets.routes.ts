import { Router } from "express";
import { PetController } from "./pets.controller";
import { protect, restrictTo } from "../../common/middlewares/auth.middleware";
import { UserRole } from "../../../generated/prisma";
import { validate } from "@/common/middlewares/validate.middleware";
import { CreatePetSchema, UpdatePetSchema } from "./pets.dto";
import { uploadPet, uploadAnalyze } from "../../common/middlewares/upload.middleware";

const router = Router();

router.post("/analyze", protect, uploadAnalyze.single("photo"), PetController.analyzePhoto);

router.use(protect, restrictTo(UserRole.PET_OWNER));

router.post("/", validate(CreatePetSchema), PetController.createPet);
router.get("/", PetController.getMyPets);
router.get("/:id", PetController.getPet);
router.patch("/:id", validate(UpdatePetSchema), PetController.updatePet);
router.delete("/:id", PetController.deletePet);
router.post("/:id/photo", uploadPet.single("photo"), PetController.uploadPhoto);
router.post("/:id/image", uploadPet.single("image"), PetController.uploadImage);

export default router;
