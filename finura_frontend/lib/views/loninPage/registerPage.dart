import 'package:finura_frontend/services/local_database/local_database_helper.dart';

import 'package:finura_frontend/views/loninPage/login.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<void> insertWelcomeNotification(String userId) async {
  final db = await FinuraLocalDbHelper().database;
  final now = DateTime.now(); // keep it as DateTime
  final formattedTime = DateFormat(
    'yyyy-MM-dd – hh:mm a',
  ).format(now); // format it
  final nowIso = now.toIso8601String(); // convert to ISO string if needed

  await db.insert('notification', {
    'id': const Uuid().v4(),
    'user_id': userId,
    'predicted_expense_amount': 0.0,
    'predicted_mood': 5, // default neutral/happy mood
    'predicted_time': formattedTime,
    'push_time': nowIso,
    'notif_message':
        'Welcome to Finura! Let’s start building your financial journey.',
    'notif_status': 0,
    'harm_level': ' ',
    'created_at': nowIso,
  });
}

//  function for simulate storing user data in the database
Future<String> storeUserData({
  required String firstName,
  required String lastName,
  required String email,
  required String occupation,
  required String sex,
  required String pin, // Already hashed
  String? photoPath,
}) async {
  final db = await FinuraLocalDbHelper().database;

  String? savedImagePath;

  if (photoPath != null) {
    // If it's an asset path, just store the string (no copying)
    if (photoPath.startsWith('assets/')) {
      savedImagePath = photoPath;
    } else {
      // Else, it's a user-picked file: copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(photoPath);
      final newImagePath = '${appDir.path}/$fileName';

      await File(photoPath).copy(newImagePath);
      savedImagePath = newImagePath;
    }
  }

  var uuid = Uuid();
  String userId = uuid.v4(); // This is your new user ID

  await db.insert('user', {
    'id': userId,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'occupation': occupation,
    'sex': sex,
    'pin_hash': pin,
    'created_at': DateTime.now().toIso8601String(),
    'user_photo': savedImagePath,
    'data_status': null,
  });

  print('User stored successfully.');
  return userId;
}

// Function to hash the pin using SHA256
String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String? _selectedSex;
  File? _photo;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.green[700],
        // Fixed invalid shade
      ),
      body: Container(
        width: double.infinity,
        color: Colors.green[100], // Fixed invalid shade
        alignment: Alignment.center,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _photo != null ? FileImage(_photo!) : null,
                    child: _photo == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter first name'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(labelText: 'Occupation'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter occupation'
                      : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  decoration: const InputDecoration(labelText: 'Sex'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    //DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select sex' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pinController,
                  decoration: const InputDecoration(labelText: 'PIN'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter PIN' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPinController,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your PIN';
                    }
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async {
                    String? finalPhotoPath = _photo?.path;

                    if (finalPhotoPath == null) {
                      if (_selectedSex == 'male') {
                        finalPhotoPath = 'assets/default_user/male_user.jpg';
                      } else if (_selectedSex == 'female') {
                        finalPhotoPath = 'assets/default_user/female_user.jpg';
                      }
                    }

                    if (_formKey.currentState!.validate()) {
                      final userId = await storeUserData(
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        email: _emailController.text.trim(),
                        occupation: _occupationController.text.trim(),
                        sex: _selectedSex ?? '',
                        pin: hashPin(_pinController.text.trim()),
                        photoPath: finalPhotoPath,
                      );

                      await insertWelcomeNotification(userId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration submitted!'),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },

                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
