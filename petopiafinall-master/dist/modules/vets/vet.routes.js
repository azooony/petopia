"use strict";
// src/modules/vets/vet.routes.ts
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const vetController = __importStar(require("./vet.controller"));
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const admin_middleware_1 = require("../../common/middlewares/admin.middleware");
const upload_middleware_1 = require("../../common/middlewares/upload.middleware");
const router = (0, express_1.Router)();
router.post('/certificate', upload_middleware_1.upload.single('certificate'), vetController.uploadCertificate);
// ── Registration ────────────────────────────────────────────────
// POST /vets/register  —  Logged-in VET creates their vet profile
router.post('/register', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.registerVetProfile);
// ── Profile ─────────────────────────────────────────────────────
// GET  /vets/profile         —  Get own profile
// PATCH /vets/profile        —  Update profile (photo, name, phone, specialization, clinic address)
router.get('/profile', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.getMyProfile);
router.patch('/profile', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.updateProfile);
// ── Admin Verification ──────────────────────────────────────────
// PATCH /vets/:id/verify     —  Admin approves/rejects a vet
router.patch('/:id/verify', auth_middleware_1.protect, admin_middleware_1.isAdmin, vetController.verifyVet);
// ── Availability Slots ──────────────────────────────────────────
// POST   /vets/availability             —  Add a new slot
// GET    /vets/availability             —  List all own slots
// PATCH  /vets/availability/:slotId     —  Update a slot
// DELETE /vets/availability/:slotId     —  Delete a slot
router.post('/availability', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.addAvailabilitySlot);
router.get('/availability', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.getAvailabilitySlots);
router.patch('/availability/:slotId', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.updateAvailabilitySlot);
router.delete('/availability/:slotId', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.deleteAvailabilitySlot);
// ── Appointment Dashboard ───────────────────────────────────────
// GET /vets/appointments     —  Upcoming appointments with pet details
router.get('/appointments', auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)('VET'), vetController.getUpcomingAppointments);
exports.default = router;
//# sourceMappingURL=vet.routes.js.map