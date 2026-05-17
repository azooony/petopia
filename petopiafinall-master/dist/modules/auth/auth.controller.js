"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("./auth.service");
class AuthController {
    static registerPetOwner = async (req, res, next) => {
        try {
            const result = await auth_service_1.AuthService.registerPetOwner(req.body);
            res.status(201).json({
                success: true,
                message: "Pet owner registered successfully",
                data: result,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static registerVet = async (req, res, next) => {
        try {
            if (!req.file) {
                res.status(400).json({
                    success: false,
                    message: "Certificate image is required",
                    error: "Certificate image is required",
                });
                return;
            }
            const result = await auth_service_1.AuthService.registerVet(req.body, req.file);
            res.status(201).json({
                success: true,
                message: result.message,
                data: result.user,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static login = async (req, res, next) => {
        try {
            const { email, password } = req.body;
            const result = await auth_service_1.AuthService.login(email, password);
            res.status(200).json({
                success: true,
                message: "Login successful",
                data: result,
            });
        }
        catch (err) {
            next(err);
        }
    };
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map