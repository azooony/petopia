import { Router } from "express";
import { AuthController } from "./auth.controller";
import { upload } from "../../common/middlewares/upload.middleware";

const router = Router();

router.post("/register-owner", AuthController.registerPetOwner);

router.post("/register-vet", upload.single("certificate"), AuthController.registerVet);

router.post("/login", AuthController.login);

export default router;