import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/shared_preferences.dart';
import '../login_screen.dart';
import './widgets/biodata_list.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Flexible(
          child: Container(
            height: size.height * 0.5,
            width: size.width,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Profil Anda',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Icon(
                      Icons.person,
                      size: size.height * 0.22,
                      color: Colors.black,
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: const Text(
                                  'Jika keluar, maka anda akan menginput NIK lagi agar bisa masuk.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    DataSharedPreferences.setNIK('');
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('OK, paham!'),
                                )
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.logout_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const Text(
                        'Keluar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: SizedBox(
            height: size.height * 0.5 - MediaQuery.of(context).padding.top,
            child: const Center(
              child: BiodataList(),
            ),
          ),
        ),
      ],
    );
  }
}
