import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/user_session.dart';

void main() {
  group('UserSession', () {
    test('displayName derives from the email local part', () {
      const user = UserSession(email: 'student@school.edu');
      expect(user.displayName, 'student');
    });

    test('withModuleCompleted adds XP and records the module id', () {
      const user = UserSession(email: 'a@b.com', xp: 10);
      final updated = user.withModuleCompleted('m1', 90);

      expect(updated.xp, 100);
      expect(updated.completedModuleIds, ['m1']);
    });

    test('withModuleCompleted does not duplicate an already-completed module id', () {
      const user = UserSession(email: 'a@b.com', xp: 10, completedModuleIds: ['m1']);
      final updated = user.withModuleCompleted('m1', 50);

      expect(updated.xp, 60);
      expect(updated.completedModuleIds, ['m1']);
    });
  });
}
