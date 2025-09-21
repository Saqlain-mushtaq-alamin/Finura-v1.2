import 'dart:convert';
import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/views/HomePage.dart';
import 'package:finura_frontend/views/loninPage/registerPage.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart'; // To use SystemNavigator

class LoginPage extends StatelessWidget {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  LoginPage({super.key});

  // This method is responsible for checking user credentials
  Future<int> _getIdPin(String accountName, String pin) async {
    final db = await FinuraLocalDbHelper().database;

    // Fetch user record by email
    final userQuery = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [accountName],
      limit: 1,
    );

    if (userQuery.isEmpty) {
      ScaffoldMessenger.of(
        FinuraLocalDbHelper.navigatorKey.currentContext!,
      ).showSnackBar(const SnackBar(content: Text('Email not found')));
      return 0;
    }

    final user = userQuery.first;
    final String storedPinHash = user['pin_hash'] as String;
    final String? firstName = user['first_name'] as String?;
    final String? userPhoto = user['user_photo'] as String?;
    final String userId = user['id'] as String;
    print("=======================================>>The user ID is $userId");

    // Hash entered PIN
    final enteredPinHash = sha256.convert(utf8.encode(pin)).toString();

    if (storedPinHash == enteredPinHash) {
      Navigator.push(
        FinuraLocalDbHelper.navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userFirstName: firstName ?? 'Guest',
            userProfilePicUrl: userPhoto ?? '',
            user_Id: userId,
          ),
        ),
      );

      print("User photo is: ");
      print(userPhoto);

      return 1;
    } else {
      ScaffoldMessenger.of(
        FinuraLocalDbHelper.navigatorKey.currentContext!,
      ).showSnackBar(const SnackBar(content: Text('PIN does not match')));
      return 0;
    }
  }

  // This method prevents the back action and closes the app
  Future<bool> _onWillPop() async {
    // Close the app when back button is pressed
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept the back button press
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            color: Colors.green[100], // Color of the screen
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const Text(
                    'Finura',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'increase your financial aura',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(8.0),
                          topEnd: Radius.circular(50.0),
                          bottomStart: Radius.circular(50.0),
                          bottomEnd: Radius.circular(8.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 70),
                            TextField(
                              controller: accountController,
                              decoration: const InputDecoration(
                                labelText: 'Account name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Enter PIN',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Forget PIN?'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('Register Now'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _getIdPin(
                                    accountController.text.trim(),
                                    pinController.text.trim(),
                                  ).then((result) {
                                    if (result == 1) {
                                      // Successfully logged in
                                      ScaffoldMessenger.of(
                                        FinuraLocalDbHelper
                                            .navigatorKey
                                            .currentContext!,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful'),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
