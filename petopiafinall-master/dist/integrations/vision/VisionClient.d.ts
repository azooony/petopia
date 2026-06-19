export interface PetAnalysisResult {
    animal: 'cat' | 'dog';
    breed: string;
    confidence: number;
}
export declare class VisionClient {
    static analyzePetImage(imageBuffer: Buffer, filename?: string): Promise<PetAnalysisResult>;
}
//# sourceMappingURL=VisionClient.d.ts.map