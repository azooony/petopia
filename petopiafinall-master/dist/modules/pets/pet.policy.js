"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetPolicy = void 0;
const AppError_1 = require("../../common/errors/AppError");
class PetPolicy {
    static ensureOwner(pet, userId) {
        if (!pet || pet.ownerId !== userId) {
            throw new AppError_1.AppError("Pet not found or unauthorized", AppError_1.HttpCode.NOT_FOUND);
        }
    }
}
exports.PetPolicy = PetPolicy;
//# sourceMappingURL=pet.policy.js.map