# 📊 Finura – AI-Powered Personal Finance Assistant

Finura is a **cross-platform, AI-driven budget management system** built to help users in both **cash-heavy economies (like Bangladesh)** and **digital economies (like the US)** manage money smarter.  

It combines traditional finance tracking with **AI/ML insights** to not only log your income/expenses but also **predict spending behavior, monitor moods, and nudge you with smart notifications** so you stick to your saving plans.  

---

## ✨ Features

### 🔐 Authentication
- Secure user login & signup with password protection.  
- Local PIN hash stored securely.

### 🏠 Frontend (Flutter App)
- Cross-platform (Android, iOS, Desktop).  
- Built with **Flutter** for smooth, modern UI.  
- Password-protected access.  
- **Home page** to quickly input:
  - Expense or income  
  - Description  
  - Mood rating (0–5)  
  - Amount  
  - Category selection with **auto-classification (AI)**  

### 📱 App Sections
- **Dashboard** → ML-powered charts & insights.  
- **Saving Planner** → Create daily, weekly, monthly saving plans.  
- **Saving Monitor** → Check progress in real time.  
- **Notes** → Add financial notes tied to your calendar.  
- **Notifications** → Smart reminders + AI nudges.  
- **History** → Expense & income logs.  
- **Settings** → Personalize Finura.  
- **Help** → User guide & tips.  
- **AI Chatbot** → Talk to a language model for money advice.  

### ⚙️ Backend (FastAPI + Python)
- REST APIs powered by **FastAPI**.  
- Secure CRUD operations for users, expenses, incomes, savings, and notes.  
- Syncs data between **SQLite (offline)** and **PostgreSQL (online server)** when internet is available.  

---

## 🧠 Machine Learning Models

### 📂 Naive Bayes / Logistic Regression
- Convert raw **expense descriptions** into **categories automatically**.  

### 🔮 LSTM (Long Short-Term Memory)
- Takes last **7 days of data (mood + expense + time)**.  
- Predicts the **8th day**:
  - Low mood probability  
  - High expense risk  
  - Likely category & time  

**Example behavior:**  
> “User has been at Mood 2 for 3 days → it’s 12:30 → high chance of spending on food → send alert at 12:30.”

### 📬 Smart Notifications
- Notifications sent via **Firebase Cloud Messaging (FCM)**.  
- Example alert:  
  > “Hey! Heads up 👀 You tend to spend $$$ on food when you’re feeling down around 1 PM. Maybe go for a walk?”  

- **Post-notification monitoring**:  
  - If user reduces spending in the next 2 hours → savings are calculated as “avoided expense.”  

---

## 🗄️ Database

- **Local (Offline)** → SQLite (stores all data when offline).  
- **Server (Online)** → PostgreSQL (syncs when internet returns).  

### 🔄 Sync Strategy
1. Data is always written to **SQLite** first.  
2. Background job syncs pending records to **PostgreSQL** when connection is restored.  

---

## 🔔 Example User Flow

1. User logs expenses & mood → stored in SQLite.  
2. Internet comes back → sync to PostgreSQL.  
3. LSTM runs daily at end of day → predicts tomorrow’s spending risks.  
4. If risk detected → notification sent via FCM at predicted time.  
5. Backend monitors next 2 hours after notification:  
   - If user spends less than predicted → log as savings.  

---

## 🚀 Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/Saqlain-mushtaq-alamin/Finura-v22.git 



2. Backend Setup (FastAPI)
cd finura_backend
python -m venv venv
source venv/bin/activate    
pip install -r requirements.txt


Run backend:

uvicorn backend.main:app --reload

3. Database Setup

Local: SQLite auto-created.

Server: Set up PostgreSQL and update .env:

 

4. Frontend Setup (Flutter)
cd finura_frontend
flutter pub get
flutter run