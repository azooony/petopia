"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appointmentsController = exports.AppointmentsController = void 0;
const AppError_1 = require("../../common/errors/AppError");
const appointments_dto_1 = require("./appointments.dto");
const appointments_service_1 = require("./appointments.service");
class AppointmentsController {
    service;
    constructor(service) {
        this.service = service;
    }
    getDoctors = async (_req, res) => {
        try {
            const doctors = await this.service.listDoctors();
            res.status(AppError_1.HttpCode.OK).json({
                success: true,
                message: "Verified vets retrieved successfully",
                data: doctors,
            });
        }
        catch (err) {
            this.handleError(err, res);
        }
    };
    getMyAppointments = async (req, res) => {
        const userId = req.user?.userId;
        if (!userId) {
            res.status(AppError_1.HttpCode.UNAUTHORIZED).json({ success: false, message: 'Not authenticated', error: 'Not authenticated' });
            return;
        }
        try {
            const appointments = await this.service.getMyAppointments(userId);
            res.status(AppError_1.HttpCode.OK).json({ success: true, data: appointments });
        }
        catch (err) {
            this.handleError(err, res);
        }
    };
    bookAppointment = async (req, res) => {
        const userId = req.user?.userId;
        if (!userId) {
            res.status(AppError_1.HttpCode.UNAUTHORIZED).json({
                success: false,
                message: "Not authenticated",
                error: "Not authenticated",
            });
            return;
        }
        const parsed = appointments_dto_1.BookAppointmentSchema.safeParse(req.body);
        if (!parsed.success) {
            res.status(AppError_1.HttpCode.BAD_REQUEST).json({
                success: false,
                message: "Validation failed",
                error: parsed.error.flatten(),
            });
            return;
        }
        try {
            const result = await this.service.bookAppointment(userId, parsed.data, req.file);
            res.status(AppError_1.HttpCode.CREATED).json({
                success: true,
                message: "Appointment booked successfully",
                data: result,
            });
        }
        catch (err) {
            this.handleError(err, res);
        }
    };
    handleError(err, res) {
        if (err instanceof AppError_1.AppError) {
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
exports.AppointmentsController = AppointmentsController;
exports.appointmentsController = new AppointmentsController(appointments_service_1.appointmentsService);
//# sourceMappingURL=appointments.controller.js.map