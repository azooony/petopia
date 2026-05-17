"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorMiddleware = void 0;
const multer_1 = __importDefault(require("multer"));
const AppError_1 = require("../errors/AppError");
const errorMiddleware = (err, _req, res, _next) => {
    const statusCode = err instanceof AppError_1.AppError ? err.statusCode : err instanceof multer_1.default.MulterError ? 400 : 500;
    const message = err.message || "Internal Server Error";
    res.status(statusCode).json({
        success: false,
        message,
        error: process.env.NODE_ENV === 'development' ? err.stack : message,
    });
};
exports.errorMiddleware = errorMiddleware;
//# sourceMappingURL=error.middleware.js.map