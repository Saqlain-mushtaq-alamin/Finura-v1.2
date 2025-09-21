// services/fcm_service.dart
import 'package:finura_frontend/finura_local_db.dart';
import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initFCM(String userId) async {
    String? token = await _fcm.getToken();
    if (token != null) {
      await http.post(
        //! Replace with your actual backend URL 
        Uri.parse("http://your-backend.com/update-fcm-token"),
        body: {"user_id": userId, "fcm_token": token},
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await FinuraLocalDbHelper().insertNotification(message.data);
    });
  }
}
