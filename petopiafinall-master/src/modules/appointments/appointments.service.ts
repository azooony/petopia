import { Prisma, UserRole, VerificationStatus } from "../../../generated/prisma";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { BookAppointmentDto } from "./appointments.dto";
import {
  AppointmentsRepository,
  ConflictError,
  appointmentsRepository,
} from "./appointments.repository";
import { fireNotification } from "../Notification/notification.helpers";
import { notifyAppointmentBookedPending } from "../Notification/notification.templates";

export class AppointmentsService {
  constructor(private readonly repo: AppointmentsRepository) {}

  async listDoctors() {
    return this.repo.listVerifiedVets();
  }

  async getMyAppointments(ownerId: string) {
    return this.repo.findMyAppointments(ownerId);
  }

  async bookAppointment(
    ownerId: string,
    dto: BookAppointmentDto,
    invoiceFile: Express.Multer.File | undefined
  ) {
    if (!invoiceFile) {
      throw new AppError("Invoice proof image is required", HttpCode.BAD_REQUEST);
    }

    const requestedTime = new Date(dto.startTime);

    const vet = await this.repo.findVetWithProfile(dto.vetId);
    if (!vet || vet.role !== UserRole.VET || !vet.vetProfile) {
      throw new AppError("Vet not found", HttpCode.NOT_FOUND);
    }

    if (vet.vetProfile.verificationStatus !== VerificationStatus.VERIFIED) {
      throw new AppError("Only verified vets can receive appointments", HttpCode.FORBIDDEN);
    }

    this.validateWithinWorkingHours(
      requestedTime,
      vet.vetProfile.startTime,
      vet.vetProfile.endTime
    );

    const pet = await this.repo.findPetForOwner(dto.petId, ownerId);
    if (!pet) {
      throw new AppError("Pet not found for this owner", HttpCode.NOT_FOUND);
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

      fireNotification(
        notifyAppointmentBookedPending(ownerId, result.appointment.id),
      );

      return result;
    } catch (err) {
      if (err instanceof ConflictError) {
        throw new AppError(err.message, HttpCode.CONFLICT);
      }
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === "P2034"
      ) {
        throw new AppError(
          "Slot was taken by a concurrent request. Please try again.",
          HttpCode.CONFLICT
        );
      }
      throw err;
    }
  }

  private validateWithinWorkingHours(
    startTime: Date,
    profileStart: string,
    profileEnd: string
  ) {
    const apptMinutes = startTime.getHours() * 60 + startTime.getMinutes();
    const [sh, sm] = profileStart.split(":").map(Number) as [number, number];
    const [eh, em] = profileEnd.split(":").map(Number) as [number, number];
    const startMinutes = sh * 60 + sm;
    const endMinutes = eh * 60 + em;

    if (apptMinutes < startMinutes || apptMinutes >= endMinutes) {
      throw new AppError(
        "Appointment time must be within vet working hours",
        HttpCode.BAD_REQUEST
      );
    }
  }
}

export const appointmentsService = new AppointmentsService(appointmentsRepository);
