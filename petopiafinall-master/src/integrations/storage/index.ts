export { IStorageClient, UploadOptions, UploadResult } from "./IStorageClient";
export { LocalStorageClient } from "./LocalStorageClient";

import { LocalStorageClient } from "./LocalStorageClient";

// Default storage client instance for local storage
export const storageClient = new LocalStorageClient("uploads", "/uploads");
