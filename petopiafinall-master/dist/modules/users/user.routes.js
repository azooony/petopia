"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const user_controller_1 = require("./user.controller");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /users/me - Get current user profile
router.get("/me", auth_middleware_1.protect, user_controller_1.UserController.getMe);
// PUT /users/me - Update user profile (fullName, age, gender, phone, etc.)
router.put("/me", auth_middleware_1.protect, user_controller_1.UserController.updateProfile);
// PUT /users/me/password - Update password
router.put("/me/password", auth_middleware_1.protect, user_controller_1.UserController.updatePassword);
// DELETE /users/me - Delete user profile
router.delete("/me", auth_middleware_1.protect, user_controller_1.UserController.deleteProfile);
exports.default = router;
//# sourceMappingURL=user.routes.js.map