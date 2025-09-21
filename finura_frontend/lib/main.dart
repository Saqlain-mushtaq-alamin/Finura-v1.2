import 'package:finura_frontend/services/local_database/local_database_helper.dart';
import 'package:finura_frontend/services/server%20connection/sync__service.dart';
import 'package:finura_frontend/views/loninPage/login.dart';
import 'package:flutter/material.dart';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'finura_local_db.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FinuraLocalDbHelper().insertNotification(message.data);
}
 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call the resetDatabase method
  //await FinuraLocalDbHelper().resetDatabase();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());

  // Start sync after UI is shown
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SyncService.syncAll();
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finora the budgetbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      navigatorKey: FinuraLocalDbHelper.navigatorKey,

      //debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
