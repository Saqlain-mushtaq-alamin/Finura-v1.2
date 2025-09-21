import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/views/panning/planningHistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PlanningPage extends StatefulWidget {
  final String userId;

  const PlanningPage({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController savingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  double expenseLimit = 0.0;

  // Month selection
  void _selectMonth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      helpText: "Select Month",
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateFormat('MMMM yyyy').format(picked);
      });
    }
  }

  // Insert into DB
  Future<void> _submitGoal() async {
    final db = await FinuraLocalDbHelper().database;

    if (incomeController.text.isEmpty || savingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final monthlyIncome = double.tryParse(incomeController.text) ?? 0;
    final targetSaving = double.tryParse(savingController.text) ?? 0;
    final description = descriptionController.text;

    // Parse selectedMonth to DateTime
    final parsedMonth = DateFormat('MMMM yyyy').parse(selectedMonth);

    // Calculate start date (first day of selected month)
    final startDate = DateTime(parsedMonth.year, parsedMonth.month, 1);

    // Calculate end date (last day of selected month)
    final endDate = DateTime(parsedMonth.year, parsedMonth.month + 1, 0);

    // Calculate expense limit
    expenseLimit = monthlyIncome - targetSaving;

    if (monthlyIncome < 0 || targetSaving < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Income and saving must be positive numbers."),
        ),
      );
      return;
    }
    if (expenseLimit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense limit cannot be negative.")),
      );
      return;
    }

    try {
      await db.insert('saving_goal', {
        'id': const Uuid().v4(),
        'user_id': widget.userId,
        'monthly_income': monthlyIncome,
        'target_saving': targetSaving,
        'target_expense_limit': expenseLimit,
        'frequency': 1.0,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        'current_saved': 0,
        'description': description,
        'synced': 0,
      });
    } catch (e) {
      print('Error inserting saving goal entry: $e');
    }

    incomeController.clear();
    savingController.clear();
    descriptionController.clear();

    setState(() {}); // Refresh expense limit display

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Goal saved successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title: const Text("Planning"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to history page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlanningHistoryPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(50, 10, 8.0, 8.0),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expense limit", style: TextStyle(fontSize: 25)),
                    const SizedBox(height: 10),
                    Text(
                      "${expenseLimit.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 80), // Space between text and image
                Image.asset('assets/gif/plaing1.gif', height: 150, width: 150),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.all(8.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Row with month + icon
                Container(
                  height: 60,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey, width: 3.0),

                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          " $selectedMonth",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey, width: 3.0),
                          ),
                        ),

                        child: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectMonth(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Monthly income
                TextField(
                  controller: incomeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Monthly Income",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Target Saving
                TextField(
                  controller: savingController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Target Saving",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitGoal,

                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
