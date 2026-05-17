"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocalStorageClient = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const AppError_1 = require("../../common/errors/AppError");
class LocalStorageClient {
    baseDir;
    baseUrl;
    constructor(baseDir = "uploads", baseUrl = "/uploads") {
        this.baseDir = baseDir;
        this.baseUrl = baseUrl;
        // Ensure base directory exists
        if (!fs_1.default.existsSync(this.baseDir)) {
            fs_1.default.mkdirSync(this.baseDir, { recursive: true });
        }
    }
    async upload(buffer, filename, folder, options) {
        try {
            // Generate unique filename
            const timestamp = Date.now();
            const random = Math.random().toString(36).substring(7);
            const ext = path_1.default.extname(filename);
            const uniqueFilename = `${timestamp}-${random}${ext}`;
            // Create folder path
            const folderPath = path_1.default.join(this.baseDir, folder);
            if (!fs_1.default.existsSync(folderPath)) {
                fs_1.default.mkdirSync(folderPath, { recursive: true });
            }
            // Write file
            const filePath = path_1.default.join(folderPath, uniqueFilename);
            fs_1.default.writeFileSync(filePath, buffer);
            // Generate storage key and public URL
            const storageKey = path_1.default.join(folder, uniqueFilename).replace(/\\/g, "/");
            const url = `${this.baseUrl}/${storageKey}`;
            const result = {
                url,
                storageKey,
                sizeBytes: buffer.length,
            };
            if (options?.mimeType) {
                result.mimeType = options.mimeType;
            }
            return result;
        }
        catch (error) {
            throw new AppError_1.AppError(`Failed to upload file: ${error instanceof Error ? error.message : "Unknown error"}`, AppError_1.HttpCode.INTERNAL_SERVER_ERROR);
        }
    }
    async delete(storageKey) {
        try {
            const filePath = path_1.default.join(this.baseDir, storageKey);
            // Check if file exists
            if (!fs_1.default.existsSync(filePath)) {
                return false;
            }
            // Delete file
            fs_1.default.unlinkSync(filePath);
            return true;
        }
        catch (error) {
            throw new AppError_1.AppError(`Failed to delete file: ${error instanceof Error ? error.message : "Unknown error"}`, AppError_1.HttpCode.INTERNAL_SERVER_ERROR);
        }
    }
    async getPublicUrl(storageKey) {
        return `${this.baseUrl}/${storageKey}`;
    }
}
exports.LocalStorageClient = LocalStorageClient;
//# sourceMappingURL=LocalStorageClient.js.map