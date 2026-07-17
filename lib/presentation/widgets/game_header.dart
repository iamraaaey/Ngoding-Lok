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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final backButton = _HeaderIconButton(
              tooltip: 'Back to dashboard',
              icon: Icons.dashboard,
              onPressed: onBack,
            );
            final moduleIcon = Container(
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
            );
            final titleBlock = Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LandingTokens.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            );
            final timer = _GameTimer(timerController: timerController);
            final hintButton = CinematicOutlineButton(
              onPressed: hasHint ? null : onGetHint,
              icon: Icons.lightbulb,
              label: hasHint ? 'Hint Unlocked' : 'Get Hint (Ad)',
              compact: true,
            );
            final runButton = GradientButton(
              onPressed: (isExecuting || isSyncing) ? null : onRun,
              icon: isSyncing ? Icons.sync : Icons.play_arrow,
              label: isSyncing ? 'Syncing...' : 'Compile & Run',
              compact: true,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      backButton,
                      const SizedBox(width: 10),
                      moduleIcon,
                      const SizedBox(width: 10),
                      Expanded(child: titleBlock),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      timer,
                      _HeaderIconButton(
                        tooltip: hasHint ? 'Hint unlocked' : 'Get hint with ad',
                        icon: Icons.lightbulb,
                        onPressed: hasHint ? null : onGetHint,
                      ),
                      GradientButton(
                        onPressed: (isExecuting || isSyncing) ? null : onRun,
                        icon: isSyncing ? Icons.sync : Icons.play_arrow,
                        label: isSyncing ? 'Syncing' : 'Run',
                        compact: true,
                      ),
                    ],
                  ),
                ],
              );
            }

            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: constraints.maxWidth >= 900
                      ? 320
                      : constraints.maxWidth,
                  child: Row(
                    children: [
                      backButton,
                      const SizedBox(width: 10),
                      moduleIcon,
                      const SizedBox(width: 10),
                      Expanded(child: titleBlock),
                    ],
                  ),
                ),
                timer,
                hintButton,
                runButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: MouseRegion(
      cursor: onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Opacity(
          opacity: onPressed == null ? 0.45 : 1,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(color: LandingTokens.hairlineStrong),
            ),
            child: Icon(icon, color: LandingTokens.textPrimary, size: 16),
          ),
        ),
      ),
    ),
  );
}

class _GameTimer extends StatelessWidget {
  final GameTimerController timerController;
  const _GameTimer({required this.timerController});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: LandingTokens.voidBlack,
      borderRadius: LandingTokens.smallRadius,
      border: Border.all(color: LandingTokens.hairlineStrong),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 13, color: LandingTokens.textMuted),
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
  );
}
