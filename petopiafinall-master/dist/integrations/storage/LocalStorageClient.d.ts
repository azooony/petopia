import { IStorageClient, UploadOptions, UploadResult } from "./IStorageClient";
export declare class LocalStorageClient implements IStorageClient {
    private readonly baseDir;
    private readonly baseUrl;
    constructor(baseDir?: string, baseUrl?: string);
    upload(buffer: Buffer, filename: string, folder: string, options?: UploadOptions): Promise<UploadResult>;
    delete(storageKey: string): Promise<boolean>;
    getPublicUrl(storageKey: string): Promise<string>;
}
//# sourceMappingURL=LocalStorageClient.d.ts.map