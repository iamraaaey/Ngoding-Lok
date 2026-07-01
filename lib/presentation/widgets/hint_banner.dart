import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Banner shown under [GameHeader] once a module's hint has been unlocked
/// via the rewarded-ad flow. While the Socratic Hint Engine request is in
/// flight, [isLoading] renders a spinner in place of [hint] so the ad-hint
/// flow reads as "your hint is on its way" rather than silently pausing.
class HintBanner extends StatelessWidget {
  final String hint;
  final bool isLoading;

  const HintBanner({super.key, required this.hint, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DoodlePalette.dark,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DoodlePalette.yellow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            else
              const Icon(Icons.smart_toy, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isLoading ? 'Generating a hint...' : 'Hint: $hint',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
