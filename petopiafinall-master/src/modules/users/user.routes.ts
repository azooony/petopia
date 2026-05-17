import { Router } from "express";
import { UserController } from "./user.controller";
import { protect, restrictTo } from "../../common/middlewares/auth.middleware";

const router = Router();

// GET /users/me - Get current user profile
router.get("/me", protect, UserController.getMe);

// PUT /users/me - Update user profile (fullName, age, gender, phone, etc.)
router.put("/me", protect, UserController.updateProfile);

// PUT /users/me/password - Update password
router.put("/me/password", protect, UserController.updatePassword);

// DELETE /users/me - Delete user profile
router.delete("/me", protect, UserController.deleteProfile);

export default router;