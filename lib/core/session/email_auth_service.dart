import 'package:firebase_auth/firebase_auth.dart';

import 'google_auth_service.dart' show GoogleAuthResult;

/// Firebase-backed email authentication operations used by the auth screens.
///
/// [signIn] and [signUp] return a [GoogleAuthResult] (the shared identity type)
/// on success, throw an [EmailAuthException] with a user-facing message on a
/// real Firebase error (wrong password, email already in use, …), and return
/// `null` when Firebase itself is unavailable — an unsupported platform or the
/// plugin-less test VM — so the caller can fall back to the simulated session,
/// matching the soft-failure contract of [GoogleAuthService].
class EmailAuthService {
  EmailAuthService._();

  /// Creates a Firebase email/password account and returns the new identity.
  static Future<GoogleAuthResult?> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      final displayName = name?.trim();
      if (user != null && displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      return GoogleAuthResult(
        email: user?.email ?? email,
        name: (displayName != null && displayName.isNotEmpty)
            ? displayName
            : user?.displayName,
        photoUrl: user?.photoURL,
      );
    } on FirebaseAuthException catch (error) {
      throw EmailAuthException(_signUpMessage(error.code), code: error.code);
    } catch (_) {
      // Firebase unavailable (unsupported platform / plugin-less test VM):
      // let the caller fall back to the simulated session.
      return null;
    }
  }

  /// Signs in with an existing Firebase email/password account.
  static Future<GoogleAuthResult?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      return GoogleAuthResult(
        email: user?.email ?? email,
        name: user?.displayName,
        photoUrl: user?.photoURL,
      );
    } on FirebaseAuthException catch (error) {
      throw EmailAuthException(_signInMessage(error.code), code: error.code);
    } catch (_) {
      return null;
    }
  }

  /// Sends Firebase's password-reset email. The Firebase console controls the
  /// sender, template, and reset action link.
  static Future<void> sendPasswordResetLink(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      // Do not disclose whether an email is registered. Firebase projects
      // with email-enumeration protection may already return this behavior;
      // keeping it here also protects projects using the older response.
      if (error.code == 'user-not-found') return;
      throw PasswordResetException(_messageFor(error.code), code: error.code);
    } catch (_) {
      throw const PasswordResetException(
        'Authentication is unavailable right now. Check your connection and try again.',
      );
    }
  }

  static String _signUpMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email already has an account. Try signing in instead.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled for this app yet.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes, then try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'We could not create your account. Try again in a moment.';
    }
  }

  static String _signInMessage(String code) {
    switch (code) {
      // Modern Firebase with email-enumeration protection returns
      // 'invalid-credential' for both a wrong password and an unknown email.
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes, then try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this app yet.';
      default:
        return 'We could not sign you in. Try again in a moment.';
    }
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this app yet.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes, then try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'We could not send the reset email. Try again in a moment.';
    }
  }
}

/// User-facing failure from a Firebase email sign-in or sign-up operation.
class EmailAuthException implements Exception {
  final String message;
  final String? code;

  const EmailAuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// User-facing failure from a Firebase password-reset operation.
class PasswordResetException implements Exception {
  final String message;
  final String? code;

  const PasswordResetException(this.message, {this.code});

  @override
  String toString() => message;
}
