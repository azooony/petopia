import bcrypt from "bcrypt";
import { generateToken } from "@/common/utils/jwt";
import { AppError, HttpCode } from "@/common/errors/AppError";
import { VerificationStatus, SitterVerificationStatus, PaymentStatus, Prisma, AppointmentStatus } from "../../../generated/prisma";
import { AdminRepository, adminRepository } from "./admin.repository";
import type { AdminLoginDto } from "./admin.dto";

export class AdminService {
  constructor(private readonly repo: AdminRepository) {}

  // ── Auth ──────────────────────────────────────────────────────────────────

  async login(dto: AdminLoginDto) {
    const admin = await this.repo.findAdminByEmail(dto.email);
    if (!admin) throw new AppError("Invalid credentials", HttpCode.UNAUTHORIZED);

    const isValid = await bcrypt.compare(dto.password, admin.passwordHash);
    if (!isValid) throw new AppError("Invalid credentials", HttpCode.UNAUTHORIZED);

    const token = generateToken({ userId: admin.id, role: admin.role });
    const { passwordHash: _omit, ...adminSafe } = admin;
    return { token, admin: adminSafe };
  }

  // ── Vets ──────────────────────────────────────────────────────────────────

  async getPendingVets() {
    return this.repo.findPendingVets();
  }

  async approveVet(vetProfileId: string, adminId: string) {
    const profile = await this.repo.findVetProfileById(vetProfileId);
    if (!profile) throw new AppError("Vet profile not found", HttpCode.NOT_FOUND);

    if (profile.verificationStatus !== VerificationStatus.PENDING) {
      throw new AppError(
        `Cannot approve: vet is already ${profile.verificationStatus.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await this.repo.updateVetStatus(vetProfileId, VerificationStatus.VERIFIED);

    await this.repo.createAdminActionLog({
      adminId,
      action: "APPROVE_VET",
      entityType: "VetProfile",
      entityId: vetProfileId,
    });

    return updated;
  }

  async rejectVet(vetProfileId: string, adminId: string) {
    const profile = await this.repo.findVetProfileById(vetProfileId);
    if (!profile) throw new AppError("Vet profile not found", HttpCode.NOT_FOUND);

    if (profile.verificationStatus !== VerificationStatus.PENDING) {
      throw new AppError(
        `Cannot reject: vet is already ${profile.verificationStatus.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await this.repo.updateVetStatus(vetProfileId, VerificationStatus.REJECTED);

    await this.repo.createAdminActionLog({
      adminId,
      action: "REJECT_VET",
      entityType: "VetProfile",
      entityId: vetProfileId,
    });

    return updated;
  }

  // ── Sitters ───────────────────────────────────────────────────────────────

  async getPendingSitters() {
    return this.repo.findPendingSitters();
  }

  async approveSitter(serviceId: string, adminId: string) {
    const listing = await this.repo.findSitterListingById(serviceId);
    if (!listing) throw new AppError("Sitter listing not found", HttpCode.NOT_FOUND);

    if (listing.verificationStatus !== SitterVerificationStatus.PENDING) {
      throw new AppError(
        `Cannot approve: listing is already ${listing.verificationStatus.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await this.repo.updateSitterStatus(serviceId, SitterVerificationStatus.APPROVED);

    await this.repo.createAdminActionLog({
      adminId,
      action: "APPROVE_SITTER",
      entityType: "SitterProfile",
      entityId: serviceId,
    });

    return updated;
  }

  async rejectSitter(serviceId: string, adminId: string) {
    const listing = await this.repo.findSitterListingById(serviceId);
    if (!listing) throw new AppError("Sitter listing not found", HttpCode.NOT_FOUND);

    if (listing.verificationStatus !== SitterVerificationStatus.PENDING) {
      throw new AppError(
        `Cannot reject: listing is already ${listing.verificationStatus.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    const updated = await this.repo.updateSitterStatus(serviceId, SitterVerificationStatus.REJECTED);

    await this.repo.createAdminActionLog({
      adminId,
      action: "REJECT_SITTER",
      entityType: "SitterProfile",
      entityId: serviceId,
    });

    return updated;
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  async getPendingPayments() {
    return this.repo.findPendingAppointmentPayments();
  }

  async approvePayment(paymentId: string, adminId: string) {
    const payment = await this.repo.findPaymentById(paymentId);
    if (!payment) throw new AppError("Payment not found", HttpCode.NOT_FOUND);

    if (payment.status !== PaymentStatus.PENDING) {
      throw new AppError(
        `Cannot approve: payment is already ${payment.status.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    if (!payment.appointmentId) {
      throw new AppError("Payment is not linked to an appointment", HttpCode.BAD_REQUEST);
    }

    if (!payment.appointment || payment.appointment.status !== AppointmentStatus.PENDING) {
      throw new AppError("Only pending appointments can be confirmed", HttpCode.BAD_REQUEST);
    }

    const [updatedPayment, updatedAppointment] = await this.repo.approveAppointmentPayment(
      paymentId,
      payment.appointmentId
    );

    await this.repo.createAdminActionLog({
      adminId,
      action: "APPROVE_PAYMENT",
      entityType: "Payment",
      entityId: paymentId,
      meta: { appointmentId: payment.appointmentId } satisfies Prisma.InputJsonObject,
    });

    return { payment: updatedPayment, appointment: updatedAppointment };
  }

  async rejectPayment(paymentId: string, adminId: string) {
    const payment = await this.repo.findPaymentById(paymentId);
    if (!payment) throw new AppError("Payment not found", HttpCode.NOT_FOUND);

    if (payment.status !== PaymentStatus.PENDING) {
      throw new AppError(
        `Cannot reject: payment is already ${payment.status.toLowerCase()}`,
        HttpCode.BAD_REQUEST
      );
    }

    if (!payment.appointmentId) {
      throw new AppError("Payment is not linked to an appointment", HttpCode.BAD_REQUEST);
    }

    if (!payment.appointment || payment.appointment.status !== AppointmentStatus.PENDING) {
      throw new AppError("Only pending appointments can be cancelled", HttpCode.BAD_REQUEST);
    }

    const [updatedPayment, updatedAppointment] = await this.repo.rejectAppointmentPayment(
      paymentId,
      payment.appointmentId
    );

    await this.repo.createAdminActionLog({
      adminId,
      action: "REJECT_PAYMENT",
      entityType: "Payment",
      entityId: paymentId,
      meta: { appointmentId: payment.appointmentId } satisfies Prisma.InputJsonObject,
    });

    return { payment: updatedPayment, appointment: updatedAppointment };
  }
}

export const adminService = new AdminService(adminRepository);
