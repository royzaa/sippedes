import '../services/shared_preferences.dart';

class Profile {
  final String name, address, gender, nik, ttgl;

  Profile(
      {required this.address,
      required this.gender,
      required this.name,
      required this.nik,
      required this.ttgl});
}

Profile userProfile = Profile(
    address: 'Toyareka RT 02/10',
    gender: 'Laki-laki',
    name: 'Budi Hatmawan',
    nik: DataSharedPreferences.getNIK(),
    ttgl: 'Bandung, 10 Maret 1995');
