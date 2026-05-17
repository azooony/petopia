"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// clinic.routes.ts
const express_1 = require("express");
const clinic_controller_1 = require("./clinic.controller");
const auth_middleware_1 = require("@/common/middlewares/auth.middleware");
const prisma_1 = require("../../../generated/prisma");
const router = (0, express_1.Router)();
router.post("/", auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.ADMIN), clinic_controller_1.createClinic);
exports.default = router;
//# sourceMappingURL=clinic.routes.js.map