from flask import Blueprint

ai_prediction_model = Blueprint('ai_prediction_model', __name__)

from backend.ai_prediction_model import controller
