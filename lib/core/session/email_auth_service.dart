import 'dart:async';

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
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
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
      throw const EmailAuthException(
        'Account sign-in is temporarily unavailable. Check your connection and try again.',
      );
    }
  }

  /// Signs in with an existing Firebase email/password account.
  static Future<GoogleAuthResult?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      return GoogleAuthResult(
        email: user?.email ?? email,
        name: user?.displayName,
        photoUrl: user?.photoURL,
      );
    } on FirebaseAuthMultiFactorException catch (error) {
      throw MfaRequiredException(error.resolver);
    } on FirebaseAuthException catch (error) {
      throw EmailAuthException(_signInMessage(error.code), code: error.code);
    } catch (_) {
      throw const EmailAuthException(
        'Account sign-in is temporarily unavailable. Check your connection and try again.',
      );
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

  static FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static User get _user {
    final user = _auth?.currentUser;
    if (user == null) {
      throw const AccountSecurityException(
        'Sign in again before changing account security settings.',
      );
    }
    return user;
  }

  static bool get emailVerified => _auth?.currentUser?.emailVerified ?? false;

  static String? get currentEmail => _auth?.currentUser?.email;

  /// Sends Firebase's address-verification email to the current user.
  static Future<void> sendEmailVerification() async {
    final user = _user;
    await _runAccountAction(() => user.sendEmailVerification());
  }

  /// Refreshes the current Firebase user and returns the latest verification
  /// state. This is needed after the user clicks the email link elsewhere.
  static Future<bool> reloadEmailVerification() async {
    await _runAccountAction(() => _user.reload());
    return emailVerified;
  }

  /// Requests a verified email-address change. Firebase sends the address
  /// change email and applies the new address after the user confirms it.
  static Future<void> requestEmailChange(String newEmail) async {
    final user = _user;
    await _runAccountAction(() => user.verifyBeforeUpdateEmail(newEmail));
  }

  /// Re-authenticates an email/password user before updating the password.
  /// Firebase requires recent credentials for this sensitive operation.
  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _user;
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw const AccountSecurityException(
        'Password changes are available for email/password accounts only.',
      );
    }
    await _runAccountAction(() async {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    });
  }

  /// Starts native phone verification for linking a phone number or enrolling
  /// SMS MFA. On Android, Firebase may complete with an automatically resolved
  /// credential; otherwise the UI receives a verification ID for manual code
  /// entry.
  static Future<PhoneVerificationChallenge> startPhoneVerification({
    String? phoneNumber,
    MultiFactorSession? multiFactorSession,
    PhoneMultiFactorInfo? multiFactorInfo,
  }) async {
    final completer = Completer<PhoneVerificationChallenge>();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        multiFactorSession: multiFactorSession,
        multiFactorInfo: multiFactorInfo,
        verificationCompleted: (credential) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationChallenge(automaticCredential: credential),
            );
          }
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(_accountError(error));
          }
        },
        codeSent: (verificationId, _) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationChallenge(verificationId: verificationId),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationChallenge(verificationId: verificationId),
            );
          }
        },
      );
    } catch (error) {
      if (!completer.isCompleted) completer.completeError(_accountError(error));
    }
    return completer.future;
  }

  /// Links a manually entered SMS code to the current Firebase account.
  static Future<void> linkPhoneWithCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _runAccountAction(() => _user.linkWithCredential(credential));
  }

  static Future<void> linkPhoneCredential(PhoneAuthCredential credential) {
    return _runAccountAction(() => _user.linkWithCredential(credential));
  }

  /// Starts web phone linking. Firebase manages the reCAPTCHA verifier.
  static Future<ConfirmationResult> startWebPhoneLink(String phoneNumber) {
    return _runAccountAction(() => _user.linkWithPhoneNumber(phoneNumber));
  }

  /// Confirms a web phone-link SMS code.
  static Future<void> confirmWebPhoneLink(
    ConfirmationResult confirmation,
    String smsCode,
  ) async {
    await _runAccountAction(() => confirmation.confirm(smsCode));
  }

  /// Starts SMS second-factor enrollment. Firebase requires a verified email
  /// before a user can enroll MFA and automatically sends the MFA enrollment
  /// notification email after [enrollMfaWithCode] succeeds.
  static Future<PhoneVerificationChallenge> startMfaEnrollment(
    String phoneNumber,
  ) async {
    final user = _user;
    if (!user.emailVerified) {
      throw const AccountSecurityException(
        'Verify your email address before enrolling SMS MFA.',
      );
    }
    final session = await _runAccountAction(user.multiFactor.getSession);
    return startPhoneVerification(
      phoneNumber: phoneNumber,
      multiFactorSession: session,
    );
  }

  /// Enrolls an SMS second factor with the code the user received.
  static Future<void> enrollMfaWithCode({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _enrollMfaCredential(credential, displayName: displayName);
  }

  static Future<void> enrollMfaCredential(
    PhoneAuthCredential credential, {
    String? displayName,
  }) => _enrollMfaCredential(credential, displayName: displayName);

  static Future<void> _enrollMfaCredential(
    PhoneAuthCredential credential, {
    String? displayName,
  }) async {
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    await _runAccountAction(
      () => _user.multiFactor.enroll(assertion, displayName: displayName),
    );
  }

  /// Sends an MFA challenge to the first enrolled phone factor during sign-in.
  static Future<PhoneVerificationChallenge> startMfaSignIn(
    MultiFactorResolver resolver,
  ) {
    PhoneMultiFactorInfo? hint;
    for (final factor in resolver.hints) {
      if (factor is PhoneMultiFactorInfo) {
        hint = factor;
        break;
      }
    }
    if (hint == null) {
      throw const AccountSecurityException(
        'No supported phone MFA factor is enrolled on this account.',
      );
    }
    return startPhoneVerification(
      multiFactorSession: resolver.session,
      multiFactorInfo: hint,
    );
  }

  /// Completes an email/password MFA sign-in challenge.
  static Future<UserCredential> resolveMfaSignIn({
    required MultiFactorResolver resolver,
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return resolveMfaSignInWithCredential(
      resolver: resolver,
      credential: credential,
    );
  }

  static Future<UserCredential> resolveMfaSignInWithCredential({
    required MultiFactorResolver resolver,
    required PhoneAuthCredential credential,
  }) {
    return resolver.resolveSignIn(
      PhoneMultiFactorGenerator.getAssertion(credential),
    );
  }

  static Future<List<MultiFactorInfo>> enrolledMfaFactors() async =>
      _runAccountAction(_user.multiFactor.getEnrolledFactors);

  static Future<void> unenrollMfa(String factorUid) async {
    await _runAccountAction(
      () => _user.multiFactor.unenroll(factorUid: factorUid),
    );
  }

  static Future<T> _runAccountAction<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw _accountError(error);
    } catch (error) {
      if (error is AccountSecurityException) rethrow;
      throw const AccountSecurityException(
        'Account security is temporarily unavailable. Check your connection and try again.',
      );
    }
  }

  static AccountSecurityException _accountError(Object error) {
    if (error is AccountSecurityException) return error;
    if (error is FirebaseAuthException) {
      return AccountSecurityException(
        _accountMessage(error.code),
        code: error.code,
      );
    }
      return const AccountSecurityException(
        'Account security is temporarily unavailable. Check your connection and try again.',
    );
  }

  static String _accountMessage(String code) {
    switch (code) {
      case 'requires-recent-login':
        return 'For security, sign in again before changing this setting.';
      case 'invalid-phone-number':
        return 'Enter a valid phone number with its country code, for example +60123456789.';
      case 'invalid-verification-code':
        return 'That SMS code is incorrect. Check it and try again.';
      case 'invalid-verification-id':
        return 'That SMS session expired. Request a new code.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The current password is incorrect.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Wait and try again later.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Refresh the page and try again.';
      case 'credential-already-in-use':
      case 'phone-number-already-exists':
      case 'second-factor-already-in-use':
        return 'That phone number is already linked to another account.';
      case 'operation-not-allowed':
        return 'This security method is not enabled for the app yet.';
      case 'unverified-email':
        return 'Verify your email address before enrolling MFA.';
      default:
        return 'We could not complete this account-security action. Try again.';
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

/// Raised when the first sign-in factor succeeded but Firebase requires an
/// enrolled second factor to complete sign-in.
class MfaRequiredException extends EmailAuthException {
  final MultiFactorResolver resolver;

  const MfaRequiredException(this.resolver)
    : super('Enter the SMS code sent to your enrolled phone.');
}

/// User-facing failure from a Firebase password-reset operation.
class PasswordResetException implements Exception {
  final String message;
  final String? code;

  const PasswordResetException(this.message, {this.code});

  @override
  String toString() => message;
}

/// SMS verification state returned by Firebase's native callbacks.
class PhoneVerificationChallenge {
  final String? verificationId;
  final PhoneAuthCredential? automaticCredential;

  const PhoneVerificationChallenge({
    this.verificationId,
    this.automaticCredential,
  });
}

/// User-facing failure from email, phone, or MFA account-security operations.
class AccountSecurityException implements Exception {
  final String message;
  final String? code;

  const AccountSecurityException(this.message, {this.code});

  @override
  String toString() => message;
}
