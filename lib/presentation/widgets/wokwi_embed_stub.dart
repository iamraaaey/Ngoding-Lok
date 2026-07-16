import 'package:flutter/material.dart';

import '../theme/landing_tokens.dart';

/// Native fallback. Wokwi is a browser-based simulator, so this app embeds it
/// only in Flutter Web builds.
class WokwiEmbed extends StatelessWidget {
  final String projectUrl;

  const WokwiEmbed({super.key, required this.projectUrl});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.web_rounded, color: LandingTokens.ember, size: 34),
            SizedBox(height: 12),
            Text(
              'The live Wokwi simulator is available in the web version.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LandingTokens.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
