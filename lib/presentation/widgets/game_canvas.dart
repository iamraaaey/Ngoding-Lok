import 'package:flutter/material.dart';
import '../../core/state/game_state.dart';
import '../theme/doodle.dart';

/// Renders the abstract game grid from a [GameState] snapshot. Kept as a
/// pure function of state so rebuilds are cheap and predictable even during
/// long execution queues.
class GameCanvas extends StatelessWidget {
  final GameState state;

  const GameCanvas({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DoodlePalette.dark,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DoodlePalette.green,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: state.gridSize,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: state.gridSize * state.gridSize,
              itemBuilder: (context, index) {
                final x = index % state.gridSize;
                final y = index ~/ state.gridSize;
                final isPlayer = x == state.playerX && y == state.playerY;
                final isTarget = x == state.targetX && y == state.targetY;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? DoodlePalette.red
                        : isTarget
                            ? DoodlePalette.yellow
                            : Colors.white.withValues(alpha: 0.5),
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: isPlayer
                        ? const Icon(Icons.smart_button, color: Colors.white)
                        : isTarget
                            ? const Icon(Icons.flag, color: Colors.black)
                            : Text('$x,$y', style: const TextStyle(fontSize: 10, color: Colors.black26)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
