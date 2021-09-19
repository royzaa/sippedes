import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sippedes/services/firestore_services.dart';

import './widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirestoreServices.historySnapshot(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List listNotification = snapshot.data!.docs;

            if (listNotification.isEmpty) {
              return const Center(
                child: Text('Belum terdapat update notifikasi'),
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              reverse: true,
              separatorBuilder: (_, __) => const Divider(),
              itemCount: listNotification.length,
              itemBuilder: (context, index) {
                return NotificationItem(
                  body:
                      'Pengajuan surat anda untuk ${listNotification[index]['letterName']} berstatus sudah ${listNotification[index]['progressStatus']}',
                  date: listNotification[index]['submissionDate'],
                  readStatus: listNotification[index]['readStatus'],
                  title: listNotification[index]['letterName'],
                  letterId: listNotification[index]['letterId'],
                );
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
