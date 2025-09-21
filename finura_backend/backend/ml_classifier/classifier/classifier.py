"""
Loads trained text classification pipeline (vectorizer + model together)
and exposes predict_category()
"""

import warnings
import joblib
from pathlib import Path
from sklearn.exceptions import InconsistentVersionWarning

# Suppress noisy InconsistentVersionWarning (optional)
warnings.filterwarnings("ignore", category=InconsistentVersionWarning)

MODEL_DIR = Path(__file__).resolve().parent.parent / "model"

# Use the model you trained (Naive Bayes or Logistic Regression)
MODEL_PATH = MODEL_DIR / "naive_bayes_model.pkl"
# MODEL_PATH = MODEL_DIR / "logistic_regression_model.pkl"  # <- uncomment if you want LR instead

print(f"Loading model pipeline from: {MODEL_PATH}")

# Load the pipeline (includes TF-IDF + classifier)
_model = joblib.load(MODEL_PATH)

def predict_category(description: str) -> str:
    """Predict expense category from a description string."""
    return _model.predict([description])[0]
