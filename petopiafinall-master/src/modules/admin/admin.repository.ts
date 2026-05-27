import {
  PrismaClient,
  Prisma,
  VerificationStatus,
  SitterVerificationStatus,
  PaymentStatus,
  AppointmentStatus,
  UserRole,
} from "../../../generated/prisma";
import prisma from "@/config/prisma";

export class AdminRepository {
  constructor(private readonly db: PrismaClient) {}

  // ── Auth ──────────────────────────────────────────────────────────────────

  async findAdminByEmail(email: string) {
    return this.db.user.findFirst({
      where: { email, role: UserRole.ADMIN },
    });
  }

  // ── Vets ──────────────────────────────────────────────────────────────────

  async findPendingVets() {
    return this.db.vetProfile.findMany({
      where: { verificationStatus: VerificationStatus.PENDING },
      include: {
        user: { select: { id: true, fullName: true, email: true, createdAt: true } },
        clinic: { select: { id: true, name: true, address: true } },
      },
      orderBy: { user: { createdAt: "asc" } },
    });
  }

  async findVetProfileById(id: string) {
    return this.db.vetProfile.findUnique({ where: { id } });
  }

  async updateVetStatus(id: string, status: VerificationStatus) {
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
      where: { verificationStatus: SitterVerificationStatus.PENDING },
      include: {
        user: { select: { id: true, fullName: true, email: true } },
        images: { select: { id: true, imageUrl: true, createdAt: true } },
      },
      orderBy: { createdAt: "asc" },
    });
  }

  async findSitterListingById(id: string) {
    return this.db.sitterProfile.findUnique({ where: { id } });
  }

  async updateSitterStatus(id: string, status: SitterVerificationStatus) {
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
        status: PaymentStatus.PENDING,
        appointmentId: { not: null },
      },
      include: {
        payer: { select: { id: true, fullName: true, email: true } },
        appointment: {
          include: {
            owner: { select: { id: true, fullName: true, email: true } },
            vet:   { select: { id: true, fullName: true, email: true } },
            pet:   { select: { name: true } },
          },
        },
        proofAsset: { select: { id: true, url: true } },
      },
      orderBy: { createdAt: "asc" },
    });
  }

  async findPaymentById(id: string) {
    return this.db.payment.findUnique({
      where: { id },
      include: {
        appointment: {
          include: {
            owner: { select: { id: true } },
            vet: { select: { id: true } },
            pet: { select: { name: true } },
          },
        },
      },
    });
  }

  async approveAppointmentPayment(paymentId: string, appointmentId: string) {
    return this.db.$transaction([
      this.db.payment.update({
        where: { id: paymentId },
        data: { status: PaymentStatus.PAID },
      }),
      this.db.appointment.update({
        where: { id: appointmentId },
        data: { status: AppointmentStatus.CONFIRMED },
      }),
    ]);
  }

  async rejectAppointmentPayment(paymentId: string, appointmentId: string) {
    return this.db.$transaction([
      this.db.payment.update({
        where: { id: paymentId },
        data: { status: PaymentStatus.FAILED },
      }),
      this.db.appointment.update({
        where: { id: appointmentId },
        data: { status: AppointmentStatus.CANCELLED },
      }),
    ]);
  }

  // ── Audit Log ─────────────────────────────────────────────────────────────

  async createAdminActionLog(data: {
    adminId: string;
    action: string;
    entityType?: string;
    entityId?: string;
    meta?: Prisma.InputJsonValue;
  }) {
    return this.db.adminActionLog.create({ data });
  }
}

export const adminRepository = new AdminRepository(prisma);