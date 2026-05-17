"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const user_service_1 = require("./user.service");
const AppError_1 = require("../../common/errors/AppError");
class UserController {
    // GET /users/me - Get current user profile
    static getMe = async (req, res, next) => {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", 401);
            }
            const user = await user_service_1.UserService.getMe(req.user.userId);
            res.json({
                success: true,
                message: "User profile retrieved successfully",
                data: user,
            });
        }
        catch (err) {
            next(err);
        }
    };
    // PUT /users/me - Update user profile
    static updateProfile = async (req, res, next) => {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", 401);
            }
            const updateData = req.body;
            // Validate that at least one field is provided
            if (Object.keys(updateData).length === 0) {
                throw new AppError_1.AppError("No data provided for update", 400);
            }
            const user = await user_service_1.UserService.updateProfile(req.user.userId, req.user.role, updateData);
            res.json({
                success: true,
                message: "Profile updated successfully",
                data: user,
            });
        }
        catch (err) {
            next(err);
        }
    };
    // PUT /users/me/password - Update password
    static updatePassword = async (req, res, next) => {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", 401);
            }
            const { currentPassword, newPassword, confirmPassword } = req.body;
            // Validate inputs
            if (!currentPassword || !newPassword || !confirmPassword) {
                throw new AppError_1.AppError("Current password, new password, and confirmation are required", 400);
            }
            if (newPassword !== confirmPassword) {
                throw new AppError_1.AppError("New password and confirmation do not match", 400);
            }
            if (newPassword.length < 6) {
                throw new AppError_1.AppError("New password must be at least 6 characters", 400);
            }
            const result = await user_service_1.UserService.updatePassword(req.user.userId, currentPassword, newPassword);
            res.json({
                success: true,
                message: result.message,
            });
        }
        catch (err) {
            next(err);
        }
    };
    // DELETE /users/me - Delete user profile
    static deleteProfile = async (req, res, next) => {
        try {
            if (!req.user?.userId) {
                throw new AppError_1.AppError("Unauthorized", 401);
            }
            const result = await user_service_1.UserService.deleteProfile(req.user.userId);
            res.json({
                success: true,
                message: result.message,
                userId: result.userId,
            });
        }
        catch (err) {
            next(err);
        }
    };
}
exports.UserController = UserController;
//# sourceMappingURL=user.controller.js.map