import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Dummy "Join the Quest" auth card: Google button, email/password fields,
/// and a primary CTA. None of it validates anything — every affordance
/// (Google, "Let's Go!", "Create an account") signs the student in under
/// the same simulated session, matching the prototype's fake-SSO behavior.
class AuthScreen extends StatefulWidget {
  final void Function(String email) onLogin;
  final VoidCallback onBack;

  const AuthScreen({super.key, required this.onLogin, required this.onBack});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;

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
    _passwordController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    widget.onLogin(email.isNotEmpty ? email : 'student@school.edu');
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
                              children: [
                                const Text(
                                  'Join the Quest! 🚀',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Save your progress & climb the leaderboard.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                DoodleButton(
                                  label: 'Continue with Google',
                                  color: Colors.white,
                                  icon: Icons.g_mobiledata_rounded,
                                  onPressed: _submit,
                                  dense: dense,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(child: Divider(color: Colors.black, thickness: 2)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Colors.black, thickness: 2)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _LabeledField(label: 'Email Address', controller: _emailController, hint: 'coder@unimas.my'),
                                const SizedBox(height: 16),
                                _LabeledField(label: 'Password', controller: _passwordController, hint: '••••••••', obscure: true),
                                const SizedBox(height: 24),
                                DoodleButton(
                                  label: "Let's Go!",
                                  color: DoodlePalette.yellow,
                                  icon: Icons.arrow_forward,
                                  onPressed: _submit,
                                  dense: dense,
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: _submit,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
                                      children: [
                                        const TextSpan(text: 'New here? '),
                                        TextSpan(
                                          text: 'Create an account',
                                          style: TextStyle(
                                            color: DoodlePalette.blue,
                                            decoration: TextDecoration.underline,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: -14,
                        right: -14,
                        child: GestureDetector(
                          onTap: widget.onBack,
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
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _LabeledField({required this.label, required this.controller, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
