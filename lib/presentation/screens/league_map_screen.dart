import 'package:flutter/material.dart';
import '../../core/curriculum/curriculum.dart';
import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/user_session.dart';
import '../theme/doodle.dart';

/// Screen 5 — the League Map / Level Selector. Presents the curriculum as a
/// scrolling vertical path of levels: locked levels are grayed out and unlock
/// as the previous one is cleared, and cleared levels surface the player's
/// best efficiency score plus a star rating. A track filter switches the
/// map's programming language — only the Python track is playable in this
/// prototype, with the Java track shown as a locked "coming soon" preview.
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

/// View model for one node on the map. [module] is null for coming-soon
/// placeholders (the Java track), which carry no playable content.
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

class _LeagueMapScreenState extends State<LeagueMapScreen> {
  LanguageTrack _track = LanguageTrack.cybersecurity;

  List<_LevelEntry> _buildEntries() {
    final cleared = widget.user.completedModuleIds;
    final trackModules = Curriculum.modules
        .where((m) => m.track == _track)
        .toList();

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DoodlePalette.dark : DoodlePalette.cream;
    final entries = _buildEntries();
    return Scaffold(
      backgroundColor: bg,
      body: DoodleDotBackground(
        backgroundColor: bg,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _Header(
                      track: _track,
                      onBack: widget.onBack,
                      onTrackChanged: (t) => setState(() => _track = t),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          onTap(_LevelEntry e) => (e.locked || e.module == null)
                              ? null
                              : () => widget.onLaunch(e.module!);

                          // Wide: a 2-column grid of level cards fills the
                          // width (connector rail dropped since a grid isn't a
                          // single path). Narrow: the vertical path with rails.
                          if (constraints.maxWidth > 900) {
                            const gap = 16.0;
                            final tileW = (constraints.maxWidth - gap) / 2;
                            return Wrap(
                              spacing: gap,
                              children: [
                                for (final e in entries)
                                  SizedBox(
                                    width: tileW,
                                    child: _LevelTile(
                                      entry: e,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LanguageTrack track;
  final VoidCallback onBack;
  final ValueChanged<LanguageTrack> onTrackChanged;

  const _Header({
    required this.track,
    required this.onBack,
    required this.onTrackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const DoodleIconBadge(
              icon: Icons.arrow_back,
              color: DoodlePalette.white,
              iconColor: Colors.black,
              size: 40,
              iconSize: 20,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'League Map',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _TrackDropdown(track: track, onChanged: onTrackChanged),
        ],
      ),
    );
  }
}

/// Language filter — switches the map between programming-language tracks.
class _TrackDropdown extends StatelessWidget {
  final LanguageTrack track;
  final ValueChanged<LanguageTrack> onChanged;

  const _TrackDropdown({required this.track, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: DoodlePalette.yellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LanguageTrack>(
          value: track,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          dropdownColor: DoodlePalette.white,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          items: [
            for (final t in LanguageTrack.values)
              DropdownMenuItem(value: t, child: Text(t.label)),
          ],
          onChanged: (t) {
            if (t != null) onChanged(t);
          },
        ),
      ),
    );
  }
}

/// A single node on the level path: a numbered/locked circle on a connector
/// rail, next to a level card whose footer shows XP to earn (unlocked), stars
/// + efficiency score (cleared), or an unlock/coming-soon hint (locked).
class _LevelTile extends StatelessWidget {
  final _LevelEntry entry;
  final bool isLast;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = entry.locked;
    final accent = locked
        ? const Color(0xFFB8B8B8)
        : (entry.completed ? DoodlePalette.green : DoodlePalette.blue);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left rail: node circle + connector line down to the next node.
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                alignment: Alignment.center,
                child: locked
                    ? const Icon(Icons.lock, size: 18, color: Colors.black)
                    : Text(
                        '${entry.number}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4,
                    color: Colors.black.withValues(alpha: 0.22),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Opacity(
                opacity: locked ? 0.6 : 1,
                child: GestureDetector(
                  onTap: onTap,
                  child: DoodleCard(
                    color: locked
                        ? const Color(0xFFECECEC)
                        : DoodlePalette.white,
                    padding: const EdgeInsets.all(16),
                    borderRadius: 18,
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
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (entry.completed)
                              const DoodlePill(
                                text: 'Cleared',
                                background: DoodlePalette.green,
                              )
                            else if (locked)
                              const Icon(
                                Icons.lock,
                                size: 18,
                                color: Colors.black45,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Footer(entry: entry),
                      ],
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
  const _Footer({required this.entry});

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
            ? 'Coming soon'
            : 'Clear the previous level to unlock',
        style: const TextStyle(
          color: Colors.black45,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
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
                  size: 18,
                  color: i < _stars ? DoodlePalette.orange : Colors.black38,
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: 15, color: Colors.black),
              const SizedBox(width: 3),
              Text(
                '${entry.score ?? 0} pts',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const _ActionChip(
            label: 'Replay',
            icon: Icons.refresh,
            color: DoodlePalette.yellow,
          ),
        ],
      );
    }

    // Unlocked, not yet completed.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 15, color: Colors.black),
            const SizedBox(width: 3),
            Text(
              '+${entry.module!.xpReward} XP',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const _ActionChip(
          label: 'Play',
          icon: Icons.play_arrow,
          color: DoodlePalette.green,
        ),
      ],
    );
  }
}

/// Small decorative affordance chip; the whole level card handles the tap.
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 15, color: Colors.black),
        ],
      ),
    );
  }
}
