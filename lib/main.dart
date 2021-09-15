import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './services/shared_preferences.dart';
import './interface/screens/login_screen.dart';
import './interface/main_app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataSharedPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPPeDes',
      theme: ThemeData(
          primaryColor: const Color.fromRGBO(67, 86, 255, 1),
          fontFamily: GoogleFonts.poppins().fontFamily,
          primaryTextTheme: const TextTheme(
            subtitle1: TextStyle(color: Colors.black, fontSize: 16),
          )),
      home: DataSharedPreferences.getNIK() == ''
          ? const LoginScreen()
          : const MainApp(),
    );
  }
}
