import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/user_session.dart';

void main() {
  group('UserSession', () {
    test('displayName derives from the email local part', () {
      const user = UserSession(email: 'student@school.edu');
      expect(user.displayName, 'student');
    });

    test('displayName prefers the Google profile name when present', () {
      const user = UserSession(
        email: 'student@school.edu',
        name: 'Raynold Kabai',
      );
      expect(user.displayName, 'Raynold Kabai');
    });

    test('displayName falls back to email when the profile name is blank', () {
      const user = UserSession(email: 'student@school.edu', name: '  ');
      expect(user.displayName, 'student');
    });

    test('withModuleCompleted preserves the Google identity fields', () {
      const user = UserSession(
        email: 'a@b.com',
        name: 'Ray',
        photoUrl: 'https://example.com/p.png',
      );
      final updated = user.withModuleCompleted('m1', 100);

      expect(updated.name, 'Ray');
      expect(updated.photoUrl, 'https://example.com/p.png');
    });

    test('withModuleCompleted adds XP and records the module id', () {
      const user = UserSession(email: 'a@b.com', xp: 10);
      final updated = user.withModuleCompleted('m1', 90);

      expect(updated.xp, 100);
      expect(updated.completedModuleIds, ['m1']);
    });

    test(
      'withModuleCompleted does not duplicate an already-completed module id',
      () {
        const user = UserSession(
          email: 'a@b.com',
          xp: 10,
          completedModuleIds: ['m1'],
        );
        final updated = user.withModuleCompleted('m1', 50);

        expect(updated.xp, 60);
        expect(updated.completedModuleIds, ['m1']);
      },
    );

    test('withActivity increments once per consecutive calendar day', () {
      final first = const UserSession(
        email: 'a@b.com',
      ).withActivity(now: DateTime(2026, 7, 18, 9));
      final sameDay = first.withActivity(now: DateTime(2026, 7, 18, 22));
      final nextDay = sameDay.withActivity(now: DateTime(2026, 7, 19, 8));

      expect(first.streak, 1);
      expect(sameDay.streak, 1);
      expect(nextDay.streak, 2);
      expect(nextDay.bestStreak, 2);
    });

    test('withActivity resets after a missed day', () {
      final first = const UserSession(
        email: 'a@b.com',
      ).withActivity(now: DateTime(2026, 7, 18));
      final second = first.withActivity(now: DateTime(2026, 7, 19));
      final afterMiss = second.withActivity(now: DateTime(2026, 7, 21));

      expect(second.streak, 2);
      expect(afterMiss.streak, 1);
      expect(afterMiss.bestStreak, 2);
    });
  });
}
