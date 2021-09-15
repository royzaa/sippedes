import 'package:shared_preferences/shared_preferences.dart';

class DataSharedPreferences {
  static late SharedPreferences _preferences;

  static const _keyNIK = 'NIK';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setNIK(String title) async =>
      await _preferences.setString(_keyNIK, title);

  static String getNIK() => _preferences.getString(_keyNIK) == null
      ? ''
      : _preferences.getString(_keyNIK).toString();
}
