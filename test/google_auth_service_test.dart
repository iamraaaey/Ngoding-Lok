import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/session/google_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleAuthService', () {
    // The test VM has no platform plugin registered, which is exactly the
    // "unsupported platform" case the service must absorb: the contract is
    // that sign-in NEVER throws — it resolves to null so the auth screen
    // falls back to the simulated email login.
    test('signIn resolves to null instead of throwing when the plugin is unavailable', () async {
      final result = await GoogleAuthService.signIn();
      expect(result, isNull);
    });

    test('signOut completes without throwing when the plugin is unavailable', () async {
      await expectLater(GoogleAuthService.signOut(), completes);
    });
  });
}
