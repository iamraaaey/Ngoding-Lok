import 'package:flutter/material.dart';
import '../../core/timer/game_timer_controller.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';

/// Shared chrome bar for every game screen, in the terminal noir style:
/// back button, title/icon, live timer, hint-via-ad button, and the Run
/// button. Fully responsive — adapts to mobile/tablet/desktop. Stateless — all
/// state is owned by the parent screen; this widget never mutates anything.
class GameHeader extends StatefulWidget {
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
  State<GameHeader> createState() => _GameHeaderState();
}

class _GameHeaderState extends State<GameHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

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
            final isExtraSmall = constraints.maxWidth < 360;
            final isSmall = constraints.maxWidth < 560;
            final isMedium = constraints.maxWidth < 900;
            final isLarge = constraints.maxWidth >= 900;

            final backButton = _AnimatedHeaderButton(
              tooltip: 'Back to dashboard',
              icon: Icons.dashboard,
              onPressed: widget.onBack,
              controller: _hoverController,
            );

            final moduleIcon = Container(
              width: isExtraSmall ? 28 : 34,
              height: isExtraSmall ? 28 : 34,
              decoration: BoxDecoration(
                color: LandingTokens.ember.withValues(alpha: 0.1),
                borderRadius: LandingTokens.smallRadius,
                border: Border.all(
                  color: LandingTokens.ember.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(
                widget.icon,
                color: LandingTokens.ember,
                size: isExtraSmall ? 14 : 17,
              ),
            );

            final titleBlock = Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: LandingTokens.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: isExtraSmall ? 13 : 15,
              ),
            );

            final timer = _GameTimer(
              timerController: widget.timerController,
              compact: isSmall,
            );

            final hintButton = CinematicOutlineButton(
              onPressed: widget.hasHint ? null : widget.onGetHint,
              icon: Icons.lightbulb,
              label: widget.hasHint ? 'Hint Unlocked' : 'Get Hint (Ad)',
              compact: true,
            );

            final runButton = GradientButton(
              onPressed: (widget.isExecuting || widget.isSyncing) ? null : widget.onRun,
              icon: widget.isSyncing ? Icons.sync : Icons.play_arrow,
              label: widget.isSyncing ? 'Syncing...' : 'Compile & Run',
              compact: true,
            );

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      backButton,
                      const SizedBox(width: 8),
                      moduleIcon,
                      const SizedBox(width: 8),
                      Expanded(child: titleBlock),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: isExtraSmall ? 6 : 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        timer,
                        _AnimatedHeaderButton(
                          tooltip: widget.hasHint ? 'Hint unlocked' : 'Get hint with ad',
                          icon: Icons.lightbulb,
                          onPressed: widget.hasHint ? null : widget.onGetHint,
                          controller: _hoverController,
                          compact: true,
                        ),
                        GradientButton(
                          onPressed: (widget.isExecuting || widget.isSyncing) ? null : widget.onRun,
                          icon: widget.isSyncing ? Icons.sync : Icons.play_arrow,
                          label: isExtraSmall ? 'Run' : 'Compile & Run',
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: isMedium ? 12 : 16,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: isLarge ? 320 : constraints.maxWidth,
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

class _AnimatedHeaderButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final AnimationController controller;
  final bool compact;

  const _AnimatedHeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.controller,
    this.compact = false,
  });

  @override
  State<_AnimatedHeaderButton> createState() => _AnimatedHeaderButtonState();
}

class _AnimatedHeaderButtonState extends State<_AnimatedHeaderButton> {
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut),
    );
  }

  void _onHover(bool isHovering) {
    if (isHovering && widget.onPressed != null) {
      widget.controller.forward();
    } else {
      widget.controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: MouseRegion(
      cursor: widget.onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Opacity(
            opacity: widget.onPressed == null ? 0.45 : 1,
            child: Container(
              width: widget.compact ? 32 : 34,
              height: widget.compact ? 32 : 34,
              decoration: BoxDecoration(
                borderRadius: LandingTokens.smallRadius,
                border: Border.all(color: LandingTokens.hairlineStrong),
              ),
              child: Icon(
                widget.icon,
                color: LandingTokens.textPrimary,
                size: widget.compact ? 14 : 16,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _GameTimer extends StatelessWidget {
  final GameTimerController timerController;
  final bool compact;

  const _GameTimer({
    required this.timerController,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 10,
      vertical: compact ? 6 : 8,
    ),
    decoration: BoxDecoration(
      color: LandingTokens.voidBlack,
      borderRadius: LandingTokens.smallRadius,
      border: Border.all(color: LandingTokens.hairlineStrong),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: compact ? 11 : 13,
          color: LandingTokens.textMuted,
        ),
        const SizedBox(width: 4),
        ValueListenableBuilder<int>(
          valueListenable: timerController.elapsedSeconds,
          builder: (context, seconds, _) => Text(
            GameTimerController.format(seconds),
            style: LandingTokens.mono(
              fontSize: compact ? 10 : 12,
              color: LandingTokens.signal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
