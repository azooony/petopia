"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadAvatar = exports.uploadLostFound = exports.uploadAnalyze = exports.uploadVet = exports.uploadPet = exports.uploadVetRegistration = exports.upload = void 0;
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const AppError_1 = require("../errors/AppError");
function makeStorage(folder) {
    return multer_1.default.diskStorage({
        destination: (req, file, cb) => {
            fs_1.default.mkdirSync(folder, { recursive: true });
            cb(null, folder);
        },
        filename: (req, file, cb) => {
            const uniqueName = Date.now() + path_1.default.extname(file.originalname);
            cb(null, uniqueName);
        },
    });
}
function makeVetRegistrationStorage() {
    return multer_1.default.diskStorage({
        destination: (req, file, cb) => {
            const folder = file.fieldname === "photo" ? "uploads/vets/" : "uploads/certificates/";
            fs_1.default.mkdirSync(folder, { recursive: true });
            cb(null, folder);
        },
        filename: (req, file, cb) => {
            const uniqueName = Date.now() + path_1.default.extname(file.originalname);
            cb(null, uniqueName);
        },
    });
}
const imageFilter = (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
        cb(null, true);
    }
    else {
        cb(new AppError_1.AppError("Only images are allowed", AppError_1.HttpCode.BAD_REQUEST), false);
    }
};
const limits = { fileSize: 5 * 1024 * 1024 };
exports.upload = (0, multer_1.default)({
    storage: makeStorage("uploads/certificates/"),
    fileFilter: imageFilter,
    limits,
});
exports.uploadVetRegistration = (0, multer_1.default)({
    storage: makeVetRegistrationStorage(),
    fileFilter: imageFilter,
    limits,
});
exports.uploadPet = (0, multer_1.default)({
    storage: makeStorage("uploads/pets/"),
    fileFilter: imageFilter,
    limits,
});
exports.uploadVet = (0, multer_1.default)({
    storage: makeStorage("uploads/vets/"),
    fileFilter: imageFilter,
    limits,
});
exports.uploadAnalyze = (0, multer_1.default)({
    storage: multer_1.default.memoryStorage(),
    fileFilter: imageFilter,
    limits,
});
exports.uploadLostFound = (0, multer_1.default)({
    storage: makeStorage("uploads/lost-found/"),
    fileFilter: imageFilter,
    limits,
});
exports.uploadAvatar = (0, multer_1.default)({
    storage: makeStorage("uploads/avatars/"),
    fileFilter: imageFilter,
    limits,
});
//# sourceMappingURL=upload.middleware.js.map