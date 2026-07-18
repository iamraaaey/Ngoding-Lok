import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/user_repository.dart';

class LevelCompleteResult {
  final int finalScore;
  const LevelCompleteResult(this.finalScore);
}

/// Fake backend standing in for a real XP-sync endpoint. Simulates network
/// latency and penalizes the base XP reward by lines-of-code used and
/// execution time, mirroring the prototype's `ApiService.syncLevelComplete`.
class ApiService {
  static final UserRepository _userRepository = UserRepository();

  static Future<LevelCompleteResult> syncLevelComplete({
    required int baseXp,
    required int linesUsed,
    required int executionMs,
    String? moduleId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final penalty = (linesUsed * 5 + executionMs * 0.02).floor();
    final score = (baseXp - penalty) < 10 ? 10 : (baseXp - penalty);

    // Sync module completion to Firestore if user is authenticated
    if (moduleId != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userRepository
            .addCompletedModule(currentUser.uid, moduleId, score)
            .catchError(
          (e) => print('Failed to sync module completion: $e'),
        );
      }
    }

    return LevelCompleteResult(score);
  }
}
