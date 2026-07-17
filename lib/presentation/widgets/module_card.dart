import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_type.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';

/// Curriculum module tile in the terminal noir style: carbon panel, hairline
/// border that warms up on hover, accent-tinted module glyph, mono metadata,
/// and an ember Launch CTA.
class ModuleCard extends StatefulWidget {
  final CurriculumModule module;
  final bool isCompleted;
  final VoidCallback onLaunch;

  const ModuleCard({
    super.key,
    required this.module,
    required this.isCompleted,
    required this.onLaunch,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _hovered = false;

  IconData get _icon => switch (widget.module.type) {
    ModuleType.logicGrid => Icons.videogame_asset,
    ModuleType.sqlTerminal => Icons.storage,
    ModuleType.rocketFlight => Icons.rocket_launch,
    ModuleType.cybersecurityRoom => Icons.shield_outlined,
    ModuleType.arduinoSimulator => Icons.memory_rounded,
  };

  /// Accents stay inside the theme's three permitted hues.
  Color get _accent => switch (widget.module.type) {
    ModuleType.logicGrid => LandingTokens.circuit,
    ModuleType.sqlTerminal => LandingTokens.ember,
    ModuleType.rocketFlight => LandingTokens.ember,
    ModuleType.cybersecurityRoom => LandingTokens.signal,
    ModuleType.arduinoSimulator => LandingTokens.circuit,
  };

  @override
  Widget build(BuildContext context) {
    final motion = LandingTokens.motionFor(context, LandingTokens.motionFast);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: motion,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? LandingTokens.panel : LandingTokens.carbon,
          borderRadius: LandingTokens.mediumRadius,
          border: Border.all(
            color: _hovered
                ? LandingTokens.hairlineStrong
                : LandingTokens.hairline,
          ),
          boxShadow: LandingTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Icon(_icon, color: _accent, size: 19),
                ),
                if (widget.isCompleted) const _ClearedChip(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              widget.module.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LandingTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.module.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LandingTokens.body(fontSize: 12.5),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '+${widget.module.xpReward} XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LandingTokens.mono(
                      fontSize: 12,
                      color: LandingTokens.ember,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  key: Key('launch-${widget.module.id}'),
                  label: 'Launch',
                  compact: true,
                  onPressed: widget.onLaunch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mono "CLEARED" status chip with the signal-green live dot.
class _ClearedChip extends StatelessWidget {
  const _ClearedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LandingTokens.signal.withValues(alpha: 0.08),
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.signal.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, color: LandingTokens.signal),
          const SizedBox(width: 6),
          Text(
            'CLEARED',
            style: LandingTokens.label(
              fontSize: 9,
              color: LandingTokens.signal,
            ),
          ),
        ],
      ),
    );
  }
}
