// lib/services/sync_service.dart
import 'dart:convert';
import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:http/http.dart' as http;

import 'internet_checker.dart';

class SyncService {
  static Future<void> syncAll() async {
    final isOnline = await InternetChecker.isOnline();
    if (!isOnline) {
      print("📴 No internet. Skipping sync.");
      return;
    }

    print("🌐 Online detected. Starting sync...");

    final db = await FinuraLocalDbHelper().database;

    // 🔄 Sync users
    final users = await db.query(
      'user',
      where: "data_status IS NULL OR data_status != 'uploaded'",
    );
    for (var user in users) {
      final success = await _postToAPI('/sync_user', user);
      if (success) {
        print("✅ Synced user: ${user['name']}");
        await db.update(
          'user',
          {'data_status': 'uploaded'},
          where: 'id = ?',
          whereArgs: [user['id']],
        );
      }
    }

    // 🔄 Sync expenses
    final expenses = await db.query('expense_entry', where: 'synced = 0');
    for (var item in expenses) {
      final success = await _postToAPI('/sync_expense', item);
      if (success) {
        print("✅ Synced expense: ${item['title']}");
         // Update the synced status in the database
        await db.update(
          'expense_entry',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    // 🔄 Sync income
    final incomes = await db.query('income_entry', where: 'synced = 0');
    for (var item in incomes) {
      final success = await _postToAPI('/sync_income', item);
      if (success) {
        print("✅ Synced income: ${item['title']}");
        // Update the synced status in the database
        await db.update(
          'income_entry',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    // 🔄 Sync savings
    final goals = await db.query('saving_goal', where: 'synced = 0');
    for (var item in goals) {
      final success = await _postToAPI('/sync_goal', item);
      if (success) {
        print("✅ Synced saving goal: ${item['title']}");
        // Update the synced status in the database
        await db.update(
          'saving_goal',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    // 🔄 Sync notes
    final notes = await db.query('note_entry', where: 'synced = 0');
    for (var item in notes) {
      final success = await _postToAPI('/sync_note', item);
      if (success) {
        // assuming notes always overwrite on sync
        await db.update(
          'note_entry',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
        print("✅ Synced note: ${item['title']}");
      }
    }

    print("🎉 Sync completed!");
  }

  // Helper function to POST to backend
  static Future<bool> _postToAPI(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    //! Replace with your actual FastAPI URL  
    final baseUrl = 'http://10.0.2.2:8000'; // Or your deployed URL
 // 🔁 Replace this
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        print('❌ Sync failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Sync error: $e');
      return false;
    }
  }
}
