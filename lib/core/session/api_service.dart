class LevelCompleteResult {
  final int finalScore;
  const LevelCompleteResult(this.finalScore);
}

/// Fake backend standing in for a real XP-sync endpoint. Simulates network
/// latency and penalizes the base XP reward by lines-of-code used and
/// execution time, mirroring the prototype's `ApiService.syncLevelComplete`.
class ApiService {
  static Future<LevelCompleteResult> syncLevelComplete({
    required int baseXp,
    required int linesUsed,
    required int executionMs,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final penalty = (linesUsed * 5 + executionMs * 0.02).floor();
    final score = (baseXp - penalty) < 10 ? 10 : (baseXp - penalty);
    return LevelCompleteResult(score);
  }
}
