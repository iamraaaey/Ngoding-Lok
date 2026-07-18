import '../cybersecurity/cyber_room.dart';
import 'module_performance.dart';

/// Immutable snapshot of the logged-in student: their identity, XP total,
/// and which curriculum modules they've cleared.
class UserSession {
  final String email;

  /// Full display name from the Google profile, when signed in via OAuth.
  /// Null for the simulated email login.
  final String? name;

  /// Google profile picture URL, when available.
  final String? photoUrl;

  final int xp;
  final List<String> completedModuleIds;

  /// Consecutive-day play streak, updated from [lastActivityDate].
  final int streak;

  /// Highest streak reached by this account.
  final int bestStreak;

  /// Local calendar day on which the account last opened the learning loop.
  /// It is stored as `yyyy-MM-dd` so all clients compare calendar days rather
  /// than milliseconds and time zones.
  final String? lastActivityDate;

  /// Best "efficiency score" achieved per module id. The League Map reads
  /// this to show how well each cleared level was solved (stars + points).
  final Map<String, int> moduleScores;

  /// Detailed, durable performance for each cleared module.
  final Map<String, ModulePerformance> modulePerformance;

  /// Number of "Streak Freeze" tokens the player owns, bought with XP on the
  /// Profile screen. A freeze would spare a missed day from breaking a streak.
  final int streakFreezes;
  final Map<String, CyberRoomProgress> cyberRoomProgress;
  final List<String> badges;

  /// Achievement IDs already acknowledged by the account. Achievement state
  /// is also derived from progress, so a stale cache can never hide a badge.
  final List<String> achievementIds;

  /// Stable invite code used to connect this account with another coder.
  final String? referralCode;

  /// UID of the account that referred this user, when the one-time referral
  /// reward has been claimed.
  final String? referredBy;

  /// Server-backed guard that prevents a referral reward from being claimed
  /// more than once for this account.
  final bool referralRewardClaimed;

  /// Firebase UIDs of accepted friends.
  final List<String> friendIds;

  const UserSession({
    required this.email,
    this.name,
    this.photoUrl,
    this.xp = 0,
    this.completedModuleIds = const [],
    this.streak = 1,
    this.bestStreak = 1,
    this.lastActivityDate,
    this.moduleScores = const {},
    this.modulePerformance = const {},
    this.streakFreezes = 0,
    this.cyberRoomProgress = const {},
    this.badges = const [],
    this.achievementIds = const [],
    this.referralCode,
    this.referredBy,
    this.referralRewardClaimed = false,
    this.friendIds = const [],
  });

  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return email.split('@').first;
  }

  UserSession copyWith({
    int? xp,
    List<String>? completedModuleIds,
    int? streak,
    int? bestStreak,
    String? lastActivityDate,
    Map<String, int>? moduleScores,
    Map<String, ModulePerformance>? modulePerformance,
    int? streakFreezes,
    Map<String, CyberRoomProgress>? cyberRoomProgress,
    List<String>? badges,
    List<String>? achievementIds,
    String? referralCode,
    String? referredBy,
    bool? referralRewardClaimed,
    List<String>? friendIds,
  }) {
    return UserSession(
      email: email,
      name: name,
      photoUrl: photoUrl,
      xp: xp ?? this.xp,
      completedModuleIds: completedModuleIds ?? this.completedModuleIds,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      moduleScores: moduleScores ?? this.moduleScores,
      modulePerformance: modulePerformance ?? this.modulePerformance,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      cyberRoomProgress: cyberRoomProgress ?? this.cyberRoomProgress,
      badges: badges ?? this.badges,
      achievementIds: achievementIds ?? this.achievementIds,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      referralRewardClaimed:
          referralRewardClaimed ?? this.referralRewardClaimed,
      friendIds: friendIds ?? this.friendIds,
    );
  }

  UserSession withCyberRoomProgress(
    String moduleId,
    CyberRoomProgress progress,
  ) => copyWith(cyberRoomProgress: {...cyberRoomProgress, moduleId: progress});

  UserSession withBadge(String badge) =>
      copyWith(badges: [...badges, if (!badges.contains(badge)) badge]);

  /// Applies one activity event using the device's local calendar day. This
  /// is used for demo sessions; signed-in sessions use the same calculation
  /// inside the repository transaction.
  UserSession withActivity({DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = _dayKey(current);
    if (lastActivityDate == today) return this;

    final previous = _parseDay(lastActivityDate);
    final yesterday = DateTime(
      current.year,
      current.month,
      current.day,
    ).subtract(const Duration(days: 1));
    final nextStreak = previous != null && _sameDay(previous, yesterday)
        ? streak + 1
        : 1;
    return copyWith(
      streak: nextStreak,
      bestStreak: nextStreak > bestStreak ? nextStreak : bestStreak,
      lastActivityDate: today,
    );
  }

  UserSession withModuleCompleted(String moduleId, int score) {
    final best = moduleScores[moduleId];
    return copyWith(
      xp: xp + score,
      completedModuleIds: [
        ...completedModuleIds,
        if (!completedModuleIds.contains(moduleId)) moduleId,
      ],
      moduleScores: {
        ...moduleScores,
        moduleId: (best == null || score > best) ? score : best,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'xp': xp,
      'completedModuleIds': completedModuleIds,
      'streak': streak,
      'bestStreak': bestStreak,
      'lastActivityDate': lastActivityDate,
      'moduleScores': moduleScores,
      'modulePerformance': modulePerformance.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'streakFreezes': streakFreezes,
      'cyberRoomProgress': cyberRoomProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'badges': badges,
      'achievementIds': achievementIds,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralRewardClaimed': referralRewardClaimed,
      'friendIds': friendIds,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      xp: _intValue(json['xp']),
      completedModuleIds:
          (json['completedModuleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: _intValue(json['streak'], fallback: 1),
      bestStreak: _intValue(json['bestStreak'], fallback: 1),
      lastActivityDate: json['lastActivityDate'] as String?,
      moduleScores:
          (json['moduleScores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, _intValue(v)),
          ) ??
          const {},
      modulePerformance:
          (json['modulePerformance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ModulePerformance.fromMap(value)),
          ) ??
          const {},
      streakFreezes: json['streakFreezes'] as int? ?? 0,
      cyberRoomProgress:
          (json['cyberRoomProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              CyberRoomProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          const {},
      badges: (json['badges'] as List<dynamic>?)?.cast<String>() ?? const [],
      achievementIds:
          (json['achievementIds'] as List<dynamic>?)?.cast<String>() ??
          const [],
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      referralRewardClaimed: json['referralRewardClaimed'] as bool? ?? false,
      friendIds:
          (json['friendIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  static int _intValue(Object? value, {int fallback = 0}) =>
      value is num ? value.toInt() : fallback;

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDay(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
