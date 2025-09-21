# backend/services/notification_service.py

import uuid
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from backend.database.models import SavingGoal, ExpenseEntry, Notification

FRIENDLY_WARNINGS = {
    "bad": [
        "Yo bestie 👋 Looks like you might drop some 💸 on {category} around {time}… you sure about that? 😏",
        "Ayo! 🚨 You tend to spend big on {category} when feeling like Mood {mood}… maybe think twice? 🤔",
        "Bruh… {time} is your danger zone for {category}. You tryna wreck the budget or nah? 😭",
        "Lowkey… you’ve been in Mood {mood} and {time} is prime spending time for {category}. Stay strong 💪"
    ],
    "very_bad": [
        "OMG 😱 If you buy {category} at {time}, your savings are *done for*. Don’t let the wallet bleed! 🩸",
        "🚨 Big spender alert! {category} at {time} will hit harder than my student loans. 🥲",
        "BFF, pls… no {category} at {time}. Your bank account is already crying 😭",
        "Major yikes 😬 Mood {mood} + {category} at {time} = Budget funeral. 💀"
    ],
    #NOT NEED FOR NOW LESS IMPROVEMENT
    "good": [
        "OK king/queen 👑, {category} at {time} won’t kill your budget. Treat yourself (a lil). 😉",
        "Not bad, not bad 😌 {category} at {time} is safe this time. Budget still vibin’ ✨",
        "Aight, that {category} at {time} isn’t too sus. You’re good. 👍"
    ],
    "very_good": [
        "You’re basically a finance god 😇 {category} at {time} is harmless.",
        "Yessir! {category} at {time} is totally fine. Budget stays winning 🏆",
        "No stress! {category} at {time} is chill for your savings."
    ]
}

def categorize_harm(harm_value):
    if harm_value <= 0:
        return "very_good"
    elif harm_value <= 0.1:
        return "good"
    elif harm_value <= 0.25:
        return "bad"
    else:
        return "very_bad"

def create_notification(db: Session, user_id: str, predicted_expense_amount: float, predicted_mood: int, predicted_time: str, predicted_category: str):
    # Get saving goal
    saving_goal = db.query(SavingGoal).filter(SavingGoal.user_id == user_id).first()
    if not saving_goal:
        return None

    # Calculate monthly expenses
    this_month = datetime.now().strftime("%Y-%m")
    expenses = db.query(ExpenseEntry).filter(
        ExpenseEntry.user_id == user_id,
        ExpenseEntry.date.like(f"{this_month}%")
    ).all()
    total_expense_amount = sum(e.expense_amount or 0 for e in expenses)

    # Harm calc
    new_total_expenses = total_expense_amount + predicted_expense_amount
    over_budget = max(0, new_total_expenses - saving_goal.target_expense_limit)
    harm_ratio = over_budget / saving_goal.target_saving if saving_goal.target_saving else 0
    harm_level = categorize_harm(harm_ratio)

    # Choose message
    template_list = FRIENDLY_WARNINGS[harm_level]
    index = predicted_mood % len(template_list)
    notif_message = template_list[index].format(
        category=predicted_category,
        time=predicted_time,
        mood=predicted_mood
    )

    # Push time (30 min before predicted)
    try:
        predicted_datetime = datetime.strptime(predicted_time, "%H:%M")
        push_datetime = (predicted_datetime - timedelta(minutes=30)).strftime("%H:%M")
    except:
        push_datetime = predicted_time

    # Save
    notification = Notification(
        id=str(uuid.uuid4()),
        user_id=user_id,
        predicted_expense_amount=predicted_expense_amount,
        predicted_mood=predicted_mood,
        predicted_time=predicted_time,
        push_time=push_datetime,
        notif_message=notif_message,
        notif_status=0,
        harm_level=harm_level
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification
