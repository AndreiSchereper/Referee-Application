from flask import render_template, jsonify, Flask, request
from backend.ai_prediction_model import ai_prediction_model
from backend.ai_prediction_model.service import process_image, train_new_model
# import os
# from werkzeug.utils import secure_filename

#simple /predict entrypoint
@ai_prediction_model.route('/hello')
def hello():
    return jsonify("Hello there!")

@ai_prediction_model.route('/predict', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in the request'}), 400
    elif 'model_name' not in request.args:
        return jsonify({'error': 'No model specified'}), 400
    
    model_name = request.args.get('model_name')
    image_file = request.files['image']
    if image_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    # filename = secure_filename(image_file.filename)
    # file_path = os.path.join("/app/backend/ai_prediction_model/api_test", filename)
    # image_file.save(file_path)

    result = process_image(image_file, model_name)
    return jsonify(result)

#creates datset, trains model and outputs 200. Cannot substain concurrency atm
@ai_prediction_model.route('/train', methods=['POST'])
def train_model():
    if 'video' not in request.files:
        return jsonify({'error': 'No video part in the request'}), 400
    elif 'model_name' not in request.args:
        return jsonify({'error': 'No model name in request'}), 400
    
    model_name = request.args.get('model_name')
    video_file = request.files['video']
    if video_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    result = train_new_model(video_file, model_name)

    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result), 200
