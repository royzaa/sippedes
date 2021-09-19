import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/profile.dart';
import './shared_preferences.dart';
import '../model/notification.dart';

enum LetterType {
  ktp,
  skck,
  sktm,
  suratKelahiran,
  suratPindah,
  suratKehilangan,
  suratJalan,
  suratKematian,
  keteranganUsaha,
  suratDomisili,
}

class FirestoreServices {
  static late FirebaseFirestore _firestore;

  static init() {
    _firestore = FirebaseFirestore.instance;
  }

  static Future<bool> validateUser(String registredNIK) async {
    bool status = false;
    try {
      final result =
          await _firestore.collection('civil').doc(registredNIK).get();
      if (result.exists) {
        status = true;
      } else {
        status = false;
      }
    } on FirebaseException catch (e) {
      debugPrint('Error when validating NIK: ' + e.toString());
    }
    return status;
  }

  static Future<Profile> getUserProfile() async {
    final jsonData = await _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .get();

    final user = Profile.fromJson(jsonData.data()!);
    return user;
  }

  static Future changeProfileField(
      String registredNIK, String field, String value) async {
    await _firestore
        .collection('civil')
        .doc(registredNIK)
        .update({field: value});
  }

  static Future createSuratPindah(
      {required String address,
      required String ktpUrl,
      required int migratedNIK,
      required String letterId}) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await _firestore.collection('surat pindah').doc(letterId).set({
      'address': address,
      'ktpUrl': ktpUrl,
      'migratedNIK': migratedNIK,
      'submissionDate': submissionDate,
      'letterId': letterId,
    });
  }

  static Future writeTrace({
    required LetterType letterType,
    required String registredNIK,
    required String letterId,
  }) async {
    String? letterName;
    switch (letterType) {
      case LetterType.ktp:
        letterName = 'KTP';
        break;
      case LetterType.sktm:
        letterName = 'SKTM';
        break;
      case LetterType.skck:
        letterName = 'SKCK';
        break;
      case LetterType.keteranganUsaha:
        letterName = 'Keterangan Usaha';
        break;
      case LetterType.suratDomisili:
        letterName = 'Surat Domisili';
        break;
      case LetterType.suratJalan:
        letterName = 'Surat Jalan';
        break;
      case LetterType.suratKehilangan:
        letterName = 'Surat Kehilangan';
        break;
      case LetterType.suratKelahiran:
        letterName = 'Surat Kelahiran';
        break;
      case LetterType.suratKematian:
        letterName = 'Surat Kematian';
        break;
      case LetterType.suratPindah:
        letterName = 'Surat Pindah';
        break;
      default:
    }

    String month = '';
    final int monthInNumber = DateTime.now().month;
    final int day = DateTime.now().day;
    final int year = DateTime.now().year;

    switch (monthInNumber) {
      case 1:
        month = 'Januari';
        break;
      case 2:
        month = 'Februari';
        break;
      case 3:
        month = 'Maret';
        break;
      case 4:
        month = 'April';
        break;
      case 5:
        month = 'Mei';
        break;
      case 6:
        month = 'Juni';
        break;
      case 7:
        month = 'Juli';
        break;
      case 8:
        month = 'Agustus';
        break;
      case 9:
        month = 'September';
        break;
      case 10:
        month = 'Oktober';
        break;
      case 11:
        month = 'November';
        break;
      case 12:
        month = 'Desember';
        break;
      default:
    }
    final String submissionDate = '$day $month $year';

    await _firestore
        .collection('civil')
        .doc(registredNIK)
        .collection('history')
        .doc(letterId)
        .set({
      'progressStatus': 'Terkirim',
      'readStatus': 'Belum dibaca',
      'letterName': letterName,
      'lastChanged': DateTime.now(),
      'submissionDate': submissionDate,
      'letterId': letterId,
    });
  }

  static Future changeLetterStatus({
    String? progressStatus,
    String? readStatus,
    required String registredNIK,
    required String letterId,
  }) async {
    if (progressStatus != null) {
      await _firestore
          .collection('civil')
          .doc(registredNIK)
          .collection('history')
          .doc(letterId)
          .update({
        'progressStatus': 'Selesai',
        'lastChanged': DateTime.now(),
      });
    }
    if (readStatus != null) {
      await _firestore
          .collection('civil')
          .doc(registredNIK)
          .collection('history')
          .doc(letterId)
          .update({'readStatus': readStatus});
    }
  }

  static Stream<QuerySnapshot> historySnapshot() {
    return _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .collection('history')
        .snapshots();
  }

  static Stream<int> numOfNotificationSnapshot() {
    return _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .collection('history')
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .where((data) => !(data.data()['readStatus'] == 'read'))
              .map(
                (data) => NotificationModel(
                  title: data['letterName'],
                  body:
                      'Pengajuan surat anda untuk ${data['letterName']} berstatus sudah ${data['progressStatus']}',
                  date: data['lastChanged'].toString(),
                  readStatus: data['readStatus'],
                ),
              )
              .toList()
              .length,
        );
  }

  static Stream<List<NotificationModel>> listOfHistorySnapshot() {
    return _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .collection('history')
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .where((data) => !(data.data()['readStatus'] == 'read'))
              .map(
                (data) => NotificationModel(
                  title: data['letterName'],
                  body:
                      'Pengajuan surat anda untuk ${data['letterName']} berstatus sudah ${data['progressStatus']}',
                  date: data['submissionDate'].toString(),
                  readStatus: data['progressStatus'],
                ),
              )
              .toList(),
        );
  }
  // static Future<List<QueryDocumentSnapshot>> getAllTrace({
  //   required String registredNIK,
  // }) async {
  //   final QuerySnapshot snapshot = await _firestore
  //       .collection('civil')
  //       .doc(registredNIK)
  //       .collection('history')
  //       .get();

  //   final jsonQueryData = snapshot.docs;
  //   return jsonQueryData;
  // }
}
