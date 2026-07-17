import 'package:flutter/material.dart';
import '../../core/session/google_auth_service.dart';
import '../theme/landing_tokens.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_hero.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/sso_buttons.dart';

/// "Join the Quest" auth card in the terminal noir style. The Google button
/// performs a real OAuth sign-in via [GoogleAuthService]; when that is
/// cancelled or unavailable (unsupported platform, unconfigured origin),
/// the email/password path still signs the student in under the simulated
/// session, matching the prototype's fake-SSO behavior. "Create an account"
/// leads to the dedicated [SignUpScreen] route.
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

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;
  bool _googleBusy = false;
  bool _githubBusy = false;

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
          content: Text(
            'Google sign-in was cancelled or is unavailable here — you can use the email option below.',
          ),
        ),
      );
      return;
    }
    widget.onLogin(result.email, name: result.name, photoUrl: result.photoUrl);
  }

  Future<void> _signInWithGithub() async {
    if (_githubBusy) return;
    setState(() => _githubBusy = true);
    final result = await GitHubAuthService.signIn();
    if (!mounted) return;
    setState(() => _githubBusy = false);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GitHub sign-in was cancelled or is unavailable here.'),
        ),
      );
      return;
    }
    widget.onLogin(result.email, name: result.name, photoUrl: result.photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      entrance: CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
      onClose: widget.onBack,
      form: LayoutBuilder(
        builder: (context, constraints) {
          final dense = constraints.maxWidth < 340;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeading(
                eyebrow: 'Player login',
                title: 'JOIN THE\nQUEST',
                subtitle: 'SAVE YOUR PROGRESS & CLIMB THE LEADERBOARD',
              ),
              const SizedBox(height: 24),
              SsoButtons(
                actionVerb: 'Continue',
                googleBusy: _googleBusy,
                onGooglePressed: _signInWithGoogle,
                githubBusy: _githubBusy,
                onGithubPressed: _signInWithGithub,
                dense: dense,
              ),
              const SizedBox(height: 20),
              const AuthDivider(),
              const SizedBox(height: 20),
              LabeledTextField(
                label: 'Email Address',
                controller: _emailController,
                hint: 'coder@unimas.my',
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Password',
                controller: _passwordController,
                hint: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: AuthLink(
                  key: const Key('forgot-password-link'),
                  text: 'FORGOT YOUR PASSWORD?',
                  onTap: widget.onForgotPassword,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: "Let's Go!",
                onPressed: _submit,
                compact: dense,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'NEW HERE? ',
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textFaint,
                    ),
                  ),
                  AuthLink(
                    key: const Key('create-account-link'),
                    text: 'CREATE AN ACCOUNT',
                    onTap: widget.onCreateAccount,
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

/// Full-width responsive scaffold shared by the auth-flow screens.
///
/// Desktop widths get a two-column layout — the Ngoding Lok brand pane with
/// the typing terminal on the left, the form panel on the right — spanning
/// the page grid. Narrow widths collapse to a single full-width column with
/// a compact brand header.
class AuthScaffold extends StatelessWidget {
  final Animation<double> entrance;
  final VoidCallback? onClose;
  final Widget form;

  const AuthScaffold({
    super.key,
    required this.entrance,
    required this.form,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= LandingTokens.desktopBreakpoint;

    final formPanel = Stack(
      clipBehavior: Clip.none,
      children: [
        AuthPanel(child: form),
        if (onClose != null)
          Positioned(
            top: -14,
            right: -14,
            child: AuthCloseButton(onTap: onClose!),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: LandingTokens.voidBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CinematicBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: LandingTokens.pagePaddingFor(
                  width,
                ).copyWith(top: 40, bottom: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: LandingTokens.contentMaxWidth,
                  ),
                  child: AuthEntrance(
                    animation: entrance,
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 6, child: _BrandPane()),
                              const SizedBox(width: LandingTokens.space64),
                              Expanded(flex: 5, child: formPanel),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _CompactBrandHeader(),
                              const SizedBox(height: LandingTokens.space24),
                              formPanel,
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Left column of the desktop auth layout: boxed wordmark, typing terminal,
/// and the promises that make an account worth having.
class _BrandPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '// NGODING LOK — ACCESS TERMINAL',
          style: LandingTokens.label(color: LandingTokens.textMuted),
        ),
        const SizedBox(height: LandingTokens.space24),
        const BoxedHeadline(size: 52),
        const SizedBox(height: LandingTokens.space32),
        const TerminalPromptCard(),
        const SizedBox(height: LandingTokens.space32),
        for (final promise in const <String>[
          'SAVE YOUR PROGRESS ACROSS MISSIONS',
          'EARN XP, STREAKS & LEAGUE RANKS',
          'CLIMB THE GLOBAL LEADERBOARD',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: LandingTokens.space12),
            child: Row(
              children: [
                Text(
                  '+',
                  style: LandingTokens.mono(
                    fontSize: 13,
                    color: LandingTokens.signal,
                  ),
                ),
                const SizedBox(width: LandingTokens.space12),
                Flexible(
                  child: Text(
                    promise,
                    style: LandingTokens.label(
                      fontSize: 10,
                      color: LandingTokens.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Slim brand row shown above the form on narrow layouts.
class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: LandingTokens.ember,
            borderRadius: LandingTokens.smallRadius,
          ),
          child: const Icon(
            Icons.terminal_rounded,
            color: Color(0xFF0A0500),
            size: 17,
          ),
        ),
        const SizedBox(width: LandingTokens.space12),
        Text(
          'NGODING LOK',
          style: LandingTokens.label(
            fontSize: 12,
            color: LandingTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ).copyWith(letterSpacing: 2.2),
        ),
      ],
    );
  }
}

/// Shared entrance transition for the auth-flow cards.
class AuthEntrance extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AuthEntrance({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 40),
            child: child,
          ),
        );
      },
    );
  }
}

/// The carbon card every auth screen sits on: hairline border, near-sharp
/// corners, and a thin iridescent strip along the top edge.
class AuthPanel extends StatelessWidget {
  final Widget child;

  const AuthPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 400;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 3,
            child: AnimatedIridescence(borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 20 : 28,
              32,
              compact ? 20 : 28,
              28,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Mono eyebrow + heavy display title + mono subtitle.
class AuthHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const AuthHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '// ${eyebrow.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LandingTokens.label(color: LandingTokens.ember),
              ),
            ),
            const SizedBox(width: 12),
            const BlinkingCursor(width: 8, height: 14),
          ],
        ),
        const SizedBox(height: 14),
        Text(title, style: LandingTokens.display(fontSize: 36)),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: LandingTokens.label(
            fontSize: 9.5,
            color: LandingTokens.textFaint,
          ),
        ),
      ],
    );
  }
}

/// "── OR ──" rule between the SSO buttons and the email form.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: HairlineDivider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.textFaint,
            ),
          ),
        ),
        const Expanded(child: HairlineDivider()),
      ],
    );
  }
}

/// Ember mono hyperlink used across the auth cards.
class AuthLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const AuthLink({super.key, required this.text, required this.onTap});

  @override
  State<AuthLink> createState() => _AuthLinkState();
}

class _AuthLinkState extends State<AuthLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style:
              LandingTokens.label(
                fontSize: 10,
                color: _hovered
                    ? LandingTokens.emberBright
                    : LandingTokens.ember,
                fontWeight: FontWeight.w700,
              ).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: LandingTokens.ember,
              ),
        ),
      ),
    );
  }
}

/// Small boxed close button pinned to the card corner.
class AuthCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const AuthCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: LandingTokens.panelRaised,
            borderRadius: LandingTokens.smallRadius,
            border: Border.all(color: LandingTokens.hairlineStrong),
            boxShadow: LandingTokens.cardShadow,
          ),
          child: const Icon(
            Icons.close,
            color: LandingTokens.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
