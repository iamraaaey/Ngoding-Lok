import 'package:flutter/material.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';

/// Shared chrome bar for every game screen, in the terminal noir style:
/// back button, title/icon, live timer, hint-via-ad button, and the Run
/// button. Stateless — all state (hint status, sync status, timer) is owned
/// by the parent screen and passed in; this widget never mutates anything
/// itself.
class GameHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final GameTimerController timerController;
  final bool hasHint;
  final bool isExecuting;
  final bool isSyncing;
  final VoidCallback onBack;
  final VoidCallback? onGetHint;
  final VoidCallback onRun;

  const GameHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.timerController,
    required this.hasHint,
    required this.isExecuting,
    required this.isSyncing,
    required this.onBack,
    required this.onGetHint,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingTokens.voidBlack,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: LandingTokens.carbon,
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(color: LandingTokens.hairline),
          boxShadow: LandingTokens.cardShadow,
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: LandingTokens.smallRadius,
                        border: Border.all(
                          color: LandingTokens.hairlineStrong,
                        ),
                      ),
                      child: const Icon(
                        Icons.dashboard,
                        color: LandingTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: LandingTokens.ember.withValues(alpha: 0.1),
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(
                      color: LandingTokens.ember.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Icon(icon, color: LandingTokens.ember, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: LandingTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: LandingTokens.voidBlack,
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(color: LandingTokens.hairlineStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: LandingTokens.textMuted,
                      ),
                      const SizedBox(width: 5),
                      ValueListenableBuilder<int>(
                        valueListenable: timerController.elapsedSeconds,
                        builder: (context, seconds, _) => Text(
                          GameTimerController.format(seconds),
                          style: LandingTokens.mono(
                            fontSize: 12,
                            color: LandingTokens.signal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CinematicOutlineButton(
                  onPressed: hasHint ? null : onGetHint,
                  icon: Icons.lightbulb,
                  label: hasHint ? 'Hint Unlocked' : 'Get Hint (Ad)',
                  compact: true,
                ),
                const SizedBox(width: 8),
                GradientButton(
                  onPressed: (isExecuting || isSyncing) ? null : onRun,
                  icon: isSyncing ? Icons.sync : Icons.play_arrow,
                  label: isSyncing ? 'Syncing...' : 'Compile & Run',
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
