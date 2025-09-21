import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:flutter/material.dart';

class SavingGoal {
  final String id;
  final double targetAmount;
  final DateTime startDate;
  final String description;

  SavingGoal({
    required this.id,
    required this.targetAmount,
    required this.startDate,
    required this.description,
  });

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'],
      targetAmount: map['target_saving']?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['start_date']),
      description: map['description'] ?? '',
    );
  }
}

Future<List<SavingGoal>> fetchSavingGoals(String userId) async {
  final db = await FinuraLocalDbHelper().database;
  final List<Map<String, dynamic>> maps = await db.query(
    'saving_goal',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'start_date DESC',
  );
  return maps.map((map) => SavingGoal.fromMap(map)).toList();
}

Future<void> deleteSavingGoal(String id) async {
  final db = await FinuraLocalDbHelper().database;
  await db.delete('saving_goal', where: 'id = ?', whereArgs: [id]);
}

class PlanningHistoryPage extends StatefulWidget {
  final String userId;

  const PlanningHistoryPage({super.key, required this.userId});

  @override
  State<PlanningHistoryPage> createState() => _PlanningHistoryPageState();
}

class _PlanningHistoryPageState extends State<PlanningHistoryPage> {
  late Future<List<SavingGoal>> _futureGoals;

  @override
  void initState() {
    super.initState();
    _futureGoals = fetchSavingGoals(widget.userId);
  }

  void _deleteGoal(String id) async {
    await deleteSavingGoal(id);
    setState(() {
      _futureGoals = fetchSavingGoals(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning History'),
        centerTitle: false,
        backgroundColor: Colors.green[100],
      ),

      body: FutureBuilder<List<SavingGoal>>(
        future: _futureGoals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No planning history found.'));
          }
          final goals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
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
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target: \$${goal.targetAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ' ${goal.startDate.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Goal'),
                                content: Text(
                                  'Are you sure you want to delete this goal?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              _deleteGoal(goal.id);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(),
                    const SizedBox(height: 8),
                    Text(goal.description, style: TextStyle(fontSize: 16)),
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
