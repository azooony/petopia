"use strict";
// src/modules/vets/vet.controller.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUpcomingAppointments = exports.deleteAvailabilitySlot = exports.updateAvailabilitySlot = exports.getAvailabilitySlots = exports.addAvailabilitySlot = exports.verifyVet = exports.updateProfile = exports.getMyProfile = exports.registerVetProfile = exports.uploadCertificate = void 0;
const vets_service_1 = require("./vets.service");
const AppError_1 = require("../../common/errors/AppError");
const uploadCertificate = async (req, res, next) => {
    try {
        if (!req.file) {
            throw new AppError_1.AppError('Certificate image is required', AppError_1.HttpCode.BAD_REQUEST);
        }
        const certificateUrl = `${req.protocol}://${req.get('host')}/uploads/certificates/${req.file.filename}`;
        res.status(201).json({
            success: true,
            message: 'Certificate uploaded successfully',
            data: { certificateUrl },
        });
    }
    catch (error) {
        next(error);
    }
};
exports.uploadCertificate = uploadCertificate;
// ── 1. Registration ─────────────────────────────────────────────
const registerVetProfile = async (req, res, next) => {
    try {
        const profile = await vets_service_1.VetService.registerVet(req.user.userId, req.body);
        res.status(201).json({
            success: true,
            message: 'Vet profile created successfully. Awaiting admin verification.',
            data: profile,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.registerVetProfile = registerVetProfile;
// ── 2. Get Own Profile ──────────────────────────────────────────
const getMyProfile = async (req, res, next) => {
    try {
        const profile = await vets_service_1.VetService.getProfile(req.user.userId);
        res.status(200).json({
            success: true,
            message: 'Profile retrieved successfully',
            data: profile,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getMyProfile = getMyProfile;
// ── 3. Profile Setup / Update ───────────────────────────────────
const updateProfile = async (req, res, next) => {
    try {
        const profile = await vets_service_1.VetService.updateProfile(req.user.userId, req.body);
        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: profile,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updateProfile = updateProfile;
// ── 4. Admin Verification ───────────────────────────────────────
const verifyVet = async (req, res, next) => {
    try {
        const id = req.params.id;
        const { status } = req.body;
        if (!id) {
            throw new AppError_1.AppError('Vet profile ID is required', AppError_1.HttpCode.BAD_REQUEST);
        }
        if (!status || !['PENDING', 'VERIFIED', 'REJECTED'].includes(status)) {
            throw new AppError_1.AppError('Invalid verification status', AppError_1.HttpCode.BAD_REQUEST);
        }
        const profile = await vets_service_1.VetService.verifyVet(id, status);
        res.status(200).json({
            success: true,
            message: `Vet verification status updated to ${status}`,
            data: profile,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.verifyVet = verifyVet;
// ── 5. Availability Slots ───────────────────────────────────────
const addAvailabilitySlot = async (req, res, next) => {
    try {
        const slot = await vets_service_1.VetService.addAvailabilitySlot(req.user.userId, req.body);
        res.status(201).json({
            success: true,
            message: 'Availability slot added successfully',
            data: slot,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.addAvailabilitySlot = addAvailabilitySlot;
const getAvailabilitySlots = async (req, res, next) => {
    try {
        const slots = await vets_service_1.VetService.getAvailabilitySlots(req.user.userId);
        res.status(200).json({
            success: true,
            message: 'Availability slots retrieved successfully',
            data: slots,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getAvailabilitySlots = getAvailabilitySlots;
const updateAvailabilitySlot = async (req, res, next) => {
    try {
        const slotId = req.params.slotId;
        if (!slotId) {
            throw new AppError_1.AppError('Slot ID is required', AppError_1.HttpCode.BAD_REQUEST);
        }
        const slot = await vets_service_1.VetService.updateAvailabilitySlot(req.user.userId, slotId, req.body);
        res.status(200).json({
            success: true,
            message: 'Availability slot updated successfully',
            data: slot,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.updateAvailabilitySlot = updateAvailabilitySlot;
const deleteAvailabilitySlot = async (req, res, next) => {
    try {
        const slotId = req.params.slotId;
        if (!slotId) {
            throw new AppError_1.AppError('Slot ID is required', AppError_1.HttpCode.BAD_REQUEST);
        }
        await vets_service_1.VetService.deleteAvailabilitySlot(req.user.userId, slotId);
        res.status(200).json({
            success: true,
            message: 'Availability slot deleted successfully',
        });
    }
    catch (error) {
        next(error);
    }
};
exports.deleteAvailabilitySlot = deleteAvailabilitySlot;
// ── 6. Appointment Dashboard ────────────────────────────────────
const getUpcomingAppointments = async (req, res, next) => {
    try {
        const appointments = await vets_service_1.VetService.getUpcomingAppointments(req.user.userId);
        res.status(200).json({
            success: true,
            message: 'Upcoming appointments retrieved successfully',
            data: appointments,
        });
    }
    catch (error) {
        next(error);
    }
};
exports.getUpcomingAppointments = getUpcomingAppointments;
//# sourceMappingURL=vet.controller.js.map