/// League tiers in ascending order, each tagged with the inclusive XP floor a
/// player crosses to enter it. Tier is derived purely from XP (see
/// [Progression]) so it can never drift out of sync with a player's real
/// score — the same stateless approach [Leaderboard] uses for rankings.
enum LeagueTier {
  wood('Wood', 0),
  bronze('Bronze', 500),
  silver('Silver', 1500),
  gold('Gold', 3000),
  platinum('Platinum', 5000);

  final String label;
  final int floor;
  const LeagueTier(this.label, this.floor);
}

/// Read-only view over a player's XP that exposes every XP-derived value the
/// UI needs — displayed level, current league tier, and progress toward the
/// next tier — in one place, so screens never recompute these ad hoc. Holds
/// no colors/icons: presentation styling for a tier lives in the presentation
/// layer (see league_style.dart) to keep this logic Flutter-free.
class Progression {
  final int xp;
  const Progression(this.xp);

  /// XP required to advance one displayed level.
  static const int xpPerLevel = 250;

  /// 1-based vanity level shown in the top app bar.
  int get level => 1 + xp ~/ xpPerLevel;

  /// The highest tier whose [LeagueTier.floor] the player has reached.
  LeagueTier get tier {
    var current = LeagueTier.values.first;
    for (final t in LeagueTier.values) {
      if (xp >= t.floor) current = t;
    }
    return current;
  }

  /// The next tier up, or null once the player is at the maximum tier.
  LeagueTier? get nextTier {
    final next = tier.index + 1;
    return next < LeagueTier.values.length ? LeagueTier.values[next] : null;
  }

  /// Progress (0..1) from the current tier's floor toward the next tier's
  /// floor. Returns 1.0 once the player is at the maximum tier.
  double get tierProgress {
    final next = nextTier;
    if (next == null) return 1;
    final span = next.floor - tier.floor;
    if (span <= 0) return 1;
    return ((xp - tier.floor) / span).clamp(0.0, 1.0);
  }

  /// XP still needed to reach [nextTier], or null at the maximum tier.
  int? get xpToNextTier {
    final next = nextTier;
    return next == null ? null : next.floor - xp;
  }
}
