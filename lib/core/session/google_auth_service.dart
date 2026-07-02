import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';

/// Identity returned by a successful Google sign-in.
class GoogleAuthResult {
  final String email;
  final String? name;
  final String? photoUrl;

  const GoogleAuthResult({required this.email, this.name, this.photoUrl});
}

/// Thin wrapper around the `google_sign_in` plugin. Never throws: a
/// dismissed popup, an unconfigured origin, or an unsupported platform
/// (e.g. Windows desktop, or the plugin-less test VM) all resolve to
/// `null` so the auth screen can fall back to the simulated email login —
/// the same soft-failure contract as [HintService].
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _google = GoogleSignIn(
    // The plugin reads the client ID from platform config on mobile; on web
    // it must be supplied explicitly.
    clientId: kIsWeb ? googleWebClientId : null,
    scopes: const ['email'],
  );

  static Future<GoogleAuthResult?> signIn() async {
    try {
      final account = await _google.signIn();
      if (account == null) return null; // user closed the popup
      return GoogleAuthResult(
        email: account.email,
        name: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Best-effort sign-out; safe to fire-and-forget on any platform.
  static Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {
      // Ignored — logging out of the local session must always succeed.
    }
  }
}
