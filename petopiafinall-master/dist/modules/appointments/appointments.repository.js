"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentsRepository = exports.AppointmentsRepository = exports.ConflictError = void 0;
const prisma_1 = require("../../../generated/prisma");
const prisma_2 = __importDefault(require("../../config/prisma"));
class ConflictError extends Error {
    constructor() {
        super("This appointment slot is already booked");
        this.name = "ConflictError";
    }
}
exports.ConflictError = ConflictError;
class AppointmentsRepository {
    db;
    constructor(db) {
        this.db = db;
    }
    async listVerifiedVets() {
        return this.db.user.findMany({
            where: {
                role: "VET",
                vetProfile: { verificationStatus: prisma_1.VerificationStatus.VERIFIED },
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
    async findVetWithProfile(vetId) {
        return this.db.user.findUnique({
            where: { id: vetId },
            include: {
                vetProfile: { include: { clinic: true } },
            },
        });
    }
    async findMyAppointments(ownerId) {
        return this.db.appointment.findMany({
            where: {
                ownerId,
                status: { in: [prisma_1.AppointmentStatus.PENDING, prisma_1.AppointmentStatus.CONFIRMED] },
            },
            orderBy: { startTime: 'asc' },
            include: {
                vet: { select: { id: true, fullName: true, vetProfile: { select: { specialization: true, photo: true } } } },
                pet: { select: { id: true, name: true } },
            },
        });
    }
    async findPetForOwner(petId, ownerId) {
        return this.db.pet.findFirst({
            where: { id: petId, ownerId },
            select: { id: true, petOwnerProfileId: true },
        });
    }
    async bookAtomically(data) {
        return this.db.$transaction(async (tx) => {
            const conflict = await tx.appointment.findFirst({
                where: {
                    vetId: data.vetId,
                    startTime: data.startTime,
                    status: { in: [prisma_1.AppointmentStatus.PENDING, prisma_1.AppointmentStatus.CONFIRMED] },
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
                    method: prisma_1.PaymentMethod.INSTAPAY,
                    status: prisma_1.PaymentStatus.PENDING,
                    amount: Math.round(data.price),
                    proofAssetId: asset.id,
                    ...(data.petOwnerProfileId !== undefined
                        ? { petOwnerProfileId: data.petOwnerProfileId }
                        : {}),
                },
            });
            return { appointment, payment, asset };
        }, {
            isolationLevel: prisma_1.Prisma.TransactionIsolationLevel.Serializable,
        });
    }
}
exports.AppointmentsRepository = AppointmentsRepository;
exports.appointmentsRepository = new AppointmentsRepository(prisma_2.default);
//# sourceMappingURL=appointments.repository.js.map