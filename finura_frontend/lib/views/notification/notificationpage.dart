import 'package:flutter/material.dart';
import 'package:finura_frontend/services/local_database/local_database_helper.dart';

class NotificationModel {
  final String id;
  final String userId;
  final double predictedExpenseAmount;
  final int predictedMood;
  final String predictedTime;
  final String pushTime;
  final String notifMessage;
  final int notifStatus;
  final String harmLevel;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.predictedExpenseAmount,
    required this.predictedMood,
    required this.predictedTime,
    required this.pushTime,
    required this.notifMessage,
    required this.notifStatus,
    required this.harmLevel,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      predictedExpenseAmount:
          map['predicted_expense_amount']?.toDouble() ?? 0.0,
      predictedMood: map['predicted_mood'],
      predictedTime: map['predicted_time'],
      pushTime: map['push_time'],
      notifMessage: map['notif_message'],
      notifStatus: map['notif_status'],
      harmLevel: map['harm_level'],
      createdAt: map['created_at'],
    );
  }
}

Future<List<NotificationModel>> fetchNotifications(String userId) async {
  final db = await FinuraLocalDbHelper().database;
  final List<Map<String, dynamic>> maps = await db.query(
    'notification',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'push_time DESC',
  );
  return maps.map((map) => NotificationModel.fromMap(map)).toList();
}

Future<void> deleteNotification(String id) async {
  final db = await FinuraLocalDbHelper().database;
  await db.delete('notification', where: 'id = ?', whereArgs: [id]);
}

class NotificationPage extends StatefulWidget {
  final String userId;

  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationModel>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = fetchNotifications(widget.userId);
  }

  void _deleteNotification(String id) async {
    await deleteNotification(id);
    setState(() {
      _futureNotifications = fetchNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        centerTitle: false,
        backgroundColor: Colors.blue[100],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row with delete button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.predictedTime,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Notification'),
                                content: const Text(
                                  'Are you sure you want to delete this notification?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              _deleteNotification(notif.id);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Row for Mood and Harm Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(" ${notif.predictedMood}"),
                        Text(" ${notif.harmLevel}"),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Notification message
                    Text(
                      notif.notifMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
