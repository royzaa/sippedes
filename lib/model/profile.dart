import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name, address, gender, nik, ttgl;

  Profile(
      {required this.address,
      required this.gender,
      required this.name,
      required this.nik,
      required this.ttgl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        address: json['Alamat'],
        gender: json['Jenis Kelamin'],
        name: json['Nama'],
        nik: json['NIK'].toString(),
        ttgl: json['Ttgl']);
  }
}
