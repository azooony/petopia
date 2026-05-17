import { Request, Response } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { AppointmentsService } from "./appointments.service";
export declare class AppointmentsController {
    private readonly service;
    constructor(service: AppointmentsService);
    getDoctors: (_req: Request, res: Response) => Promise<void>;
    getMyAppointments: (req: AuthRequest, res: Response) => Promise<void>;
    bookAppointment: (req: AuthRequest, res: Response) => Promise<void>;
    private handleError;
}
export declare const appointmentsController: AppointmentsController;
//# sourceMappingURL=appointments.controller.d.ts.map