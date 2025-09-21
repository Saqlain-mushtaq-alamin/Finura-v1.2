"""
DB insert helpers.
Uses SQLAlchemy `merge()` so SQLite IDs are preserved (upsert style).
"""

from sqlalchemy.orm import Session

from . import models, schemas
from ..ml_classifier.classifier import predict_category


def create_user(db: Session, payload: schemas.UserCreate):
    db_user = models.User(**payload.dict())
    db.merge(db_user)
    db.commit()

def create_expense(db: Session, payload: schemas.ExpenseCreate):
    data = payload.dict()
    data["category"] = predict_category(data["description"])
    db_expense = models.ExpenseEntry(**data)
    db.merge(db_expense)
    db.commit()

def create_income(db: Session, payload: schemas.IncomeCreate):
    data = payload.dict()
    #data["category"] = predict_category(data["description"])
    db_income = models.IncomeEntry(**data)
    db.merge(db_income)
    db.commit()



# ---------- Saving Goal ----------
def create_saving_goal(db: Session, goal: schemas.SavingGoalCreate):
    db_goal = models.SavingGoal(**goal.dict())
    db.merge(db_goal)
    db.commit()
 
    return db_goal

# ---------- Note Entry ----------
def create_note_entry(db: Session, note: schemas.NoteEntryCreate):
    db_note = models.NoteEntry(**note.dict())
    db.merge(db_note)
    db.commit()
     
    return db_note