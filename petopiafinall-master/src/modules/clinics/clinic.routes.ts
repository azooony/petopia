// clinic.routes.ts
import { Router } from "express";
import { createClinic } from "./clinic.controller";
import { protect, restrictTo } from "@/common/middlewares/auth.middleware";
import { UserRole } from "../../../generated/prisma";

const router = Router();

router.post("/", protect, restrictTo(UserRole.ADMIN), createClinic);

export default router;
