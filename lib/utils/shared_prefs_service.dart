import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Private constructor
  SharedPrefsService._privateConstructor();

  // Static instance variable
  static final SharedPrefsService _instance =
      SharedPrefsService._privateConstructor();

  // Factory constructor to return the same instance
  factory SharedPrefsService() {
    return _instance;
  }

  // SharedPreferences instance (late and nullable, initialized asynchronously)
  SharedPreferences? _prefs;

  // Asynchronous method to initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
