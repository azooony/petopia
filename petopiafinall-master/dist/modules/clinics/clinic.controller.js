"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createClinic = void 0;
const prisma_1 = __importDefault(require("../../config/prisma")); //changed from import {prisma} from "../../config/prisma"
const AppError_1 = require("../../common/errors/AppError");
const createClinic = async (req, res, next) => {
    try {
        const { name, address, phone } = req.body;
        if (!name || !address || !phone) {
            throw new AppError_1.AppError("Clinic name, address, and phone are required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const clinic = await prisma_1.default.clinic.create({
            data: {
                name,
                address,
                phone,
            },
        });
        res.status(201).json({
            success: true,
            message: "Clinic created successfully",
            data: clinic,
        });
    }
    catch (err) {
        next(err);
    }
};
exports.createClinic = createClinic;
//# sourceMappingURL=clinic.controller.js.map