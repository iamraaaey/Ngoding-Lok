import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/session/email_auth_service.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';
import 'labeled_text_field.dart';
import 'noir_dialog.dart';

/// Shows the current Firebase email-verification state and lets the user
/// request another verification message or refresh the state after clicking
/// the link in their inbox.
class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({super.key});

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _verified = EmailAuthService.emailVerified;
  bool _busy = false;
  String? _error;
  String? _message;

  Future<void> _refresh() async {
    await _run(() async {
      final verified = await EmailAuthService.reloadEmailVerification();
      if (mounted) setState(() => _verified = verified);
      return verified
          ? 'Email address verified.'
          : 'Verification is still pending.';
    });
  }

  Future<void> _send() async {
    await _run(() async {
      await EmailAuthService.sendEmailVerification();
      return 'Verification email sent. Check your inbox and spam folder.';
    });
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      final message = await action();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NoirDialogShell(
      title: 'EMAIL\nVERIFICATION',
      eyebrow: 'Account security',
      maxWidth: 460,
      maxHeight: 500,
      actions: [
        CinematicOutlineButton(
          label: 'Close',
          compact: true,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        if (!_verified)
          GradientButton(
            label: _busy ? 'Working...' : 'Send Email',
            compact: true,
            onPressed: _busy ? null : _send,
          ),
        GradientButton(
          label: _busy ? 'Working...' : 'Refresh Status',
          compact: true,
          onPressed: _busy ? null : _refresh,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            EmailAuthService.currentEmail == null
                ? 'Sign in before managing your email address.'
                : 'Current address: ${EmailAuthService.currentEmail}',
            style: LandingTokens.mono(
              fontSize: 12,
              color: LandingTokens.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          _StatusMessage(
            text: _verified
                ? 'EMAIL ADDRESS VERIFIED'
                : 'EMAIL ADDRESS NOT VERIFIED',
            color: _verified ? LandingTokens.signal : LandingTokens.ember,
          ),
          const SizedBox(height: 14),
          Text(
            _verified
                ? 'Your account can use verified-email features.'
                : 'We will send a message to verify this email address.',
            style: LandingTokens.mono(
              fontSize: 12,
              color: LandingTokens.textMuted,
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 14),
            _FeedbackText(text: _message!, color: LandingTokens.signal),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            _FeedbackText(text: _error!, color: const Color(0xFFFF4D5E)),
          ],
        ],
      ),
    );
  }
}

/// Requests Firebase's verified email-change flow. The new address is not
/// applied until the recipient confirms Firebase's email link.
class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({super.key});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final _emailController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid new email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await EmailAuthService.requestEmailChange(email);
      if (!mounted) return;
      setState(() => _busy = false);
      showNoirSnack(
        context,
        'Check the new address and confirm the email-change link.',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NoirDialogShell(
      title: 'CHANGE\nEMAIL',
      eyebrow: 'Account security',
      maxWidth: 460,
      maxHeight: 480,
      actions: [
        CinematicOutlineButton(
          label: 'Cancel',
          compact: true,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        GradientButton(
          label: _busy ? 'Working...' : 'Send Confirmation',
          compact: true,
          onPressed: _busy ? null : _submit,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'We will send a confirmation link to the new address. The change takes effect only after confirmation.',
            style: LandingTokens.mono(
              fontSize: 12,
              color: LandingTokens.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          LabeledTextField(
            label: 'New Email Address',
            controller: _emailController,
            hint: 'new-address@example.com',
            errorText: _error,
          ),
        ],
      ),
    );
  }
}

/// Links a phone number to the current Firebase account through SMS. Native
/// platforms use verifyPhoneNumber; web uses Firebase's reCAPTCHA-backed
/// linkWithPhoneNumber flow.
class PhoneLinkDialog extends StatefulWidget {
  const PhoneLinkDialog({super.key});

  @override
  State<PhoneLinkDialog> createState() => _PhoneLinkDialogState();
}

class _PhoneLinkDialogState extends State<PhoneLinkDialog> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  PhoneVerificationChallenge? _challenge;
  ConfirmationResult? _webConfirmation;
  bool _complete = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+') || phone.length < 8) {
      setState(
        () => _error =
            'Use a valid phone number with country code, e.g. +60123456789.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (kIsWeb) {
        final confirmation = await EmailAuthService.startWebPhoneLink(phone);
        if (!mounted) return;
        setState(() {
          _busy = false;
          _webConfirmation = confirmation;
        });
      } else {
        final challenge = await EmailAuthService.startPhoneVerification(
          phoneNumber: phone,
        );
        if (challenge.automaticCredential != null) {
          await EmailAuthService.linkPhoneCredential(
            challenge.automaticCredential!,
          );
          if (!mounted) return;
          setState(() {
            _busy = false;
            _complete = true;
          });
        } else if (!mounted) {
          return;
        } else {
          setState(() {
            _busy = false;
            _challenge = challenge;
          });
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the six-digit SMS code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (kIsWeb) {
        await EmailAuthService.confirmWebPhoneLink(_webConfirmation!, code);
      } else {
        final verificationId = _challenge?.verificationId;
        if (verificationId == null) {
          throw const AccountSecurityException('Request a new SMS code first.');
        }
        await EmailAuthService.linkPhoneWithCode(
          verificationId: verificationId,
          smsCode: code,
        );
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _complete = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChallenge = _challenge != null || _webConfirmation != null;
    return NoirDialogShell(
      title: 'SMS\nVERIFICATION',
      eyebrow: 'Phone security',
      maxWidth: 460,
      maxHeight: 560,
      actions: [
        CinematicOutlineButton(
          label: 'Close',
          compact: true,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        if (!_complete)
          GradientButton(
            label: _busy
                ? 'Working...'
                : hasChallenge
                ? 'Verify Code'
                : 'Send SMS',
            compact: true,
            onPressed: _busy
                ? null
                : hasChallenge
                ? _verifyCode
                : _sendCode,
          ),
      ],
      child: _complete
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StatusMessage(
                  text: 'PHONE NUMBER VERIFIED AND LINKED',
                  color: LandingTokens.signal,
                ),
                const SizedBox(height: 14),
                Text(
                  'This phone number is now ready for account security.',
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.textMuted,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter an international phone number. We will send an SMS when needed.',
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                LabeledTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  hint: '+60123456789',
                ),
                if (hasChallenge) ...[
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'SMS Code',
                    controller: _codeController,
                    hint: '123456',
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _FeedbackText(text: _error!, color: const Color(0xFFFF4D5E)),
                ],
              ],
            ),
    );
  }
}

/// Enrolls the current user in SMS MFA. Firebase requires a verified email
/// and a recent authenticated session before this flow can complete.
class MfaEnrollmentDialog extends StatefulWidget {
  const MfaEnrollmentDialog({super.key});

  @override
  State<MfaEnrollmentDialog> createState() => _MfaEnrollmentDialogState();
}

class _MfaEnrollmentDialogState extends State<MfaEnrollmentDialog> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  PhoneVerificationChallenge? _challenge;
  bool _complete = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+') || phone.length < 8) {
      setState(
        () => _error =
            'Use a valid phone number with country code, e.g. +60123456789.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await EmailAuthService.startMfaEnrollment(phone);
      if (challenge.automaticCredential != null) {
        await EmailAuthService.enrollMfaCredential(
          challenge.automaticCredential!,
          displayName: 'SMS phone',
        );
        if (!mounted) return;
        setState(() {
          _busy = false;
          _complete = true;
        });
      } else if (!mounted) {
        return;
      } else {
        setState(() {
          _busy = false;
          _challenge = challenge;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    final verificationId = _challenge?.verificationId;
    if (code.length < 6 || verificationId == null) {
      setState(() => _error = 'Enter the six-digit SMS code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await EmailAuthService.enrollMfaWithCode(
        verificationId: verificationId,
        smsCode: code,
        displayName: 'SMS phone',
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _complete = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = accountSecurityMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChallenge = _challenge != null;
    return NoirDialogShell(
      title: 'ENROLL\nSMS MFA',
      eyebrow: 'Multi-factor security',
      maxWidth: 460,
      maxHeight: 560,
      actions: [
        CinematicOutlineButton(
          label: 'Close',
          compact: true,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        if (!_complete)
          GradientButton(
            label: _busy
                ? 'Working...'
                : hasChallenge
                ? 'Enroll Factor'
                : 'Send SMS',
            compact: true,
            onPressed: _busy
                ? null
                : hasChallenge
                ? _verifyCode
                : _sendCode,
          ),
      ],
      child: _complete
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StatusMessage(
                  text: 'SMS MFA ENROLLED',
                  color: LandingTokens.signal,
                ),
                const SizedBox(height: 14),
                Text(
                  'A multi-factor enrollment notification email will be sent automatically.',
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.textMuted,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Verify your email first. Then we will send an SMS to register this phone as a second sign-in factor.',
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                LabeledTextField(
                  label: 'MFA Phone Number',
                  controller: _phoneController,
                  hint: '+60123456789',
                ),
                if (hasChallenge) ...[
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'SMS Code',
                    controller: _codeController,
                    hint: '123456',
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _FeedbackText(text: _error!, color: const Color(0xFFFF4D5E)),
                ],
              ],
            ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusMessage({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: LandingTokens.label(fontSize: 11, color: color),
          ),
        ),
      ],
    );
  }
}

class _FeedbackText extends StatelessWidget {
  final String text;
  final Color color;

  const _FeedbackText({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: LandingTokens.mono(fontSize: 12, color: color),
    );
  }
}

String accountSecurityMessage(Object error) => error is AccountSecurityException
    ? error.message
    : 'We could not complete this security action. Try again.';
