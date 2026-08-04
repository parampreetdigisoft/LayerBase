import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  SharedPrefsService._privateConstructor();

  static final SharedPrefsService instance =
      SharedPrefsService._privateConstructor();

  factory SharedPrefsService() {
    return instance;
  }

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs!.getString(key) ?? '';
  }

  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  Future<void>? setBool(String key, bool value) {
    return _prefs!.setBool(key, value);
  }

  Future<void> clear() async {
    await _prefs!.clear();
  }
}
