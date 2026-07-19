import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/session/email_auth_service.dart';
import '../../core/session/google_auth_service.dart';
import '../theme/landing_tokens.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/mfa_sign_in_dialog.dart';
import '../widgets/sso_buttons.dart';

/// Enhanced "Join the Quest" auth with account requirements prominently displayed.
/// Every entry path REQUIRES a valid Firebase account. All progress, achievements,
/// streaks, and performance reports are persisted to Firestore and tied to the user's
/// authenticated identity. No guest sessions are supported.
class EnhancedAuthScreen extends StatefulWidget {
  final void Function(String email, {String? name, String? photoUrl}) onLogin;
  final VoidCallback onBack;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;

  const EnhancedAuthScreen({
    super.key,
    required this.onLogin,
    required this.onBack,
    required this.onCreateAccount,
    required this.onForgotPassword,
  });

  @override
  State<EnhancedAuthScreen> createState() => _EnhancedAuthScreenState();
}

class _EnhancedAuthScreenState extends State<EnhancedAuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;
  bool _googleBusy = false;
  bool _githubBusy = false;
  bool _emailBusy = false;
  String? _formError;

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

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _formError =
            'Email and password required. Must have a registered account.',
      );
      return;
    }

    setState(() {
      _emailBusy = true;
      _formError = null;
    });
    try {
      final result = await EmailAuthService.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      setState(() => _emailBusy = false);
      if (result != null) {
        widget.onLogin(
          result.email,
          name: result.name,
          photoUrl: result.photoUrl,
        );
      } else {
        setState(
          () => _formError =
              'Authentication failed. Check credentials or create a new account.',
        );
      }
    } on MfaRequiredException catch (error) {
      if (!mounted) return;
      setState(() {
        _emailBusy = false;
        _formError = null;
      });
      final credential = await showDialog<UserCredential>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MfaSignInDialog(resolver: error.resolver),
      );
      if (!mounted || credential?.user == null) return;
      final user = credential!.user!;
      widget.onLogin(
        user.email ?? email,
        name: user.displayName,
        photoUrl: user.photoURL,
      );
    } on EmailAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _emailBusy = false;
        _formError = error.message;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_googleBusy) return;
    setState(() {
      _googleBusy = true;
      _formError = null;
    });
    try {
      final result = await GoogleAuthService.signIn();
      if (!mounted) return;
      setState(() => _googleBusy = false);
      if (result == null) return;
      widget.onLogin(
        result.email,
        name: result.name,
        photoUrl: result.photoUrl,
      );
    } on SocialAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _googleBusy = false;
        _formError = error.message;
      });
    }
  }

  Future<void> _signInWithGithub() async {
    if (_githubBusy) return;
    setState(() {
      _githubBusy = true;
      _formError = null;
    });
    try {
      final result = await GitHubAuthService.signIn();
      if (!mounted) return;
      setState(() => _githubBusy = false);
      if (result == null) return;
      widget.onLogin(
        result.email,
        name: result.name,
        photoUrl: result.photoUrl,
      );
    } on SocialAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _githubBusy = false;
        _formError = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0500),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CinematicBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Header with account requirement banner
                    _AccountRequirementBanner(),
                    const SizedBox(height: 24),

                    // Features showcase
                    if (!isMobile) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _FeaturesPanel()),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _AuthFormPanel(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              onSubmit: _submit,
                              onGoogleSignIn: _signInWithGoogle,
                              onGithubSignIn: _signInWithGithub,
                              onCreateAccount: widget.onCreateAccount,
                              onForgotPassword: widget.onForgotPassword,
                              emailBusy: _emailBusy,
                              googleBusy: _googleBusy,
                              githubBusy: _githubBusy,
                              formError: _formError,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Mobile stack
                      _FeaturesPanel(),
                      const SizedBox(height: 20),
                      _AuthFormPanel(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onSubmit: _submit,
                        onGoogleSignIn: _signInWithGoogle,
                        onGithubSignIn: _signInWithGithub,
                        onCreateAccount: widget.onCreateAccount,
                        onForgotPassword: widget.onForgotPassword,
                        emailBusy: _emailBusy,
                        googleBusy: _googleBusy,
                        githubBusy: _githubBusy,
                        formError: _formError,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRequirementBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LandingTokens.ember.withValues(alpha: 0.1),
        border: Border.all(
          color: LandingTokens.ember.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: LandingTokens.ember,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT REQUIRED',
                  style: LandingTokens.label(
                    fontSize: 9,
                    color: LandingTokens.ember,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login or create an account to save progress, build streaks, earn achievements, and access your performance reports.',
                  style: LandingTokens.body(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      (
        icon: Icons.trending_up,
        color: Color(0xFF00D98E),
        title: 'Track Progress',
        desc:
            'Save your XP, module completions, and efficiency scores to Firestore',
      ),
      (
        icon: Icons.local_fire_department,
        color: LandingTokens.ember,
        title: 'Build Streaks',
        desc: 'Maintain daily login streaks and unlock persistence badges',
      ),
      (
        icon: Icons.emoji_events,
        color: Color(0xFFFFD700),
        title: 'Earn Achievements',
        desc: '22+ badges unlocked by completing modules and reaching milestones',
      ),
      (
        icon: Icons.assessment,
        color: LandingTokens.circuit,
        title: 'View Reports',
        desc:
            'Comprehensive performance analytics with accuracy, speed, and mastery metrics',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Features',
          style: LandingTokens.display(fontSize: 20),
        ),
        const SizedBox(height: 16),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FeatureCard(
            icon: f.icon,
            color: f.color,
            title: f.title,
            description: f.desc,
          ),
        )),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LandingTokens.label(fontSize: 10, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.body(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGithubSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;
  final bool emailBusy;
  final bool googleBusy;
  final bool githubBusy;
  final String? formError;

  const _AuthFormPanel({
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onGoogleSignIn,
    required this.onGithubSignIn,
    required this.onCreateAccount,
    required this.onForgotPassword,
    required this.emailBusy,
    required this.googleBusy,
    required this.githubBusy,
    required this.formError,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = emailBusy || googleBusy || githubBusy;

    return LandingGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PLAYER LOGIN',
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.ember,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ACCESS YOUR ACCOUNT',
            style: LandingTokens.display(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to sync your progress and unlock all features.',
            style: LandingTokens.body(fontSize: 12),
          ),
          const SizedBox(height: 20),

          // OAuth buttons
          SsoButtons(
            actionVerb: 'Continue',
            googleBusy: googleBusy,
            onGooglePressed: onGoogleSignIn,
            githubBusy: githubBusy,
            onGithubPressed: onGithubSignIn,
          ),

          const SizedBox(height: 16),
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
          const SizedBox(height: 16),

          // Email/password form
          LabeledTextField(
            label: 'EMAIL ADDRESS',
            controller: emailController,
            hint: 'coder@unimas.my',
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'PASSWORD',
            controller: passwordController,
            hint: '••••••••',
            obscure: true,
          ),

          if (formError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D5E).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFFFF4D5E).withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formError!,
                style: LandingTokens.body(
                  fontSize: 12,
                  color: const Color(0xFFFF4D5E),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isBusy ? null : onForgotPassword,
              child: Text(
                'FORGOT PASSWORD?',
                style: LandingTokens.label(
                  fontSize: 10,
                  color: isBusy
                      ? Colors.white.withValues(alpha: 0.3)
                      : LandingTokens.ember,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          GradientButton(
            label: emailBusy ? 'SIGNING IN...' : 'SIGN IN & CONTINUE',
            onPressed: isBusy ? null : onSubmit,
          ),

          const SizedBox(height: 12),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'NEW HERE? ',
                style: LandingTokens.body(fontSize: 12),
                children: [
                  TextSpan(
                    text: 'CREATE AN ACCOUNT',
                    style: LandingTokens.label(
                      fontSize: 12,
                      color: LandingTokens.circuit,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = isBusy ? null : onCreateAccount,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CinematicBackdrop extends StatelessWidget {
  const CinematicBackdrop({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0500),
          const Color(0xFF1A1015),
          const Color(0xFF0A0500),
        ],
      ),
    ),
  );
}
