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

    test('keeps cached sessions isolated by authenticated account', () async {
      const first = UserSession(email: 'first@example.com', xp: 50);
      const second = UserSession(email: 'second@example.com', xp: 100);

      await SessionPersistence.saveSession(first, accountId: 'first-account');
      await SessionPersistence.saveSession(second, accountId: 'second-account');

      final restoredFirst = await SessionPersistence.loadSession(
        accountId: 'first-account',
      );
      final restoredSecond = await SessionPersistence.loadSession(
        accountId: 'second-account',
      );

      expect(restoredFirst!.email, first.email);
      expect(restoredSecond!.email, second.email);
      await SessionPersistence.clearSession(accountId: 'first-account');
      expect(
        await SessionPersistence.loadSession(accountId: 'first-account'),
        isNull,
      );
      expect(
        (await SessionPersistence.loadSession(
          accountId: 'second-account',
        ))!.email,
        second.email,
      );
    });
  });
}
