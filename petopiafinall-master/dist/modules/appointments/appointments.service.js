"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentsService = exports.AppointmentsService = void 0;
const prisma_1 = require("../../../generated/prisma");
const AppError_1 = require("../../common/errors/AppError");
const appointments_repository_1 = require("./appointments.repository");
const notification_helpers_1 = require("../Notification/notification.helpers");
const notification_templates_1 = require("../Notification/notification.templates");
class AppointmentsService {
    repo;
    constructor(repo) {
        this.repo = repo;
    }
    async listDoctors() {
        return this.repo.listVerifiedVets();
    }
    async getMyAppointments(ownerId) {
        return this.repo.findMyAppointments(ownerId);
    }
    async bookAppointment(ownerId, dto, invoiceFile) {
        if (!invoiceFile) {
            throw new AppError_1.AppError("Invoice proof image is required", AppError_1.HttpCode.BAD_REQUEST);
        }
        const requestedTime = new Date(dto.startTime);
        const vet = await this.repo.findVetWithProfile(dto.vetId);
        if (!vet || vet.role !== prisma_1.UserRole.VET || !vet.vetProfile) {
            throw new AppError_1.AppError("Vet not found", AppError_1.HttpCode.NOT_FOUND);
        }
        if (vet.vetProfile.verificationStatus !== prisma_1.VerificationStatus.VERIFIED) {
            throw new AppError_1.AppError("Only verified vets can receive appointments", AppError_1.HttpCode.FORBIDDEN);
        }
        this.validateWithinWorkingHours(requestedTime, vet.vetProfile.startTime, vet.vetProfile.endTime);
        const pet = await this.repo.findPetForOwner(dto.petId, ownerId);
        if (!pet) {
            throw new AppError_1.AppError("Pet not found for this owner", AppError_1.HttpCode.NOT_FOUND);
        }
        try {
            const result = await this.repo.bookAtomically({
                ownerId,
                vetId: dto.vetId,
                petId: dto.petId,
                startTime: requestedTime,
                price: vet.vetProfile.appointmentPrice,
                clinicName: vet.vetProfile.clinic.name,
                clinicAddress: vet.vetProfile.clinic.address,
                ...(dto.reason !== undefined ? { reason: dto.reason } : {}),
                ...(pet.petOwnerProfileId !== null && pet.petOwnerProfileId !== undefined
                    ? { petOwnerProfileId: pet.petOwnerProfileId }
                    : {}),
                invoiceUrl: `/uploads/invoices/${invoiceFile.filename}`,
                invoiceStorageKey: `invoices/${invoiceFile.filename}`,
                invoiceMimeType: invoiceFile.mimetype,
                invoiceSizeBytes: invoiceFile.size,
            });
            (0, notification_helpers_1.fireNotification)((0, notification_templates_1.notifyAppointmentBookedPending)(ownerId, result.appointment.id));
            return result;
        }
        catch (err) {
            if (err instanceof appointments_repository_1.ConflictError) {
                throw new AppError_1.AppError(err.message, AppError_1.HttpCode.CONFLICT);
            }
            if (err instanceof prisma_1.Prisma.PrismaClientKnownRequestError &&
                err.code === "P2034") {
                throw new AppError_1.AppError("Slot was taken by a concurrent request. Please try again.", AppError_1.HttpCode.CONFLICT);
            }
            throw err;
        }
    }
    validateWithinWorkingHours(startTime, profileStart, profileEnd) {
        const apptMinutes = startTime.getHours() * 60 + startTime.getMinutes();
        const [sh, sm] = profileStart.split(":").map(Number);
        const [eh, em] = profileEnd.split(":").map(Number);
        const startMinutes = sh * 60 + sm;
        const endMinutes = eh * 60 + em;
        if (apptMinutes < startMinutes || apptMinutes >= endMinutes) {
            throw new AppError_1.AppError("Appointment time must be within vet working hours", AppError_1.HttpCode.BAD_REQUEST);
        }
    }
}
exports.AppointmentsService = AppointmentsService;
exports.appointmentsService = new AppointmentsService(appointments_repository_1.appointmentsRepository);
//# sourceMappingURL=appointments.service.js.map