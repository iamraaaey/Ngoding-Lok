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
/// backend; this stands in with a fixed, deterministic roster per learning
/// track. Every entry references a current module in the same track.
class CodeGolf {
  static const List<CodeGolfEntry> _python = [
    CodeGolfEntry(
      player: 'Alice_Hacker',
      avatar: '\u{1F47E}',
      bytes: 74,
      moduleId: 'm1',
      moduleTitle: 'Module 1: Sequential Steps',
      source:
          'move.right()\nmove.right()\nmove.right()\nmove.down()\nmove.down()\nmove.down()',
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'CamelCaseCarol',
      avatar: '\u{1F42B}',
      bytes: 75,
      moduleId: 'm1',
      moduleTitle: 'Module 1: Sequential Steps',
      source:
          'move.right();move.down();move.right();move.down();move.right();move.down();',
      isFriend: true,
    ),
    CodeGolfEntry(
      player: 'Syntax_Error',
      avatar: '\u{1F525}',
      bytes: 45,
      moduleId: 'm3',
      moduleTitle: 'Module 3: Aerospace Logic',
      source: 'sys.preflight();engine.start();throttle(500);',
      isFriend: true,
    ),
  ];

  static const List<CodeGolfEntry> _sql = [
    CodeGolfEntry(
      player: 'BobbyDropTables',
      avatar: '\u{1F6E1}',
      bytes: 46,
      moduleId: 'm2',
      moduleTitle: 'Module 2: Intro to SQL',
      source: "SELECT password FROM users WHERE role='admin';",
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'Null_Pointer',
      avatar: '\u{1F47B}',
      bytes: 41,
      moduleId: 'm2',
      moduleTitle: 'Module 2: Intro to SQL',
      source: "SELECT * FROM users WHERE role = 'admin';",
      isFriend: true,
    ),
    CodeGolfEntry(
      player: 'QueryNinja',
      avatar: '\u{1F9E0}',
      bytes: 42,
      moduleId: 'j2',
      moduleTitle: 'SQL Level 5: Filtering with WHERE',
      source: "SELECT name FROM students WHERE grade='A';",
      isFriend: true,
    ),
  ];

  static const List<CodeGolfEntry> _java = [
    CodeGolfEntry(
      player: 'JitEnjoyer',
      avatar: '\u{2615}',
      bytes: 74,
      moduleId: 'j1',
      moduleTitle: 'Java Level 1: Variables & Method Calls',
      source:
          'move.right()\nmove.right()\nmove.right()\nmove.down()\nmove.down()\nmove.down()',
      isFriend: false,
    ),
    CodeGolfEntry(
      player: 'GarbageCollector',
      avatar: '\u{1F5D1}',
      bytes: 45,
      moduleId: 'j3',
      moduleTitle: 'Java Level 3: Space Object Control',
      source: 'sys.preflight();engine.start();throttle(750);',
      isFriend: true,
    ),
  ];

  /// Entries for a track, ranked strictly by ascending byte count (shortest
  /// solution wins). Ties broken by player name for determinism.
  static List<CodeGolfEntry> forTrack(LanguageTrack track) {
    final List<CodeGolfEntry> list = switch (track) {
      LanguageTrack.python => _python,
      LanguageTrack.sql => _sql,
      LanguageTrack.java => _java,
      LanguageTrack.cybersecurity => const <CodeGolfEntry>[],
      LanguageTrack.arduino => const <CodeGolfEntry>[],
    };
    return [...list]..sort(
      (a, b) => a.bytes != b.bytes
          ? a.bytes.compareTo(b.bytes)
          : a.player.toLowerCase().compareTo(b.player.toLowerCase()),
    );
  }
}
