import { Router } from "express";
import { UserController } from "./user.controller";
import { protect, restrictTo } from "../../common/middlewares/auth.middleware";
import { uploadAvatar } from "../../common/middlewares/upload.middleware";

const router = Router();

// GET /users/me - Get current user profile
router.get("/me", protect, UserController.getMe);

// PUT /users/me - Update user profile (fullName, age, gender, phone, etc.)
router.put("/me", protect, UserController.updateProfile);

// POST /users/me/avatar - Upload / replace profile picture
router.post("/me/avatar", protect, uploadAvatar.single("avatar"), UserController.uploadAvatar);

// PUT /users/me/password - Update password
router.put("/me/password", protect, UserController.updatePassword);

// DELETE /users/me - Delete user profile
router.delete("/me", protect, UserController.deleteProfile);

// POST /users/:targetUserId/block - Block a user
router.post("/:targetUserId/block", protect, UserController.blockUser);

export default router;