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

  /// validate nik with data in firebase
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

  /// store user id in nik doc in civil collection
  static Future<bool> storeUserUid(String uid, String valitadedNIK) async {
    bool status = false;
    try {
      await _firestore
          .collection('civil')
          .doc(valitadedNIK)
          .update({'uid': uid}).then((value) => status = true);
    } on FirebaseException catch (e) {
      debugPrint('Error when store user uid: ' + e.toString());
    }
    return status;
  }

  // get and create profile that match with uid from firebase through Profile fromJson
  static Future<Profile> getUserProfile(String uid) async {
    // makes firestore offline
    _firestore.settings.persistenceEnabled;
    final jsonData = await _firestore
        .collection('civil')
        .where(
          'uid',
          isEqualTo: uid,
        )
        .get();

    final user = Profile.fromJson(
        jsonData.docs.firstWhere((doc) => doc.data()['uid'] == uid));
    return user;
  }

  /// stream user letter history
  static Stream<QuerySnapshot> historySnapshot() {
    return _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .collection('history')
        .snapshots();
  }

  /// stream number of [not_read] readstatus collection history
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

  /// stream list of notification, create from notification model
  static Stream<List<NotificationModel>> listOfHistorySnapshot() {
    return _firestore
        .collection('civil')
        .doc(DataSharedPreferences.getNIK())
        .collection('history')
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
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

  /// Store fcm token to firestore, get inital message, and listen
  static Future<void> getAndSaveToken(String? fcmToken) async {
    try {
      if (fcmToken != null) {
        final tokenDoc = _firestore
            .collection('civil')
            .doc(DataSharedPreferences.getNIK())
            .collection('tokens')
            .doc(fcmToken);

        await tokenDoc.set({
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(),
        }).then(
            (value) => debugPrint('writing fcm token... with token $fcmToken'));
      }
    } on FirebaseException catch (e) {
      debugPrint('error when write fcm token: $e');
    }
  }

  /// search family member with KK
  static Future<Query> searchFamily(int nomerKK) async {
    late Query query;
    try {
      query = _firestore
          .collection('civil')
          .where('KK', isEqualTo: nomerKK.toString());
    } on FirebaseException catch (e) {
      debugPrint('error when search family: $e');
    }
    return query;
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

class FirestoreLetterServices {
  static Future changeProfileField(
      String registredNIK, String field, String value) async {
    await FirestoreServices._firestore
        .collection('civil')
        .doc(registredNIK)
        .update({field: value});
  }

  static Future writeLetterStatus({
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

    await FirestoreServices._firestore
        .collection('civil')
        .doc(registredNIK)
        .collection('history')
        .doc(letterId)
        .set({
      'nik': DataSharedPreferences.getNIK(),
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
      await FirestoreServices._firestore
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
      await FirestoreServices._firestore
          .collection('civil')
          .doc(registredNIK)
          .collection('history')
          .doc(letterId)
          .update({'readStatus': readStatus});
    }
  }

  static Future createSKKematian({
    required String address,
    required String skUrl,
    required String name,
    required String jk,
    required String ages,
    required String day,
    required String date,
    required String place,
    required String hour,
    required String cause,
    required String reporterName,
    required String relationship,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore
        .collection('Surat Kematian')
        .doc(letterId)
        .set({
      'address': address,
      'skUrl': skUrl,
      'name': name,
      'jk': jk,
      'ages': ages,
      'day': day,
      'date': date,
      'place': place,
      'hour': hour,
      'cause': cause,
      'reporterName': reporterName,
      'relationship': relationship,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }

  static Future createSKLahir({
    required String address,
    required String skUrl,
    required String name,
    required String jk,
    required String day,
    required String date,
    required String place,
    required String hour,
    required String father,
    required String mother,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore
        .collection('Surat Kelahiran')
        .doc(letterId)
        .set({
      'address': address,
      'skUrl': skUrl,
      'name': name,
      'jk': jk,
      'day': day,
      'date': date,
      'place': place,
      'hour': hour,
      'father': father,
      'mother': mother,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }

  static Future createSKUsaha({
    required String address,
    required String ktpUrl,
    required String name,
    required String ttgl,
    required String phone,
    required String jenisUsaha,
    required String lamaUsaha,
    required String tempatUsaha,
    required String nik,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore
        .collection('Keterangan Usaha')
        .doc(letterId)
        .set({
      'address': address,
      'ktpUrl': ktpUrl,
      'name': name,
      'ttgl': ttgl,
      'jenisUsaha': jenisUsaha,
      'lamaUsaha': lamaUsaha,
      'tempatUsaha': tempatUsaha,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }

  static Future createSKCK({
    required String address,
    required String ktpUrl,
    required String name,
    required String ttgl,
    required String nationality,
    required String relationshipStatus,
    required String religion,
    required String job,
    required String necessity,
    required String nik,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore.collection('SKCK').doc(letterId).set({
      'address': address,
      'ktpUrl': ktpUrl,
      'name': name,
      'ttgl': ttgl,
      'nationality': nationality,
      'relationshipStatus': relationshipStatus,
      'religion': religion,
      'job': job,
      'necessity': necessity,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }

  static Future createSKTM({
    required String address,
    required String ktpUrl,
    required String kkUrl,
    required String name,
    required String ttgl,
    required String jk,
    required String nationality,
    required String job,
    required String necessity,
    required String childName,
    required String schoolOrUniversity,
    required String gradeOrSemester,
    required String nik,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore.collection('SKTM').doc(letterId).set({
      'address': address,
      'ktpUrl': ktpUrl,
      'kkUrl': kkUrl,
      'name': name,
      'ttgl': ttgl,
      'nationality': nationality,
      'job': job,
      'necessity': necessity,
      'childName': childName,
      'schoolOrUniversity': schoolOrUniversity,
      'gradeOrSemester': gradeOrSemester,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }

  static Future createSuratPindah({
    required String address,
    required String ktpUrl,
    required String kkUrl,
    required String photoUrl,
    required String previousAddress,
    required String name,
    required String ttgl,
    required String jk,
    required String nationality,
    required String relationshipStatus,
    required String job,
    required String education,
    required String father,
    required String mother,
    required String excuse,
    required String migratedNIK,
    required String letterId,
    Map<String, String>? followers,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore
        .collection('Surat Pindah')
        .doc(letterId)
        .set({
      'address': address,
      'ktpUrl': ktpUrl,
      'kkUrl': kkUrl,
      'photoUrl': photoUrl,
      'previousAddress': previousAddress,
      'name': name,
      'ttgl': ttgl,
      'jk': jk,
      'nationality': nationality,
      'relationshipStatus': relationshipStatus,
      'job': job,
      'education': education,
      'father': father,
      'mother': mother,
      'excuse': excuse,
      'migratedNIK': migratedNIK,
      'letterId': letterId,
      'followers': followers,
      'submissionDate': submissionDate,
    });
  }

  static Future createSuratKehilangan({
    required String address,
    required String ktpUrl,
    required String name,
    required String ttgl,
    required String jk,
    required String nationality,
    required String relationshipStatus,
    required String job,
    required String necessity,

    /// what, when, where
    required Map<String, String> lostDescription,
    required String nik,
    required String letterId,
  }) async {
    final String submissionDate =
        '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}';
    await FirestoreServices._firestore
        .collection('Surat Kehilangan')
        .doc(letterId)
        .set({
      'address': address,
      'ktpUrl': ktpUrl,
      'name': name,
      'ttgl': ttgl,
      'jk': jk,
      'nationality': nationality,
      'relationshipStatus': relationshipStatus,
      'job': job,
      'necessity': necessity,
      'lostDescription': lostDescription,
      'letterId': letterId,
      'submissionDate': submissionDate,
    });
  }
}
