import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';

/// Identity returned by a successful Google sign-in.
class GoogleAuthResult {
  final String email;
  final String? name;
  final String? photoUrl;

  const GoogleAuthResult({required this.email, this.name, this.photoUrl});
}

/// Thin wrapper around Google Sign-In and Firebase Authentication. Never throws: a
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
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        final userCredential = await FirebaseAuth.instance.signInWithPopup(
          provider,
        );
        final user = userCredential.user;
        if (user == null || user.email == null) return null;
        return GoogleAuthResult(
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
        );
      }

      final account = await _google.signIn();
      if (account == null) return null; // user closed the popup

      final authentication = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) return null;

      return GoogleAuthResult(
        email: user.email ?? account.email,
        name: user.displayName ?? account.displayName,
        photoUrl: user.photoURL ?? account.photoUrl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Best-effort sign-out; safe to fire-and-forget on any platform.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _google.signOut();
    } catch (_) {
      // Ignored — logging out of the local session must always succeed.
    }
  }
}

/// Signs in with the GitHub provider configured in Firebase Authentication.
class GitHubAuthService {
  GitHubAuthService._();

  static Future<GoogleAuthResult?> signIn() async {
    try {
      final provider = GithubAuthProvider();
      final credential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);
      final user = credential.user;
      if (user == null || user.email == null) return null;
      return GoogleAuthResult(
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } catch (_) {
      return null;
    }
  }
}
