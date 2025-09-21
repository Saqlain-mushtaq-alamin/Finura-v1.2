# backend/services/fcm_service.py
import os
from firebase_admin import credentials, initialize_app, messaging

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FIREBASE_PATH = os.path.join(BASE_DIR, "..", "finura-53b27-firebase-adminsdk-fbsvc-8e974bc9a9.json")

 
cred = credentials.Certificate(FIREBASE_PATH )
default_app = initialize_app(cred)


def send_fcm_notification(token: str, title: str, body: str, data: dict = None):
    if not token:
        return None
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=token,
        data={k: str(v) for k, v in (data or {}).items()}
    )
    response = messaging.send(message)
    return response
     