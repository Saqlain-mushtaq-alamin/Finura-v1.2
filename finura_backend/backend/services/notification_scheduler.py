# backend/services/notification_scheduler.py

from datetime import datetime
from sqlalchemy.orm import Session
from backend.database.database import SessionLocal
from backend.database.models import Notification, User
from backend.services.fcm_service import send_fcm_notification

def send_due_notifications():
    db: Session = SessionLocal()
    now = datetime.now().strftime("%H:%M")

    notifications = db.query(Notification).filter(
        Notification.push_time == now,
        Notification.notif_status == 0
    ).all()

    for notif in notifications:
        user = db.query(User).filter(User.id == notif.user_id).first()
        if not user or not user.fcm_token:
            continue

        # Send via FCM
        send_fcm_notification(
            token=user.fcm_token,
            title="Finura Prediction 💡",
            body=notif.notif_message,
            data={
                "id": notif.id,
                "user_id": notif.user_id,
                "harm_level": notif.harm_level,
                "predicted_time": notif.predicted_time,
                "expense_amount": notif.predicted_expense_amount
            }
        )

        # Mark as sent
        notif.notif_status = 1
        db.commit()

    db.close()
