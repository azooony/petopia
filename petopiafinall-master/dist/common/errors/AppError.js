"use strict";
// src/common/errors/AppError.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppError = exports.HttpCode = void 0;
var HttpCode;
(function (HttpCode) {
    HttpCode[HttpCode["OK"] = 200] = "OK";
    HttpCode[HttpCode["CREATED"] = 201] = "CREATED";
    HttpCode[HttpCode["BAD_REQUEST"] = 400] = "BAD_REQUEST";
    HttpCode[HttpCode["UNAUTHORIZED"] = 401] = "UNAUTHORIZED";
    HttpCode[HttpCode["FORBIDDEN"] = 403] = "FORBIDDEN";
    HttpCode[HttpCode["NOT_FOUND"] = 404] = "NOT_FOUND";
    HttpCode[HttpCode["CONFLICT"] = 409] = "CONFLICT";
    HttpCode[HttpCode["INTERNAL_SERVER_ERROR"] = 500] = "INTERNAL_SERVER_ERROR";
})(HttpCode || (exports.HttpCode = HttpCode = {}));
class AppError extends Error {
    statusCode; // Changed to use the Enum type
    isOperational;
    constructor(message, statusCode = HttpCode.INTERNAL_SERVER_ERROR) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;
        Error.captureStackTrace(this, this.constructor);
    }
}
exports.AppError = AppError;
// export class AppError extends Error {
//   statusCode: number;
//   isOperational: boolean;
//   constructor(message: string, statusCode: number = 500) {
//     super(message);
//     this.statusCode = statusCode;
//     this.isOperational = true;
//     Error.captureStackTrace(this, this.constructor);
//   }
// }
//# sourceMappingURL=AppError.js.map