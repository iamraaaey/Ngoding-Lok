/// The measurable result of a module completion.
///
/// Keeping this beside the session makes progress cards, achievements and
/// Code Golf use the same source of truth instead of each deriving a slightly
/// different result.
class ModulePerformance {
  final int score;
  final int linesUsed;
  final int executionMs;
  final double accuracy;
  final int attempts;
  final DateTime? firstCompletedAt;
  final DateTime? lastCompletedAt;

  const ModulePerformance({
    required this.score,
    required this.linesUsed,
    required this.executionMs,
    required this.accuracy,
    this.attempts = 1,
    this.firstCompletedAt,
    this.lastCompletedAt,
  });

  Map<String, dynamic> toMap() => {
    'score': score,
    'linesUsed': linesUsed,
    'executionMs': executionMs,
    'accuracy': accuracy,
    'attempts': attempts,
    'firstCompletedAt': firstCompletedAt?.toIso8601String(),
    'lastCompletedAt': lastCompletedAt?.toIso8601String(),
  };

  factory ModulePerformance.fromMap(Object? raw) {
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};
    return ModulePerformance(
      score: _intValue(data['score']),
      linesUsed: _intValue(data['linesUsed']),
      executionMs: _intValue(data['executionMs']),
      accuracy: _doubleValue(data['accuracy']),
      attempts: _intValue(data['attempts'], fallback: 1),
      firstCompletedAt: _dateValue(data['firstCompletedAt']),
      lastCompletedAt: _dateValue(data['lastCompletedAt']),
    );
  }

  ModulePerformance copyWith({
    int? score,
    int? linesUsed,
    int? executionMs,
    double? accuracy,
    int? attempts,
    DateTime? firstCompletedAt,
    DateTime? lastCompletedAt,
  }) => ModulePerformance(
    score: score ?? this.score,
    linesUsed: linesUsed ?? this.linesUsed,
    executionMs: executionMs ?? this.executionMs,
    accuracy: accuracy ?? this.accuracy,
    attempts: attempts ?? this.attempts,
    firstCompletedAt: firstCompletedAt ?? this.firstCompletedAt,
    lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
  );

  static int _intValue(Object? value, {int fallback = 0}) =>
      value is num ? value.toInt() : fallback;

  static double _doubleValue(Object? value) =>
      value is num ? value.toDouble() : 0;

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
