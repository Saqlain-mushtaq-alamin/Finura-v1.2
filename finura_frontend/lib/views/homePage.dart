import 'dart:io';

import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/views/DashboardPage/dashboard.dart';
import 'package:finura_frontend/views/calendarPage/calendar.dart';
import 'package:finura_frontend/views/defoult/payment.dart';
import 'package:finura_frontend/views/finuraChatPage.dart';
import 'package:finura_frontend/views/helpPage/help.dart';
import 'package:finura_frontend/views/historyPage/historyPage.dart';
import 'package:finura_frontend/views/notification/notificationpage.dart';
import 'package:finura_frontend/views/panning/planning.dart';
import 'package:finura_frontend/views/savingMonitor/savingMonitingPage.dart';
import 'package:finura_frontend/views/setting/mainSetting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final String userFirstName;
  final String userProfilePicUrl;

  String user_Id; // 👈 user_id from the user table

  HomePage({
    super.key,
    required this.userFirstName,
    required this.userProfilePicUrl,
    required this.user_Id, // 👈 user_id from the user table
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController categoryController = TextEditingController();

  final TextEditingController amountController = TextEditingController();
  int selectedMood = 0;

  String? selectedOption;
  NotificationModel? _latestNotification;

  @override
  void initState() {
    super.initState();
    _loadLatestNotification();
  }

  Future<void> _loadLatestNotification() async {
    final latest = await fetchLatestNotification(widget.user_Id);
    setState(() {
      _latestNotification = latest;
    });
  }

  ImageProvider _buildImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('/')) {
      return FileImage(File(path));
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return const AssetImage('assets/default_user/fallback.jpg');
    }
  }

  // notification fetching logic
  Future<NotificationModel?> fetchLatestNotification(String userId) async {
    final db = await FinuraLocalDbHelper().database;

    final result = await db.query(
      'notification',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'push_time DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return NotificationModel.fromMap(result.first);
    }

    return null; // No notifications found
  }

  Future<void> insertIncomeEntry({
    required String userId,
    required int mood,
    required String category,
    required double amount,
  }) async {
    final db = await FinuraLocalDbHelper().database;
    final now = DateTime.now();

    // 🕒 Format date and time as strings
    String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    int day = now.weekday; // Dart: 1 = Monday, 7 = Sunday

    // Optional: Custom day mapping (1 = Sat, 2 = Sun, etc.)
    List<int> custom = [7, 1, 2, 3, 4, 5, 6];
    int customDay = custom[day - 1];

    var uuid = Uuid();
    String incomeID = uuid.v4(); // This is your new user ID

    try {
      await db.insert(
        'income_entry', // 👈 Your table name
        {
          'id': incomeID,
          'user_id': userId, // 👈 Foreign key to user table
          'date': date, // 👈 Formatted date
          'day': customDay, // 👈 Custom day format (if needed)
          'time': time, // 👈 Time in "HH:mm"
          'mood': mood, // 👈 Placeholder mood value (0-5)
          'description': category, // 👈 Income category
          'income_amount': amount, // 👈 Double value
          'synced': 0, // 👈 Default is 0 (not synced)
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Income entry inserted successfully.');
    } catch (e) {
      print('Error inserting income entry: $e');
    }
  }

  // Function to insert an expense entry into the database
  Future<void> insertExpenseEntry({
    required String userId,
    required int mood,
    required String description,
    required double amount,
  }) async {
    final db = await FinuraLocalDbHelper().database;
    final now = DateTime.now();

    // 🕒 Format date and time as strings
    String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    int day = now.weekday; // Dart: 1 = Monday, 7 = Sunday

    // Optional: Custom day mapping (1 = Sat, 2 = Sun, etc.)
    List<int> custom = [7, 1, 2, 3, 4, 5, 6];
    int customDay = custom[day - 1];
    var uuid = Uuid();
    String epxenseID = uuid.v4(); // This is your new user ID
    try {
      await db.insert(
        'expense_entry', // 👈 Your table name
        {
          'id': epxenseID,
          'user_id': userId, // 👈 Foreign key to user table
          'date': date, // 👈 Formatted date
          'day': customDay, // 👈 Custom day format (if needed)
          'time': time, // 👈 Time in "HH:mm"
          'mood': mood, // 👈 1-5 mood rating
          'description': description, // 👈 User-entered string
          'expense_amount': amount, // 👈 Double value
          'synced': 0, // 👈 Default is 0 (not synced)
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Expense entry inserted successfully.');
    } catch (e) {
      print('Error inserting expense entry: $e');
    }
  }

  // Build method to create the HomePage UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
        titleSpacing: 0,
        title: Row(
          children: [
            // User profile picture
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 16.0),

              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,

                  child: Image(
                    image: _buildImageProvider(widget.userProfilePicUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // User first name
            Text(
              widget.userFirstName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            // Target icon (rightmost)
            Padding(
              padding: const EdgeInsets.only(
                right: 35.0,
                left: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),

              child: GestureDetector(
                onTap: () {
                  print("AppBaar Icon tapped"); //?need to change this
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentPage(), // Navigate to PaymentPage
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/icons/trophy.png',
                        width: 38,
                        height: 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),

          width: double.infinity,
          //height: double.infinity, // Adjust height to fit the screen
          padding: const EdgeInsets.all(16.0),
          color: const Color.fromARGB(255, 235, 250, 235),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),

              // Box 1: Input Field
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Text fields for category and amount
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText:
                            'Enter category here', // This should be changed when i found something better'
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'Enter amount here',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      inputFormatters: [
                        // Allow only numbers and decimal point
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      hint: const Text('Select an option'),

                      items: const [
                        DropdownMenuItem(
                          value: 'ExpenseOption',
                          child: Text('Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'IncomeOption',
                          child: Text('Income'),
                        ),
                      ],
                      onChanged: (value) {
                        selectedOption = value;

                        if (selectedOption == null) {
                          // Show an error message if no option is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an option.'),
                            ),
                          );
                        }
                      },
                    ),

                    // Emoji Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        // Mapping emoji and mood value
                        // final emojiList = ["😤", "😌", "😐", "🥳", "😍"];
                        final emojiList = ['😢', '😟', '😐', '🙂', '😍'];
                        final moodValue = index + 1;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMood = moodValue;
                            });
                          },
                          onLongPress: () async {
                            setState(() {
                              selectedMood = 0; // Deselect
                            });

                            // Optional: Play sound (requires audioplayers or similar package)
                            // await AudioPlayer().play(AssetSource('sounds/unselect.mp3'));
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: selectedMood == moodValue ? 1.4 : 1.0,
                            child: Text(
                              emojiList[index],
                              style: TextStyle(
                                fontSize: 32,
                                color: selectedMood == moodValue
                                    ? Colors.blueAccent
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    //submit button
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle submit action
                          if (categoryController.text.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            if (selectedOption == "ExpenseOption") {
                              // Handle Expense option

                              // Call the insertExpenseEntry method
                              insertExpenseEntry(
                                userId: widget.user_Id, // 👈 Pass the user_id
                                mood:
                                    selectedMood, //!replace it with  mood logical value
                                description: categoryController.text,
                                amount: double.parse(amountController.text),
                              );

                              // Clear the input fields after submission
                              categoryController.clear();
                              amountController.clear();
                              selectedOption = null;
                              setState(() {
                                selectedMood =
                                    0; // 👈 Unselect emoji after submit
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense entry submitted!'),
                                ),
                              );
                            } else if (selectedOption == "IncomeOption") {
                              // Handle Income option

                              // Call the insertIncomeEntry method
                              insertIncomeEntry(
                                userId: widget.user_Id, // 👈 Pass the user_id
                                mood:
                                    selectedMood, //!replace it with mood logical value
                                category: categoryController.text,
                                amount: double.parse(amountController.text),
                              );

                              // Clear the input fields after submission
                              categoryController.clear();
                              amountController.clear();
                              selectedOption = null;
                              setState(() {
                                selectedMood =
                                    0; // 👈 Unselect emoji after submit
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Income entry submitted!'),
                                ),
                              );
                            } else {
                              // Show an error message if fields are empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a option.'),
                                ),
                              );
                            }
                          } else {
                            // Show an error message if fields are empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),

              // Box 2: all app facilities icons
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 200.0, // Adjust height as needed

                  child: GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Icon 1: Settings icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 1 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SettingsPage(userId: widget.user_Id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/icons/settings.png',
                                width: 40,
                                height: 40,
                              ),
                            ),

                            const SizedBox(height: 8),
                            const Text(
                              'Setting',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Icon 2: Planning icon button
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlanningPage(userId: widget.user_Id),
                            ),
                          );
                        },

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/planning.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Panning',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Icon 3: Dashboard icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 3 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DashboardPage(userId: widget.user_Id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/dashboard.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Dashboard',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Icon 4: histoy icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 4 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryPage(userId: widget.user_Id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/history.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'History',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Icon 5: targeted icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 5 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SavingMonitorPage(userId: widget.user_Id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/targeted.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Targeted',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Icon 6: calendar icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 6 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CalendarPage(userID: widget.user_Id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/calendar.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Calendar',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Icon 7: help icon button
                      GestureDetector(
                        onTap: () {
                          print("Icon 7 tapped"); //?need to change this
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GetHelpPage(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/help-desk.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text('Help', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Box 3: Notification Display
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                height: 100.0, // You can adjust height if needed
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _latestNotification == null
                    ? const Text(
                        'No notifications yet.',
                        style: TextStyle(color: Colors.black87),
                      )
                    : SingleChildScrollView(
                        // 👈 makes inner content scrollable
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "💸💸",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _latestNotification!.notifMessage,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),

              // Box 4: finura chat box
              Container(
                width: double.infinity,
                height: 400.0,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final TextEditingController _controller =
                        TextEditingController();
                    final ScrollController _scrollController =
                        ScrollController();
                    final List<String> messages = [
                      "Hi, I am Finuro. I am here to give you financial advice...",
                    ];

                    void _sendMessage() {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          messages.add(text);
                          _controller.clear();
                        });

                        // Auto-scroll to bottom
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    }

                    return Column(
                      children: [
                        // Top Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(
                                'assets/finura_icon.webp',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Finuro",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.fullscreen),
                              onPressed: () {
                                //Handle fullscreen action
                                //Optional fullscreen logic
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FinuraChatPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Scrollable chat messages
                        Flexible(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final isBot = index == 0;
                              return Align(
                                alignment: isBot
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  constraints: const BoxConstraints(
                                    maxWidth: 250,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isBot
                                        ? Colors.grey.shade200
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    messages[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Input field and send button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    hintText: "Type your message...",
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      // This is a simple bottom navigation bar with three icons
      // QR Scanner, Home, and Notification icons
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: const Color.fromARGB(255, 164, 245, 171),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // QR Scanner icon (left)
              GestureDetector(
                onTap: () {
                  print("Scan Icon tapped"); //?need to change this
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentPage(), // Navigate to PaymentPage
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/scan.png', width: 28, height: 28),
                  ],
                ),
              ),
              // Home icon (center)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FinuraChatPage()),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/finura_icon.webp'),
                    ),
                  ],
                ),
              ),
              // Notification icon (right)
              GestureDetector(
                onTap: () {
                  print("Scan Icon tapped"); //?need to change this
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationPage(userId: widget.user_Id),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/bell.png', width: 28, height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
