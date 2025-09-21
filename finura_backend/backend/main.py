from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware
from backend.database import SessionLocal, engine  # from database/__init__.py
from backend.database import models             # triggers model import
from backend.database import crud, schemas         # same package
from backend.jobs.scheduler import start_scheduler
#  <--this code for sent the notification logic

from apscheduler.schedulers.background import BackgroundScheduler
from backend.services.notification_scheduler import send_due_notifications

scheduler = BackgroundScheduler()
scheduler.add_job(send_due_notifications, "cron", minute="*")  # check every min
scheduler.start()


# Create tables once on startup
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Finura Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specific Flutter app domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DB session dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.on_event("startup")
def startup_event():
    start_scheduler()

# -------------------- Endpoints --------------------
@app.post("/sync_user")
def sync_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    crud.create_user(db, user)
    return {"status": "ok", "item": "user"}

@app.post("/sync_expense")
def sync_expense(expense: schemas.ExpenseCreate, db: Session = Depends(get_db)):
    crud.create_expense(db, expense)
    return {"status": "ok", "item": "expense"}

@app.post("/sync_income")
def sync_income(income: schemas.IncomeCreate, db: Session = Depends(get_db)):
    crud.create_income(db, income)
    return {"status": "ok", "item": "income"}

@app.post("/sync_goal")
def sync_saving_goal(goal: schemas.SavingGoalCreate, db: Session = Depends(get_db)):
    crud.create_saving_goal(db, goal)
    return {"status": "ok", "item": "saving_goal"}

@app.post("/sync_note")
def sync_note_entry(note: schemas.NoteEntryCreate, db: Session = Depends(get_db)):
    crud.create_note_entry(db, note)
    return {"status": "ok", "item": "note_entry"}


#-----------for testing the code----------------------------
@app.get("/")
def root():
    return {"message": "Finura Backend is running"}

@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(models.User).all()

@app.get("/income")
def get_income(db: Session = Depends(get_db)):
    return db.query(models.IncomeEntry).all()

@app.get("/expance")
def get_expance(db: Session = Depends(get_db)):
    return db.query(models.ExpenseEntry).all()

@app.get("/saving_goal")
def get_saving_goal(db: Session = Depends(get_db)):
    return db.query(models.SavingGoal).all()    

@app.get("/note_entry")
def get_note_entry(db: Session = Depends(get_db)):
    return db.query(models.NoteEntry).all()