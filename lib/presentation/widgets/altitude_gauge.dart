import 'package:flutter/material.dart';
import '../../core/state/rocket_state.dart';
import '../theme/doodle.dart';

/// Pure render of a [RocketState] snapshot: a vertical progress gauge plus
/// altitude/engine readouts. Kept stateless like [GameCanvas] — all
/// animation/timing is owned by the parent screen.
class AltitudeGauge extends StatelessWidget {
  final RocketState state;

  const AltitudeGauge({super.key, required this.state});

  String get _engineLabel {
    if (state.exploded) return 'EXPLODED';
    if (state.engineStarted) return 'IGNITED';
    if (state.preflightDone) return 'READY';
    return 'OFFLINE';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (state.altitude / state.targetAltitude).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoodlePalette.orange, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALT: ${state.altitude}m / ${state.targetAltitude}m',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
              Text('ENG: $_engineLabel',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: state.exploded ? DoodlePalette.red : DoodlePalette.green,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white24,
              color: state.exploded ? DoodlePalette.red : DoodlePalette.orange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.exploded ? '\u{1F4A5}' : '\u{1F680}',
            style: const TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }
}
