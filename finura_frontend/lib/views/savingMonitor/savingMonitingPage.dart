import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SavingMonitorPage extends StatefulWidget {
  final String userId;
  const SavingMonitorPage({super.key, required this.userId});

  @override
  State<SavingMonitorPage> createState() => _SavingMonitorPageState();
}

class _SavingMonitorPageState extends State<SavingMonitorPage> {
  final dbHelper = FinuraLocalDbHelper();
  double totalSaving = 0;
  String currentMonth = DateFormat.MMMM().format(DateTime.now());
  List<Map<String, dynamic>> savingGoals = [];
  List<FlSpot> incomeData = [];
  List<FlSpot> expenseData = [];
  List<FlSpot> savingData = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData({String? month}) async {
    final db = await dbHelper.database;
    final String filterMonth = month ?? currentMonth;

    // Fetch all saving goals
    savingGoals = await db.query(
      'saving_goal',
      where: 'user_id = ?',
      whereArgs: [widget.userId],
    );

    // Total Saving = sum of current_saved for this month
    final savingSumResult = await db.rawQuery(
      '''
    SELECT SUM(current_saved) as total_saved
    FROM saving_goal
    WHERE user_id = ? AND strftime('%m', start_date) = ?
  ''',
      [widget.userId, _monthToNumber(filterMonth)],
    );

    totalSaving =
        (savingSumResult.first['total_saved'] as num?)?.toDouble() ?? 0;

    // Fetch income for the month
    final incomeEntries = await db.rawQuery(
      '''
    SELECT day, SUM(income_amount) as total_income
    FROM income_entry
    WHERE user_id = ? AND strftime('%m', date) = ?
    GROUP BY day
  ''',
      [widget.userId, _monthToNumber(filterMonth)],
    );

    // Fetch expenses for the month
    final expenseEntries = await db.rawQuery(
      '''
    SELECT day, SUM(expense_amount) as total_expense
    FROM expense_entry
    WHERE user_id = ? AND strftime('%m', date) = ?
    GROUP BY day
  ''',
      [widget.userId, _monthToNumber(filterMonth)],
    );

    // Fetch savings for the month from saving_goal table
    final savingEntries = await db.rawQuery(
      '''
    SELECT day, SUM(current_saved) as total_saved
    FROM saving_goal
    JOIN (
      SELECT DISTINCT date, CAST(strftime('%d', date) AS INTEGER) as day
      FROM expense_entry WHERE user_id = ?
    ) days ON 1=1
    WHERE user_id = ? AND strftime('%m', start_date) = ?
    GROUP BY day
  ''',
      [widget.userId, widget.userId, _monthToNumber(filterMonth)],
    );

    // Convert to maps for fast lookup
    final incomeMap = {
      for (var e in incomeEntries)
        (e['day'] as int): (e['total_income'] as num?)?.toDouble() ?? 0,
    };
    final expenseMap = {
      for (var e in expenseEntries)
        (e['day'] as int): (e['total_expense'] as num?)?.toDouble() ?? 0,
    };
    final savingMap = {
      for (var e in savingEntries)
        (e['day'] as int): (e['total_saved'] as num?)?.toDouble() ?? 0,
    };

    // Fill missing days with 0
    incomeData = [];
    expenseData = [];
    savingData = [];
    for (int day = 1; day <= 30; day++) {
      incomeData.add(FlSpot(day.toDouble(), incomeMap[day] ?? 0));
      expenseData.add(FlSpot(day.toDouble(), expenseMap[day] ?? 0));
      savingData.add(FlSpot(day.toDouble(), savingMap[day] ?? 0));
    }

    setState(() {});
  }

  String _monthToNumber(String monthName) {
    return DateFormat('MM').format(DateFormat.MMMM().parse(monthName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saving Monitor"),
        backgroundColor: Color.fromARGB(255, 102, 241, 197),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Total Saving & Month
          Container(
            padding: const EdgeInsets.fromLTRB(28, 12, 12, 12),

            decoration: BoxDecoration(
              color: Color.fromARGB(255, 102, 241, 197),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "\$${totalSaving.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.all(1),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlue),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "saving",
                        style: TextStyle(fontSize: 12, color: Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
                Text(
                  currentMonth,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Line Chart
          Expanded(
            flex: 2,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 30,
                minY: 0,
                backgroundColor: Color.fromARGB(255, 102, 241, 197),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Income (Green)
                  LineChartBarData(
                    spots: incomeData,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false), // hide dots
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Expense (Red)
                  LineChartBarData(
                    spots: expenseData,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Saving (Blue)
                  LineChartBarData(
                    spots: savingData,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Saving Goals List
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(18.0),
              margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 183, 238, 221),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(0),
                ),
              ),

              child: ListView.builder(
                itemCount: savingGoals.length,
                itemBuilder: (context, index) {
                  final goal = savingGoals[index];
                  double progress = 0;
                  if (goal['target_saving'] > 0) {
                    progress = (goal['current_saved'] / goal['target_saving'])
                        .clamp(0.0, 1.0);
                  }
                  String goalMonth = DateFormat.MMMM().format(
                    DateTime.parse(goal['start_date']),
                  );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentMonth = goalMonth;
                      });
                      _loadAllData(month: goalMonth);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month & % Left
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goalMonth,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${((1 - progress) * 100).toStringAsFixed(0)}% left",
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Line
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 6,
                                width:
                                    MediaQuery.of(context).size.width *
                                    progress,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text("Target Saving: \$${goal['target_saving']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
