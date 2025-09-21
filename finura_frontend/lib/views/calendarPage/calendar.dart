import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/views/calendarPage/noteHistory.dart';
import 'package:finura_frontend/views/finuraChatPage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class CalendarPage extends StatefulWidget {
  var userID;
  CalendarPage({super.key, required this.userID});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String formattedSelectedDate = DateFormat.yMMMMd().format(
      _selectedDay,
    );
    final String formattedMonth = DateFormat.yMMMM().format(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 164, 245, 171),
        title: Text('Calendar'),
        centerTitle: false,

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 35.0,
              left: 16.0,
              top: 8.0,
              bottom: 8.0,
            ),

            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () {
                    print("AppBaar Icon tapped"); //?need to change this
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteHistoryPage(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/icons/unotse.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top bar with current selected date and current month
              // Top bar with current selected date and current month
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Date - Below current date
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedSelectedDate,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Visible Month - Top Right
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 1),
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: Text(
                      formattedMonth,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                  weekendDecoration: BoxDecoration(shape: BoxShape.circle),
                  outsideDecoration: BoxDecoration(shape: BoxShape.circle),
                ),
                headerVisible: false,
                daysOfWeekVisible: true,
                calendarBuilders: CalendarBuilders(
                  outsideBuilder: (context, day, focusedDay) {
                    return Center(child: Text('${day.day}'));
                  },
                ),
              ),

              Divider(thickness: 2, color: Colors.grey, height: 30),

              // Input fields
              SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'Write your note here',
                ),
                maxLines: 3,
              ),

              SizedBox(height: 25),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 14,
                    ), // remove horizontal padding
                  ),
                  onPressed: () async {
                    String title = _titleController.text.trim();
                    String note = _noteController.text.trim();

                    if (title.isEmpty && note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a title or note')),
                      );
                      return;
                    }

                    try {
                      final dbHelper = FinuraLocalDbHelper();
                      final db = await dbHelper.database;

                      var uuid = Uuid();
                      String noteID = uuid.v4(); // This is your new user ID

                      await db.insert('note_entry', {
                        'id': noteID,

                        'user_id': widget.userID,
                        'title': title,
                        'content': note,
                        'created_at': DateTime.now().toIso8601String(),
                        'updated_at': _selectedDay.toIso8601String(),
                        'synced': 0,
                      });

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Note saved')));

                      _titleController.clear();
                      _noteController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving note: $e')),
                      );
                    }
                  },

                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
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
