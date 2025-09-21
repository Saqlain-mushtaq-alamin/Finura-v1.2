import os, joblib

BASE_DIR = os.path.dirname(os.path.dirname(__file__))  # backend/
DATA_DIR = os.path.join(BASE_DIR, "data")

category_encoder = joblib.load(os.path.join(DATA_DIR, "category_encoder.pkl"))
time_encoder = joblib.load(os.path.join(DATA_DIR, "time_encoder.pkl"))
scaler = joblib.load(os.path.join(DATA_DIR, "scaler.pkl"))
