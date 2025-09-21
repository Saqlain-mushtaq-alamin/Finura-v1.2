 
// finura_local_db.dart
import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:sqflite/sqflite.dart';

extension NotificationDb on FinuraLocalDbHelper {
  Future<void> insertNotification(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'notification',
      {
        "id": data["id"],
        "user_id": data["user_id"],
        "predicted_expense_amount": double.tryParse(data["expense_amount"] ?? "0"),
        "predicted_mood": int.tryParse(data["predicted_mood"] ?? "0"),
        "predicted_time": data["predicted_time"],
        "push_time": data["push_time"] ?? "",
        "notif_message": data["body"] ?? data["notif_message"],
        "notif_status": 1,
        "harm_level": data["harm_level"],
        "created_at": DateTime.now().toIso8601String()
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query("notification", orderBy: "created_at DESC");
  }
}
