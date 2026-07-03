import 'package:flutter/material.dart';
import '../theme/doodle.dart';
import '../widgets/labeled_text_field.dart';

/// "Password Recovery" card. There is no account backend in this prototype
/// (see [SignUpScreen]'s note on in-memory-only accounts), so submitting
/// here can't actually look up or email anyone — it swaps to a confirmation
/// state after a valid-looking email is entered, matching the always-succeed
/// contract of the rest of the simulated auth flow.
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();
  late final AnimationController _entrance;

  String? _emailError;
  bool _sent = false;

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

  void _submit() {
    final email = _emailController.text.trim();
    final valid = _emailPattern.hasMatch(email);
    setState(() {
      _emailError = valid ? null : 'Enter a valid email address.';
      if (valid) _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: DoodleDotBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: DoodleFadeSlide(
                  animation: CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
                  yOffset: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      DoodleCard(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
                        borderRadius: 24,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dense = constraints.maxWidth < 340;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _sent ? _confirmation(dense) : _form(dense),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: -14,
                        right: -14,
                        child: GestureDetector(
                          onTap: widget.onBackToLogin,
                          child: const DoodleIconBadge(
                            icon: Icons.close,
                            color: DoodlePalette.red,
                            size: 40,
                            iconSize: 20,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _form(bool dense) => [
        const Text(
          'Reset Your Password 🔑',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter the email on your account and we'll send you a reset link.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
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
        DoodleButton(
          label: 'Send Reset Link',
          color: DoodlePalette.yellow,
          icon: Icons.send_rounded,
          onPressed: _submit,
          dense: dense,
        ),
        const SizedBox(height: 20),
        _backToLoginLink(),
      ];

  List<Widget> _confirmation(bool dense) => [
        const Align(
          alignment: Alignment.center,
          child: DoodleIconBadge(icon: Icons.mark_email_read_rounded, color: DoodlePalette.green, size: 56, iconSize: 28),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check Your Email 📬',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          "If an account exists for ${_emailController.text.trim()}, a reset link is on its way.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _backToLoginLink(),
      ];

  Widget _backToLoginLink() => GestureDetector(
        key: const Key('forgot-password-back-link'),
        onTap: widget.onBackToLogin,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
            children: [
              const TextSpan(text: 'Remembered it? '),
              TextSpan(
                text: 'Back to login',
                style: TextStyle(
                  color: DoodlePalette.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
}
