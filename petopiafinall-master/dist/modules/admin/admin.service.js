"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminService = exports.AdminService = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const jwt_1 = require("@/common/utils/jwt");
const AppError_1 = require("@/common/errors/AppError");
const prisma_1 = require("../../../generated/prisma");
const admin_repository_1 = require("./admin.repository");
const notification_helpers_1 = require("../Notification/notification.helpers");
const notification_templates_1 = require("../Notification/notification.templates");
class AdminService {
    repo;
    constructor(repo) {
        this.repo = repo;
    }
    // ── Auth ──────────────────────────────────────────────────────────────────
    async login(dto) {
        const admin = await this.repo.findAdminByEmail(dto.email);
        if (!admin)
            throw new AppError_1.AppError("Invalid credentials", AppError_1.HttpCode.UNAUTHORIZED);
        const isValid = await bcrypt_1.default.compare(dto.password, admin.passwordHash);
        if (!isValid)
            throw new AppError_1.AppError("Invalid credentials", AppError_1.HttpCode.UNAUTHORIZED);
        const token = (0, jwt_1.generateToken)({ userId: admin.id, role: admin.role });
        const { passwordHash: _omit, ...adminSafe } = admin;
        return { token, admin: adminSafe };
    }
    // ── Vets ──────────────────────────────────────────────────────────────────
    async getPendingVets() {
        return this.repo.findPendingVets();
    }
    async approveVet(vetProfileId, adminId) {
        const profile = await this.repo.findVetProfileById(vetProfileId);
        if (!profile)
            throw new AppError_1.AppError("Vet profile not found", AppError_1.HttpCode.NOT_FOUND);
        if (profile.verificationStatus !== prisma_1.VerificationStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot approve: vet is already ${profile.verificationStatus.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        const updated = await this.repo.updateVetStatus(vetProfileId, prisma_1.VerificationStatus.VERIFIED);
        await this.repo.createAdminActionLog({
            adminId,
            action: "APPROVE_VET",
            entityType: "VetProfile",
            entityId: vetProfileId,
        });
        (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyVetApproved)(updated.user.id, vetProfileId));
        return updated;
    }
    async rejectVet(vetProfileId, adminId) {
        const profile = await this.repo.findVetProfileById(vetProfileId);
        if (!profile)
            throw new AppError_1.AppError("Vet profile not found", AppError_1.HttpCode.NOT_FOUND);
        if (profile.verificationStatus !== prisma_1.VerificationStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot reject: vet is already ${profile.verificationStatus.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        const updated = await this.repo.updateVetStatus(vetProfileId, prisma_1.VerificationStatus.REJECTED);
        await this.repo.createAdminActionLog({
            adminId,
            action: "REJECT_VET",
            entityType: "VetProfile",
            entityId: vetProfileId,
        });
        (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyVetRejected)(profile.userId, vetProfileId));
        return updated;
    }
    // ── Sitters ───────────────────────────────────────────────────────────────
    async getPendingSitters() {
        return this.repo.findPendingSitters();
    }
    async approveSitter(serviceId, adminId) {
        const listing = await this.repo.findSitterListingById(serviceId);
        if (!listing)
            throw new AppError_1.AppError("Sitter listing not found", AppError_1.HttpCode.NOT_FOUND);
        if (listing.verificationStatus !== prisma_1.SitterVerificationStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot approve: listing is already ${listing.verificationStatus.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        const updated = await this.repo.updateSitterStatus(serviceId, prisma_1.SitterVerificationStatus.APPROVED);
        await this.repo.createAdminActionLog({
            adminId,
            action: "APPROVE_SITTER",
            entityType: "SitterProfile",
            entityId: serviceId,
        });
        (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifySitterApproved)(updated.user.id, serviceId));
        return updated;
    }
    async rejectSitter(serviceId, adminId) {
        const listing = await this.repo.findSitterListingById(serviceId);
        if (!listing)
            throw new AppError_1.AppError("Sitter listing not found", AppError_1.HttpCode.NOT_FOUND);
        if (listing.verificationStatus !== prisma_1.SitterVerificationStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot reject: listing is already ${listing.verificationStatus.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        const updated = await this.repo.updateSitterStatus(serviceId, prisma_1.SitterVerificationStatus.REJECTED);
        await this.repo.createAdminActionLog({
            adminId,
            action: "REJECT_SITTER",
            entityType: "SitterProfile",
            entityId: serviceId,
        });
        (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifySitterRejected)(listing.userId, serviceId));
        return updated;
    }
    // ── Payments ──────────────────────────────────────────────────────────────
    async getPendingPayments() {
        return this.repo.findPendingAppointmentPayments();
    }
    async approvePayment(paymentId, adminId) {
        const payment = await this.repo.findPaymentById(paymentId);
        if (!payment)
            throw new AppError_1.AppError("Payment not found", AppError_1.HttpCode.NOT_FOUND);
        if (payment.status !== prisma_1.PaymentStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot approve: payment is already ${payment.status.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!payment.appointmentId) {
            throw new AppError_1.AppError("Payment is not linked to an appointment", AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!payment.appointment || payment.appointment.status !== prisma_1.AppointmentStatus.PENDING) {
            throw new AppError_1.AppError("Only pending appointments can be confirmed", AppError_1.HttpCode.BAD_REQUEST);
        }
        const [updatedPayment, updatedAppointment] = await this.repo.approveAppointmentPayment(paymentId, payment.appointmentId);
        await this.repo.createAdminActionLog({
            adminId,
            action: "APPROVE_PAYMENT",
            entityType: "Payment",
            entityId: paymentId,
            meta: { appointmentId: payment.appointmentId },
        });
        const appt = payment.appointment;
        if (appt) {
            (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyPaymentApproved)(appt.owner.id, paymentId, appt.id));
            (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyAppointmentConfirmedForVet)(appt.vet.id, appt.id, appt.pet.name ?? undefined));
        }
        return { payment: updatedPayment, appointment: updatedAppointment };
    }
    async rejectPayment(paymentId, adminId) {
        const payment = await this.repo.findPaymentById(paymentId);
        if (!payment)
            throw new AppError_1.AppError("Payment not found", AppError_1.HttpCode.NOT_FOUND);
        if (payment.status !== prisma_1.PaymentStatus.PENDING) {
            throw new AppError_1.AppError(`Cannot reject: payment is already ${payment.status.toLowerCase()}`, AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!payment.appointmentId) {
            throw new AppError_1.AppError("Payment is not linked to an appointment", AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!payment.appointment || payment.appointment.status !== prisma_1.AppointmentStatus.PENDING) {
            throw new AppError_1.AppError("Only pending appointments can be cancelled", AppError_1.HttpCode.BAD_REQUEST);
        }
        const [updatedPayment, updatedAppointment] = await this.repo.rejectAppointmentPayment(paymentId, payment.appointmentId);
        await this.repo.createAdminActionLog({
            adminId,
            action: "REJECT_PAYMENT",
            entityType: "Payment",
            entityId: paymentId,
            meta: { appointmentId: payment.appointmentId },
        });
        const appt = payment.appointment;
        if (appt) {
            (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyPaymentRejected)(appt.owner.id, paymentId, appt.id));
        }
        return { payment: updatedPayment, appointment: updatedAppointment };
    }
}
exports.AdminService = AdminService;
exports.adminService = new AdminService(admin_repository_1.adminRepository);
//# sourceMappingURL=admin.service.js.map