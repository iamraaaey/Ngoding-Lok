import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';

/// Banner shown under [GameHeader] once a module's hint has been unlocked
/// via the rewarded-ad flow, styled as the AI tutor's terminal message.
/// While the Socratic Hint Engine request is in flight, [isLoading] renders
/// a spinner in place of [hint] so the ad-hint flow reads as "your hint is
/// on its way" rather than silently pausing.
class HintBanner extends StatelessWidget {
  final String hint;
  final bool isLoading;

  const HintBanner({super.key, required this.hint, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingTokens.voidBlack,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LandingTokens.signal.withValues(alpha: 0.07),
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(
            color: LandingTokens.signal.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LandingTokens.signal,
                ),
              )
            else
              const Icon(
                Icons.smart_toy,
                color: LandingTokens.signal,
                size: 18,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLoading ? '> generating a hint...' : '> hint: $hint',
                style: LandingTokens.mono(
                  fontSize: 13,
                  color: LandingTokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
