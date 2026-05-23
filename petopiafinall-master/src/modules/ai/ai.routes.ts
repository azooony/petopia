import { Router } from "express";
import { protect } from "../../common/middlewares/auth.middleware";
import { AiController } from "./ai.controller";

const router = Router();

router.post("/chat", protect, AiController.chat);

export default router;
