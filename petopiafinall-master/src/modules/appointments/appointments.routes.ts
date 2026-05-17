import { Router } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import { Request } from "express";
import { UserRole } from "../../../generated/prisma";
import { protect, restrictTo } from "../../common/middlewares/auth.middleware";
import { appointmentsController } from "./appointments.controller";
import { AppError, HttpCode } from "../../common/errors/AppError";

const router = Router();

const invoiceStorage = multer.diskStorage({
  destination: (_req: Request, _file, cb) => {
    const dir = "uploads/invoices/";
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (_req: Request, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const invoiceUpload = multer({
  storage: invoiceStorage,
  fileFilter: (_req: Request, file: Express.Multer.File, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new AppError("Only images are allowed for invoices", HttpCode.BAD_REQUEST) as unknown as null, false);
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 },
});

// GET /appointments/doctors — list all verified vets with profile, clinic, availability
router.get("/doctors", protect, appointmentsController.getDoctors);

// GET /appointments/my — pet owner's own active appointments
router.get("/my", protect, restrictTo(UserRole.PET_OWNER), appointmentsController.getMyAppointments);

// POST /appointments/book — pet owner submits booking + InstaPay invoice image
router.post(
  "/book",
  protect,
  restrictTo(UserRole.PET_OWNER),
  invoiceUpload.single("invoice"),
  appointmentsController.bookAppointment
);

export default router;
