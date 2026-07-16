import 'package:flutter/material.dart';
import '../widgets/landing/landing_button.dart';

/// Column of SSO buttons shared by the login and sign-up cards, styled as
/// the theme's bracketed hairline boxes. Google is wired to a real OAuth
/// flow via [GoogleAuthService]; GitHub and LinkedIn have no registered API
/// credentials or backend yet, so they show the same honest "not
/// configured" fallback that Google itself falls back to when its popup is
/// cancelled or unavailable — no fake logins.
class SsoButtons extends StatelessWidget {
  final String actionVerb;
  final bool googleBusy;
  final VoidCallback onGooglePressed;
  final bool githubBusy;
  final VoidCallback onGithubPressed;
  final bool dense;

  const SsoButtons({
    super.key,
    required this.actionVerb,
    required this.googleBusy,
    required this.onGooglePressed,
    required this.githubBusy,
    required this.onGithubPressed,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CinematicOutlineButton(
          label: googleBusy ? 'Connecting…' : '$actionVerb with Google',
          icon: googleBusy ? null : Icons.g_mobiledata_rounded,
          compact: dense,
          onPressed: googleBusy ? null : onGooglePressed,
        ),
        const SizedBox(height: 10),
        CinematicOutlineButton(
          label: githubBusy ? 'Connecting…' : '$actionVerb with GitHub',
          icon: Icons.code_rounded,
          compact: dense,
          onPressed: githubBusy ? null : onGithubPressed,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
