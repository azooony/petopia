"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminController = exports.AdminController = void 0;
const AppError_1 = require("@/common/errors/AppError");
const admin_service_1 = require("./admin.service");
const admin_dto_1 = require("./admin.dto");
class AdminController {
    service;
    constructor(service) {
        this.service = service;
    }
    // ── Helpers ───────────────────────────────────────────────────────────────
    ok(res, message, data) {
        return res.status(200).json({ success: true, message, data });
    }
    fail(res, err) {
        const statusCode = err instanceof AppError_1.AppError ? err.statusCode : 500;
        const message = err instanceof Error ? err.message : "Internal server error";
        return res.status(statusCode).json({ success: false, message, error: message });
    }
    resolveId(req, res) {
        const id = req.params["id"];
        if (!id) {
            this.fail(res, new AppError_1.AppError("Missing route parameter: id", AppError_1.HttpCode.BAD_REQUEST));
            return null;
        }
        return id;
    }
    // ── Auth ──────────────────────────────────────────────────────────────────
    login = async (req, res) => {
        try {
            const parsed = admin_dto_1.AdminLoginSchema.safeParse(req.body);
            if (!parsed.success) {
                return res.status(400).json({
                    success: false,
                    message: "Validation failed",
                    error: parsed.error.flatten().fieldErrors,
                });
            }
            const data = await this.service.login(parsed.data);
            return this.ok(res, "Login successful", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    // ── Vets ──────────────────────────────────────────────────────────────────
    getPendingVets = async (_req, res) => {
        try {
            const data = await this.service.getPendingVets();
            return this.ok(res, "Pending vet registrations retrieved", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    approveVet = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.approveVet(id, req.user.userId);
            return this.ok(res, "Vet approved successfully", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    rejectVet = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.rejectVet(id, req.user.userId);
            return this.ok(res, "Vet rejected", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    // ── Sitters ───────────────────────────────────────────────────────────────
    getPendingSitters = async (_req, res) => {
        try {
            const data = await this.service.getPendingSitters();
            return this.ok(res, "Pending sitter listings retrieved", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    approveSitter = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.approveSitter(id, req.user.userId);
            return this.ok(res, "Sitter listing approved", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    rejectSitter = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.rejectSitter(id, req.user.userId);
            return this.ok(res, "Sitter listing rejected", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    // ── Payments ──────────────────────────────────────────────────────────────
    getPendingPayments = async (_req, res) => {
        try {
            const data = await this.service.getPendingPayments();
            return this.ok(res, "Pending appointment payments retrieved", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    approvePayment = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.approvePayment(id, req.user.userId);
            return this.ok(res, "Payment approved — appointment confirmed", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
    rejectPayment = async (req, res) => {
        try {
            const id = this.resolveId(req, res);
            if (!id)
                return;
            const data = await this.service.rejectPayment(id, req.user.userId);
            return this.ok(res, "Payment rejected — appointment cancelled", data);
        }
        catch (err) {
            return this.fail(res, err);
        }
    };
}
exports.AdminController = AdminController;
exports.adminController = new AdminController(admin_service_1.adminService);
//# sourceMappingURL=admin.controller.js.map