import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/user_session.dart';
import '../theme/landing_tokens.dart';
import '../widgets/landing/landing_surface.dart';

/// Screen 5 — the League Map / Level Selector, in the terminal noir style.
/// Presents the curriculum as a numbered mission ledger: locked levels are
/// dimmed and unlock as the previous one is cleared, and cleared levels
/// surface the player's best efficiency score plus a star rating. A learning
/// track filter keeps Python, SQL, Java, and cybersecurity lessons separate.
class LeagueMapScreen extends StatefulWidget {
  final UserSession user;
  final void Function(CurriculumModule module) onLaunch;
  final VoidCallback onBack;

  const LeagueMapScreen({
    super.key,
    required this.user,
    required this.onLaunch,
    required this.onBack,
  });

  @override
  State<LeagueMapScreen> createState() => _LeagueMapScreenState();
}

/// View model for one playable node on the map.
class _LevelEntry {
  final int number;
  final String title;
  final String subtitle;
  final CurriculumModule? module;
  final bool locked;
  final bool completed;
  final int? score;

  const _LevelEntry({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.module,
    required this.locked,
    required this.completed,
    required this.score,
  });
}

/// Brightness-resolved surfaces so the Settings dark/light switch keeps
/// working; dark is the canonical terminal noir.
class _Skin {
  final Color bg;
  final Color panel;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color sub;
  final Color faint;

  const _Skin({
    required this.bg,
    required this.panel,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.sub,
    required this.faint,
  });

  static const dark = _Skin(
    bg: LandingTokens.voidBlack,
    panel: LandingTokens.carbon,
    border: LandingTokens.hairline,
    borderStrong: LandingTokens.hairlineStrong,
    text: LandingTokens.textPrimary,
    sub: LandingTokens.textMuted,
    faint: LandingTokens.textFaint,
  );

  static const light = _Skin(
    bg: Color(0xFFF4F2EC),
    panel: Color(0xFFFFFFFF),
    border: Color(0x1A000000),
    borderStrong: Color(0x33000000),
    text: Color(0xFF16150F),
    sub: Color(0xFF6A6960),
    faint: Color(0xFF9A988D),
  );

  static _Skin of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class _LeagueMapScreenState extends State<LeagueMapScreen> {
  // Start the map on Python; the remaining topic-specific tracks are
  // available from the selector.
  LanguageTrack _track = LanguageTrack.python;

  List<_LevelEntry> _buildEntries() {
    final cleared = widget.user.completedModuleIds;
    final trackModules = Curriculum.modulesForTrack(_track);

    return [
      for (var i = 0; i < trackModules.length; i++)
        _LevelEntry(
          number: i + 1,
          title: trackModules[i].title,
          subtitle: trackModules[i].description,
          module: trackModules[i],
          // Testing mode: every module is launchable without completing a
          // previous module. Completion still records scores and badges.
          locked: false,
          completed: cleared.contains(trackModules[i].id),
          score: widget.user.moduleScores[trackModules[i].id],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final skin = _Skin.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final entries = _buildEntries();

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (dark) const CinematicBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) {
                // Let the map use the available web canvas.  The old 1400px
                // cap created very large empty gutters on wide monitors.
                final sidePadding = viewport.maxWidth >= 900 ? 24.0 : 16.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        16,
                        sidePadding,
                        8,
                      ),
                      child: _Header(
                        track: _track,
                        skin: skin,
                        onBack: widget.onBack,
                        onTrackChanged: (t) => setState(() => _track = t),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sidePadding,
                          8,
                          sidePadding,
                          24,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            onTap(_LevelEntry e) =>
                                (e.locked || e.module == null)
                                ? null
                                : () => widget.onLaunch(e.module!);

                            // Wide: a 2-column grid of level cards fills the
                            // width (connector rail dropped since a grid isn't
                            // a single path). Narrow: the vertical path.
                            if (constraints.maxWidth > 900) {
                              const gap = 16.0;
                              final tileW = (constraints.maxWidth - gap) / 2;
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final e in entries)
                                    SizedBox(
                                      width: tileW,
                                      child: _LevelTile(
                                        entry: e,
                                        skin: skin,
                                        isLast: true,
                                        onTap: onTap(e),
                                      ),
                                    ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                for (var i = 0; i < entries.length; i++)
                                  _LevelTile(
                                    entry: entries[i],
                                    skin: skin,
                                    isLast: i == entries.length - 1,
                                    onTap: onTap(entries[i]),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LanguageTrack track;
  final _Skin skin;
  final VoidCallback onBack;
  final ValueChanged<LanguageTrack> onTrackChanged;

  const _Header({
    required this.track,
    required this.skin,
    required this.onBack,
    required this.onTrackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: skin.panel,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: skin.border),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: skin.borderStrong),
                ),
                child: Icon(Icons.arrow_back, color: skin.text, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '// LEVEL SELECT',
                  style: LandingTokens.label(
                    fontSize: 9,
                    color: LandingTokens.ember,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'LEAGUE MAP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LandingTokens.display(fontSize: 20, color: skin.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _TrackDropdown(track: track, skin: skin, onChanged: onTrackChanged),
        ],
      ),
    );
  }
}

/// Learning-track filter for the map.
class _TrackDropdown extends StatelessWidget {
  final LanguageTrack track;
  final _Skin skin;
  final ValueChanged<LanguageTrack> onChanged;

  const _TrackDropdown({
    required this.track,
    required this.skin,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.ember.withValues(alpha: 0.6)),
        color: LandingTokens.ember.withValues(alpha: 0.08),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LanguageTrack>(
          value: track,
          isDense: true,
          borderRadius: LandingTokens.mediumRadius,
          icon: const Icon(Icons.arrow_drop_down, color: LandingTokens.ember),
          dropdownColor: skin.panel,
          style: LandingTokens.label(
            fontSize: 11,
            color: LandingTokens.ember,
            fontWeight: FontWeight.w700,
          ),
          items: [
            for (final t in LanguageTrack.values)
              DropdownMenuItem(value: t, child: Text(t.label.toUpperCase())),
          ],
          onChanged: (t) {
            if (t != null) onChanged(t);
          },
        ),
      ),
    );
  }
}

/// A single node on the level path: a numbered square on a hairline rail,
/// next to a level card whose footer shows XP to earn (unlocked), stars +
/// efficiency score (cleared), or an unlock/coming-soon hint (locked).
class _LevelTile extends StatefulWidget {
  final _LevelEntry entry;
  final _Skin skin;
  final bool isLast;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.entry,
    required this.skin,
    required this.isLast,
    required this.onTap,
  });

  @override
  State<_LevelTile> createState() => _LevelTileState();
}

class _LevelTileState extends State<_LevelTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final skin = widget.skin;
    final locked = entry.locked;
    final accent = locked
        ? skin.faint
        : (entry.completed ? LandingTokens.signal : LandingTokens.ember);
    final motion = LandingTokens.motionFor(
      context,
      LandingTokens.motionStandard,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left rail: numbered node + hairline connector to the next one.
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: LandingTokens.smallRadius,
                  border: Border.all(color: accent.withValues(alpha: 0.7)),
                ),
                alignment: Alignment.center,
                child: locked
                    ? Icon(Icons.lock, size: 15, color: skin.faint)
                    : Text(
                        entry.number.toString().padLeft(2, '0'),
                        style: LandingTokens.mono(
                          fontSize: 13,
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              if (!widget.isLast)
                Expanded(child: Container(width: 1, color: skin.borderStrong)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16),
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: MouseRegion(
                  cursor: widget.onTap == null
                      ? MouseCursor.defer
                      : SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hovered = true),
                  onExit: (_) => setState(() => _hovered = false),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: AnimatedContainer(
                      duration: motion,
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.translationValues(
                        0,
                        _hovered && widget.onTap != null ? -3 : 0,
                        0,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: skin.panel,
                        borderRadius: LandingTokens.mediumRadius,
                        border: Border.all(
                          color: _hovered && widget.onTap != null
                              ? accent.withValues(alpha: 0.65)
                              : skin.border,
                        ),
                        boxShadow: LandingTokens.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: skin.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (entry.completed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: LandingTokens.smallRadius,
                                    border: Border.all(
                                      color: LandingTokens.signal.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    color: LandingTokens.signal.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                  child: Text(
                                    'CLEARED',
                                    style: LandingTokens.label(
                                      fontSize: 8.5,
                                      color: LandingTokens.signal,
                                    ),
                                  ),
                                )
                              else if (locked)
                                Icon(Icons.lock, size: 16, color: skin.faint),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: LandingTokens.body(
                              fontSize: 12,
                              color: skin.sub,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Footer(entry: entry, skin: skin),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final _LevelEntry entry;
  final _Skin skin;

  const _Footer({required this.entry, required this.skin});

  int get _stars {
    final score = entry.score;
    final reward = entry.module?.xpReward ?? 0;
    if (score == null || reward <= 0) return 1;
    final ratio = score / reward;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (entry.locked) {
      return Text(
        entry.module == null
            ? '// COMING SOON'
            : '// CLEAR THE PREVIOUS LEVEL TO UNLOCK',
        style: LandingTokens.label(fontSize: 9, color: skin.faint),
      );
    }

    if (entry.completed) {
      // Wrap keeps the stars, score, and replay chip from overflowing on
      // narrow phones — they flow onto a second line instead.
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Icon(
                  i < _stars ? Icons.star : Icons.star_border,
                  size: 16,
                  color: i < _stars ? LandingTokens.ember : skin.faint,
                ),
            ],
          ),
          Text(
            '${entry.score ?? 0} PTS',
            style: LandingTokens.mono(
              fontSize: 12,
              color: skin.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const _ActionChip(
            label: 'REPLAY',
            icon: Icons.refresh,
            filled: false,
          ),
        ],
      );
    }

    // Unlocked, not yet completed.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '+${entry.module!.xpReward} XP',
          style: LandingTokens.mono(
            fontSize: 12,
            color: LandingTokens.ember,
            fontWeight: FontWeight.w700,
          ),
        ),
        const _ActionChip(label: 'PLAY', icon: Icons.play_arrow, filled: true),
      ],
    );
  }
}

/// Small decorative affordance chip; the whole level card handles the tap.
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? const Color(0xFF0A0500) : LandingTokens.ember;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? LandingTokens.ember : Colors.transparent,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(
          color: filled
              ? LandingTokens.ember
              : LandingTokens.ember.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: LandingTokens.label(
              fontSize: 9.5,
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: fg),
        ],
      ),
    );
  }
}
