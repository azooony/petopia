"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const prisma_1 = require("../../../generated/prisma");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const validate_middleware_1 = require("../../common/middlewares/validate.middleware");
const petMatching_dto_1 = require("./petMatching.dto");
const petMatching_controller_1 = require("./petMatching.controller");
const router = (0, express_1.Router)();
router.use(auth_middleware_1.protect, (0, auth_middleware_1.restrictTo)(prisma_1.UserRole.PET_OWNER));
// PROFILE
router.post("/profile", (0, validate_middleware_1.validate)(petMatching_dto_1.CreateMatchProfileSchema), petMatching_controller_1.PetMatchingController.createProfile);
router.patch("/profile/:petId", (0, validate_middleware_1.validate)(petMatching_dto_1.UpdateMatchProfileSchema), petMatching_controller_1.PetMatchingController.updateProfile);
// MATCHES
router.get("/discover/:petId", petMatching_controller_1.PetMatchingController.findMatches);
// REQUESTS
router.post("/request", (0, validate_middleware_1.validate)(petMatching_dto_1.SendMatchRequestSchema), petMatching_controller_1.PetMatchingController.sendRequest);
router.get("/requests/:petId", petMatching_controller_1.PetMatchingController.getIncomingRequests);
router.patch("/requests/:requestId/accept", petMatching_controller_1.PetMatchingController.acceptRequest);
router.patch("/requests/:requestId/reject", petMatching_controller_1.PetMatchingController.rejectRequest);
exports.default = router;
//# sourceMappingURL=petMatching.routes.js.map