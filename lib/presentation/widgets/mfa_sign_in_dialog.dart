import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/session/email_auth_service.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';
import 'labeled_text_field.dart';
import 'noir_dialog.dart';

/// Completes the second step after Firebase accepts the first sign-in factor.
class MfaSignInDialog extends StatefulWidget {
  final MultiFactorResolver resolver;

  const MfaSignInDialog({super.key, required this.resolver});

  @override
  State<MfaSignInDialog> createState() => _MfaSignInDialogState();
}

class _MfaSignInDialogState extends State<MfaSignInDialog> {
  final _codeController = TextEditingController();
  String? _verificationId;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await EmailAuthService.startMfaSignIn(widget.resolver);
      if (!mounted) return;
      if (challenge.automaticCredential != null) {
        final result = await EmailAuthService.resolveMfaSignInWithCredential(
          resolver: widget.resolver,
          credential: challenge.automaticCredential!,
        );
        if (mounted) Navigator.of(context).pop(result);
        return;
      }
      setState(() {
        _busy = false;
        _verificationId = challenge.verificationId;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _securityMessage(error);
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 6 || _verificationId == null) {
      setState(() => _error = 'Enter the six-digit SMS code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await EmailAuthService.resolveMfaSignIn(
        resolver: widget.resolver,
        verificationId: _verificationId!,
        smsCode: code,
      );
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _securityMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? phoneHint;
    for (final factor in widget.resolver.hints) {
      if (factor is PhoneMultiFactorInfo) {
        phoneHint = factor.phoneNumber;
        break;
      }
    }
    final hasCode = _verificationId != null;
    return NoirDialogShell(
      title: 'VERIFY\nSECOND FACTOR',
      eyebrow: 'SMS security check',
      maxWidth: 440,
      maxHeight: 520,
      actions: [
        CinematicOutlineButton(
          label: 'Cancel',
          compact: true,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        GradientButton(
          label: _busy
              ? 'Working...'
              : hasCode
              ? 'Verify Code'
              : 'Send Code',
          compact: true,
          onPressed: _busy
              ? null
              : hasCode
              ? _verifyCode
              : _sendCode,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            phoneHint == null
                ? 'Enter the SMS code from your enrolled phone.'
                : 'We will send a code to $phoneHint.',
            style: LandingTokens.mono(
              fontSize: 12,
              color: LandingTokens.textMuted,
            ),
          ),
          if (hasCode) ...[
            const SizedBox(height: 20),
            LabeledTextField(
              label: 'SMS Code',
              controller: _codeController,
              hint: '123456',
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: LandingTokens.mono(
                fontSize: 12,
                color: const Color(0xFFFF4D5E),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _securityMessage(Object error) => error is AccountSecurityException
    ? error.message
    : 'We could not complete this security action. Try again.';
