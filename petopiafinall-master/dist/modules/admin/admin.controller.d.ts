import { Request, Response } from "express";
import { AuthRequest } from "@/common/middlewares/auth.middleware";
import { AdminService } from "./admin.service";
export declare class AdminController {
    private readonly service;
    constructor(service: AdminService);
    private ok;
    private fail;
    private resolveId;
    login: (req: Request, res: Response) => Promise<Response<any, Record<string, any>>>;
    getPendingVets: (_req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>>>;
    approveVet: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
    rejectVet: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
    getPendingSitters: (_req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>>>;
    approveSitter: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
    rejectSitter: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
    getPendingPayments: (_req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>>>;
    approvePayment: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
    rejectPayment: (req: AuthRequest, res: Response) => Promise<Response<any, Record<string, any>> | undefined>;
}
export declare const adminController: AdminController;
//# sourceMappingURL=admin.controller.d.ts.map