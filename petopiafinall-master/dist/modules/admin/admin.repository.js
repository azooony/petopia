"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminRepository = exports.AdminRepository = void 0;
const prisma_1 = require("../../../generated/prisma");
const prisma_2 = __importDefault(require("@/config/prisma"));
class AdminRepository {
    db;
    constructor(db) {
        this.db = db;
    }
    // ── Auth ──────────────────────────────────────────────────────────────────
    async findAdminByEmail(email) {
        return this.db.user.findFirst({
            where: { email, role: prisma_1.UserRole.ADMIN },
        });
    }
    // ── Vets ──────────────────────────────────────────────────────────────────
    async findPendingVets() {
        return this.db.vetProfile.findMany({
            where: { verificationStatus: prisma_1.VerificationStatus.PENDING },
            include: {
                user: { select: { id: true, fullName: true, email: true, createdAt: true } },
                clinic: { select: { id: true, name: true, address: true } },
            },
            orderBy: { user: { createdAt: "asc" } },
        });
    }
    async findVetProfileById(id) {
        return this.db.vetProfile.findUnique({ where: { id } });
    }
    async updateVetStatus(id, status) {
        return this.db.vetProfile.update({
            where: { id },
            data: { verificationStatus: status },
            include: {
                user: { select: { id: true, fullName: true, email: true } },
                clinic: { select: { id: true, name: true } },
            },
        });
    }
    // ── Sitters ───────────────────────────────────────────────────────────────
    async findPendingSitters() {
        return this.db.sitterProfile.findMany({
            where: { verificationStatus: prisma_1.SitterVerificationStatus.PENDING },
            include: {
                user: { select: { id: true, fullName: true, email: true } },
                images: { select: { id: true, imageUrl: true, createdAt: true } },
            },
            orderBy: { createdAt: "asc" },
        });
    }
    async findSitterListingById(id) {
        return this.db.sitterProfile.findUnique({ where: { id } });
    }
    async updateSitterStatus(id, status) {
        return this.db.sitterProfile.update({
            where: { id },
            data: { verificationStatus: status },
            include: {
                user: { select: { id: true, fullName: true, email: true } },
                images: { select: { id: true, imageUrl: true } },
            },
        });
    }
    // ── Payments ──────────────────────────────────────────────────────────────
    async findPendingAppointmentPayments() {
        return this.db.payment.findMany({
            where: {
                status: prisma_1.PaymentStatus.PENDING,
                appointmentId: { not: null },
            },
            include: {
                payer: { select: { id: true, fullName: true, email: true } },
                appointment: {
                    include: {
                        owner: { select: { id: true, fullName: true, email: true } },
                        vet: { select: { id: true, fullName: true, email: true } },
                    },
                },
                proofAsset: { select: { id: true, url: true } },
            },
            orderBy: { createdAt: "asc" },
        });
    }
    async findPaymentById(id) {
        return this.db.payment.findUnique({
            where: { id },
            include: { appointment: true },
        });
    }
    async approveAppointmentPayment(paymentId, appointmentId) {
        return this.db.$transaction([
            this.db.payment.update({
                where: { id: paymentId },
                data: { status: prisma_1.PaymentStatus.PAID },
            }),
            this.db.appointment.update({
                where: { id: appointmentId },
                data: { status: prisma_1.AppointmentStatus.CONFIRMED },
            }),
        ]);
    }
    async rejectAppointmentPayment(paymentId, appointmentId) {
        return this.db.$transaction([
            this.db.payment.update({
                where: { id: paymentId },
                data: { status: prisma_1.PaymentStatus.FAILED },
            }),
            this.db.appointment.update({
                where: { id: appointmentId },
                data: { status: prisma_1.AppointmentStatus.CANCELLED },
            }),
        ]);
    }
    // ── Audit Log ─────────────────────────────────────────────────────────────
    async createAdminActionLog(data) {
        return this.db.adminActionLog.create({ data });
    }
}
exports.AdminRepository = AdminRepository;
exports.adminRepository = new AdminRepository(prisma_2.default);
//# sourceMappingURL=admin.repository.js.map