import 'package:flutter/material.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/user_session.dart';
import '../../core/social/code_golf.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/landing/landing_surface.dart';

/// Screen 9 — Code Golf Leaderboards, in the terminal noir style. Players are
/// ranked strictly by byte count (shortest solution wins). A Global/Friends
/// scope filter and a per-language tab narrow the board. Tapping a row expands
/// it to reveal the exact winning source — but only if the current player has
/// themselves cleared that level, otherwise the solution stays locked.
class CodeGolfScreen extends StatefulWidget {
  final UserSession user;
  final VoidCallback onBack;

  const CodeGolfScreen({super.key, required this.user, required this.onBack});

  @override
  State<CodeGolfScreen> createState() => _CodeGolfScreenState();
}

class _CodeGolfScreenState extends State<CodeGolfScreen> {
  bool _friendsOnly = false;
  LanguageTrack _track = LanguageTrack.python;
  String? _expandedKey;

  Widget _rowFor(CodeGolfEntry e, int i, NoirSkin skin) {
    final key = '${e.player}-${e.moduleId}';
    return _GolfRow(
      rank: i + 1,
      entry: e,
      skin: skin,
      unlocked: widget.user.completedModuleIds.contains(e.moduleId),
      expanded: _expandedKey == key,
      onToggle: () =>
          setState(() => _expandedKey = _expandedKey == key ? null : key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);

    final entries = CodeGolf.forTrack(
      _track,
    ).where((e) => !_friendsOnly || e.isFriend).toList();
    final emptyMessage = _friendsOnly
        ? 'No friends have posted a score for this track yet.'
        : 'No Code Golf entries for this track yet.';

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: NoirHeader(
                        title: 'Code Golf',
                        eyebrow: 'Fewest bytes wins',
                        skin: skin,
                        onBack: widget.onBack,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SegTabs(
                        options: const ['Global', 'Friends'],
                        selected: _friendsOnly ? 1 : 0,
                        skin: skin,
                        onSelected: (i) =>
                            setState(() => _friendsOnly = i == 1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SegTabs(
                        options: [
                          for (final t in LanguageTrack.values) t.shortLabel,
                        ],
                        selected: _track.index,
                        skin: skin,
                        onSelected: (i) => setState(() {
                          _track = LanguageTrack.values[i];
                          _expandedKey = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                      child: Text(
                        '// RANKED BY FEWEST BYTES',
                        style: LandingTokens.label(
                          fontSize: 9.5,
                          color: skin.faint,
                        ),
                      ),
                    ),
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                              child: Text(
                                emptyMessage,
                                style: LandingTokens.body(
                                  fontSize: 14,
                                  color: skin.sub,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final rows = [
                                    for (var i = 0; i < entries.length; i++)
                                      _rowFor(entries[i], i, skin),
                                  ];
                                  // Wide: two columns of ranked cards fill the
                                  // width; reading order keeps the ranking.
                                  if (constraints.maxWidth <= 900) {
                                    return Column(children: rows);
                                  }
                                  const gap = 16.0;
                                  final tileW =
                                      (constraints.maxWidth - gap) / 2;
                                  return Wrap(
                                    spacing: gap,
                                    children: [
                                      for (final r in rows)
                                        SizedBox(width: tileW, child: r),
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
        ],
      ),
    );
  }
}

/// Segmented control: a hairline bar with one active ember segment.
class _SegTabs extends StatelessWidget {
  final List<String> options;
  final int selected;
  final NoirSkin skin;
  final ValueChanged<int> onSelected;

  const _SegTabs({
    required this.options,
    required this.selected,
    required this.skin,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: skin.panel,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: skin.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: AnimatedContainer(
                    duration: LandingTokens.motionFor(
                      context,
                      LandingTokens.motionFast,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? LandingTokens.ember
                          : Colors.transparent,
                      borderRadius: LandingTokens.smallRadius,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      options[i].toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LandingTokens.label(
                        fontSize: 10,
                        color: i == selected
                            ? const Color(0xFF0A0500)
                            : skin.sub,
                        fontWeight: FontWeight.w700,
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

class _GolfRow extends StatelessWidget {
  final int rank;
  final CodeGolfEntry entry;
  final NoirSkin skin;
  final bool unlocked;
  final bool expanded;
  final VoidCallback onToggle;

  const _GolfRow({
    required this.rank,
    required this.entry,
    required this.skin,
    required this.unlocked,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NoirPanel(
        skin: skin,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '#$rank',
                        style: LandingTokens.mono(
                          fontSize: 12,
                          color: rank == 1 ? LandingTokens.ember : skin.faint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(entry.avatar, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  entry.player,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: skin.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (entry.isFriend) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.people,
                                  size: 13,
                                  color: LandingTokens.circuit,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entry.moduleTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LandingTokens.label(
                              fontSize: 9,
                              color: skin.faint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.bytes} B',
                          style: LandingTokens.mono(
                            fontSize: 16,
                            color: skin.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: skin.faint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              if (unlocked)
                _CodeBlock(source: entry.source)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: skin.panelRaised,
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(color: skin.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: skin.faint),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Beat this level yourself to view the winning solution.',
                          style: LandingTokens.body(
                            fontSize: 12,
                            color: skin.sub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String source;

  const _CodeBlock({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LandingTokens.voidBlack,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.hairlineStrong),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          source,
          style: LandingTokens.mono(fontSize: 13, color: LandingTokens.signal),
        ),
      ),
    );
  }
}
