"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.restrictTo = exports.protect = void 0;
const jwt_1 = require("../utils/jwt");
const AppError_1 = require("../errors/AppError");
// Verifies the Bearer token and attaches the decoded payload to req.user.
const protect = (req, _res, next) => {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
        return next(new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED));
    }
    const token = header.split(" ")[1];
    if (!token) {
        return next(new AppError_1.AppError("Unauthorized", AppError_1.HttpCode.UNAUTHORIZED));
    }
    try {
        req.user = (0, jwt_1.verifyToken)(token);
        next();
    }
    catch {
        return next(new AppError_1.AppError("Invalid or expired token", AppError_1.HttpCode.UNAUTHORIZED));
    }
};
exports.protect = protect;
// Guards a route to one or more roles. Must be used after `protect`.
const restrictTo = (...roles) => {
    return (req, _res, next) => {
        if (!req.user || !roles.includes(req.user.role)) {
            return next(new AppError_1.AppError("You do not have permission to perform this action", AppError_1.HttpCode.FORBIDDEN));
        }
        next();
    };
};
exports.restrictTo = restrictTo;
exports.default = { protect: exports.protect, restrictTo: exports.restrictTo };
//# sourceMappingURL=auth.middleware.js.map