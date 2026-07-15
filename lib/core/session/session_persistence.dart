import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class SessionPersistence {
  static const String _sessionKey = 'user_session';

  /// Saves the user session to local storage.
  static Future<void> saveSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(session.toJson());
      await prefs.setString(_sessionKey, jsonStr);
    } catch (_) {
      // ignore
    }
  }

  /// Loads the persisted user session, if it exists.
  static Future<UserSession?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_sessionKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return UserSession.fromJson(decoded);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  /// Clears the user session from local storage (on logout).
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {
      // ignore
    }
  }
}
