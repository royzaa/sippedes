import 'package:flutter/material.dart';

import './widgets/ajukan_baru.dart';
import './widgets/riwayat.dart';

class LetterForm extends StatelessWidget {
  const LetterForm({Key? key, required this.letterName, required this.appColor})
      : super(key: key);
  final String letterName;
  final Color appColor;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appColor,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Pengajuan $letterName',
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            indicatorPadding: EdgeInsets.only(bottom: 8),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.black,
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
        body: TabBarView(children: [
          AjukanBaru(
            color: appColor,
          ),
          const Riwayat(),
        ]),
      ),
    );
  }
}
