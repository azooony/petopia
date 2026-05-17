export interface PetAnalysisResult {
  animal: 'cat' | 'dog';
  breed: string;
  confidence: number;
}

const AI_SERVICE_URL = process.env.AI_SERVICE_URL ?? 'http://localhost:5001';

export class VisionClient {
  static async analyzePetImage(
    imageBuffer: Buffer,
    filename = 'photo.jpg',
  ): Promise<PetAnalysisResult> {
    const form = new FormData();
    form.append(
      'photo',
      new Blob([new Uint8Array(imageBuffer)], { type: 'image/jpeg' }),
      filename,
    );

    const res = await fetch(`${AI_SERVICE_URL}/classify`, {
      method: 'POST',
      body: form,
    });

    const json = await res.json() as Record<string, unknown>;
    if (!res.ok) {
      throw new Error((json['error'] as string | undefined) ?? 'AI service error');
    }

    return json as unknown as PetAnalysisResult;
  }
}
