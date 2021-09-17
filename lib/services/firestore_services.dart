import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/profile.dart';
import './shared_preferences.dart';

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

  static Future changeProfileField(String registredNIK, field, value) async {
    await _firestore
        .collection('civil')
        .doc(registredNIK)
        .update({field: value});
  }
}
