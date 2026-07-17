import 'package:flutter/material.dart';
import '../../core/state/rocket_state.dart';
import '../theme/landing_tokens.dart';

/// Pure render of a [RocketState] snapshot: a vertical progress gauge plus
/// altitude/engine readouts, styled as a terminal noir instrument panel.
/// Kept stateless like [GameCanvas] — all animation/timing is owned by the
/// parent screen.
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
    const alertRed = Color(0xFFFF4D5E);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairlineStrong),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                'ALT: ${state.altitude}m / ${state.targetAltitude}m',
                style: LandingTokens.mono(
                  fontSize: 12,
                  color: LandingTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'ENG: $_engineLabel',
                style: LandingTokens.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: state.exploded ? alertRed : LandingTokens.signal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: LandingTokens.hairline),
              color: LandingTokens.voidBlack,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: state.exploded ? alertRed : LandingTokens.ember,
                  boxShadow: [
                    BoxShadow(
                      color: (state.exploded ? alertRed : LandingTokens.ember)
                          .withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
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
