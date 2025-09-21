from sqlalchemy import Column, ForeignKey, Integer, String, Float, Text
from . import Base  # imported from __init__.py
from datetime import datetime



class User(Base):
    __tablename__ = "user"
    id = Column(String, primary_key=True, index=True)
    pin_hash = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    occupation = Column(String)
    sex = Column(String)
    created_at = Column(String)
    fcm_token = Column(String)  # <-- keep the latest device token
    user_photo = Column(String)


class ExpenseEntry(Base):
    __tablename__ = "expense_entry"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)  # Changed from Integer
    date = Column(String, nullable=False)
    day = Column(Integer, nullable=False)
    time = Column(String, nullable=False)
    mood = Column(Integer)
    description = Column(Text)
    expense_amount = Column(Float)
    category = Column(String)  


class IncomeEntry(Base):
    __tablename__ = "income_entry"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)  # Changed from Integer
    date = Column(String, nullable=False)
    day = Column(Integer, nullable=False)
    time = Column(String, nullable=False)
    mood = Column(Integer)
    description = Column(Text)
    income_amount = Column(Float)
    category = Column(String)  # <-- Optional



class SavingGoal(Base):
    __tablename__ = "saving_goal"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)
    monthly_income = Column(Float, nullable=False)
    target_saving = Column(Float, nullable=False)
    target_expense_limit = Column(Float, nullable=False)
    frequency = Column(Float, nullable=False)  # 🔁 CHANGED from Float to String
    start_date = Column(String, nullable=False)
    end_date = Column(String)
    current_saved = Column(Float, default=0)
    description = Column(String)

class NoteEntry(Base):
    __tablename__ = "note_entry"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(String, nullable=False)
    updated_at = Column(String, nullable=False)

class Notification(Base):
    __tablename__ = "notification"
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("user.id"), nullable=False)
    predicted_expense_amount = Column(Float, nullable=False)
    predicted_mood = Column(Integer, nullable=False)
    predicted_time = Column(String, nullable=False)
    push_time = Column(String, nullable=False)
    notif_message = Column(Text, nullable=False)
    notif_status = Column(Integer, default=0)  # 0 = pending, 1 = sent
    harm_level = Column(String, nullable=False)  # Very Good, Good, Bad, Very Bad
    created_at = Column(String, default=lambda: datetime.now().isoformat())