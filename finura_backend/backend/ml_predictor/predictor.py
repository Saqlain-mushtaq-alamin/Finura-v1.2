from backend.ml_predictor.model_loader import load_model
from backend.utils.encoders import category_encoder, time_encoder

model = load_model()

def predict_next_day(data):
    pred = model.predict(data)[0]
    mood, amount, cat, time = pred
    return {
        "mood": int(round(mood)),
        "expense_amount": float(amount),
        "category": category_encoder.inverse_transform([int(round(cat))])[0],
        "time": time_encoder.inverse_transform([int(round(time))])[0]
    }
