import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _darkModeKey = 'app_dark_mode';
  static const String _soundEnabledKey = 'app_sound_enabled';

  static Future<bool?> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey);
  }

  static Future<bool?> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey);
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<void> saveSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }
}
