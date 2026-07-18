class LevelCompleteResult {
  final int finalScore;
  const LevelCompleteResult(this.finalScore);
}

/// Calculates the local score for a completed level. Persistence is handled by
/// the repository transaction in the app orchestrator so XP, streaks,
/// achievements and Code Golf cannot race one another.
class ApiService {
  static Future<LevelCompleteResult> syncLevelComplete({
    required int baseXp,
    required int linesUsed,
    required int executionMs,
    String? moduleId,
  }) async {
    final penalty = (linesUsed * 5 + executionMs * 0.02).floor();
    final score = (baseXp - penalty) < 10 ? 10 : (baseXp - penalty);

    return LevelCompleteResult(score);
  }
}
