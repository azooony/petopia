"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const user_controller_1 = require("./user.controller");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const upload_middleware_1 = require("../../common/middlewares/upload.middleware");
const router = (0, express_1.Router)();
// GET /users/me - Get current user profile
router.get("/me", auth_middleware_1.protect, user_controller_1.UserController.getMe);
// PUT /users/me - Update user profile (fullName, age, gender, phone, etc.)
router.put("/me", auth_middleware_1.protect, user_controller_1.UserController.updateProfile);
// POST /users/me/avatar - Upload / replace profile picture
router.post("/me/avatar", auth_middleware_1.protect, upload_middleware_1.uploadAvatar.single("avatar"), user_controller_1.UserController.uploadAvatar);
// PUT /users/me/password - Update password
router.put("/me/password", auth_middleware_1.protect, user_controller_1.UserController.updatePassword);
// DELETE /users/me - Delete user profile
router.delete("/me", auth_middleware_1.protect, user_controller_1.UserController.deleteProfile);
// POST /users/:targetUserId/block - Block a user
router.post("/:targetUserId/block", auth_middleware_1.protect, user_controller_1.UserController.blockUser);
exports.default = router;
//# sourceMappingURL=user.routes.js.map