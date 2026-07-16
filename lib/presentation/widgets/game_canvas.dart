import 'package:flutter/material.dart';
import '../../core/state/game_state.dart';
import '../theme/landing_tokens.dart';

/// Renders the abstract game grid from a [GameState] snapshot in the
/// terminal noir style: hairline board, ember player, signal-green flag.
/// Kept as a pure function of state so rebuilds are cheap and predictable
/// even during long execution queues.
class GameCanvas extends StatelessWidget {
  final GameState state;

  const GameCanvas({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingTokens.voidBlack,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LandingTokens.carbon,
              borderRadius: LandingTokens.mediumRadius,
              border: Border.all(color: LandingTokens.hairlineStrong),
              boxShadow: LandingTokens.cardShadow,
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
                        ? LandingTokens.ember
                        : isTarget
                            ? LandingTokens.signal.withValues(alpha: 0.16)
                            : LandingTokens.panelRaised,
                    border: Border.all(
                      color: isPlayer
                          ? LandingTokens.emberBright
                          : isTarget
                              ? LandingTokens.signal.withValues(alpha: 0.6)
                              : LandingTokens.hairline,
                    ),
                    borderRadius: LandingTokens.smallRadius,
                    boxShadow: isPlayer ? LandingTokens.emberGlow : null,
                  ),
                  child: Center(
                    child: isPlayer
                        ? const Icon(
                            Icons.smart_button,
                            color: Color(0xFF0A0500),
                          )
                        : isTarget
                            ? const Icon(
                                Icons.flag,
                                color: LandingTokens.signal,
                              )
                            : Text(
                                '$x,$y',
                                style: LandingTokens.mono(
                                  fontSize: 9,
                                  color: LandingTokens.textFaint,
                                ),
                              ),
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
