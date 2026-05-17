import {
  PrismaClient,
  AppointmentStatus,
  VerificationStatus,
  PaymentMethod,
  PaymentStatus,
  Prisma,
} from "../../../generated/prisma";
import prisma from "../../config/prisma";

export class ConflictError extends Error {
  constructor() {
    super("This appointment slot is already booked");
    this.name = "ConflictError";
  }
}

export class AppointmentsRepository {
  constructor(private readonly db: PrismaClient) {}

  async listVerifiedVets() {
    return this.db.user.findMany({
      where: {
        role: "VET",
        vetProfile: { verificationStatus: VerificationStatus.VERIFIED },
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        vetProfile: {
          select: {
            id: true,
            phone: true,
            description: true,
            yearsOfExperience: true,
            appointmentPrice: true,
            startTime: true,
            endTime: true,
            photo: true,
            specialization: true,
            verificationStatus: true,
            clinic: {
              select: { id: true, name: true, address: true, phone: true },
            },
          },
        },
        availabilitySlots: {
          where: {
            isActive: true,
            endTime: { gt: new Date() },
          },
          orderBy: { startTime: "asc" },
          take: 10,
          select: { id: true, startTime: true, endTime: true },
        },
      },
    });
  }

  async findVetWithProfile(vetId: string) {
    return this.db.user.findUnique({
      where: { id: vetId },
      include: {
        vetProfile: { include: { clinic: true } },
      },
    });
  }

  async findMyAppointments(ownerId: string) {
    return this.db.appointment.findMany({
      where: {
        ownerId,
        status: { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
      },
      orderBy: { startTime: 'asc' },
      include: {
        vet: { select: { id: true, fullName: true, vetProfile: { select: { specialization: true, photo: true } } } },
        pet: { select: { id: true, name: true } },
      },
    });
  }

  async findPetForOwner(petId: string, ownerId: string) {
    return this.db.pet.findFirst({
      where: { id: petId, ownerId },
      select: { id: true, petOwnerProfileId: true },
    });
  }

  async bookAtomically(data: {
    ownerId: string;
    vetId: string;
    petId: string;
    startTime: Date;
    price: number;
    clinicName: string;
    clinicAddress: string;
    reason?: string;
    petOwnerProfileId?: string;
    invoiceUrl: string;
    invoiceStorageKey: string;
    invoiceMimeType: string;
    invoiceSizeBytes: number;
  }) {
    return this.db.$transaction(
      async (tx) => {
        const conflict = await tx.appointment.findFirst({
          where: {
            vetId: data.vetId,
            startTime: data.startTime,
            status: { in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
          },
        });

        if (conflict) {
          throw new ConflictError();
        }

        const appointment = await tx.appointment.create({
          data: {
            ownerId: data.ownerId,
            vetId: data.vetId,
            petId: data.petId,
            startTime: data.startTime,
            price: data.price,
            clinicName: data.clinicName,
            clinicAddress: data.clinicAddress,
            ...(data.reason !== undefined ? { reason: data.reason } : {}),
            ...(data.petOwnerProfileId !== undefined
              ? { petOwnerProfileId: data.petOwnerProfileId }
              : {}),
          },
          include: {
            vet: { select: { id: true, fullName: true, email: true } },
            pet: { select: { id: true, name: true, breed: true } },
            owner: { select: { id: true, fullName: true, email: true } },
          },
        });

        const asset = await tx.asset.create({
          data: {
            url: data.invoiceUrl,
            storageKey: data.invoiceStorageKey,
            mimeType: data.invoiceMimeType,
            sizeBytes: data.invoiceSizeBytes,
            uploadedById: data.ownerId,
          },
        });

        const payment = await tx.payment.create({
          data: {
            appointmentId: appointment.id,
            payerId: data.ownerId,
            method: PaymentMethod.INSTAPAY,
            status: PaymentStatus.PENDING,
            amount: Math.round(data.price),
            proofAssetId: asset.id,
            ...(data.petOwnerProfileId !== undefined
              ? { petOwnerProfileId: data.petOwnerProfileId }
              : {}),
          },
        });

        return { appointment, payment, asset };
      },
      {
        isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
      }
    );
  }
}

export const appointmentsRepository = new AppointmentsRepository(prisma);
