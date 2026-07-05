import '../curriculum/curriculum.dart';
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

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

class Achievements {
  /// Builds the full badge set for [user], each tagged unlocked/locked from
  /// their completed modules, streak, XP, and best efficiency scores.
  static List<Achievement> forUser(UserSession user) {
    final done = user.completedModuleIds;
    final allCleared = Curriculum.modules.every((m) => done.contains(m.id));

    return [
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Clear your very first level.',
        unlocked: done.isNotEmpty,
      ),
      Achievement(
        id: 'grid_master',
        title: 'Grid Master',
        description: 'Navigate the Sequential Steps grid.',
        unlocked: done.contains('m1'),
      ),
      Achievement(
        id: 'sql_sleuth',
        title: 'SQL Sleuth',
        description: 'Crack the database query level.',
        unlocked: done.contains('m2'),
      ),
      Achievement(
        id: 'rocket_scientist',
        title: 'Rocket Scientist',
        description: 'Reach escape velocity.',
        unlocked: done.contains('m3'),
      ),
      Achievement(
        id: 'persistence',
        title: 'The Persistence Badge',
        description: 'Hold a 3-day coding streak.',
        unlocked: user.streak >= 3,
      ),
      Achievement(
        id: 'polyglot',
        title: 'The Polyglot Badge',
        description: 'Clear every level in a track.',
        unlocked: allCleared,
      ),
      Achievement(
        id: 'high_roller',
        title: 'High Roller',
        description: 'Bank 500 XP.',
        unlocked: user.xp >= 500,
      ),
      Achievement(
        id: 'efficiency_expert',
        title: 'Efficiency Expert',
        description: 'Score 90%+ efficiency on a level.',
        unlocked: _hasEfficientClear(user),
      ),
    ];
  }

  static bool _hasEfficientClear(UserSession user) {
    for (final module in Curriculum.modules) {
      final score = user.moduleScores[module.id];
      if (score != null && score >= module.xpReward * 0.9) return true;
    }
    return false;
  }
}
