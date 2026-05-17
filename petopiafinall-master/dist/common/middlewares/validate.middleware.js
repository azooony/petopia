"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validate = void 0;
const zod_1 = require("zod");
const AppError_1 = require("../errors/AppError");
const validate = (schema) => async (req, _res, next) => {
    try {
        req.body = await schema.parseAsync(req.body);
        next();
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return next(new AppError_1.AppError(error.issues.map((issue) => issue.message).join(", "), AppError_1.HttpCode.BAD_REQUEST));
        }
        next(error);
    }
};
exports.validate = validate;
//# sourceMappingURL=validate.middleware.js.map