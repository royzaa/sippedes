import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/tab/ajukan_baru.dart';
import './widgets/tab/riwayat.dart';
import '../../../model/notification.dart';
import '../../../services/firestore_services.dart';

class LetterForm extends StatelessWidget {
  const LetterForm({
    Key? key,
    this.letterName,
    this.appColor,
    this.tabIndex = 0,
  }) : super(key: key);
  final String? letterName;
  final Color? appColor;
  final int tabIndex;
  static const routeToAjukanBaru = 'ajukan-baru';
  static const routeToRiwayat = 'riwayat';
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: tabIndex,
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
            letterName: letterName ?? '',
            color: appColor!,
          ),
          StreamProvider<List<NotificationModel>>(
            initialData: [
              NotificationModel(
                title: 'Belum ada data',
                body: 'Belum ada data',
                date: 'Belum ada data',
                readStatus: 'Belum ada daya',
              ),
            ],
            create: (context) => FirestoreServices.listOfHistorySnapshot(),
            child: const Riwayat(),
          ),
        ]),
      ),
    );
  }
}
