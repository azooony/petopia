import { Request, Response } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { BookAppointmentSchema } from "./appointments.dto";
import { AppointmentsService, appointmentsService } from "./appointments.service";

export class AppointmentsController {
  constructor(private readonly service: AppointmentsService) {}

  getDoctors = async (_req: Request, res: Response): Promise<void> => {
    try {
      const doctors = await this.service.listDoctors();
      res.status(HttpCode.OK).json({
        success: true,
        message: "Verified vets retrieved successfully",
        data: doctors,
      });
    } catch (err) {
      this.handleError(err, res);
    }
  };

  getMyAppointments = async (req: AuthRequest, res: Response): Promise<void> => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(HttpCode.UNAUTHORIZED).json({ success: false, message: 'Not authenticated', error: 'Not authenticated' });
      return;
    }
    try {
      const appointments = await this.service.getMyAppointments(userId);
      res.status(HttpCode.OK).json({ success: true, data: appointments });
    } catch (err) {
      this.handleError(err, res);
    }
  };

  bookAppointment = async (req: AuthRequest, res: Response): Promise<void> => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(HttpCode.UNAUTHORIZED).json({
        success: false,
        message: "Not authenticated",
        error: "Not authenticated",
      });
      return;
    }

    const parsed = BookAppointmentSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(HttpCode.BAD_REQUEST).json({
        success: false,
        message: "Validation failed",
        error: parsed.error.flatten(),
      });
      return;
    }

    try {
      const result = await this.service.bookAppointment(userId, parsed.data, req.file);
      res.status(HttpCode.CREATED).json({
        success: true,
        message: "Appointment booked successfully",
        data: result,
      });
    } catch (err) {
      this.handleError(err, res);
    }
  };

  private handleError(err: unknown, res: Response): void {
    if (err instanceof AppError) {
      res.status(err.statusCode).json({
        success: false,
        message: err.message,
        error: err.message,
      });
      return;
    }
    throw err;
  }
}

export const appointmentsController = new AppointmentsController(appointmentsService);
