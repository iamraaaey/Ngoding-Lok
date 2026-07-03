import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/session/google_auth_service.dart';
import '../theme/doodle.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/policy_dialog.dart';
import '../widgets/sso_buttons.dart';

/// "Create Your Account" registration card. Validates name, email format,
/// password length, and password confirmation before registering; Google
/// sign-up reuses the real OAuth flow from [GoogleAuthService]. Accounts
/// live in the in-memory session only (no persistence), per the FYP scope.
class SignUpScreen extends StatefulWidget {
  final void Function(String email, {String? name, String? photoUrl}) onRegister;
  final VoidCallback onBackToLogin;

  const SignUpScreen({super.key, required this.onRegister, required this.onBackToLogin});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final AnimationController _entrance;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _consentError;
  bool _googleBusy = false;
  bool _consentChecked = false;
  bool _newsletterOptIn = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Please tell us your name.' : null;
      _emailError = _emailPattern.hasMatch(email) ? null : 'Enter a valid email address.';
      _passwordError = password.length >= 6 ? null : 'Password must be at least 6 characters.';
      _confirmError = confirm == password ? null : 'Passwords do not match.';
      _consentError = _consentChecked ? null : 'You must agree to continue.';
    });

    final valid = _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _consentError == null;
    if (valid) widget.onRegister(email, name: name);
  }

  Future<void> _signUpWithGoogle() async {
    if (_googleBusy) return;
    setState(() => _googleBusy = true);

    final result = await GoogleAuthService.signIn();
    if (!mounted) return;
    setState(() => _googleBusy = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-up was cancelled or is unavailable here — you can register with email below.'),
        ),
      );
      return;
    }
    widget.onRegister(result.email, name: result.name, photoUrl: result.photoUrl);
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
                                  'Create Your Account ✨',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'One account for XP, streaks & the leaderboard.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                SsoButtons(
                                  actionVerb: 'Sign up',
                                  googleBusy: _googleBusy,
                                  onGooglePressed: _signUpWithGoogle,
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
                                LabeledTextField(
                                  key: const Key('signup-name'),
                                  label: 'Full Name',
                                  controller: _nameController,
                                  hint: 'Ray the Coder',
                                  errorText: _nameError,
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  key: const Key('signup-email'),
                                  label: 'Email Address',
                                  controller: _emailController,
                                  hint: 'coder@unimas.my',
                                  errorText: _emailError,
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  key: const Key('signup-password'),
                                  label: 'Password',
                                  controller: _passwordController,
                                  hint: 'At least 6 characters',
                                  obscure: true,
                                  errorText: _passwordError,
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  key: const Key('signup-confirm'),
                                  label: 'Confirm Password',
                                  controller: _confirmController,
                                  hint: 'Same password again',
                                  obscure: true,
                                  errorText: _confirmError,
                                ),
                                const SizedBox(height: 20),
                                _ConsentCheckbox(
                                  key: const Key('signup-consent-checkbox'),
                                  value: _consentChecked,
                                  onChanged: (v) => setState(() {
                                    _consentChecked = v;
                                    if (v) _consentError = null;
                                  }),
                                  errorText: _consentError,
                                ),
                                const SizedBox(height: 10),
                                _NewsletterCheckbox(
                                  key: const Key('signup-newsletter-checkbox'),
                                  value: _newsletterOptIn,
                                  onChanged: (v) => setState(() => _newsletterOptIn = v),
                                ),
                                const SizedBox(height: 24),
                                DoodleButton(
                                  label: 'Create My Account',
                                  color: DoodlePalette.yellow,
                                  icon: Icons.rocket_launch,
                                  onPressed: _submit,
                                  dense: dense,
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  key: const Key('back-to-login-link'),
                                  onTap: widget.onBackToLogin,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
                                      children: [
                                        const TextSpan(text: 'Already a quester? '),
                                        TextSpan(
                                          text: 'Log in',
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
}

/// Required "I agree to the Privacy Policy and Cookies Policy" checkbox.
/// Both policy names are tappable and open [showPolicyDialog].
class _ConsentCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  const _ConsentCheckbox({super.key, required this.value, required this.onChanged, this.errorText});

  @override
  State<_ConsentCheckbox> createState() => _ConsentCheckboxState();
}

class _ConsentCheckboxState extends State<_ConsentCheckbox> {
  late final _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => showPolicyDialog(context, title: 'Privacy Policy');
  late final _cookiesRecognizer = TapGestureRecognizer()
    ..onTap = () => showPolicyDialog(context, title: 'Cookies Policy');

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    _cookiesRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CheckboxRow(
          value: widget.value,
          onChanged: widget.onChanged,
          hasError: hasError,
          toggleOnLabelTap: false,
          label: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 12, height: 1.35),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(color: DoodlePalette.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.w800),
                  recognizer: _privacyRecognizer,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Cookies Policy',
                  style: const TextStyle(color: DoodlePalette.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.w800),
                  recognizer: _cookiesRecognizer,
                ),
                const TextSpan(text: '. *'),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(widget.errorText!, style: const TextStyle(color: DoodlePalette.red, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ],
    );
  }
}

/// Optional "Keep me posted" newsletter opt-in checkbox.
class _NewsletterCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NewsletterCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _CheckboxRow(
      value: value,
      onChanged: onChanged,
      hasError: false,
      label: const Text(
        'Send me tips, new modules & leaderboard updates (optional).',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 12, height: 1.35),
      ),
    );
  }
}

/// Shared checkbox + label row used by [_ConsentCheckbox] and [_NewsletterCheckbox].
///
/// [toggleOnLabelTap] must be false when [label] embeds its own tap targets
/// (e.g. the consent checkbox's policy links) — otherwise the label's
/// GestureDetector and the embedded TextSpan recognizers would compete for
/// the same pointer event in the same gesture arena.
class _CheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool hasError;
  final Widget label;
  final bool toggleOnLabelTap;

  const _CheckboxRow({
    required this.value,
    required this.onChanged,
    required this.hasError,
    required this.label,
    this.toggleOnLabelTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: DoodlePalette.green,
            checkColor: Colors.black,
            side: BorderSide(color: hasError ? DoodlePalette.red : Colors.black, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: toggleOnLabelTap
              ? GestureDetector(
                  onTap: () => onChanged(!value),
                  behavior: HitTestBehavior.translucent,
                  child: label,
                )
              : label,
        ),
      ],
    );
  }
}
