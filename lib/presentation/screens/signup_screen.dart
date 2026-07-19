import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/session/email_auth_service.dart';
import '../../core/session/google_auth_service.dart';
import '../theme/landing_tokens.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/policy_dialog.dart';
import '../widgets/sso_buttons.dart';
import 'auth_screen.dart';

const _errorRed = Color(0xFFFF4D5E);

/// "Create Your Account" registration card in the terminal noir style.
/// Validates name, email format, password length, and password confirmation
/// before registering; Google sign-up reuses the real OAuth flow from
/// [GoogleAuthService]. The resulting Firebase identity is required before
/// the player can enter the learning hub.
class SignUpScreen extends StatefulWidget {
  final void Function(String email, {String? name, String? photoUrl})
  onRegister;
  final VoidCallback onBackToLogin;

  const SignUpScreen({
    super.key,
    required this.onRegister,
    required this.onBackToLogin,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
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
  String? _submitError;
  bool _googleBusy = false;
  bool _githubBusy = false;
  bool _submitBusy = false;
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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Please tell us your name.' : null;
      _emailError = _emailPattern.hasMatch(email)
          ? null
          : 'Enter a valid email address.';
      _passwordError = password.length >= 6
          ? null
          : 'Password must be at least 6 characters.';
      _confirmError = confirm == password ? null : 'Passwords do not match.';
      _consentError = _consentChecked ? null : 'You must agree to continue.';
      _submitError = null;
    });

    final valid =
        _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _consentError == null;
    if (!valid || _submitBusy) return;

    setState(() => _submitBusy = true);
    try {
      final result = await EmailAuthService.signUp(
        email: email,
        password: password,
        name: name,
      );
      if (!mounted) return;
      setState(() => _submitBusy = false);
      if (result != null) {
        widget.onRegister(
          result.email,
          name: result.name ?? name,
          photoUrl: result.photoUrl,
        );
      } else {
        setState(
          () => _submitError =
              'Account creation did not complete. Check your connection and try again.',
        );
      }
    } on EmailAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitBusy = false;
        _submitError = error.message;
      });
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_googleBusy) return;
    setState(() {
      _googleBusy = true;
      _submitError = null;
    });
    try {
      final result = await GoogleAuthService.signIn();
      if (!mounted) return;
      setState(() => _googleBusy = false);
      // A null result means the player closed the popup — nothing to report.
      if (result == null) return;
      widget.onRegister(
        result.email,
        name: result.name,
        photoUrl: result.photoUrl,
      );
    } on SocialAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _googleBusy = false;
        _submitError = error.message;
      });
    }
  }

  Future<void> _signUpWithGithub() async {
    if (_githubBusy) return;
    setState(() {
      _githubBusy = true;
      _submitError = null;
    });
    try {
      final result = await GitHubAuthService.signIn();
      if (!mounted) return;
      setState(() => _githubBusy = false);
      if (result == null) return;
      widget.onRegister(
        result.email,
        name: result.name,
        photoUrl: result.photoUrl,
      );
    } on SocialAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _githubBusy = false;
        _submitError = error.message;
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
            children: [
              const AuthHeading(
                eyebrow: 'New player',
                title: 'CREATE YOUR\nACCOUNT',
                subtitle: 'ONE ACCOUNT FOR XP, STREAKS & THE LEADERBOARD',
              ),
              const SizedBox(height: 24),
              SsoButtons(
                actionVerb: 'Sign up',
                googleBusy: _googleBusy,
                onGooglePressed: _signUpWithGoogle,
                githubBusy: _githubBusy,
                onGithubPressed: _signUpWithGithub,
                dense: dense,
              ),
              const SizedBox(height: 20),
              const AuthDivider(),
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
              GradientButton(
                label: _submitBusy
                    ? 'Creating account...'
                    : 'Create My Account',
                onPressed: _submitBusy ? null : _submit,
                compact: dense,
              ),
              if (_submitError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _submitError!,
                  key: const Key('signup-submit-error'),
                  textAlign: TextAlign.center,
                  style: LandingTokens.mono(fontSize: 12, color: _errorRed),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'ALREADY A QUESTER? ',
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textFaint,
                    ),
                  ),
                  AuthLink(
                    key: const Key('back-to-login-link'),
                    text: 'LOG IN',
                    onTap: widget.onBackToLogin,
                  ),
                ],
              ),
            ],
          );
        },
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

  const _ConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

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
    final linkStyle =
        LandingTokens.mono(
          fontSize: 12,
          color: LandingTokens.ember,
          fontWeight: FontWeight.w700,
        ).copyWith(
          decoration: TextDecoration.underline,
          decorationColor: LandingTokens.ember,
        );

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
              style: LandingTokens.mono(
                fontSize: 12,
                color: LandingTokens.textMuted,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: _privacyRecognizer,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Cookies Policy',
                  style: linkStyle,
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
            child: Text(
              widget.errorText!,
              style: LandingTokens.mono(fontSize: 12, color: _errorRed),
            ),
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

  const _NewsletterCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _CheckboxRow(
      value: value,
      onChanged: onChanged,
      hasError: false,
      label: Text(
        'Send me tips, new modules & leaderboard updates (optional).',
        style: LandingTokens.mono(fontSize: 12, color: LandingTokens.textMuted),
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
            activeColor: LandingTokens.signal,
            checkColor: const Color(0xFF0A0500),
            side: BorderSide(
              color: hasError ? _errorRed : LandingTokens.hairlineStrong,
              width: 1.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
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
