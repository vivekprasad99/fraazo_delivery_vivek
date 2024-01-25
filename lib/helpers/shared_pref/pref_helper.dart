import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static PrefHelper? _prefHelper;
  static late SharedPreferences _preferences;

  static Future<PrefHelper?> getInstance() async {
    if (_prefHelper == null) {
      final prefHelperInitiated = PrefHelper._();
      _preferences = await SharedPreferences.getInstance();
      _prefHelper = prefHelperInitiated;
    }
    return _prefHelper;
  }

  PrefHelper._();

  static Future<bool> setValue(String key, dynamic value) {
    if (value == null) {
      return Future.value(false);
    }
    if (value is String) {
      return _preferences.setString(key, value);
    } else if (value is int) {
      return _preferences.setInt(key, value);
    } else if (value is double) {
      return _preferences.setDouble(key, value);
    } else if (value is bool) {
      return _preferences.setBool(key, value);
    }
    throw "PrefHelper: setValue() - Not implemented yet";
  }

  static String? getString(String key) {
    return _preferences.getString(key);
  }

  static int? getInt(String key) {
    return _preferences.getInt(key) ?? 0;
  }

  static double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  static bool getBool(String key) {
    return _preferences.getBool(key) ?? false;
  }

  static bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  static Future reload() {
    return _preferences.reload();
  }

  static Future<bool> removeValue(String key) {
    return _preferences.remove(key);
  }

  static Future clearAll() {
    return _preferences.clear();
  }
}
