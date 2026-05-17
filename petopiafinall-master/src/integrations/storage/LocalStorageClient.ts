import fs from "fs";
import path from "path";
import { IStorageClient, UploadOptions, UploadResult } from "./IStorageClient";
import { AppError, HttpCode } from "../../common/errors/AppError";

export class LocalStorageClient implements IStorageClient {
  private readonly baseDir: string;
  private readonly baseUrl: string;

  constructor(baseDir: string = "uploads", baseUrl: string = "/uploads") {
    this.baseDir = baseDir;
    this.baseUrl = baseUrl;

    // Ensure base directory exists
    if (!fs.existsSync(this.baseDir)) {
      fs.mkdirSync(this.baseDir, { recursive: true });
    }
  }

  async upload(
    buffer: Buffer,
    filename: string,
    folder: string,
    options?: UploadOptions
  ): Promise<UploadResult> {
    try {
      // Generate unique filename
      const timestamp = Date.now();
      const random = Math.random().toString(36).substring(7);
      const ext = path.extname(filename);
      const uniqueFilename = `${timestamp}-${random}${ext}`;

      // Create folder path
      const folderPath = path.join(this.baseDir, folder);
      if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
      }

      // Write file
      const filePath = path.join(folderPath, uniqueFilename);
      fs.writeFileSync(filePath, buffer);

      // Generate storage key and public URL
      const storageKey = path.join(folder, uniqueFilename).replace(/\\/g, "/");
      const url = `${this.baseUrl}/${storageKey}`;

      const result: any = {
        url,
        storageKey,
        sizeBytes: buffer.length,
      };

      if (options?.mimeType) {
        result.mimeType = options.mimeType;
      }

      return result;
    } catch (error) {
      throw new AppError(
        `Failed to upload file: ${error instanceof Error ? error.message : "Unknown error"}`,
        HttpCode.INTERNAL_SERVER_ERROR
      );
    }
  }

  async delete(storageKey: string): Promise<boolean> {
    try {
      const filePath = path.join(this.baseDir, storageKey);

      // Check if file exists
      if (!fs.existsSync(filePath)) {
        return false;
      }

      // Delete file
      fs.unlinkSync(filePath);
      return true;
    } catch (error) {
      throw new AppError(
        `Failed to delete file: ${error instanceof Error ? error.message : "Unknown error"}`,
        HttpCode.INTERNAL_SERVER_ERROR
      );
    }
  }

  async getPublicUrl(storageKey: string): Promise<string> {
    return `${this.baseUrl}/${storageKey}`;
  }
}
