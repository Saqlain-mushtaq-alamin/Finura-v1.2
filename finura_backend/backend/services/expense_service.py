from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from backend.database.models import ExpenseEntry

def get_last_7_days_expenses(db: Session, user_id: str):
    today = datetime.now().date()
    seven_days_ago = today - timedelta(days=7)

    return db.query(ExpenseEntry).filter(
        ExpenseEntry.user_id == user_id,
        ExpenseEntry.date >= seven_days_ago.isoformat()
    ).order_by(ExpenseEntry.date.asc()).all()
