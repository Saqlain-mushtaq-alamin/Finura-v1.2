import pandas as pd
import numpy as np
from backend.utils.encoders import category_encoder, time_encoder, scaler

def preprocess(entries):
    df = pd.DataFrame([{
        "mood": e.mood,
        "expense_amount": e.expense_amount,
        "category": e.category,
        "time": e.time
    } for e in entries])

    df["category"] = category_encoder.transform(df["category"])
    df["time"] = time_encoder.transform(df["time"])
    df = scaler.transform(df)

    return np.expand_dims(df, axis=0)  # (1, 7, features)
