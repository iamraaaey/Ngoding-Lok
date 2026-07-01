import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Line-numbered multiline text field container for entering NgeCode Juh!
/// script commands (e.g. `move.right();`).
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
      color: DoodlePalette.dark,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LineNumberGutter(controller: controller, activeLineIndex: activeLineIndex),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: '// Input commands:\nmove.right();\nmove.down();',
                  hintStyle: TextStyle(fontFamily: 'monospace', color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
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

  const _LineNumberGutter({required this.controller, required this.activeLineIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lineCount = controller.text.split('\n').length;
        return Container(
          width: 36,
          padding: const EdgeInsets.only(top: 12),
          decoration: const BoxDecoration(
            color: DoodlePalette.cream,
            border: Border(right: BorderSide(color: Colors.black, width: 2)),
          ),
          child: Column(
            children: List.generate(lineCount, (i) {
              final isActive = i == activeLineIndex;
              return Text(
                '${i + 1}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
                  color: isActive ? DoodlePalette.blue : Colors.black38,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
