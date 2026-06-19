"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VisionClient = void 0;
const AI_SERVICE_URL = process.env.AI_SERVICE_URL ?? 'http://localhost:5001';
class VisionClient {
    static async analyzePetImage(imageBuffer, filename = 'photo.jpg') {
        const form = new FormData();
        form.append('photo', new Blob([new Uint8Array(imageBuffer)], { type: 'image/jpeg' }), filename);
        const res = await fetch(`${AI_SERVICE_URL}/classify`, {
            method: 'POST',
            body: form,
        });
        const json = await res.json();
        if (!res.ok) {
            throw new Error(json['error'] ?? 'AI service error');
        }
        return json;
    }
}
exports.VisionClient = VisionClient;
//# sourceMappingURL=VisionClient.js.map