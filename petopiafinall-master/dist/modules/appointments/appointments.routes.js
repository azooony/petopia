"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const prisma_1 = require("../../../generated/prisma");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const appointments_controller_1 = require("./appointments.controller");
const AppError_1 = require("../../common/errors/AppError");
const router = (0, express_1.Router)();
const invoiceStorage = multer_1.default.diskStorage({
    destination: (_req, _file, cb) => {
        const dir = "uploads/invoices/";
        fs_1.default.mkdirSync(dir, { recursive: true });
        cb(null, dir);
    },
    filename: (_req, file, cb) => {
        cb(null, Date.now() + path_1.default.extname(file.originalname));
    },
});
const invoiceUpload = (0, multer_1.default)({
    storage: invoiceStorage,
    fileFilter: (_req, file, cb) => {
        if (file.mimetype.startsWith("image/")) {
            cb(null, true);
        }
        else {
            cb(new AppError_1.AppError("Only images are allowed for invoices", AppError_1.HttpCode.BAD_REQUEST), false);
        }
    },
    limits: { fileSize: 5 * 1024 * 1024 },
});
// GET /appointments/doctors — list all verified vets with profile, clinic, availability
router.get("/doctors", auth_middleware_1.protect, appointments_controller_1.appointmentsController.getDoctors);
// GET /appointments/my — pet owner's own active appointments
router.get("/my", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.PET_OWNER), appointments_controller_1.appointmentsController.getMyAppointments);
// POST /appointments/book — pet owner submits booking + InstaPay invoice image
router.post("/book", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.PET_OWNER), invoiceUpload.single("invoice"), appointments_controller_1.appointmentsController.bookAppointment);
exports.default = router;
//# sourceMappingURL=appointments.routes.js.map