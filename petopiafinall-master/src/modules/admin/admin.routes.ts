import { Router } from "express";
import { protect, restrictTo } from "@/common/middlewares/auth.middleware";
import { UserRole } from "../../../generated/prisma";
import { adminController } from "./admin.controller";

const router = Router();

// Public: admin login only /admin/login
router.post("/login", adminController.login);

// All routes below require a valid JWT with ADMIN role
router.use(protect, restrictTo(UserRole.ADMIN));

// Vet approvals /admin/vets/pending, /admin/vets/:id/approve, /admin/vets/:id/reject
router.get("/vets/pending", adminController.getPendingVets);
router.patch("/vets/:id/approve", adminController.approveVet);
router.patch("/vets/:id/reject", adminController.rejectVet);

// Sitter environment approvals /admin/sitters/pending, /admin/sitters/:id/approve, /admin/sitters/:id/reject
router.get("/sitters/pending", adminController.getPendingSitters);
router.patch("/sitters/:id/approve", adminController.approveSitter);
router.patch("/sitters/:id/reject", adminController.rejectSitter);

// Appointment payment (InstaPay invoice) approvals /admin/payments/pending, /admin/payments/:id/approve, /admin/payments/:id/reject
router.get("/payments/pending", adminController.getPendingPayments);
router.patch("/payments/:id/approve", adminController.approvePayment);
router.patch("/payments/:id/reject", adminController.rejectPayment);

export default router;