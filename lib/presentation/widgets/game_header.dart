import 'package:flutter/material.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/doodle.dart';

/// Shared chrome bar for every game screen: back button, title/icon, live
/// timer, hint-via-ad button, and the Run button. Stateless — all state
/// (hint status, sync status, timer) is owned by the parent screen and
/// passed in; this widget never mutates anything itself.
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
      color: DoodlePalette.dark,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: DoodleCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.dashboard, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 4),
                DoodleIconBadge(icon: icon, color: DoodlePalette.blue, size: 34, iconSize: 18, borderRadius: 10),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: DoodlePalette.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      ValueListenableBuilder<int>(
                        valueListenable: timerController.elapsedSeconds,
                        builder: (context, seconds, _) => Text(
                          GameTimerController.format(seconds),
                          style: const TextStyle(color: Colors.black, fontFamily: 'monospace', fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DoodleButton(
                  onPressed: hasHint ? null : onGetHint,
                  color: hasHint ? DoodlePalette.green : DoodlePalette.yellow,
                  icon: Icons.lightbulb,
                  label: hasHint ? 'Hint Unlocked' : 'Get Hint (Ad)',
                  dense: true,
                ),
                const SizedBox(width: 8),
                DoodleButton(
                  onPressed: (isExecuting || isSyncing) ? null : onRun,
                  color: DoodlePalette.orange,
                  icon: isSyncing ? null : Icons.play_arrow,
                  isLoading: isSyncing,
                  label: isSyncing ? 'Syncing...' : 'Compile & Run',
                  dense: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
