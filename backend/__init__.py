from flask import Flask
from backend.ai_prediction_model.controller import ai_prediction_model as ai_blueprint

def create_app():
    app = Flask(__name__)

    app.register_blueprint(ai_blueprint, url_prefix='/ai_models')

    return app
