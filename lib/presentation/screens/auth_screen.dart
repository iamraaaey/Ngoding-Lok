import 'package:flutter/material.dart';
import '../../core/session/google_auth_service.dart';
import '../theme/doodle.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/sso_buttons.dart';

/// "Join the Quest" auth card. The Google button performs a real OAuth
/// sign-in via [GoogleAuthService]; when that is cancelled or unavailable
/// (unsupported platform, unconfigured origin), the email/password path
/// still signs the student in under the simulated session, matching the
/// prototype's fake-SSO behavior. "Create an account" leads to the
/// dedicated [SignUpScreen] route.
class AuthScreen extends StatefulWidget {
  final void Function(String email, {String? name, String? photoUrl}) onLogin;
  final VoidCallback onBack;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;

  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onBack,
    required this.onCreateAccount,
    required this.onForgotPassword,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;
  bool _googleBusy = false;

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

  Future<void> _signInWithGoogle() async {
    if (_googleBusy) return;
    setState(() => _googleBusy = true);

    final result = await GoogleAuthService.signIn();
    if (!mounted) return;
    setState(() => _googleBusy = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in was cancelled or is unavailable here — you can use the email option below.'),
        ),
      );
      return;
    }
    widget.onLogin(result.email, name: result.name, photoUrl: result.photoUrl);
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
                                SsoButtons(
                                  actionVerb: 'Continue',
                                  googleBusy: _googleBusy,
                                  onGooglePressed: _signInWithGoogle,
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
                                LabeledTextField(label: 'Email Address', controller: _emailController, hint: 'coder@unimas.my'),
                                const SizedBox(height: 16),
                                LabeledTextField(label: 'Password', controller: _passwordController, hint: '••••••••', obscure: true),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    key: const Key('forgot-password-link'),
                                    onTap: widget.onForgotPassword,
                                    child: Text(
                                      'Forgot your password?',
                                      style: TextStyle(
                                        color: DoodlePalette.blue,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                DoodleButton(
                                  label: "Let's Go!",
                                  color: DoodlePalette.yellow,
                                  icon: Icons.arrow_forward,
                                  onPressed: _submit,
                                  dense: dense,
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  key: const Key('create-account-link'),
                                  onTap: widget.onCreateAccount,
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

