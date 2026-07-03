import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Row of SSO buttons shared by the login and sign-up cards. Google is
/// wired to a real OAuth flow via [GoogleAuthService]; GitHub and LinkedIn
/// have no registered API credentials or backend yet, so they show the
/// same honest "not configured" fallback that Google itself falls back to
/// when its popup is cancelled or unavailable — no fake logins.
class SsoButtons extends StatelessWidget {
  final String actionVerb;
  final bool googleBusy;
  final VoidCallback onGooglePressed;
  final bool dense;

  const SsoButtons({
    super.key,
    required this.actionVerb,
    required this.googleBusy,
    required this.onGooglePressed,
    this.dense = false,
  });

  void _showUnconfigured(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider sign-in isn't configured yet — you can use the email option below."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoodleButton(
          label: googleBusy ? 'Connecting…' : '$actionVerb with Google',
          color: Colors.white,
          icon: googleBusy ? null : Icons.g_mobiledata_rounded,
          isLoading: googleBusy,
          onPressed: onGooglePressed,
          dense: dense,
        ),
        const SizedBox(height: 12),
        DoodleButton(
          label: '$actionVerb with GitHub',
          color: Colors.white,
          icon: Icons.code_rounded,
          onPressed: () => _showUnconfigured(context, 'GitHub'),
          dense: dense,
        ),
        const SizedBox(height: 12),
        DoodleButton(
          label: '$actionVerb with LinkedIn',
          color: Colors.white,
          icon: Icons.business_center_rounded,
          onPressed: () => _showUnconfigured(context, 'LinkedIn'),
          dense: dense,
        ),
      ],
    );
  }
}
