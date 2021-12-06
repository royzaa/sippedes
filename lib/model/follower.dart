import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  final String name, gender, age, education, noKTP, status;

  Follower({
    required this.name,
    required this.gender,
    required this.age,
    required this.education,
    required this.noKTP,
    required this.status,
  });

  factory Follower.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> json) {
    Map<String, dynamic> data = json.data();
    return Follower(
      name: data['Nama'],
      age: data['Umur'].toString(),
      education: data['Pendidikan'],
      gender: data['Jenis Kelamin'],
      noKTP: data['NIK'].toString(),
      status: data['Status Perkawinan'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Follower &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          noKTP == other.noKTP &&
          education == other.education &&
          gender == other.gender;

  @override
  int get hashCode =>
      name.hashCode ^
      age.hashCode ^
      education.hashCode ^
      gender.hashCode ^
      noKTP.hashCode;
}
