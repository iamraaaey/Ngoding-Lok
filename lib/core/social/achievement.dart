import '../curriculum/curriculum.dart';
import '../curriculum/module_type.dart';
import '../session/user_session.dart';

/// A single achievement badge and whether the player has earned it. Unlock
/// state is derived from the live [UserSession] (see [Achievements.forUser])
/// so badges can never disagree with the player's actual progress. Icons/
/// colors are mapped in the presentation layer, keyed by [id], to keep this
/// domain model free of Flutter dependencies.
class Achievement {
  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
    this.progress = 0,
    this.target = 1,
  });

  double get progressRatio =>
      target <= 0 ? 1 : (progress / target).clamp(0.0, 1.0);
}

class Achievements {
  /// Builds the full badge set for [user], each tagged unlocked/locked from
  /// their completed modules, streak, XP, and best efficiency scores.
  static List<Achievement> forUser(UserSession user) {
    final done = user.completedModuleIds;
    final totalModules = Curriculum.sortedModules.length;
    final completedCount = done.length;

    final anyGridQuestCleared = Curriculum.modules.any(
      (m) => m.type == ModuleType.logicGrid && done.contains(m.id),
    );
    final anySqlQuestCleared = Curriculum.modules.any(
      (m) => m.type == ModuleType.sqlTerminal && done.contains(m.id),
    );
    final anyRocketQuestCleared = Curriculum.modules.any(
      (m) => m.type == ModuleType.rocketFlight && done.contains(m.id),
    );
    final fullyClearedTrack = Curriculum.sortedModules.any((module) {
      final trackModules = Curriculum.modulesForTrack(module.track);
      if (trackModules.isEmpty) return false;
      return trackModules.every((m) => done.contains(m.id));
    });
    final anyCyberQuestCleared = Curriculum.modules.any(
      (m) =>
          m.track.label.toLowerCase().contains('cyber') && done.contains(m.id),
    );
    final anyJavaQuestCleared = Curriculum.modules.any(
      (m) => m.track.label.toLowerCase() == 'java' && done.contains(m.id),
    );

    final codeTrackModules = Curriculum.modules.where((m) =>
        m.type == ModuleType.logicGrid ||
        m.type == ModuleType.sqlTerminal ||
        m.type == ModuleType.rocketFlight);
    final completedCodeModules = codeTrackModules
        .where((m) => done.contains(m.id))
        .toList();
    final hasCodeGolfRun = completedCodeModules.isNotEmpty;
    final codeGolfModulesCount = completedCodeModules.length;

    final halfwayTarget = (totalModules / 2).ceil();
    final firstQuestCleared = done.contains('m1');
    final graduationCleared = done.contains('m13');

    return [
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Clear your very first level.',
        unlocked: done.isNotEmpty,
        progress: completedCount,
      ),
      Achievement(
        id: 'sequential_steps',
        title: 'Sequential Steps',
        description: 'Clear Module 1: Sequential Steps.',
        unlocked: firstQuestCleared,
        progress: firstQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'grid_master',
        title: 'Grid Master',
        description: 'Navigate the Sequential Steps grid.',
        unlocked: anyGridQuestCleared,
        progress: anyGridQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'sql_sleuth',
        title: 'SQL Sleuth',
        description: 'Crack the database query level.',
        unlocked: anySqlQuestCleared,
        progress: anySqlQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'rocket_scientist',
        title: 'Rocket Scientist',
        description: 'Reach escape velocity.',
        unlocked: anyRocketQuestCleared,
        progress: anyRocketQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'cyber_defender',
        title: 'Cyber Defender',
        description: 'Complete a cybersecurity room.',
        unlocked: anyCyberQuestCleared,
        progress: anyCyberQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'java_starter',
        title: 'Java Starter',
        description: 'Complete a Java track quest.',
        unlocked: anyJavaQuestCleared,
        progress: anyJavaQuestCleared ? 1 : 0,
      ),
      Achievement(
        id: 'module_runner',
        title: 'Module Runner',
        description: 'Clear three curriculum modules.',
        unlocked: completedCount >= 3,
        progress: completedCount,
        target: 3,
      ),
      Achievement(
        id: 'halfway_there',
        title: 'Halfway There',
        description: 'Clear half of the full curriculum.',
        unlocked: completedCount >= halfwayTarget,
        progress: completedCount,
        target: halfwayTarget,
      ),
      Achievement(
        id: 'curriculum_complete',
        title: 'Curriculum Complete',
        description: 'Clear every module in the curriculum.',
        unlocked: completedCount >= totalModules,
        progress: completedCount,
        target: totalModules,
      ),
      Achievement(
        id: 'graduation_flight',
        title: 'Graduation Flight',
        description: 'Complete Module 13: Escape Velocity.',
        unlocked: graduationCleared,
        progress: graduationCleared ? 1 : 0,
      ),
      Achievement(
        id: 'persistence',
        title: 'The Persistence Badge',
        description: 'Hold a 3-day coding streak.',
        unlocked: user.streak >= 3,
        progress: user.streak,
        target: 3,
      ),
      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Hold a 7-day coding streak.',
        unlocked: user.bestStreak >= 7,
        progress: user.bestStreak,
        target: 7,
      ),
      Achievement(
        id: 'streak_legend',
        title: 'Streak Legend',
        description: 'Hold a 14-day coding streak.',
        unlocked: user.bestStreak >= 14,
        progress: user.bestStreak,
        target: 14,
      ),
      Achievement(
        id: 'polyglot',
        title: 'The Polyglot Badge',
        description: 'Clear every level in a track.',
        unlocked: fullyClearedTrack,
        progress: fullyClearedTrack ? 1 : 0,
      ),
      Achievement(
        id: 'high_roller',
        title: 'High Roller',
        description: 'Bank 500 XP.',
        unlocked: user.xp >= 500,
        progress: user.xp,
        target: 500,
      ),
      Achievement(
        id: 'efficiency_expert',
        title: 'Efficiency Expert',
        description: 'Score 90%+ efficiency on a level.',
        unlocked: _hasEfficientClear(user),
        progress: _hasEfficientClear(user) ? 1 : 0,
      ),
      Achievement(
        id: 'speedrunner',
        title: 'Speedrunner',
        description: 'Clear a quest in under 60 seconds.',
        unlocked: user.modulePerformance.values.any(
          (performance) =>
              performance.executionMs > 0 && performance.executionMs <= 60000,
        ),
        progress:
            user.modulePerformance.values.any(
              (performance) =>
                  performance.executionMs > 0 &&
                  performance.executionMs <= 60000,
            )
            ? 1
            : 0,
      ),
      Achievement(
        id: 'code_golfer',
        title: 'Code Golfer',
        description: 'Submit a verified solution to the global board.',
        unlocked: hasCodeGolfRun,
        progress: codeGolfModulesCount,
        target: 1,
      ),
      Achievement(
        id: 'golf_enthusiast',
        title: 'Golf Enthusiast',
        description: 'Complete 3 code golf modules.',
        unlocked: codeGolfModulesCount >= 3,
        progress: codeGolfModulesCount,
        target: 3,
      ),
      Achievement(
        id: 'golf_master',
        title: 'Golf Master',
        description: 'Complete all code golf modules.',
        unlocked: codeGolfModulesCount == codeTrackModules.length && codeTrackModules.isNotEmpty,
        progress: codeGolfModulesCount,
        target: codeTrackModules.length,
      ),
    ];
  }

  static List<String> unlockedIds(UserSession user) => [
    for (final achievement in forUser(user))
      if (achievement.unlocked) achievement.id,
  ];

  static bool _hasEfficientClear(UserSession user) {
    for (final module in Curriculum.modules) {
      final score = user.moduleScores[module.id];
      if (score != null && score >= module.xpReward * 0.9) return true;
    }
    return false;
  }
}
