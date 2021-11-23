import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import './services/shared_preferences.dart';
import './interface/screens/auth_screen/login_screen.dart';
import './interface/main_app.dart';
import './services/firestore_services.dart';
import './services/local_notification_services.dart';
import './services/auth_services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationServices.initialize();
  await DataSharedPreferences.init();
  await Firebase.initializeApp().then((value) => FirestoreServices.init());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(411, 823),
        builder: () {
          return MaterialApp(
            title: 'SIPPeDes',
            theme: ThemeData(
                primaryColor: const Color.fromRGBO(67, 86, 255, 1),
                fontFamily: GoogleFonts.poppins().fontFamily,
                primaryTextTheme: const TextTheme(
                  subtitle1: TextStyle(color: Colors.black, fontSize: 16),
                )),
            home: const HomeController(),
          );
        });
  }
}

class HomeController extends StatelessWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: auth.authStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const LoginScreen();
          } else {
            return const MainApp();
          }
        } else {
          return Center(
            child: SizedBox(
              width: size.width * 0.4,
              child: LinearProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
      },
    );
  }
}
