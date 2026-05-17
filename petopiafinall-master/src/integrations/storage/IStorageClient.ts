export interface UploadOptions {
  mimeType?: string;
  metadata?: Record<string, string>;
}

export interface UploadResult {
  url: string;
  storageKey: string;
  mimeType?: string;
  sizeBytes?: number;
}

export interface IStorageClient {
  /**
   * Upload a file to storage
   * @param buffer File buffer/content
   * @param filename Original filename
   * @param folder Folder/directory path
   * @param options Upload options
   * @returns Upload result with URL and storage key
   */
  upload(
    buffer: Buffer,
    filename: string,
    folder: string,
    options?: UploadOptions
  ): Promise<UploadResult>;

  /**
   * Delete a file from storage
   * @param storageKey Storage key returned from upload
   * @returns True if deletion was successful
   */
  delete(storageKey: string): Promise<boolean>;

  /**
   * Get public URL for a stored file
   * @param storageKey Storage key
   * @returns Public URL
   */
  getPublicUrl(storageKey: string): Promise<string>;
}
