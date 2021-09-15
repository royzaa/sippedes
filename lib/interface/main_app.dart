import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './screens/letter_screen/letter_screen.dart';
import './screens/profile_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late List<Widget> _pages;

  int _selectedIndex = 0;

  void selectedPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _pages = [
      const LetterScreen(),
      const ProfileScreen(),
    ];
    super.initState();
  }

  DateTime? lastPressed;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        const maxDuration = Duration(seconds: 2);
        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;
        if (isWarning) {
          HapticFeedback.mediumImpact();
          lastPressed = DateTime.now();

          Fluttertoast.showToast(
              msg: 'Klik 2x untuk menutup aplikasi',
              fontSize: 18,
              toastLength: Toast.LENGTH_LONG);
          Timer(maxDuration, () => Fluttertoast.cancel());
          return false;
        } else {
          SystemNavigator.pop();

          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          clipBehavior: Clip.antiAlias,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: selectedPage,
            iconSize: 28,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            unselectedLabelStyle:
                const TextStyle(color: Colors.black, fontSize: 14),
            selectedLabelStyle: const TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                label: 'Pengajuan surat',
                tooltip: 'Pengajuan surat',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: 'Profil',
                tooltip: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
