import 'package:flutter/material.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/user_session.dart';
import '../../core/social/code_golf.dart';
import '../../data/repositories/user_repository.dart';
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
  final String? uid;
  final UserRepository repository;
  final VoidCallback onBack;

  const CodeGolfScreen({
    super.key,
    required this.user,
    required this.uid,
    required this.repository,
    required this.onBack,
  });

  @override
  State<CodeGolfScreen> createState() => _CodeGolfScreenState();
}

class _CodeGolfScreenState extends State<CodeGolfScreen> {
  static const _golfTracks = <LanguageTrack>[
    LanguageTrack.python,
    LanguageTrack.sql,
    LanguageTrack.java,
  ];
  bool _friendsOnly = false;
  int _boardMode = 0; // 0: Bytes (golf), 1: Speed (time), 2: Accuracy
  LanguageTrack _track = LanguageTrack.python;
  String? _expandedKey;
  DateTime? _lastSnapshotAt;

  Widget _rowFor(CodeGolfEntry e, int i, NoirSkin skin) {
    final key = '${e.uid}-${e.moduleId}';
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

  List<CodeGolfEntry> _sortEntries(List<CodeGolfEntry> entries) {
    switch (_boardMode) {
      case 0: // Bytes (golf)
        return entries..sort((a, b) {
          if (a.bytes != b.bytes) return a.bytes.compareTo(b.bytes);
          if (a.executionMs != b.executionMs) return a.executionMs.compareTo(b.executionMs);
          return b.accuracy.compareTo(a.accuracy);
        });
      case 1: // Speedrun (who completed first, then fastest)
        return entries..sort((a, b) {
          final aTime = a.completedAt ?? DateTime(2099);
          final bTime = b.completedAt ?? DateTime(2099);
          if (aTime != bTime) return aTime.compareTo(bTime);
          if (a.executionMs != b.executionMs) return a.executionMs.compareTo(b.executionMs);
          return b.accuracy.compareTo(a.accuracy);
        });
      case 2: // Accuracy
        return entries..sort((a, b) {
          if (a.accuracy != b.accuracy) return b.accuracy.compareTo(a.accuracy);
          if (a.bytes != b.bytes) return a.bytes.compareTo(b.bytes);
          return a.executionMs.compareTo(b.executionMs);
        });
      default:
        return entries;
    }
  }

  /// The board is public: every player who opens Ngoding Lok sees the live
  /// global standings, signed in or not. Firestore rules allow the read; only
  /// the winning source stays locked per-module. The try/catch keeps the
  /// screen alive when Firebase is unavailable (tests, offline demo).
  Stream<List<CodeGolfEntry>> _entriesStream() {
    try {
      return widget.repository.streamCodeGolfEntries(
        track: _track,
        friendIds: [
          ...widget.user.friendIds,
          if (widget.uid != null) widget.uid!,
        ],
      );
    } catch (_) {
      return Stream.value(const <CodeGolfEntry>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    final entriesStream = _entriesStream();

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1800),
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
                        options: const ['Bytes', 'Speedrun', 'Accuracy'],
                        selected: _boardMode,
                        skin: skin,
                        onSelected: (i) => setState(() {
                          _boardMode = i;
                          _expandedKey = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SegTabs(
                        options: [for (final t in _golfTracks) t.shortLabel],
                        selected: _golfTracks.indexOf(_track),
                        skin: skin,
                        onSelected: (i) => setState(() {
                          _track = _golfTracks[i];
                          _expandedKey = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: StreamBuilder<List<CodeGolfEntry>>(
                        stream: entriesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            _lastSnapshotAt = DateTime.now();
                          }
                          final allEntries =
                              snapshot.data ?? const <CodeGolfEntry>[];
                          final filtered = allEntries
                              .where((e) => !_friendsOnly || e.isFriend)
                              .toList();

                          final entries = _sortEntries(filtered);

                          final emptyMessage = _friendsOnly
                              ? 'No friends have posted a score for this track yet.'
                              : 'No Code Golf entries for this track yet.';

                          if (snapshot.hasError) {
                            return _CodeGolfErrorPanel(
                              message:
                                  'Live standings are unavailable right now.',
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  6,
                                  20,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _boardMode == 0 ? '// RANKED BY FEWEST BYTES'
                                          : _boardMode == 1 ? '// RANKED BY COMPLETION TIME'
                                          : '// RANKED BY HIGHEST ACCURACY',
                                        style: LandingTokens.label(
                                          fontSize: 9.5,
                                          color: skin.faint,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${entries.length} ACTIVE',
                                      style: LandingTokens.label(
                                        fontSize: 9,
                                        color: LandingTokens.circuit,
                                      ),
                                    ),
                                    if (_lastSnapshotAt != null) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        'LIVE',
                                        style: LandingTokens.label(
                                          fontSize: 9,
                                          color: LandingTokens.signal,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Expanded(
                                child:
                                    snapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !snapshot.hasData
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : entries.isEmpty
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
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          4,
                                          16,
                                          24,
                                        ),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final rows = [
                                              for (
                                                var i = 0;
                                                i < entries.length;
                                                i++
                                              )
                                                _rowFor(entries[i], i, skin),
                                            ];
                                            // Wide: two columns of ranked cards fill the
                                            // width; reading order keeps the ranking.
                                            if (constraints.maxWidth <= 900) {
                                              return Column(children: rows);
                                            }
                                            const gap = 16.0;
                                            final tileW =
                                                (constraints.maxWidth - gap) /
                                                2;
                                            return Wrap(
                                              spacing: gap,
                                              children: [
                                                for (final r in rows)
                                                  SizedBox(
                                                    width: tileW,
                                                    child: r,
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
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label:
                        '${entry.executionMs > 0 ? entry.executionMs : '—'} ms',
                    icon: Icons.timer_outlined,
                  ),
                  _MetricChip(
                    label: '${(entry.accuracy * 100).round()}% accuracy',
                    icon: Icons.track_changes,
                  ),
                  if (entry.completedAt != null)
                    _MetricChip(
                      label: _shortDate(entry.completedAt!),
                      icon: Icons.flag_outlined,
                    ),
                ],
              ),
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

class _CodeGolfErrorPanel extends StatelessWidget {
  final String message;

  const _CodeGolfErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NoirPanel(
          skin: skin,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: LandingTokens.ember),
              const SizedBox(width: 12),
              Text(message, style: LandingTokens.body(color: skin.sub)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetricChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final skin = NoirSkin.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: skin.panelRaised,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: skin.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: LandingTokens.circuit),
          const SizedBox(width: 5),
          Text(label, style: LandingTokens.label(fontSize: 9, color: skin.sub)),
        ],
      ),
    );
  }
}

String _shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
