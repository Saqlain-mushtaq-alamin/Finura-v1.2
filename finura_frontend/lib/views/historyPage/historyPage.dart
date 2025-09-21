import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String category;

  final double amount;
  final DateTime dateTime;
  final bool isIncome; // true = income, false = expense

  Transaction({
    required this.id,
    required this.category,

    required this.amount,
    required this.dateTime,
    required this.isIncome,
  });
}

class HistoryPage extends StatefulWidget {
  final dynamic userId;

  const HistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<List<Map<String, dynamic>>> getAllIncome(String userId) async {
    final db = await FinuraLocalDbHelper().database;
    return await db.query(
      'income_entry',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllExpenses(String userId) async {
    final db = await FinuraLocalDbHelper().database;
    return await db.query(
      'expense_entry',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, time DESC',
    );
  }

  Future<void> deleteIncome(String id) async {
    final db = await FinuraLocalDbHelper().database;
    await db.delete('income_entry', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await FinuraLocalDbHelper().database;
    await db.delete('expense_entry', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _loadTransactions() async {
    // Fetch income and expense entries from the database
    //!fixed order cont replace wiht each other
    // Replace with your actual DB calls
    final incomeList = await getAllIncome(widget.userId);
    final expenseList = await getAllExpenses(widget.userId);

    final allTxns = [
      // Income entries
      ...incomeList.map(
        (i) => Transaction(
          id: i['id'].toString(),

          category: i['description'] ?? 'Income',
          amount: (i['income_amount'] ?? 0).toDouble(),
          dateTime: DateTime.parse("${i['date']} ${i['time']}"),
          isIncome: true,
        ),
      ),
      // Expense entries
      ...expenseList.map(
        (e) => Transaction(
          id: e['id'].toString(),

          category: e['description'] ?? 'Expense',
          amount: (e['expense_amount'] ?? 0).toDouble(),
          dateTime: DateTime.parse("${e['date']} ${e['time']}"),
          isIncome: false,
        ),
      ),
    ];

    // Sort by most recent
    allTxns.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    setState(() {
      _transactions = allTxns;
    });
  }

  Future<void> _deleteTransaction(Transaction txn) async {
    if (txn.isIncome) {
      await deleteIncome(txn.id);
    } else {
      await deleteExpense(txn.id);
    }
    _loadTransactions();
  }

  Widget _buildTransactionItem(Transaction txn) {
    final amountColor = txn.isIncome ? Colors.green : Colors.red;
    final amountPrefix = txn.isIncome ? '+' : '-';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            txn.category,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 4),
          Text(
            DateFormat('yyyy-MM-dd - kk:mm').format(txn.dateTime),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$amountPrefix\$${txn.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Transaction'),
                  content: Text(
                    'Are you sure you want to delete this transaction?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _deleteTransaction(txn);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),

        child: _transactions.isEmpty
            ? const Center(child: Text('No transactions yet.'))
            : ListView.separated(
                itemCount: _transactions.length,
                itemBuilder: (context, index) =>
                    _buildTransactionItem(_transactions[index]),
                separatorBuilder: (_, __) => const Divider(),
              ),
      ),
    );
  }
}
