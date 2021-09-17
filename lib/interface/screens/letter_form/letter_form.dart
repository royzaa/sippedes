import 'package:flutter/material.dart';

import './widgets/ajukan_baru.dart';
import './widgets/riwayat.dart';

class LetterForm extends StatelessWidget {
  const LetterForm({Key? key, required this.letterName}) : super(key: key);
  final String letterName;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pengajuan $letterName',
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Ajukan baru',
              ),
              Tab(
                text: 'Riwayat',
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [
          AjukanBaru(),
          Riwayat(),
        ]),
      ),
    );
  }
}
