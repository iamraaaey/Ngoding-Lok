import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class SessionPersistence {
  static const String _legacySessionKey = 'user_session';

  static String _sessionKeyFor(String? accountId) {
    final normalized = accountId?.trim();
    if (normalized == null || normalized.isEmpty) return _legacySessionKey;
    return '$_legacySessionKey.$normalized';
  }

  /// Saves the user session to local storage.
  ///
  /// Authenticated callers must pass [accountId] so a cached profile from one
  /// account is never merged into another account on a shared browser.
  static Future<void> saveSession(
    UserSession session, {
    String? accountId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(session.toJson());
      await prefs.setString(_sessionKeyFor(accountId), jsonStr);
    } catch (_) {
      // ignore
    }
  }

  /// Loads the persisted user session, if it exists.
  static Future<UserSession?> loadSession({String? accountId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_sessionKeyFor(accountId));
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
  static Future<void> clearSession({String? accountId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKeyFor(accountId));
    } catch (_) {
      // ignore
    }
  }
}
