import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name, address, gender, nik, ttgl;

  Profile(
      {required this.address,
      required this.gender,
      required this.name,
      required this.nik,
      required this.ttgl});

  factory Profile.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> json) {
    final jsonData = json.data();
    return Profile(
        address: jsonData['Alamat'],
        gender: jsonData['Jenis Kelamin'],
        name: jsonData['Nama'],
        nik: jsonData['NIK'].toString(),
        ttgl: jsonData['Ttgl']);
  }
}
