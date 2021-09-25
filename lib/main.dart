import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './services/shared_preferences.dart';
import './interface/screens/auth_screen/login_screen.dart';
import './interface/main_app.dart';
import './services/firestore_services.dart';
import './services/local_notification_services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationServices.initialize();
  await DataSharedPreferences.init();
  await Firebase.initializeApp().then((value) => FirestoreServices.init());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('message from cloud:' + message.notification!.body.toString());
      LocalNotificationServices.display(message);
    });

    return MaterialApp(
      title: 'SIPPeDes',
      theme: ThemeData(
          primaryColor: const Color.fromRGBO(67, 86, 255, 1),
          fontFamily: GoogleFonts.poppins().fontFamily,
          primaryTextTheme: const TextTheme(
            subtitle1: TextStyle(color: Colors.black, fontSize: 16),
          )),
      home: const MainApp(),
    );
  }
}
