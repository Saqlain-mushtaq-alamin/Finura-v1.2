import 'dart:math';

import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  const DashboardPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedRange = 'day';
  double totalIncome = 0;
  double totalExpense = 0;

  // Data for line charts
  List<FlSpot> incomeSpots = [];
  List<FlSpot> expenseSpots = [];

  List<Map<String, dynamic>> moodExpenses = [];
  final moodEmojis = ['😢', '😟', '😐', '🙂', '😄', '🤩'];

  @override
  void initState() {
    super.initState();
    _fetchData(); // Initial fetch for 'day'
  }

  Future<void> _fetchData() async {
    final db = await FinuraLocalDbHelper().database;
    final now = DateTime.now();
    DateTime startDate;

    if (selectedRange == 'day') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (selectedRange == 'week') {
      startDate = now.subtract(const Duration(days: 6));
    } else {
      startDate = DateTime(now.year, now.month, 1); // Start of current month
    }

    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(now);

    // Total income and expense sums for pie chart
    final incomeResult = await db.rawQuery(
      '''
      SELECT SUM(income_amount) as total FROM income_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      ''',
      [widget.userId, startStr, endStr],
    );

    final expenseResult = await db.rawQuery(
      '''
      SELECT SUM(expense_amount) as total FROM expense_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      ''',
      [widget.userId, startStr, endStr],
    );

    // Fetch mood-expense entries
    final moodResult = await db.rawQuery(
      '''
  SELECT mood, expense_amount 
  FROM expense_entry 
  WHERE user_id = ? AND date BETWEEN ? AND ?
''',
      [widget.userId, startStr, endStr],
    );

    moodExpenses = moodResult
        .map(
          (row) => {
            'mood': int.tryParse(row['mood'].toString()) ?? 0,
            'amount': (row['expense_amount'] ?? 0.0) as double,
          },
        )
        .toList();

    totalIncome = (incomeResult.first['total'] ?? 0.0) as double;
    totalExpense = (expenseResult.first['total'] ?? 0.0) as double;

    // Now get data for line charts by range
    if (selectedRange == 'day') {
      await _fetchDayChartData(db, startDate, now);
    } else if (selectedRange == 'week') {
      await _fetchWeekChartData(db, startDate, now);
    } else {
      await _fetchMonthChartData(db, startDate, now);
    }

    setState(() {}); // Update UI
  }

  // Fetch hourly data for 'day' (24 hours)
  Future<void> _fetchDayChartData(
    dynamic db,
    DateTime startDate,
    DateTime now,
  ) async {
    incomeSpots = List.generate(24, (index) => FlSpot(index.toDouble(), 0));
    expenseSpots = List.generate(24, (index) => FlSpot(index.toDouble(), 0));

    // Query income amounts grouped by hour
    final incomeHourly = await db.rawQuery(
      '''
      SELECT strftime('%H', date || ' ' || time) as hour, SUM(income_amount) as total
      FROM income_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY hour
      ''',
      [
        widget.userId,
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(now),
      ],
    );

    // Query expense amounts grouped by hour
    final expenseHourly = await db.rawQuery(
      '''
      SELECT strftime('%H', date || ' ' || time) as hour, SUM(expense_amount) as total
      FROM expense_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY hour
      ''',
      [
        widget.userId,
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(now),
      ],
    );

    // Map hour string to double value for FlSpot
    Map<int, double> incomeMap = {};
    Map<int, double> expenseMap = {};

    for (var row in incomeHourly) {
      final hour = int.tryParse(row['hour'] as String) ?? 0;
      final total = (row['total'] ?? 0.0) as double;
      incomeMap[hour] = total;
    }
    for (var row in expenseHourly) {
      final hour = int.tryParse(row['hour'] as String) ?? 0;
      final total = (row['total'] ?? 0.0) as double;
      expenseMap[hour] = total;
    }

    for (int i = 0; i < 24; i++) {
      incomeSpots[i] = FlSpot(i.toDouble(), incomeMap[i] ?? 0);
      expenseSpots[i] = FlSpot(i.toDouble(), expenseMap[i] ?? 0);
    }
  }

  // Fetch daily data for 'week' (7 days)
  Future<void> _fetchWeekChartData(
    dynamic db,
    DateTime startDate,
    DateTime now,
  ) async {
    incomeSpots = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    expenseSpots = List.generate(7, (index) => FlSpot(index.toDouble(), 0));

    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(now);

    // Income by day
    final incomeDaily = await db.rawQuery(
      '''
      SELECT date, SUM(income_amount) as total
      FROM income_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      [widget.userId, startStr, endStr],
    );

    // Expense by day
    final expenseDaily = await db.rawQuery(
      '''
      SELECT date, SUM(expense_amount) as total
      FROM expense_entry
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      [widget.userId, startStr, endStr],
    );

    // Map date string to index 0..6 for 7 days
    List<DateTime> daysList = List.generate(
      7,
      (i) => startDate.add(Duration(days: i)),
    );

    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    for (var row in incomeDaily) {
      incomeMap[row['date'] as String] = (row['total'] ?? 0.0) as double;
    }
    for (var row in expenseDaily) {
      expenseMap[row['date'] as String] = (row['total'] ?? 0.0) as double;
    }

    for (int i = 0; i < 7; i++) {
      final dayStr = DateFormat('yyyy-MM-dd').format(daysList[i]);
      incomeSpots[i] = FlSpot(i.toDouble(), incomeMap[dayStr] ?? 0);
      expenseSpots[i] = FlSpot(i.toDouble(), expenseMap[dayStr] ?? 0);
    }
  }

  // Fetch weekly data for 'month' (4 weeks)
  Future<void> _fetchMonthChartData(
    dynamic db,
    DateTime startDate,
    DateTime now,
  ) async {
    incomeSpots = List.generate(4, (index) => FlSpot(index.toDouble(), 0));
    expenseSpots = List.generate(4, (index) => FlSpot(index.toDouble(), 0));

    // Calculate week ranges (4 weeks)
    List<DateTime> weekStarts = List.generate(
      4,
      (i) => startDate.add(Duration(days: i * 7)),
    );

    List<DateTime> weekEnds = List.generate(
      4,
      (i) => weekStarts[i].add(const Duration(days: 6)),
    );

    Map<int, double> incomeMap = {};
    Map<int, double> expenseMap = {};

    for (int i = 0; i < 4; i++) {
      String start = DateFormat('yyyy-MM-dd').format(weekStarts[i]);
      String end = DateFormat(
        'yyyy-MM-dd',
      ).format(weekEnds[i].isAfter(now) ? now : weekEnds[i]);

      // Income for week i
      final incomeWeek = await db.rawQuery(
        '''
        SELECT SUM(income_amount) as total
        FROM income_entry
        WHERE user_id = ? AND date BETWEEN ? AND ?
        ''',
        [widget.userId, start, end],
      );
      incomeMap[i] = (incomeWeek.first['total'] ?? 0.0) as double;

      // Expense for week i
      final expenseWeek = await db.rawQuery(
        '''
        SELECT SUM(expense_amount) as total
        FROM expense_entry
        WHERE user_id = ? AND date BETWEEN ? AND ?
        ''',
        [widget.userId, start, end],
      );
      expenseMap[i] = (expenseWeek.first['total'] ?? 0.0) as double;
    }

    for (int i = 0; i < 4; i++) {
      incomeSpots[i] = FlSpot(i.toDouble(), incomeMap[i] ?? 0);
      expenseSpots[i] = FlSpot(i.toDouble(), expenseMap[i] ?? 0);
    }
  }

  Widget _buildPieChart() {
    final total = totalIncome + totalExpense;
    if (total == 0) {
      return const Text("No data", style: TextStyle(color: Colors.grey));
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: totalIncome,
            title: '${(totalIncome / total * 100).toStringAsFixed(1)}%',
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: totalExpense,
            title: '${(totalExpense / total * 100).toStringAsFixed(1)}%',
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
        ],
      ),
      key: ValueKey('$totalIncome-$totalExpense'),
    );
  }

  Widget _buildLineChartDay() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int hour = value.toInt();
                if (hour % 3 != 0) return const SizedBox.shrink();
                String amPm = hour < 12 ? "AM" : "PM";
                int displayHour = hour % 12 == 0 ? 12 : hour % 12;
                return Text(
                  '$displayHour $amPm',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartWeek() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= 7) return const SizedBox.shrink();
                return Text(days[index], style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartMonth() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 3,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= 4) return const SizedBox.shrink();
                return Text(
                  'Week ${index + 1}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodScatterChart() {
    if (moodExpenses.isEmpty) {
      return const Text(
        "No mood-expense data",
        style: TextStyle(color: Colors.grey),
      );
    }

    final maxY = moodExpenses
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: moodExpenses.map((entry) {
            return ScatterSpot(
              entry['mood'].toDouble(),
              entry['amount'].toDouble(),
              // color: Colors.blue,   // ✅ use `color` instead of `dotColor`
              //radius: 6,            // ✅ use `radius` instead of `dotSize`
            );
          }).toList(),
          minX: 0,
          maxX: 5,
          minY: 0,
          maxY: maxY + 20,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 50, // 👈 Increase this for more vertical height
                getTitlesWidget: (value, meta) {
                  final mood = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ), // optional: more space above text
                    child: Text(
                      moodEmojis[mood.clamp(0, 5)],
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 50),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          scatterTouchData: ScatterTouchData(enabled: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                Container(
                  alignment: Alignment.centerLeft,

                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(16.0),
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    margin: const EdgeInsets.only(left: 4.0),
                    child: SizedBox(
                      height: 35,
                      width: double.infinity,
                      child: ToggleButtons(
                        isSelected: [
                          selectedRange == 'day',
                          selectedRange == 'week',
                          selectedRange == 'month',
                        ],
                        onPressed: (index) {
                          setState(() {
                            selectedRange = ['day', 'week', 'month'][index];
                            _fetchData();
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),

                            child: Text(
                              "Day",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "Week",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "Month",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Income and Expense
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            border: Border.all(
                              color: Colors.teal,
                              width: sqrt1_2,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Income:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "৳ ${totalIncome.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Total Expense:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "৳ ${totalExpense.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 25),

                      // Pie Chart
                      Container(
                        height: 155,
                        width: 160,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: _buildPieChart(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Column(
                  children: [
                    Container(
                      // Background color for both sections
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // Stretch the column to fill available width
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            // Line Chart
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                8.0,
                                8.0,
                                20,
                                8.0,
                              ),
                              child: SizedBox(
                                height: 250,
                                width: double
                                    .infinity, // Use double.infinity for full width
                                child: selectedRange == 'day'
                                    ? _buildLineChartDay()
                                    : selectedRange == 'week'
                                    ? _buildLineChartWeek()
                                    : _buildLineChartMonth(),
                              ),
                            ),
                          ),

                          // Spending Mood Correlation section
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Spending Mood Correlation",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildMoodScatterChart(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
