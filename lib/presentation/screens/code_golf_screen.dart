import 'package:flutter/material.dart';
import '../../core/curriculum/language_track.dart';
import '../../core/session/user_session.dart';
import '../../core/social/code_golf.dart';
import '../theme/doodle.dart';

/// Screen 9 — Code Golf Leaderboards. Players are ranked strictly by byte
/// count (shortest solution wins). A Global/Friends scope filter and a
/// per-language tab narrow the board. Tapping a row expands it to reveal the
/// exact winning source — but only if the current player has themselves
/// cleared that level, otherwise the solution stays locked.
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

  Widget _rowFor(CodeGolfEntry e, int i) {
    final key = '${e.player}-${e.moduleId}';
    return _GolfRow(
      rank: i + 1,
      entry: e,
      unlocked: widget.user.completedModuleIds.contains(e.moduleId),
      expanded: _expandedKey == key,
      onToggle: () => setState(() => _expandedKey = _expandedKey == key ? null : key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final onBg = dark ? Colors.white : Colors.black;

    final entries = CodeGolf.forTrack(_track).where((e) => !_friendsOnly || e.isFriend).toList();

    return Scaffold(
      backgroundColor: dark ? DoodlePalette.dark : DoodlePalette.cream,
      body: DoodleDotBackground(
        backgroundColor: dark ? DoodlePalette.dark : DoodlePalette.cream,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _Header(title: 'Code Golf', onBack: widget.onBack),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SegTabs(
                      options: const ['Global', 'Friends'],
                      selected: _friendsOnly ? 1 : 0,
                      onSelected: (i) => setState(() => _friendsOnly = i == 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SegTabs(
                      options: [for (final t in LanguageTrack.values) t.label.replaceAll(' Track', '')],
                      selected: _track.index,
                      onSelected: (i) => setState(() {
                        _track = LanguageTrack.values[i];
                        _expandedKey = null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                    child: Text('Ranked by fewest bytes',
                        style: TextStyle(color: onBg.withValues(alpha: 0.6), fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text('No friends on this board yet.',
                                style: TextStyle(color: onBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final rows = [for (var i = 0; i < entries.length; i++) _rowFor(entries[i], i)];
                                // Wide: two columns of ranked cards fill the
                                // width; reading order (left→right, top→bottom)
                                // keeps the ranking intact.
                                if (constraints.maxWidth <= 900) {
                                  return Column(children: rows);
                                }
                                const gap = 16.0;
                                final tileW = (constraints.maxWidth - gap) / 2;
                                return Wrap(
                                  spacing: gap,
                                  children: [for (final r in rows) SizedBox(width: tileW, child: r)],
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

/// Shared back-arrow + title header used by the social/profile/settings screens.
class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

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
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

/// Simple segmented control: a bordered pill row with one active segment.
class _SegTabs extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  const _SegTabs({required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DoodlePalette.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected ? DoodlePalette.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: i == selected ? Border.all(color: Colors.black, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: i == selected ? FontWeight.w800 : FontWeight.w700,
                      fontSize: 13,
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
  final bool unlocked;
  final bool expanded;
  final VoidCallback onToggle;

  const _GolfRow({
    required this.rank,
    required this.entry,
    required this.unlocked,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DoodleCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text('#$rank',
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                  Text(entry.avatar, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(entry.player,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
                            ),
                            if (entry.isFriend) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.people, size: 13, color: DoodlePalette.blue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(entry.moduleTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${entry.bytes} B',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: Colors.black54),
                    ],
                  ),
                ],
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
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, size: 18, color: Colors.black54),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Beat this level yourself to view the winning solution.',
                            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
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
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          source,
          style: const TextStyle(color: Color(0xFFE6EDF3), fontFamily: 'monospace', fontSize: 13, height: 1.4),
        ),
      ),
    );
  }
}
