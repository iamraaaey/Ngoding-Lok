import 'package:flutter/material.dart';
import '../../core/session/email_auth_service.dart';
import '../theme/landing_tokens.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/landing/landing_button.dart';
import 'auth_screen.dart';

/// "Password Recovery" card in the terminal noir style.
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;
  final Future<void> Function(String email) onSendResetLink;

  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
    required this.onSendResetLink,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();
  late final AnimationController _entrance;

  String? _emailError;
  String? _requestError;
  bool _sent = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final valid = _emailPattern.hasMatch(email);
    setState(() {
      _emailError = valid ? null : 'Enter a valid email address.';
      _requestError = null;
    });
    if (!valid || _sending) return;

    setState(() => _sending = true);
    try {
      await widget.onSendResetLink(email);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _requestError = error is PasswordResetException
            ? error.message
            : 'We could not send the reset email. Try again in a moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      entrance: CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
      onClose: widget.onBackToLogin,
      form: LayoutBuilder(
        builder: (context, constraints) {
          final dense = constraints.maxWidth < 340;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _sent ? _confirmation(dense) : _form(dense),
          );
        },
      ),
    );
  }

  List<Widget> _form(bool dense) => [
    const AuthHeading(
      eyebrow: 'Password recovery',
      title: 'RESET YOUR\nPASSWORD',
      subtitle: "ENTER YOUR ACCOUNT EMAIL AND WE'LL SEND A RESET LINK",
    ),
    const SizedBox(height: 24),
    LabeledTextField(
      key: const Key('forgot-password-email'),
      label: 'Email Address',
      controller: _emailController,
      hint: 'coder@unimas.my',
      errorText: _emailError,
    ),
    const SizedBox(height: 24),
    GradientButton(
      label: _sending ? 'Sending...' : 'Send Reset Link',
      icon: _sending ? Icons.hourglass_top_rounded : Icons.send_rounded,
      onPressed: _sending ? null : _submit,
      compact: dense,
    ),
    if (_requestError != null) ...[
      const SizedBox(height: 12),
      Text(
        _requestError!,
        key: const Key('forgot-password-request-error'),
        textAlign: TextAlign.center,
        style: LandingTokens.mono(fontSize: 12, color: const Color(0xFFFF4D5E)),
      ),
    ],
    const SizedBox(height: 20),
    _backToLoginRow(),
  ];

  List<Widget> _confirmation(bool dense) => [
    Align(
      alignment: Alignment.center,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: LandingTokens.signal.withValues(alpha: 0.1),
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(
            color: LandingTokens.signal.withValues(alpha: 0.4),
          ),
        ),
        child: const Icon(
          Icons.mark_email_read_rounded,
          color: LandingTokens.signal,
          size: 28,
        ),
      ),
    ),
    const SizedBox(height: 20),
    Text(
      'CHECK YOUR EMAIL',
      textAlign: TextAlign.center,
      style: LandingTokens.display(fontSize: 26),
    ),
    const SizedBox(height: 10),
    Text(
      '> if an account exists for ${_emailController.text.trim()},\n> a reset link is on its way.',
      textAlign: TextAlign.center,
      style: LandingTokens.mono(fontSize: 12, color: LandingTokens.textMuted),
    ),
    const SizedBox(height: 24),
    _backToLoginRow(),
  ];

  Widget _backToLoginRow() => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        'REMEMBERED IT? ',
        style: LandingTokens.label(
          fontSize: 10,
          color: LandingTokens.textFaint,
        ),
      ),
      AuthLink(
        key: const Key('forgot-password-back-link'),
        text: 'BACK TO LOGIN',
        onTap: widget.onBackToLogin,
      ),
    ],
  );
}
