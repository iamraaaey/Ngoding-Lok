import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';

/// Shared scrolling terminal console log used by every game screen.
/// Extracted from the original grid-only inline log container so
/// Grid/SQL/Rocket don't each duplicate the same widget.
class ConsoleLog extends StatelessWidget {
  final List<String> logs;

  const ConsoleLog({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingTokens.voidBlack,
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 120,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(color: LandingTokens.hairlineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: LandingTokens.hairline),
                ),
              ),
              child: Text(
                '~/CONSOLE.LOG',
                style: LandingTokens.label(
                  fontSize: 8.5,
                  color: LandingTokens.textFaint,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: logs.length,
                itemBuilder: (context, idx) => Text(
                  logs[idx],
                  style: LandingTokens.mono(
                    fontSize: 12,
                    color: LandingTokens.signal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
