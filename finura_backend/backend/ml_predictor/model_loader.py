import tensorflow as tf
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model", "lstm_model.keras")

def load_model():
    return tf.keras.models.load_model(MODEL_PATH, compile=False)  # safe for inference
