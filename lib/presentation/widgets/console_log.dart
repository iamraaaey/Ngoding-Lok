import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Shared scrolling black/green console log used by every game screen.
/// Extracted from the original grid-only inline log container so
/// Grid/SQL/Rocket don't each duplicate the same widget.
class ConsoleLog extends StatelessWidget {
  final List<String> logs;

  const ConsoleLog({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DoodlePalette.dark,
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 120,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DoodlePalette.green, width: 2),
        ),
        child: ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, idx) => Text(
            logs[idx],
            style: const TextStyle(
              fontFamily: 'monospace',
              color: DoodlePalette.green,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
