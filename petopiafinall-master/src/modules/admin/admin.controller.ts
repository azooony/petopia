import { Request, Response } from "express";
import { AppError, HttpCode } from "@/common/errors/AppError";
import { AuthRequest } from "@/common/middlewares/auth.middleware";
import { AdminService, adminService } from "./admin.service";
import { AdminLoginSchema } from "./admin.dto";

export class AdminController {
  constructor(private readonly service: AdminService) {}

  // ── Helpers ───────────────────────────────────────────────────────────────

  private ok(res: Response, message: string, data?: unknown) {
    return res.status(200).json({ success: true, message, data });
  }

  private fail(res: Response, err: unknown) {
    const statusCode = err instanceof AppError ? err.statusCode : 500;
    const message = err instanceof Error ? err.message : "Internal server error";
    return res.status(statusCode).json({ success: false, message, error: message });
  }

  private resolveId(req: AuthRequest, res: Response): string | null {
    const id = req.params["id"] as string | undefined;
    if (!id) {
      this.fail(res, new AppError("Missing route parameter: id", HttpCode.BAD_REQUEST));
      return null;
    }
    return id;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  login = async (req: Request, res: Response) => {
    try {
      const parsed = AdminLoginSchema.safeParse(req.body);
      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Validation failed",
          error: parsed.error.flatten().fieldErrors,
        });
      }
      const data = await this.service.login(parsed.data);
      return this.ok(res, "Login successful", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  // ── Vets ──────────────────────────────────────────────────────────────────

  getPendingVets = async (_req: AuthRequest, res: Response) => {
    try {
      const data = await this.service.getPendingVets();
      return this.ok(res, "Pending vet registrations retrieved", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  approveVet = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.approveVet(id, req.user!.userId);
      return this.ok(res, "Vet approved successfully", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  rejectVet = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.rejectVet(id, req.user!.userId);
      return this.ok(res, "Vet rejected", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  // ── Sitters ───────────────────────────────────────────────────────────────

  getPendingSitters = async (_req: AuthRequest, res: Response) => {
    try {
      const data = await this.service.getPendingSitters();
      return this.ok(res, "Pending sitter listings retrieved", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  approveSitter = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.approveSitter(id, req.user!.userId);
      return this.ok(res, "Sitter listing approved", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  rejectSitter = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.rejectSitter(id, req.user!.userId);
      return this.ok(res, "Sitter listing rejected", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  // ── Payments ──────────────────────────────────────────────────────────────

  getPendingPayments = async (_req: AuthRequest, res: Response) => {
    try {
      const data = await this.service.getPendingPayments();
      return this.ok(res, "Pending appointment payments retrieved", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  approvePayment = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.approvePayment(id, req.user!.userId);
      return this.ok(res, "Payment approved — appointment confirmed", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };

  rejectPayment = async (req: AuthRequest, res: Response) => {
    try {
      const id = this.resolveId(req, res);
      if (!id) return;
      const data = await this.service.rejectPayment(id, req.user!.userId);
      return this.ok(res, "Payment rejected — appointment cancelled", data);
    } catch (err) {
      return this.fail(res, err);
    }
  };
}

export const adminController = new AdminController(adminService);