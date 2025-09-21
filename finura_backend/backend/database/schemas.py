from pydantic import BaseModel
from typing import Optional

# ---------- User ----------
class UserCreate(BaseModel):
    id: str
    pin_hash: str
    first_name: str
    last_name: str
    email: str
    occupation: Optional[str] = None
    sex: str
    created_at: str
    user_photo: Optional[str] = None

# ---------- Expense ----------
class ExpenseCreate(BaseModel):
    id: str
    user_id: str
    date: str
    day: int
    time: str
    mood: Optional[int] = None
    description: Optional[str] = None
    expense_amount: float
    category: Optional[str] = None

# ---------- Income ----------
class IncomeCreate(BaseModel):
    id: str
    user_id: str
    date: str
    day: int
    time: str
    mood: Optional[int] = None
    description: Optional[str] = None
    income_amount: float
    category: Optional[str] = None  # optional as per your model


class SavingGoalCreate(BaseModel):
    id: str
    user_id: str
    monthly_income: float
    target_saving: float
    target_expense_limit: float
    frequency: float  # 🔁 CHANGED from float to str
    start_date: str
    end_date: Optional[str] = None
    current_saved: Optional[float] = 0
    description: Optional[str] = None


class NoteEntryCreate(BaseModel):
    id: str
    user_id: str
    title: str
    content: str
    created_at: str
    updated_at: str
