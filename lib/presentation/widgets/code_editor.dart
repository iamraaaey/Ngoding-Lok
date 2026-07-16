import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';

/// Line-numbered multiline text field container for entering Ngoding Lok
/// script commands (e.g. `move.right();`), styled as a terminal noir
/// editor: near-black field, hairline chrome, ember active line.
class CodeEditor extends StatelessWidget {
  final TextEditingController controller;
  final int activeLineIndex;

  const CodeEditor({
    super.key,
    required this.controller,
    this.activeLineIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingTokens.voidBlack,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: LandingTokens.carbon,
          border: Border.all(color: LandingTokens.hairlineStrong),
          borderRadius: LandingTokens.mediumRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LineNumberGutter(
              controller: controller,
              activeLineIndex: activeLineIndex,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                cursorColor: LandingTokens.ember,
                style: LandingTokens.mono(
                  fontSize: 14,
                  color: LandingTokens.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '// Input commands:\nmove.right();\nmove.down();',
                  hintStyle: LandingTokens.mono(
                    fontSize: 14,
                    color: LandingTokens.textFaint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineNumberGutter extends StatelessWidget {
  final TextEditingController controller;
  final int activeLineIndex;

  const _LineNumberGutter({
    required this.controller,
    required this.activeLineIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lineCount = controller.text.split('\n').length;
        return Container(
          width: 36,
          padding: const EdgeInsets.only(top: 12, right: 6),
          decoration: const BoxDecoration(
            color: LandingTokens.voidBlack,
            border: Border(
              right: BorderSide(color: LandingTokens.hairline),
            ),
          ),
          child: Column(
            children: List.generate(lineCount, (i) {
              final isActive = i == activeLineIndex;
              return Text(
                '${i + 1}',
                textAlign: TextAlign.right,
                style: LandingTokens.mono(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive
                      ? LandingTokens.ember
                      : LandingTokens.textFaint,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
