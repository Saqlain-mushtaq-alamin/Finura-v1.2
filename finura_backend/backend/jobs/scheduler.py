from apscheduler.schedulers.background import BackgroundScheduler
from backend.database.database import SessionLocal
from backend.database.models import User
from backend.services.expense_service import get_last_7_days_expenses
from backend.ml_predictor.predictor import predict_next_day
from backend.ml_predictor.preprocess import preprocess
from backend.services.notification_service import create_notification

def run_prediction_job():
    db = SessionLocal()
    users = db.query(User).all()

    for user in users:
        data = get_last_7_days_expenses(db, user.id)
        if len(data) == 7:
            input_data = preprocess(data)
            prediction = predict_next_day(input_data)
            print(f"Prediction for {user.email}: {prediction}")
                  #here the notification method take pace
            # Create notification
            create_notification(
                db=db,
                user_id=user.id,
                predicted_expense_amount=prediction["expense_amount"],
                predicted_mood=prediction["mood"],
                predicted_time=prediction["time"]
            )
    db.close()

def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(run_prediction_job, 'cron', hour=23, minute=59)
    scheduler.start()
