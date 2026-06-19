import { Router } from "express";
import { AuthController } from "./auth.controller";
import { uploadVetRegistration } from "../../common/middlewares/upload.middleware";

const router = Router();

router.post("/register-owner", AuthController.registerPetOwner);

router.post(
  "/register-vet",
  uploadVetRegistration.fields([
    { name: "certificate", maxCount: 1 },
    { name: "photo", maxCount: 1 },
  ]),
  AuthController.registerVet
);

router.post("/login", AuthController.login);

export default router;
