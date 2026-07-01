import 'leaderboard_entry.dart';
import 'user_session.dart';

/// Ranking is recomputed from [UserSession] on every call rather than kept
/// as separate mutable state, so there's no risk of the leaderboard
/// drifting out of sync with the user's actual XP.
class Leaderboard {
  static const List<LeaderboardEntry> _mockOthers = [
    LeaderboardEntry(rank: 0, name: 'Alice_Hacker', xp: 4500, avatar: '\u{1F47E}'),
    LeaderboardEntry(rank: 0, name: 'BobbyDropTables', xp: 3850, avatar: '\u{1F6E1}'),
    LeaderboardEntry(rank: 0, name: 'Syntax_Error', xp: 3100, avatar: '\u{1F525}'),
    LeaderboardEntry(rank: 0, name: 'Null_Pointer', xp: 1200, avatar: '\u{1F47B}'),
  ];

  /// Pure function: upserts [user] into the mock roster under their display
  /// name and returns a freshly re-ranked list (desc XP, ties broken by
  /// name ascending for determinism).
  static List<LeaderboardEntry> withUser(UserSession user) {
    final all = [
      ..._mockOthers,
      LeaderboardEntry(
        rank: 0,
        name: user.displayName,
        xp: user.xp,
        avatar: '\u{1F464}',
      ),
    ]..sort((a, b) => b.xp != a.xp
        ? b.xp.compareTo(a.xp)
        : a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return [
      for (var i = 0; i < all.length; i++)
        LeaderboardEntry(rank: i + 1, name: all[i].name, xp: all[i].xp, avatar: all[i].avatar),
    ];
  }
}
