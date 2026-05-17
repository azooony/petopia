"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("./auth.controller");
const upload_middleware_1 = require("../../common/middlewares/upload.middleware");
const router = (0, express_1.Router)();
router.post("/register-owner", auth_controller_1.AuthController.registerPetOwner);
router.post("/register-vet", upload_middleware_1.upload.single("certificate"), auth_controller_1.AuthController.registerVet);
router.post("/login", auth_controller_1.AuthController.login);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map