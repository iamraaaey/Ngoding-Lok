import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_auth_config.dart';

/// Identity returned by a successful social sign-in.
class GoogleAuthResult {
  final String email;
  final String? name;
  final String? photoUrl;

  const GoogleAuthResult({required this.email, this.name, this.photoUrl});
}

/// A real, reportable social sign-in failure — as opposed to the user simply
/// closing the popup (which resolves to `null`). Carries a user-facing
/// [message] and the underlying Firebase [code] so the screen can show the
/// actual reason instead of a catch-all "cancelled or unavailable".
class SocialAuthException implements Exception {
  final String message;
  final String? code;

  const SocialAuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Popup/redirect codes that mean "the user backed out" — never an error worth
/// surfacing to the player.
bool _isCancellation(String code) {
  switch (code) {
    case 'popup-closed-by-user':
    case 'cancelled-popup-request':
    case 'user-cancelled':
    case 'web-context-cancelled':
    case 'user-cancelled-login':
      return true;
    default:
      return false;
  }
}

String _socialAuthMessage(String code) {
  switch (code) {
    case 'account-exists-with-different-credential':
      return 'That email is already registered with a different sign-in method. '
          'Use that method, or sign in with email & password.';
    case 'popup-blocked':
      return 'Your browser blocked the sign-in popup. Allow pop-ups for this '
          'site, then try again.';
    case 'unauthorized-domain':
      return 'This site is not authorized for social sign-in yet.';
    case 'operation-not-allowed':
      return 'This sign-in provider is not enabled for the app yet.';
    case 'provider-already-linked':
      return 'This GitHub account is already linked.';
    case 'credential-already-in-use':
      return 'That GitHub account is already linked to a different player account.';
    case 'email-already-in-use':
      return 'That GitHub email is already linked to a different player account.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'web-storage-unsupported':
      return 'Your browser is blocking the storage sign-in needs (third-party '
          'cookies). Enable them for this site, or use email sign-in.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a few minutes, then try again.';
    default:
      return 'Sign-in failed ($code). Please try again, or use email sign-in.';
  }
}

/// Thin wrapper around Google Sign-In and Firebase Authentication.
///
/// [signIn] returns the identity on success, `null` when the user cancels or
/// the platform has no plugin (unsupported desktop / the plugin-less test VM —
/// the simulated-fallback contract the auth screens rely on), and throws a
/// [SocialAuthException] with an actionable message on a genuine failure.
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
    } on FirebaseAuthException catch (error) {
      if (_isCancellation(error.code)) return null;
      throw SocialAuthException(
        _socialAuthMessage(error.code),
        code: error.code,
      );
    } catch (_) {
      // Unsupported platform / plugin-less test VM: fall back silently so the
      // auth screen can offer the email option instead.
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

  static const providerId = 'github.com';

  /// Whether the current account already has GitHub connected. This is safe to
  /// call during widget construction and simply returns false in test or
  /// unsupported environments.
  static bool get isLinked {
    try {
      return FirebaseAuth.instance.currentUser?.providerData.any(
            (profile) => profile.providerId == providerId,
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<GoogleAuthResult?> signIn() async {
    try {
      final provider = _provider();
      final credential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);
      try {
        return _identityFrom(credential.user);
      } on SocialAuthException catch (error) {
        // A GitHub identity without an email cannot create a usable player
        // profile. Leave the app signed out instead of stranding the user in
        // a half-completed sign-in state.
        if (error.code == 'missing-email') {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (_) {
            // Preserve the useful missing-email message even if cleanup fails.
          }
        }
        rethrow;
      }
    } on FirebaseAuthException catch (error) {
      if (_isCancellation(error.code)) return null;
      throw SocialAuthException(
        _socialAuthMessage(error.code),
        code: error.code,
      );
    } on SocialAuthException {
      rethrow;
    } catch (_) {
      throw const SocialAuthException(
        'GitHub sign-in could not start on this device. Please try again.',
      );
    }
  }

  /// Connects GitHub to the account that is already signed in. Web uses the
  /// provider popup flow; native platforms use the platform provider flow.
  static Future<void> linkCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const SocialAuthException(
          'Sign in to your player account before connecting GitHub.',
        );
      }
      if (isLinked) return;

      final provider = _provider();
      if (kIsWeb) {
        await user.linkWithPopup(provider);
      } else {
        await user.linkWithProvider(provider);
      }
      await FirebaseAuth.instance.currentUser?.reload();
    } on FirebaseAuthException catch (error) {
      if (_isCancellation(error.code)) return;
      throw SocialAuthException(
        _socialAuthMessage(error.code),
        code: error.code,
      );
    } on SocialAuthException {
      rethrow;
    } catch (_) {
      throw const SocialAuthException(
        'GitHub could not be connected on this device. Please try again.',
      );
    }
  }

  static GithubAuthProvider _provider() => GithubAuthProvider()
    ..addScope('user:email');

  static GoogleAuthResult _identityFrom(User? user) {
    final email = user?.email?.trim();
    if (user == null || email == null || email.isEmpty) {
      throw const SocialAuthException(
        'GitHub did not provide an email address. Add a verified email to your GitHub account, then try again.',
        code: 'missing-email',
      );
    }
    return GoogleAuthResult(
      email: email,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
