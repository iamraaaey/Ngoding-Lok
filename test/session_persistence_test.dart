import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngecode_juh/core/session/user_session.dart';
import 'package:ngecode_juh/core/session/session_persistence.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserSession Serialization', () {
    test('toJson and fromJson correctly serialize and deserialize', () {
      const session = UserSession(
        email: 'test@unimas.my',
        name: 'Test Coder',
        xp: 150,
        completedModuleIds: ['m1', 'm2'],
        streak: 5,
        moduleScores: {'m1': 100, 'm2': 85},
        streakFreezes: 2,
      );

      final json = session.toJson();
      final decoded = UserSession.fromJson(json);

      expect(decoded.email, 'test@unimas.my');
      expect(decoded.name, 'Test Coder');
      expect(decoded.xp, 150);
      expect(decoded.completedModuleIds, ['m1', 'm2']);
      expect(decoded.streak, 5);
      expect(decoded.moduleScores, {'m1': 100, 'm2': 85});
      expect(decoded.streakFreezes, 2);
    });
  });

  group('SessionPersistence', () {
    test('saveSession, loadSession, and clearSession work correctly', () async {
      const session = UserSession(
        email: 'saver@unimas.my',
        name: 'Saver Coder',
        xp: 400,
        completedModuleIds: ['m1'],
        streak: 10,
        moduleScores: {'m1': 95},
        streakFreezes: 1,
      );

      // Initially null
      final initial = await SessionPersistence.loadSession();
      expect(initial, isNull);

      // Save
      await SessionPersistence.saveSession(session);

      // Load
      final loaded = await SessionPersistence.loadSession();
      expect(loaded, isNotNull);
      expect(loaded!.email, 'saver@unimas.my');
      expect(loaded.xp, 400);

      // Clear
      await SessionPersistence.clearSession();
      final cleared = await SessionPersistence.loadSession();
      expect(cleared, isNull);
    });
  });
}
