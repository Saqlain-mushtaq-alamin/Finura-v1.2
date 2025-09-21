# backend/routes/user_routes.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.database.database import get_db
from backend.database.models import User

router = APIRouter()

@router.post("/update-fcm-token")
def update_fcm_token(user_id: str, fcm_token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return {"error": "User not found"}
    user.fcm_token = fcm_token
    db.commit()
    return {"message": "FCM token updated successfully"}
