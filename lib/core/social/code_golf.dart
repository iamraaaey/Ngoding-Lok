import '../curriculum/language_track.dart';

/// One row on the Code Golf leaderboard: a player's shortest (fewest-byte)
/// solution to a specific level. [source] is gated by the screen — only shown
/// to players who have themselves cleared [moduleId].
class CodeGolfEntry {
  final String player;
  final String avatar;
  final int bytes;
  final String moduleId;
  final String moduleTitle;
  final String source;
  final bool isFriend;

  const CodeGolfEntry({
    required this.player,
    required this.avatar,
    required this.bytes,
    required this.moduleId,
    required this.moduleTitle,
    required this.source,
    required this.isFriend,
  });
}

/// Mock code-golf standings. Real byte-count competition would stream from the
/// backend; this stands in with a fixed, deterministic roster per track. The
/// Java entries reference unbuilt levels, so their solutions stay locked (the
/// player can never have cleared them) — useful for exercising the gate.
class CodeGolf {
  static const List<CodeGolfEntry> _python = [
    CodeGolfEntry(
      player: 'Alice_Hacker',
      avatar: '\u{1F47E}',
      bytes: 22,
      moduleId: 'm1',
      moduleTitle: 'Module 1: Sequential Steps',
      source: 'for _ in range(3):\n    move.right()\n    move.down()',
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'CamelCaseCarol',
      avatar: '\u{1F42B}',
      bytes: 26,
      moduleId: 'm1',
      moduleTitle: 'Module 1: Sequential Steps',
      source: 'move.right();move.down();move.right();move.down();move.right();move.down();',
      isFriend: true,
    ),
    CodeGolfEntry(
      player: 'BobbyDropTables',
      avatar: '\u{1F6E1}',
      bytes: 31,
      moduleId: 'm2',
      moduleTitle: 'Module 2: Intro to SQL',
      source: "SELECT password FROM users WHERE role='admin';",
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'Null_Pointer',
      avatar: '\u{1F47B}',
      bytes: 35,
      moduleId: 'm2',
      moduleTitle: 'Module 2: Intro to SQL',
      source: "SELECT * FROM users WHERE role = 'admin';",
      isFriend: true,
    ),
    CodeGolfEntry(
      player: 'Syntax_Error',
      avatar: '\u{1F525}',
      bytes: 44,
      moduleId: 'm3',
      moduleTitle: 'Module 3: Aerospace Logic',
      source: 'sys.preflight()\nengine.start()\nthrottle(100)',
      isFriend: true,
    ),
  ];

  static const List<CodeGolfEntry> _java = [
    CodeGolfEntry(
      player: 'JitEnjoyer',
      avatar: '\u{2615}',
      bytes: 58,
      moduleId: 'java1',
      moduleTitle: 'Java Level 1: Variables',
      source: '// solution hidden',
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'GarbageCollector',
      avatar: '\u{1F5D1}',
      bytes: 64,
      moduleId: 'java2',
      moduleTitle: 'Java Level 2: Control Flow',
      source: '// solution hidden',
      isFriend: true,
    ),
  ];

  /// Entries for a track, ranked strictly by ascending byte count (shortest
  /// solution wins). Ties broken by player name for determinism.
  static List<CodeGolfEntry> forTrack(LanguageTrack track) {
    final list = track == LanguageTrack.python ? _python : _java;
    return [...list]..sort((a, b) => a.bytes != b.bytes
        ? a.bytes.compareTo(b.bytes)
        : a.player.toLowerCase().compareTo(b.player.toLowerCase()));
  }
}
