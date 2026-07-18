import '../curriculum/language_track.dart';

/// One row on the Code Golf leaderboard: a player's shortest (fewest-byte)
/// solution to a specific level. [source] is gated by the screen — only shown
/// to players who have themselves cleared [moduleId].
class CodeGolfEntry {
  final String uid;
  final String player;
  final String avatar;
  final int bytes;
  final LanguageTrack track;
  final String moduleId;
  final String moduleTitle;
  final String source;
  final bool isFriend;
  final int executionMs;
  final double accuracy;
  final int completionScore;
  final DateTime? completedAt;

  const CodeGolfEntry({
    required this.uid,
    required this.player,
    required this.avatar,
    required this.bytes,
    required this.track,
    required this.moduleId,
    required this.moduleTitle,
    required this.source,
    required this.isFriend,
    required this.executionMs,
    required this.accuracy,
    required this.completionScore,
    required this.completedAt,
  });
  factory CodeGolfEntry.fromMap(
    String documentId,
    Map<String, dynamic> data, {
    required Set<String> friendIds,
  }) {
    final uid = data['uid'] as String? ?? documentId;
    final track = codeGolfTrackFromKey(data['track'] as String?);
    final completedAt = _dateValue(data['completedAt']);
    return CodeGolfEntry(
      uid: uid,
      player: data['playerName'] as String? ?? 'anonymous',
      avatar: data['avatar'] as String? ?? '\u{1F464}',
      bytes: (data['bytes'] as num?)?.toInt() ?? 0,
      track: track,
      moduleId: data['moduleId'] as String? ?? '',
      moduleTitle: data['moduleTitle'] as String? ?? 'Untitled module',
      source: data['source'] as String? ?? '',
      isFriend: friendIds.contains(uid),
      executionMs: (data['executionMs'] as num?)?.toInt() ?? 0,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0,
      completionScore: (data['completionScore'] as num?)?.toInt() ?? 0,
      completedAt: completedAt,
    );
  }

  static DateTime? _dateValue(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      final converted = (value as dynamic).toDate();
      return converted is DateTime ? converted : null;
    } catch (_) {
      return null;
    }
  }
}

String codeGolfTrackKey(LanguageTrack track) => switch (track) {
  LanguageTrack.python => 'python',
  LanguageTrack.sql => 'sql',
  LanguageTrack.java => 'java',
  LanguageTrack.cybersecurity => 'cybersecurity',
  LanguageTrack.arduino => 'arduino',
};

LanguageTrack codeGolfTrackFromKey(String? key) => switch (key) {
  'python' => LanguageTrack.python,
  'sql' => LanguageTrack.sql,
  'java' => LanguageTrack.java,
  'cybersecurity' => LanguageTrack.cybersecurity,
  'arduino' => LanguageTrack.arduino,
  _ => LanguageTrack.python,
};
