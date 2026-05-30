import sys
sys.stdout.reconfigure(encoding='utf-8')

import os
import io
import torch
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
from transformers import ViTForImageClassification, ViTImageProcessor

app = Flask(__name__)
CORS(app)

MODEL_DIR = os.path.join(os.path.dirname(__file__), 'models')

# Oxford-IIIT Pet Dataset — 12 cat breeds (remaining 25 are dog breeds)
_CAT_BREEDS = {
    'abyssinian', 'bengal', 'birman', 'bombay', 'british shorthair',
    'egyptian mau', 'maine coon', 'persian', 'ragdoll', 'russian blue',
    'siamese', 'sphynx',
}

processor: ViTImageProcessor = None  # type: ignore
model: ViTForImageClassification = None  # type: ignore


def _load_model():
    global processor, model
    print(f'[AI] Loading model from {MODEL_DIR} ...')
    processor = ViTImageProcessor.from_pretrained(MODEL_DIR)
    model = ViTForImageClassification.from_pretrained(MODEL_DIR)
    model.eval()
    print('[AI] Model ready.')


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'model_loaded': model is not None})


@app.route('/classify', methods=['POST'])
def classify():
    if 'photo' not in request.files:
        return jsonify({'error': 'Missing "photo" field'}), 400

    raw = request.files['photo'].read()
    try:
        image = Image.open(io.BytesIO(raw)).convert('RGB')
    except Exception as exc:
        return jsonify({'error': f'Cannot open image: {exc}'}), 400

    inputs = processor(images=image, return_tensors='pt')
    with torch.no_grad():
        logits = model(**inputs).logits

    idx = int(logits.argmax(-1).item())
    label: str = model.config.id2label[idx]
    confidence = float(torch.softmax(logits, dim=1)[0][idx])

    # Normalise: "Egyptian_Mau" -> "Egyptian Mau"
    breed = label.replace('_', ' ').strip()
    animal = 'cat' if label.lower().replace('_', ' ') in _CAT_BREEDS else 'dog'

    return jsonify({'animal': animal, 'breed': breed, 'confidence': round(confidence, 4)})


if __name__ == '__main__':
    _load_model()
    app.run(host='0.0.0.0', port=5001, debug=False, use_reloader=False)
