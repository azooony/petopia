"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAdmin = void 0;
const AppError_1 = require("../errors/AppError");
const prisma_1 = require("../../../generated/prisma"); // Use your generated Enum
const isAdmin = (req, res, next) => {
    // Assuming your auth middleware populates req.user
    if (req.user?.role !== prisma_1.UserRole.ADMIN) {
        throw new AppError_1.AppError('Access denied: Admins only', AppError_1.HttpCode.FORBIDDEN);
    }
    next();
};
exports.isAdmin = isAdmin;
//# sourceMappingURL=admin.middleware.js.map